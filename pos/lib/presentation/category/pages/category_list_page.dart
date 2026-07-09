import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/branded_refresh_indicator.dart';
import '../../../core/widgets/delete_bottom_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../data/models/category_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() {}),
            ),
          ),
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const ShimmerSkeleton();
        }
        if (state is CategoryError) {
          return Center(child: Text(state.message));
        }
        if (state is CategoriesLoaded) {
          final cats = state.categories.where((c) =>
              _searchController.text.isEmpty ||
              c.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
          if (cats.isEmpty) {
            return const EmptyStateWidget(
                icon: Icons.category,
                title: 'No categories found',
                subtitle: 'Add your first category to get started',
              );
          }
          return BrandedRefreshIndicator(
            onRefresh: () async {
              context.read<CategoryBloc>().add(LoadCategories());
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
              itemCount: cats.length,
              itemBuilder: (context, index) {
                final cat = cats[index];
                return GlassCard(
                  tintColor: Colors.teal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal.withAlpha(30),
                        ),
                        child: const Icon(Icons.folder, color: Colors.teal, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (cat.description != null && cat.description!.isNotEmpty)
                              Text(
                                cat.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.teal.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${cat.productsCount ?? 0}',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.push('/categories/edit/${cat.id}'),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
                        ),
                      ),
                      if (_isAdmin) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _deleteCategory(cat),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          ),
                        ),
                      ],
                    ],
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
      ),
    );
  }

  void _deleteCategory(CategoryModel cat) {
    showDeleteBottomSheet(
      context: context,
      title: 'Delete Category',
      itemName: cat.name,
      onConfirm: () =>
          context.read<CategoryBloc>().add(DeleteCategory(cat.id!)),
    );
  }
}