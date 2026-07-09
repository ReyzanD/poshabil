import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_client.dart';
import '../core/widgets/speed_dial_fab.dart';
import 'auth/bloc/auth_bloc.dart';
import 'auth/bloc/auth_event.dart';
import 'auth/bloc/auth_state.dart';
import 'category/bloc/category_bloc.dart';
import 'category/pages/category_list_page.dart';
import 'customer/bloc/customer_bloc.dart';
import 'customer/pages/customer_list_page.dart';
import 'dashboard/bloc/dashboard_bloc.dart';
import 'dashboard/pages/dashboard_page.dart';
import 'product/bloc/product_bloc.dart';
import 'product/pages/product_list_page.dart';
import 'transaction/bloc/transaction_bloc.dart';
import 'transaction/pages/transaction_list_page.dart';

class _TabConfig {
  final Widget page;
  final String title;
  final IconData icon;
  final List<SpeedDialAction>? fabActions;

  const _TabConfig({
    required this.page,
    required this.title,
    required this.icon,
    this.fabActions,
  });
}

class HomePage extends StatefulWidget {
  final ApiClient apiClient;

  const HomePage({super.key, required this.apiClient});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<_TabConfig> _tabs;
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    final isAdmin =
        auth is Authenticated && auth.user.role == 'admin';

    _tabs = _buildTabs(isAdmin);
    _currentIndex = isAdmin ? 0 : (_tabs.length - 1);
  }

  List<_TabConfig> _buildTabs(bool isAdmin) {
    final tabs = <_TabConfig>[
      _TabConfig(
        page: BlocProvider(
          create: (_) => DashboardBloc(widget.apiClient),
          child: const DashboardPage(),
        ),
        title: 'Dashboard',
        icon: Icons.dashboard,
      ),
      _TabConfig(
        page: BlocProvider(
          create: (_) => ProductBloc(widget.apiClient),
          child: const ProductListPage(),
        ),
        title: 'Products',
        icon: Icons.inventory,
        fabActions: isAdmin
            ? [
                SpeedDialAction(
                  icon: Icons.add,
                  label: 'Add Product',
                  onPressed: () => context.push('/products/add'),
                ),
              ]
            : null,
      ),
      _TabConfig(
        page: BlocProvider(
          create: (_) => TransactionBloc(widget.apiClient),
          child: const TransactionListPage(),
        ),
        title: 'Transactions',
        icon: Icons.receipt,
        fabActions: [
          SpeedDialAction(
            icon: Icons.add_shopping_cart,
            label: 'New Transaction',
            onPressed: () => context.push('/transactions/add'),
          ),
        ],
      ),
    ];

    if (isAdmin) {
      tabs.addAll([
        _TabConfig(
          page: BlocProvider(
            create: (_) => CategoryBloc(widget.apiClient),
            child: const CategoryListPage(),
          ),
          title: 'Categories',
          icon: Icons.category,
          fabActions: [
            SpeedDialAction(
              icon: Icons.add,
              label: 'Add Category',
              onPressed: () => context.push('/categories/add'),
            ),
          ],
        ),
        _TabConfig(
          page: BlocProvider(
            create: (_) => CustomerBloc(widget.apiClient),
            child: const CustomerListPage(),
          ),
          title: 'Customers',
          icon: Icons.people,
          fabActions: [
            SpeedDialAction(
              icon: Icons.add,
              label: 'Add Customer',
              onPressed: () => context.push('/customers/add'),
            ),
          ],
        ),
      ]);
    }

    return tabs;
  }

  void _onLogout() {
    context.read<AuthBloc>().add(const LogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTab = _tabs[_currentIndex];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentTab.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _onLogout,
            ),
          ],
        ),
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _tabs.map((t) => t.page).toList(),
            ),
            // Backdrop overlay when FAB is open
            if (_fabOpen)
              GestureDetector(
                onTap: () => setState(() => _fabOpen = false),
                behavior: HitTestBehavior.translucent,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            // FAB anchored to the bottom of the content area
            if (currentTab.fabActions != null)
              Positioned(
                right: 16,
                bottom: 16,
                child: SpeedDialFab(
                  key: ValueKey('fab_$_currentIndex'),
                  actions: currentTab.fabActions!,
                  isOpen: _fabOpen,
                  onOpenChanged: (v) => setState(() => _fabOpen = v),
                ),
              ),
          ],
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.75),
              indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.black26,
              elevation: 8,
              height: 68,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: _tabs
                  .map((t) => NavigationDestination(
                        icon: Icon(t.icon, color: theme.colorScheme.onSurfaceVariant),
                        selectedIcon: Icon(t.icon, color: theme.colorScheme.primary),
                        label: t.title,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
