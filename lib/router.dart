import 'package:go_router/go_router.dart';
import 'package:nature_connect/custom_widgets/comment_section.dart';
import 'package:nature_connect/custom_widgets/make_draft_widget.dart';
import 'package:nature_connect/custom_widgets/make_item_widget.dart';
import 'package:nature_connect/custom_widgets/make_post_widget.dart';
import 'package:nature_connect/pages/auth_page.dart';
import 'package:nature_connect/pages/drafts.dart';
import 'package:nature_connect/pages/home_page.dart';
import 'package:nature_connect/pages/marketplace.dart';
import 'package:nature_connect/pages/newsfeed.dart';
import 'package:nature_connect/pages/profile.dart';
import 'package:nature_connect/pages/profile_v.dart';
import 'package:nature_connect/pages/weather.dart';
import 'package:nature_connect/pages/scan_subscription.dart';
import 'package:nature_connect/pages/cam_scanner.dart';
import 'package:nature_connect/pages/checkout.dart';
import 'package:nature_connect/pages/location.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';

GoRouter goRouter() {
  return GoRouter(
    routes: [
      // Define your routes here
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          ),
      GoRoute(
          path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(
        path: '/marketplace',
        builder: (context, state) => const MarketplacePage(),
      ),
      GoRoute(
        path: '/weather',
        builder: (context, state) => const WeatherPage(),
      ),
      GoRoute(
        path: '/location',
        builder: (context, state) => const LocationPage(),
      ),
      GoRoute(
        path: '/newsfeed',
        builder: (context, state) => const NewsfeedPage(),
      ),
      GoRoute(
        path: '/comments/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId'];
          return CommentSection(
            postId: postId!,
          );
        },
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'];
          return ProfileV(userId: userId!);
        },
      ),
      GoRoute(
        path: '/makepost',
        builder: (context, state) {
          return const MakePostWidget();
        },
      ),
      GoRoute(
        path: '/makeitem',
        builder: (context, state) {
          return const MakeItemWidget();
        },
      ),
      GoRoute(
        path: '/makedraft',
        builder: (context, state) {
          return const MakeDraftWidget();
        },
      ),
      GoRoute(
        path: '/drafts/:showAppbar',
        builder: (context, state) {
          final showAppbar = state.pathParameters['showAppbar'];
          if (showAppbar == 'true') {
            return const DraftsPage(
              showAppBar: true,
            );
          }
          return const DraftsPage();
        },
      ),

      GoRoute(
        path: '/checkout', // Path to the checkout page
        builder: (context, state) {
          // Extract checkoutData from the extra argument
          final Map<String, dynamic> checkoutData =
              state.extra as Map<String, dynamic>;

          // Return the CheckoutPage with the extracted data
          return CheckoutPage(
            checkoutData: checkoutData,
          );
        },
      ),
      GoRoute(path: '/cam_scanner', builder: (context, state) => CamScanner()),
    ],
  );
}
