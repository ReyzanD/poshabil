import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/branded_refresh_indicator.dart';
import '../../../core/widgets/delete_bottom_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../core/widgets/stagger_fade.dart';
import '../../../data/models/product_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();
  final _currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadProducts());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductsLoaded && state.hasMore) {
        context.read<ProductBloc>().add(const LoadMoreProducts());
      }
    }
  }

  bool get _isAdmin {
    final auth = context.read<AuthBloc>().state;
    if (auth is Authenticated) return auth.user.role == 'admin';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or SKU...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<ProductBloc>()
                            .add(const LoadProducts());
                      },
                    )
                  : null,
            ),
            onChanged: (v) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 400), () {
                context.read<ProductBloc>().add(LoadProducts(search: v));
              });
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const ShimmerSkeleton();
              }
              if (state is ProductError) {
                return Center(
                  child: Text(state.message,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                );
              }
              if (state is ProductsLoaded) {
                final products = state.products;
                if (products.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.inventory_2,
                    title: 'No products found',
                    subtitle: 'Add your first product to get started',
                  );
                }
                return BrandedRefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductBloc>().add(const LoadProducts());
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: products.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == products.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final p = products[index];
                      final avatarColor = p.stock < 10 ? Colors.red : theme.colorScheme.primary;
                      return StaggerFade(
                        index: index,
                        child: GlassCard(
                          tintColor: avatarColor,
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      avatarColor,
                                      avatarColor.withAlpha(180),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: avatarColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${p.sku} | ${p.category?.name ?? ''}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'Stock: ${p.stock}',
                                      style: TextStyle(
                                        color: p.stock < 10 ? Colors.red : theme.colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                        fontWeight: p.stock < 10 ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _currency.format(p.price),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _SmallIconButton(
                                        icon: Icons.edit_outlined,
                                        onTap: () => context.push('/products/edit/${p.id}'),
                                      ),
                                      if (_isAdmin)
                                        _SmallIconButton(
                                          icon: Icons.delete_outline,
                                          color: Colors.red,
                                          onTap: () => _deleteProduct(p),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    ));
  }

  void _deleteProduct(ProductModel p) {
    showDeleteBottomSheet(
      context: context,
      title: 'Delete Product',
      itemName: p.name,
      onConfirm: () =>
          context.read<ProductBloc>().add(DeleteProduct(p.id!)),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _SmallIconButton({
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (color ?? Theme.of(context).colorScheme.primary).withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
