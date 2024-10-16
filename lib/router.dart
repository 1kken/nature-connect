import 'package:go_router/go_router.dart';
import 'package:nature_connect/custom_widgets/comment_section.dart';
import 'package:nature_connect/pages/auth_page.dart';
import 'package:nature_connect/pages/home_page.dart';
import 'package:nature_connect/pages/marketplace.dart';
import 'package:nature_connect/pages/newsfeed.dart';
import 'package:nature_connect/pages/profile.dart';
import 'package:nature_connect/pages/weather.dart';


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
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(path: '/marketplace',builder: (context, state) => const MarketplacePage(),),
      GoRoute(path: '/weather',builder:(context, state) => const WeatherPage(),),
      GoRoute(path: '/newsfeed',builder: (context, state) => const NewsfeedPage(),),
      GoRoute(path: '/comments/:postId',builder: (context, state){
        final postId = state.pathParameters['postId'];
        return CommentSection(postId: postId!,);
      },),
      // Add other routes as needed
    ],
  );
}
