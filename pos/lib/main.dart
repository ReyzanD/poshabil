import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/models/category_model.dart';
import 'data/models/customer_model.dart';
import 'data/models/product_model.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/pages/login_page.dart';
import 'presentation/auth/pages/register_page.dart';
import 'presentation/category/bloc/category_bloc.dart';
import 'presentation/category/pages/category_form_page.dart';
import 'presentation/customer/bloc/customer_bloc.dart';
import 'presentation/customer/pages/customer_form_page.dart';
import 'presentation/home_page.dart';
import 'presentation/splash_page.dart';
import 'presentation/product/bloc/product_bloc.dart';
import 'presentation/product/pages/product_form_page.dart';
import 'presentation/transaction/bloc/transaction_bloc.dart';
import 'presentation/transaction/pages/transaction_detail_page.dart';
import 'presentation/transaction/pages/transaction_form_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-warm SharedPreferences so the web plugin registers before any
  // ApiClient calls. The try/catch gracefully handles environments where
  // the plugin is unavailable (e.g. file:// protocol or restricted contexts).
  if (kIsWeb) {
    try {
      await SharedPreferences.getInstance();
    } catch (_) {
      // Web plugin unavailable — ApiClient will use in-memory fallback.
    }
  }

  final apiClient = ApiClient();
  await apiClient.restoreToken();
  runApp(MyApp(apiClient: apiClient));
}

Page _slidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    final authBloc = AuthBloc(apiClient);
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _slidePage(
            state: state,
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => _slidePage(
            state: state,
            child: const RegisterPage(),
          ),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => _slidePage(
            state: state,
            child: HomePage(apiClient: apiClient),
          ),
        ),
        GoRoute(
          path: '/categories/add',
          pageBuilder: (context, state) => _slidePage(
            state: state,
            child: BlocProvider(
              create: (_) => CategoryBloc(apiClient),
              child: const CategoryFormPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/categories/edit/:id',
          pageBuilder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return _slidePage(
              state: state,
              child: BlocProvider(
                create: (_) => CategoryBloc(apiClient),
                child: CategoryFormPage(
                  category: CategoryModel(id: id, name: ''),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: '/products/add',
          pageBuilder: (context, state) => _slidePage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ProductBloc(apiClient)),
                BlocProvider(create: (_) => CategoryBloc(apiClient)),
              ],
              child: const ProductFormPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/products/edit/:id',
          pageBuilder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return _slidePage(
              state: state,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => ProductBloc(apiClient)),
                  BlocProvider(create: (_) => CategoryBloc(apiClient)),
                ],
                child: ProductFormPage(
                  product: ProductModel(
                    id: id,
                    categoryId: 0,
                    name: '',
                    sku: '',
                    price: 0,
                    stock: 0,
                  ),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: '/customers/add',
          pageBuilder: (context, state) => _slidePage(
            state: state,
            child: BlocProvider(
              create: (_) => CustomerBloc(apiClient),
              child: const CustomerFormPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/customers/edit/:id',
          pageBuilder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return _slidePage(
              state: state,
              child: BlocProvider(
                create: (_) => CustomerBloc(apiClient),
                child: CustomerFormPage(
                  customer: CustomerModel(id: id, name: ''),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: '/transactions/add',
          pageBuilder: (context, state) => _slidePage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => TransactionBloc(apiClient)),
                BlocProvider(create: (_) => ProductBloc(apiClient)),
                BlocProvider(create: (_) => CustomerBloc(apiClient)),
              ],
              child: const TransactionFormPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/transactions/:id',
          pageBuilder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return _slidePage(
              state: state,
              child: BlocProvider(
                create: (_) => TransactionBloc(apiClient),
                child: TransactionDetailPage(id: id),
              ),
            );
          },
        ),
      ],
    );

    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'POS App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
