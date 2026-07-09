import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/branded_refresh_indicator.dart';
import '../../../core/widgets/delete_bottom_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../data/models/customer_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
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
      final state = context.read<CustomerBloc>().state;
      if (state is CustomersLoaded && state.hasMore) {
        context.read<CustomerBloc>().add(const LoadMoreCustomers());
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
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          context.read<CustomerBloc>().add(const LoadCustomers());
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  context.read<CustomerBloc>().add(LoadCustomers(search: v));
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const ShimmerSkeleton();
                }
                if (state is CustomerError) {
                  return Center(child: Text(state.message));
                }
                if (state is CustomersLoaded) {
                  final customers = state.customers;
                  if (customers.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.people,
                      title: 'No customers found',
                      subtitle: 'Add your first customer to get started',
                    );
                  }
                  return BrandedRefreshIndicator(
                    onRefresh: () async {
                      context.read<CustomerBloc>().add(const LoadCustomers());
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: customers.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == customers.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final c = customers[index];
                        return GlassCard(
                          tintColor: Colors.orange,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange.withAlpha(30),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    if (c.email != null || c.phone != null)
                                      Text(
                                        [c.email, c.phone]
                                            .where((e) => e != null)
                                            .join(' | '),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    context.push('/customers/edit/${c.id}'),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withAlpha(15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              if (_isAdmin) ...[
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _deleteCustomer(c),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red,
                                    ),
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

  void _deleteCustomer(CustomerModel c) {
    showDeleteBottomSheet(
      context: context,
      title: 'Delete Customer',
      itemName: c.name,
      onConfirm: () =>
          context.read<CustomerBloc>().add(DeleteCustomer(c.id!)),
    );
  }
}