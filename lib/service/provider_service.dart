import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:talknep/provider/another%20user%20profile/another_user_profile_provider.dart';
import 'package:talknep/provider/auth/forgot_provider.dart';
import 'package:talknep/provider/auth/login_provider.dart';
import 'package:talknep/provider/auth/register_provider.dart';
import 'package:talknep/provider/bottomBar/bottomBar_provider.dart';
import 'package:talknep/provider/chat/agora_call_provider.dart';
import 'package:talknep/provider/chat/chat_friend_list_provider.dart';
import 'package:talknep/provider/chat/chat_view_provider.dart';
import 'package:talknep/provider/comment/comment_provider.dart';
import 'package:talknep/provider/createPost/add_location_provider.dart';
import 'package:talknep/provider/createPost/create_post_provider.dart';
import 'package:talknep/provider/dashboard/add_text_provider.dart';
import 'package:talknep/provider/dashboard/dashboard_provider.dart';
import 'package:talknep/provider/dashboard/story_provider.dart';
import 'package:talknep/provider/language_provider.dart';
import 'package:talknep/provider/marketPlace/market_place_provider.dart';
import 'package:talknep/provider/menu/about_provider.dart';
import 'package:talknep/provider/menu/blog/blog_provider.dart';
import 'package:talknep/provider/menu/event/event_provider.dart';
import 'package:talknep/provider/menu/group/group_provider.dart';
import 'package:talknep/provider/menu/menu_provider.dart';
import 'package:talknep/provider/menu/page/page_provider.dart';
import 'package:talknep/provider/menu/theme/theme_provider.dart';
import 'package:talknep/provider/notification/notification_provider.dart';
import 'package:talknep/provider/search%20all%20friend/search_all_friend_provider.dart';
import 'package:talknep/provider/shortFeed/short_feed_provider.dart';
import 'package:talknep/provider/splash_provider.dart';
import 'package:talknep/provider/video/video_provider.dart';
import 'package:talknep/service/agora_config.dart';

List<SingleChildWidget> providers(LocaleProvider localeProvider) => [
  ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
  ChangeNotifierProvider(create: (context) => ThemeProvider()),
  ChangeNotifierProvider(create: (context) => SplashProvider()),
  ChangeNotifierProvider(create: (context) => LoginProvider()),
  ChangeNotifierProvider(create: (context) => RegisterProvider()),
  ChangeNotifierProvider(create: (context) => ForgotProvider()),
  ChangeNotifierProvider(create: (context) => BottomBarProvider()),
  ChangeNotifierProvider(create: (context) => MenuProvider()),
  ChangeNotifierProvider(create: (context) => AboutProvider()),
  ChangeNotifierProvider(create: (context) => NotificationProvider()),
  ChangeNotifierProvider(create: (context) => MarketPlaceProvider()),
  ChangeNotifierProvider(create: (context) => GroupProvider()),
  ChangeNotifierProvider(create: (context) => BlogProvider()),
  ChangeNotifierProvider(create: (context) => PageProvider()),
  ChangeNotifierProvider(create: (context) => CreatePostProvider()),
  ChangeNotifierProvider(create: (context) => ShortFeedProvider()),
  ChangeNotifierProvider(create: (context) => CommentProvider()),
  ChangeNotifierProvider(create: (context) => AnotherUserProfileProvider()),
  ChangeNotifierProvider(create: (context) => EventProvider()),
  ChangeNotifierProvider(create: (context) => DashboardProvider()),
  ChangeNotifierProvider(create: (context) => StoryProvider()),
  ChangeNotifierProvider(create: (context) => TextStoryProvider()),
  ChangeNotifierProvider(create: (context) => VideoProvider()),
  ChangeNotifierProvider(create: (context) => LocationProvider()),
  ChangeNotifierProvider(create: (context) => SearchAllFriendProvider()),
  ChangeNotifierProvider(create: (context) => ChatFriendListProvider()),
  ChangeNotifierProvider(create: (context) => ChatViewProvider()),
  ChangeNotifierProvider(create: (context) => AgoraCallProvider()),
  ChangeNotifierProvider(create: (context) => AgoraResponse()),
];
