// ignore_for_file: prefer_is_empty

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marvel/modules/character.dart';
import 'package:marvel/services/favourite_service.dart';
import 'package:marvel/services/my_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  final MyApi api = MyApi();
  TextEditingController searchText = TextEditingController();
  Timer? _retryTimer;
  bool _hasActiveRetry = false;
  var hasConnectionError = false.obs;

  static const _sortKey = 'sortIndex';
  static const _viewKey = 'viewMode';

  var isListSelected = true.obs;
  var characters = <Character>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isLastPage = false.obs;

  final int pageSize = 20;
  int _offset = 0;

  final sortOptions = [
    {'label': 'A → Z', 'orderBy': 'name'},
    {'label': 'Z → A', 'orderBy': '-name'},
    {'label': 'Yeni → Eski', 'orderBy': '-modified'},
    {'label': 'Eski → Yeni', 'orderBy': 'modified'},
  ];
  var selectedSortIndex = 0.obs;
  String get currentOrderBy => sortOptions[selectedSortIndex.value]['orderBy']!;

  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    if (characters.isEmpty) {
      loadCharacters(reset: true);
    }
    startHintTyping();
  }

  @override
  void onClose() {
    searchText.dispose();
    super.onClose();
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    selectedSortIndex.value = prefs.getInt(_sortKey) ?? 0;
    isListSelected.value = prefs.getBool(_viewKey) ?? false;
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortKey, selectedSortIndex.value);
    await prefs.setBool(_viewKey, isListSelected.value);
  }

  void toggleMode() {
    isListSelected.toggle();
    _savePrefs();
  }

  void setSortIndex(int i) {
    selectedSortIndex.value = i;
    _savePrefs();
    loadCharacters(reset: true);
  }

  void _onScroll() {
    if (!isLoadingMore.value &&
        !isLastPage.value &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      loadCharacters();
    }
  }

  int _requestId = 0;

  Future<void> loadCharacters({
    String? nameStartsWith,
    bool reset = false,
  }) async {
    final currentRequestId = ++_requestId;

    if (reset) {
      _offset = 0;
      characters.clear();
      isLastPage.value = false;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final query = (nameStartsWith?.trim().isNotEmpty ?? false)
          ? nameStartsWith!.trim()
          : null;

      final favoriteIds = await FavoriteStorage.getFavoriteIds();

      final result = await api.fetchCharacters(
        nameStartsWith: query,
        limit: pageSize,
        offset: _offset,
        orderBy: currentOrderBy,
      );

      // ✅ Başarılı sonuç geldiyse retry'ı durdur
      _stopRetry();

      if (currentRequestId != _requestId) return;

      // 🧠 Bağlantı var, ama veri boşsa yine de bağlantı hatası değil
      hasConnectionError.value = false;

      if (result.length < pageSize) {
        isLastPage.value = true;
      }

      final updatedResult = result.map((ch) {
        ch.isFavorite.value = favoriteIds.contains(ch.id);
        return ch;
      }).toList();

      characters.addAll(updatedResult);
      _offset += updatedResult.length;
    } catch (e) {
      // ❌ API başarısız → bağlantı problemi var
      hasConnectionError.value = true;

      _startRetry(() {
        return loadCharacters(nameStartsWith: nameStartsWith, reset: reset);
      });
    } finally {
      if (currentRequestId == _requestId) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  void _startRetry(Future<void> Function() retryFunction) {
    if (_hasActiveRetry) return;

    _hasActiveRetry = true;
    _retryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      retryFunction();
    });
  }

  void _stopRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _hasActiveRetry = false;
  }

  Future<void> refreshCharacters({String? nameStartsWith}) {
    return loadCharacters(reset: true, nameStartsWith: nameStartsWith);
  }

  Timer? _debounce;

  String _lastQuery = '';

  void onSearchChanged(String query) {
    if (query == _lastQuery) return;
    _lastQuery = query;

    if (query.isNotEmpty && query.length < 1) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadCharacters(nameStartsWith: query, reset: true);
    });
  }

  Future<void> syncFavoritesWithStorage() async {
    final ids = await FavoriteStorage.getFavoriteIds();
    for (var ch in characters) {
      ch.isFavorite.value = ids.contains(ch.id);
    }
  }

  final animatedHintText = ''.obs;

  void startHintTyping() async {
    const fullText = 'Karakter Ara...';
    while (true) {
      for (int i = 1; i <= fullText.length; i++) {
        animatedHintText.value = fullText.substring(0, i);
        await Future.delayed(const Duration(milliseconds: 150));
      }

      await Future.delayed(const Duration(milliseconds: 1200));

      for (int i = fullText.length; i >= 0; i--) {
        animatedHintText.value = fullText.substring(0, i);
        await Future.delayed(const Duration(milliseconds: 80));
      }

      await Future.delayed(const Duration(milliseconds: 700));
    }
  }
}
