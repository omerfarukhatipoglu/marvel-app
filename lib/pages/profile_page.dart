// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:marvel/consts/layout_helper.dart';
import 'package:marvel/controllers/profile_controller.dart';
import 'package:marvel/services/favourite_service.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = LayoutHelper(context).screenHeight;
    final screenWidth = LayoutHelper(context).screenWidth;
    final parts = controller.splitName(controller.character.name);
    final mainName = parts[0];
    final qualifier = parts[1];
    return Scaffold(
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: screenHeight),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/space_wallpaper.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.05,
              left: screenWidth * 0.015,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () {
                            Get.back(result: true);
                          },

                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Obx(
                        () => Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.05),
                          child: GestureDetector(
                            onTap: () async {
                              if (!controller.character.isFavorite.value) {
                                controller.character.isFavorite.value = true;

                                // ✅ RESMİ BASE64’E DÖNÜŞTÜRÜYORUZ
                                final updatedCharacter =
                                    await FavoriteStorage.convertCharacterWithBase64(
                                      controller.character,
                                    );

                                await FavoriteStorage.addFavorite(
                                  updatedCharacter,
                                );
                              } else {
                                controller.character.isFavorite.value = false;
                                await FavoriteStorage.removeFavorite(
                                  controller.character.id,
                                );
                              }
                            },

                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
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
                              child: Container(
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
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
                                      controller.character.isFavorite.value
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      key: ValueKey(
                                        controller.character.isFavorite.value,
                                      ), // 🔵
                                      color: Colors.red,
                                      size: screenWidth * 0.08,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Obx(() {
                    if (controller.isFromSQLite.value) {
                      // SQLite → base64 görsel
                      return Image.memory(
                        base64Decode(controller.character.base64Image ?? ''),
                        width: screenWidth * 0.75,
                        height: screenWidth * 0.75,
                        fit: BoxFit.fill,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      );
                    } else {
                      // API → normal URL
                      return CachedNetworkImage(
                        imageUrl: controller.character.imageUrl,
                        width: screenWidth * 0.75,
                        height: screenWidth * 0.75,
                        fit: BoxFit.fill,
                      );
                    }
                  }),
                ),
                textContainer(screenWidth, screenHeight, mainName, "İsim"),

                textContainer(
                  screenWidth,
                  screenHeight,
                  qualifier,
                  "Nİteleyici",
                ),
                Obx(
                  () => textContainer(
                    screenWidth,
                    screenHeight,
                    controller.translatedText.value,
                    "Hakkında",
                  ),
                ),
                listContainer(
                  screenWidth,
                  screenHeight,
                  controller.character.seriesTitles,
                  "Seriler",
                ),
                listContainer(
                  screenWidth,
                  screenHeight,
                  controller.character.comicNames,
                  "Çizgi Romanlar",
                ),
                listContainer(
                  screenWidth,
                  screenHeight,
                  controller.character.eventNames,
                  "Etkinlikler",
                ),
                listContainer(
                  screenWidth,
                  screenHeight,
                  controller.character.storyNames,
                  "Hikayeler",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget listContainer(
  double screenWidth,
  double screenHeight,
  List<String>? items,
  String title,
) {
  if (items == null || items.isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: EdgeInsets.only(
      top: screenHeight * 0.015,
      bottom: screenHeight * 0.02,
    ),
    child: Container(
      width: screenWidth * 0.75,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: Colors.white),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Builder(
        builder: (context) {
          final scrollController = ScrollController();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                "$title:",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.18),
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: AutoSizeText(
                          "• ${items[index]}",
                          style: GoogleFonts.orbitron(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Widget textContainer(
  double screenWidth,
  double screenHeight,
  String? name,
  String title,
) {
  final isAbout = title.toLowerCase() == "hakkında";
  final verticalPad = isAbout ? screenHeight * 0.02 : screenHeight * 0.01;

  return Padding(
    padding: EdgeInsets.only(top: screenHeight * 0.015),
    child: Container(
      width: screenWidth * 0.75,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: verticalPad,
      ),
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: Colors.white),
        borderRadius: BorderRadius.circular(30),
      ),
      child: isAbout
          ? Builder(
              builder: (context) {
                final scrollController = ScrollController();
                final controller = Get.find<ProfileController>();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$title:",
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      if (controller.isTranslating.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        );
                      }

                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.12,
                        ),
                        child: Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Text(
                              controller.translatedText.value,
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: AutoSizeText(
                    "$title:",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 7,
                  child: AutoSizeText(
                    name ?? '--',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
    ),
  );
}
