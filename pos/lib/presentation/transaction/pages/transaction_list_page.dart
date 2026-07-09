import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/branded_refresh_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../core/widgets/stagger_fade.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final _currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');
  String? _paymentFilter;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const LoadTransactions());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<TransactionBloc>().state;
      if (state is TransactionsLoaded && state.hasMore) {
        context.read<TransactionBloc>().add(const LoadMoreTransactions());
      }
    }
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
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _paymentFilter == null,
                  onTap: () {
                    setState(() => _paymentFilter = null);
                    context.read<TransactionBloc>().add(const LoadTransactions());
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Paid',
                  selected: _paymentFilter == 'paid',
                  icon: Icons.check_circle,
                  onTap: () {
                    setState(() => _paymentFilter = 'paid');
                    context.read<TransactionBloc>().add(const LoadTransactions(paymentStatus: 'paid'));
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  selected: _paymentFilter == 'pending',
                  icon: Icons.pending,
                  onTap: () {
                    setState(() => _paymentFilter = 'pending');
                    context.read<TransactionBloc>().add(const LoadTransactions(paymentStatus: 'pending'));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const ShimmerSkeleton();
                }
                if (state is TransactionError) {
                  return Center(child: Text(state.message));
                }
                if (state is TransactionsLoaded) {
                  final txs = state.transactions;
                  if (txs.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.receipt_long,
                      title: 'No transactions found',
                      subtitle: 'Create your first transaction to get started',
                    );
                  }
                  return BrandedRefreshIndicator(
                    onRefresh: () async {
                      context.read<TransactionBloc>().add(
                        LoadTransactions(paymentStatus: _paymentFilter),
                      );
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                      itemCount: txs.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == txs.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final t = txs[index];
                        final date = t.createdAt != null
                            ? DateFormat('dd/MM/yy HH:mm')
                                .format(DateTime.parse(t.createdAt!))
                            : '';
                        final isPaid = t.paymentStatus == 'paid';
                        final statusColor = isPaid ? Colors.green : Colors.red;
                        final statusLabel = isPaid ? 'PAID' : 'PENDING';
                        return StaggerFade(
                          index: index,
                          child: GlassCard(
                            onTap: () => context.push('/transactions/${t.id}'),
                            tintColor: statusColor,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        statusColor,
                                        statusColor.withAlpha(180),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: statusColor.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPaid ? Icons.check_circle : Icons.pending,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.invoiceNumber,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '$date | ${t.customer?.name ?? "Guest"}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _currency.format(t.total),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      t.paymentMethod.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? theme.colorScheme.primary.withAlpha(25)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withAlpha(100)
                : theme.colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
