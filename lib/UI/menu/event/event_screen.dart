import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talknep/UI/menu/event/create_event_screen.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/provider/menu/event/event_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() async {
            if (!tabController.indexIsChanging) {
              final provider = Provider.of<EventProvider>(
                context,
                listen: false,
              );
              provider.showMyEventsOnly = tabController.index == 1;
              await provider.getEventsList();
            }
          });
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: AppText(text: 'Events'),
              leading: IconButton(
                iconSize: 18,
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios),
              ),
              bottom: TabBar(
                dividerHeight: 0.1,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: context.colorsScheme.surface,
                labelStyle: context.textTheme.bodyLarge,
                indicatorAnimation: TabIndicatorAnimation.elastic,
                unselectedLabelStyle: context.textTheme.bodyMedium,
                unselectedLabelColor: context.colorsScheme.onSecondary,
                labelPadding: EdgeInsets.symmetric(horizontal: Sizer.w(2)),
                indicatorPadding: EdgeInsetsGeometry.symmetric(
                  vertical: Sizer.h(0.6),
                  horizontal: Sizer.w(3),
                ),
                indicator: BoxDecoration(
                  color: context.colorsScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                tabs: [Tab(text: 'All Events'), Tab(text: 'My Events')],
                onTap: (index) async {
                  final provider = Provider.of<EventProvider>(
                    context,
                    listen: false,
                  );
                  provider.showMyEventsOnly = index == 1;
                  await provider.getEventsList();
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Get.to(
                      () => CreateEventScreen(),
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            backgroundColor: context.scaffoldBackgroundColor,
            body: TabBarView(children: [EventListView(), EventListView()]),
          );
        },
      ),
    );
  }
}

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CommonLoader();
        }
        return provider.selectedEventList.isEmpty
            ? Center(
              child: AppText(text: "No Events", fontWeight: FontWeight.w500),
            )
            : RefreshIndicator.adaptive(
              onRefresh: () {
                return provider.getEventsList();
              },
              child: SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true,
                  cacheExtent: 999999999999999,
                  padding: const EdgeInsets.all(15),
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: provider.selectedEventList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final event = provider.selectedEventList[index];
                    return EventCard(event: event);
                  },
                ),
              ),
            );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final dynamic event;
  const EventCard({required this.event, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizer.w(2),
        vertical: Sizer.h(1),
      ),
      margin: EdgeInsets.only(bottom: Sizer.h(2)),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        border: Border.all(color: context.colorsScheme.onSecondary),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 2),
            color: context.colorsScheme.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetImage(
                fit: BoxFit.cover,
                width: double.infinity,
                imageUrl: event['banner'],
              ),
            ),
          ),
          AppText(
            text: event['title'],
            fontSize: Sizer.sp(3.7),
            fontWeight: FontWeight.w500,
          ),
          AppText(text: event['event_date'], fontSize: Sizer.sp(2.8)),
          SizedBox(height: Sizer.h(0.5)),
          Row(
            children: [
              Expanded(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    final eventId = event['id'].toString();
                    if (value == 'interested') {
                      provider.postInterestedAPI(eventId);
                    } else if (value == 'going') {
                      provider.postGoingAPI(eventId);
                    } else if (value == 'cancel') {
                      provider.postNotInterAPI(eventId);
                      provider.postNotGoingAPI(eventId);
                    }
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[];
                    if (event['interest'] != 'interested') {
                      items.add(
                        PopupMenuItem(
                          value: 'interested',
                          child: Row(
                            children: [
                              Icon(Icons.star_rate_sharp, size: 18),
                              SizedBox(width: 8),
                              AppText(
                                text: 'Interested',
                                fontSize: Sizer.sp(3.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (event['going'] != 'going') {
                      items.add(
                        PopupMenuItem(
                          value: 'going',
                          child: Row(
                            children: [
                              Icon(Icons.verified, size: 18),
                              SizedBox(width: 8),
                              AppText(text: 'Going', fontSize: Sizer.sp(3.5)),
                            ],
                          ),
                        ),
                      );
                    }
                    if (event['interest'] == 'interested' ||
                        event['going'] == 'going') {
                      items.add(
                        PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, size: 18),
                              SizedBox(width: 8),
                              AppText(text: 'Cancel', fontSize: Sizer.sp(3.5)),
                            ],
                          ),
                        ),
                      );
                    }
                    return items;
                  },
                  child: Container(
                    height: Sizer.h(3.5),
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color:
                          (event['interest'] == "interested" ||
                                  event['going'] == "going")
                              ? AppColors.primaryColor
                              : AppColors.borderColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          event['interest'] == "interested"
                              ? Icons.star_rate_sharp
                              : event['going'] == "going"
                              ? Icons.verified
                              : Icons.star_rate_sharp,
                          size: 15,
                          color: AppColors.whiteColor,
                        ),
                        SizedBox(width: Sizer.w(1)),
                        AppText(
                          text:
                              event['interest'] == "interested"
                                  ? "Interested"
                                  : event['going'] == "going"
                                  ? "Going"
                                  : "Interested",
                          fontSize: Sizer.sp(2.5),
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                        ),
                        Icon(
                          Icons.arrow_drop_down_sharp,
                          color: AppColors.whiteColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: Sizer.w(1)),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'share') {
                    final imageUrl = event['banner'];
                    final eventTime = event['event_date'];
                    final eventTitle = event['title'];

                    try {
                      final response = await http.get(Uri.parse(imageUrl));

                      if (response.statusCode == 200) {
                        final tempDir = await getTemporaryDirectory();
                        final file = File('${tempDir.path}/shared_event.jpg');
                        await file.writeAsBytes(response.bodyBytes);

                        await Share.shareXFiles(
                          [XFile(file.path)],
                          text:
                              'Check out this event!\n\nTitle: $eventTitle\nTime: $eventTime',
                        );
                      } else {
                        Get.snackbar(
                          "Error",
                          "Could not download image for sharing",
                        );
                      }
                    } catch (e) {
                      Get.snackbar(
                        "Error",
                        "Something went wrong while sharing",
                      );
                    }
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          spacing: 8,
                          children: [
                            Icon(Icons.share, size: 18),
                            Text('Share Event'),
                          ],
                        ),
                      ),
                    ],
                child: Container(
                  width: Sizer.w(7),
                  height: Sizer.h(3.5),
                  decoration: BoxDecoration(
                    color: context.colorsScheme.onSecondary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(Icons.more_vert),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
