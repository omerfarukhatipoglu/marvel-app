// ignore_for_file: deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:marvel/consts/layout_helper.dart';
import 'package:marvel/controllers/main_controller.dart';
import 'package:marvel/routes/routes.dart';
import 'package:marvel/services/favourite_service.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = LayoutHelper(context).screenHeight;
    final screenWidth = LayoutHelper(context).screenWidth;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/space_wallpaper.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                top: screenHeight * 0.05,
                bottom: screenHeight * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      height: screenWidth * 0.15,
                      width: screenWidth * 0.4,
                      color: Colors.white,
                      child: Image.asset(
                        "assets/marvel_logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.FAVOURITE_PAGE);
                        },
                        child: Container(
                          width: screenWidth * 0.12,
                          height: screenWidth * 0.12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite,

                              color: Colors.white,
                              size: screenWidth * 0.08,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Obx(
                        () => GestureDetector(
                          onTap: controller.toggleMode,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (c, a) =>
                                ScaleTransition(scale: a, child: c),
                            child: Image.asset(
                              controller.isListSelected.value
                                  ? "assets/icon_learn_single.png"
                                  : "assets/icon_learn_list.png",
                              key: ValueKey(controller.isListSelected.value),
                              width: screenWidth * 0.12,
                              height: screenWidth * 0.12,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      PopupMenuButton<int>(
                        icon: Image.asset(
                          "assets/icon_sort.png",
                          width: screenWidth * 0.12,
                          height: screenWidth * 0.12,
                        ),
                        onSelected: controller.setSortIndex,
                        itemBuilder: (_) =>
                            List.generate(controller.sortOptions.length, (i) {
                              final isSel =
                                  i == controller.selectedSortIndex.value;
                              return PopupMenuItem(
                                value: i,
                                child: Text(
                                  controller.sortOptions[i]['label']!,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 15,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSel
                                        ? const Color(0xFF8e79ff)
                                        : Colors.black,
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                bottom: screenHeight * 0.01,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Obx(
                  () => TextField(
                    controller: controller.searchText,
                    style: const TextStyle(color: Colors.white),
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: controller.animatedHintText.value,
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.03,
                      ),
                      suffixIcon: const Icon(Icons.search, color: Colors.white),
                    ),
                    onChanged: (value) {
                      final trimmed = value.trim();
                      if (trimmed.isEmpty) {
                        controller.onSearchChanged('');
                        return;
                      }
                      if (value.endsWith(' ')) return;
                      controller.onSearchChanged(trimmed);
                    },
                  ),
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: LoadingAnimationWidget.hexagonDots(
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                }
                if (controller.characters.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.2,
                      ),
                      child: AutoSizeText(
                        'Karakter bulunamadı.',
                        maxLines: 1,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    RefreshIndicator(
                      color: Colors.black,
                      onRefresh: () {
                        if (controller.searchText.text.isEmpty) {
                          return controller.refreshCharacters();
                        } else {
                          return controller.refreshCharacters(
                            nameStartsWith: controller.searchText.text.trim(),
                          );
                        }
                      },
                      child: controller.isListSelected.value
                          ? ListView.builder(
                              controller: controller.scrollController,
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.03,
                                right: screenWidth * 0.03,
                                bottom: screenHeight * 0.06,
                              ),
                              itemCount: controller.characters.length,
                              itemBuilder: (_, index) {
                                final ch = controller.characters[index];
                                return GestureDetector(
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.PROFILE_PAGE,
                                      arguments: ch,
                                    );
                                  },
                                  child: Card(
                                    color: Colors.white.withOpacity(0.8),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: CachedNetworkImage(
                                          imageUrl: ch.imageUrl,
                                          width: screenWidth * 0.15,
                                          height: screenWidth * 0.15,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      title: Text(
                                        ch.name.replaceAll(
                                          RegExp(r'\s*\(.*?\)'),
                                          '',
                                        ),
                                        style: GoogleFonts.orbitron(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${ch.seriesCount} seride yer aldı',
                                      ),
                                      trailing: Obx(
                                        () => GestureDetector(
                                          onTap: () async {
                                            if (!ch.isFavorite.value) {
                                              ch.isFavorite.value = true;
                                              await FavoriteStorage.addFavorite(
                                                ch.id,
                                              );
                                            } else {
                                              ch.isFavorite.value = false;
                                              await FavoriteStorage.removeFavorite(
                                                ch.id,
                                              );
                                            }
                                          },
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            switchInCurve: Curves.easeOutBack,
                                            switchOutCurve: Curves.easeInBack,
                                            transitionBuilder: (child, anim) =>
                                                RotationTransition(
                                                  turns: Tween<double>(
                                                    begin: 0.75,
                                                    end: 1,
                                                  ).animate(anim),
                                                  child: FadeTransition(
                                                    opacity: anim,
                                                    child: ScaleTransition(
                                                      scale: anim,
                                                      child: child,
                                                    ),
                                                  ),
                                                ),
                                            child: Icon(
                                              ch.isFavorite.value
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              key: ValueKey(
                                                ch.isFavorite.value,
                                              ),
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : GridView.builder(
                              controller: controller.scrollController,
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.05,
                                right: screenWidth * 0.05,
                                bottom: screenHeight * 0.06,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: screenWidth * 0.02,
                                    mainAxisSpacing: screenHeight * 0.01,
                                  ),
                              itemCount: controller.characters.length,
                              itemBuilder: (_, index) {
                                final ch = controller.characters[index];
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(
                                          Routes.PROFILE_PAGE,
                                          arguments: ch,
                                        );
                                      },
                                      child: Container(
                                        width: screenWidth * 0.5,
                                        height: screenWidth * 0.5,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(2, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                  ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      height:
                                                          screenWidth * 0.25,
                                                      width: screenWidth * 0.25,
                                                      imageUrl: ch.imageUrl,
                                                      fit: BoxFit.fill,
                                                      placeholder: (_, __) =>
                                                          Center(
                                                            child:
                                                                LoadingAnimationWidget.halfTriangleDot(
                                                                  color: Colors
                                                                      .black,
                                                                  size: 40,
                                                                ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Image.asset(
                                                            "assets/image_not_found.png",
                                                            fit: BoxFit.cover,
                                                          ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (!ch
                                                          .isFavorite
                                                          .value) {
                                                        ch.isFavorite.value =
                                                            true;
                                                        await FavoriteStorage.addFavorite(
                                                          ch.id,
                                                        );
                                                      } else {
                                                        ch.isFavorite.value =
                                                            false;
                                                        await FavoriteStorage.removeFavorite(
                                                          ch.id,
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.red,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Obx(
                                                          () => AnimatedSwitcher(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      300,
                                                                ),
                                                            switchInCurve: Curves
                                                                .easeOutBack,
                                                            switchOutCurve:
                                                                Curves
                                                                    .easeInBack,
                                                            transitionBuilder:
                                                                (
                                                                  child,
                                                                  anim,
                                                                ) => RotationTransition(
                                                                  turns: Tween<double>(
                                                                    begin: 0.75,
                                                                    end: 1,
                                                                  ).animate(anim),
                                                                  child: FadeTransition(
                                                                    opacity:
                                                                        anim,
                                                                    child: ScaleTransition(
                                                                      scale:
                                                                          anim,
                                                                      child:
                                                                          child,
                                                                    ),
                                                                  ),
                                                                ),
                                                            child: Icon(
                                                              ch.isFavorite.value
                                                                  ? Icons
                                                                        .favorite
                                                                  : Icons
                                                                        .favorite_border,
                                                              key: ValueKey(
                                                                ch
                                                                    .isFavorite
                                                                    .value,
                                                              ), // 🔵
                                                              color: Colors.red,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            AutoSizeText(
                                              ch.name.replaceAll(
                                                RegExp(r'\s*\(.*?\)'),
                                                '',
                                              ),
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.orbitron(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            AutoSizeText(
                                              '${ch.seriesCount} seride yer aldı',
                                              style: GoogleFonts.openSans(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    if (controller.isLoadingMore.value)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
