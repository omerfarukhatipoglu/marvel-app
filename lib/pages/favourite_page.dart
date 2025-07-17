// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:marvel/consts/layout_helper.dart';
import 'package:marvel/controllers/favourite_controller.dart';
import 'package:marvel/controllers/main_controller.dart';
import 'package:marvel/routes/routes.dart';

class FavouritePage extends GetView<FavouriteController> {
  const FavouritePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.reload();
    });

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
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.015,
          ),
          child: Column(
            children: [
              // ÜST BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      final mainController = Get.find<MainController>();
                      await mainController.syncFavoritesWithStorage();
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  AutoSizeText(
                    "Favorilerim",
                    style: GoogleFonts.orbitron(
                      fontSize: screenWidth * 0.07,
                      color: Colors.white,
                    ),
                  ),
                  const IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),

              // LİSTE
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

                  return RefreshIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.black,
                    onRefresh: controller.reload,
                    child: controller.characters.isEmpty
                        ? ListView(
                            physics:
                                const AlwaysScrollableScrollPhysics(), // boş olsa bile çekilebilsin
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.35,
                                  horizontal: screenWidth * 0.2,
                                ),
                                child: Center(
                                  child: AutoSizeText(
                                    'Karakter bulunamadı.',
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.aBeeZee(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              top: screenHeight * 0.01,
                              left: screenWidth * 0.03,
                              right: screenWidth * 0.03,
                              bottom: screenHeight * 0.06,
                            ),
                            itemCount: controller.characters.length,
                            itemBuilder: (_, index) {
                              final ch = controller.characters[index];
                              return GestureDetector(
                                onTap: () async {
                                  final result = await Get.toNamed(
                                    Routes.PROFILE_PAGE,
                                    arguments: ch,
                                  );

                                  if (result == true) {
                                    await controller.reload();
                                  }
                                },
                                child: Card(
                                  color: Colors.white.withOpacity(0.8),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01,
                                      horizontal: screenWidth * 0.025,
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child:
                                          ch.base64Image != null &&
                                              ch.base64Image!.isNotEmpty
                                          ? Image.memory(
                                              base64Decode(ch.base64Image!),
                                              width: screenWidth * 0.15,
                                              height: screenWidth * 0.15,
                                              fit: BoxFit.fill,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.image),
                                            )
                                          : const Icon(Icons.image),
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: AutoSizeText(
                                            ch.name.replaceAll(
                                              RegExp(r'\s*\(.*?\)'),
                                              '',
                                            ),
                                            maxLines: 1,
                                            style: GoogleFonts.orbitron(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await controller
                                                .removeFromFavorites(ch);
                                            await controller.reload();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.red,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
