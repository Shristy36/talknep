import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/app_spacing.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/createPost/add_location_provider.dart';
import 'package:talknep/provider/createPost/create_post_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class AddLocationScreen extends StatelessWidget {
  AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    return Scaffold(
      appBar: AppAppbar(title: 'Add Locations'),
      backgroundColor: context.scaffoldBackgroundColor,
      body: AppHorizontalPadding(
        child: Column(
          children: [
            // 🔍 Search Field
            SizedBox(
              height: Sizer.h(5.5),
              child: Consumer<CreatePostProvider>(
                builder: (context, createPostProvider, child) {
                  return CupertinoSearchTextField(
                    controller: locationProvider.searchController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        locationProvider.fetchSuggestions(value);
                      } else {
                        locationProvider.suggestions.clear();
                        locationProvider.notifyListeners();
                      }
                    },
                    placeholder: "Search your location",
                    placeholderStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.colorsScheme.onSurface,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.colorsScheme.onSurface,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: context.colorsScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            if (locationProvider.suggestions.isNotEmpty)
              Consumer<CreatePostProvider>(
                builder: (context, createPostProvider, child) {
                  return Container(
                    height: Sizer.h(30),
                    padding: EdgeInsets.symmetric(horizontal: Sizer.w(4)),
                    child: ListView.builder(
                      itemCount: locationProvider.suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = locationProvider.suggestions[index];
                        return ListTile(
                          title: AppText(text: suggestion['description']),
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await locationProvider.selectSuggestion(
                              suggestion['place_id'],
                              locationProvider.mapController,
                            );
                            locationProvider.searchController.text =
                                suggestion['description'];
                            createPostProvider.searchMapName =
                                locationProvider.searchController.text;
                            createPostProvider.notifyListeners();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            // 🗺 Google Map
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: Sizer.h(1)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colorsScheme.onSurface),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    onMapCreated:
                        (controller) =>
                            locationProvider.mapController = controller,
                    initialCameraPosition: CameraPosition(
                      zoom: 14,
                      target: locationProvider.position,
                    ),
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    markers: {
                      Marker(
                        position: locationProvider.position,
                        markerId: const MarkerId("searchedLocation"),
                      ),
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: Sizer.h(1)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Sizer.w(4)),
              decoration: BoxDecoration(
                color: context.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colorsScheme.onSurface),

                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    spreadRadius: 5,
                    offset: Offset(0, -2),
                    color: context.colorsScheme.shadow,
                  ),
                ],
              ),
              child: Flexible(
                child: AppText(
                  maxLines: 2,
                  text: locationProvider.locationName,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Sizer.w(4),
          vertical: Sizer.h(2),
        ),
        child: AppButton(
          onPressed: () {
            Get.back();
          },
          child: AppText(text: "Save", color: AppColors.whiteColor),
        ),
      ),
    );
  }
}
