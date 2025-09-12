import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/UI/market%20place/components/info_text.dart';
import 'package:talknep/widget/app_button.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class MarketPlaceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> marketPlaceDetailsData;

  const MarketPlaceDetailsScreen({
    super.key,
    required this.marketPlaceDetailsData,
  });

  @override
  State<MarketPlaceDetailsScreen> createState() =>
      _MarketPlaceDetailsScreenState();
}

class _MarketPlaceDetailsScreenState extends State<MarketPlaceDetailsScreen> {
  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    data = widget.marketPlaceDetailsData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppAppbar(title: 'Product Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Sizer.w(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: NetImage(
                height: 230,
                fit: BoxFit.cover,
                width: double.infinity,
                imageUrl: data['coverphoto'] ?? '',
              ),
            ),
            SizedBox(height: Sizer.h(2.5)),
            // ✅ Title, Price & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    maxLines: 2,
                    fontSize: Sizer.sp(5),
                    text: data['title'] ?? '',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppText(
                    fontSize: Sizer.sp(3.5),
                    text: data['condition'] ?? '',
                    fontWeight: FontWeight.w500,
                    color: AppColors.successColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: Sizer.h(1.5)),
            AppText(
              fontSize: Sizer.sp(4.2),
              fontWeight: FontWeight.w600,
              text: '₹ ${data['price'] ?? 'N/A'}',
              color: context.colorsScheme.primary,
            ),
            SizedBox(height: Sizer.h(1)),

            Row(
              children: [
                Icon(
                  size: 18,
                  Icons.location_on_outlined,
                  color: context.colorsScheme.secondary,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: AppText(
                    fontSize: Sizer.sp(3.5),
                    text: data['location'] ?? 'N/A',
                    color: context.colorsScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: Sizer.h(1.5)),
            // ✅ Description Section
            AppText(
              text: 'Description',
              fontSize: Sizer.sp(4),
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 6),
            AppText(
              text: data['description'] ?? 'No description provided.',
              fontSize: Sizer.sp(3.4),
              color: context.colorsScheme.secondaryContainer.withAlpha(150),
            ),
            SizedBox(height: Sizer.h(2.5)),
            // ✅ More Info
            infoRow("Status", data['status'] ?? '', context),
            infoRow("Posted On", data['created_at'] ?? '', context),
            infoRow("Brand", data['brand'] ?? 'Unknown', context),
            infoRow("Category", data['category'] ?? 'Uncategorized', context),
            SizedBox(height: Sizer.h(3)),
            // ✅ Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          color: Colors.white,
                          Icons.shopping_cart_outlined,
                        ),
                        const SizedBox(width: 6),
                        AppText(text: "Buy Now", color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    onPressed: () async {
                      try {
                        final imageUrl = data['coverphoto'] ?? '';
                        final title = data['title'] ?? '';
                        final condition = data['condition'] ?? '';
                        final price = data['price'] ?? '';
                        final location = data['location'] ?? '';
                        final description =
                            data['description'] ?? 'No description';
                        final status = data['status'] ?? '';
                        final postedOn = data['created_at'] ?? '';
                        final brand = data['brand'] ?? 'Unknown';
                        final category = data['category'] ?? 'Uncategorized';

                        final response = await http.get(Uri.parse(imageUrl));
                        final documentDirectory = await getTemporaryDirectory();
                        final imageFile = File(
                          '${documentDirectory.path}/shared_image.jpg',
                        );
                        await imageFile.writeAsBytes(response.bodyBytes);

                        final message =
                            'Title: $title, Condition: $condition, Price: ₹ $price, Location: $location, Description: $description, Status: $status, Posted On: $postedOn, Brand: $brand, Category: $category';

                        await Share.shareXFiles([
                          XFile(imageFile.path),
                        ], text: message);
                      } catch (e) {
                        print('Error sharing image: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to share image')),
                        );
                      }
                    },
                    backgroundColor: Colors.transparent,
                    borderColor: context.colorsScheme.primary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share, color: context.colorsScheme.primary),
                        const SizedBox(width: 6),
                        AppText(
                          text: "Share",
                          color: context.colorsScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: Sizer.h(4)),
          ],
        ),
      ),
    );
  }
}
