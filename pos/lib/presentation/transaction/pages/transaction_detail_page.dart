import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class TransactionDetailPage extends StatefulWidget {
  final int id;

  const TransactionDetailPage({super.key, required this.id});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final _currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactionDetail(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Detail')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const ShimmerSkeleton();
          }
          if (state is TransactionError) {
            return Center(child: Text(state.message));
          }
          if (state is TransactionDetailLoaded) {
            final t = state.transaction;
            final date = t.createdAt != null
                ? DateFormat('dd MMM yyyy HH:mm')
                    .format(DateTime.parse(t.createdAt!))
                : '';
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  tintColor: t.paymentStatus == 'paid'
                      ? Colors.green
                      : Colors.red,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            t.paymentStatus == 'paid'
                                ? Icons.check_circle
                                : Icons.pending,
                            color: t.paymentStatus == 'paid'
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.invoiceNumber,
                              style:
                                  theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(label: 'Date', value: date),
                      _DetailRow(
                          label: 'Cashier',
                          value: t.user?.name ?? '-'),
                      _DetailRow(
                          label: 'Customer',
                          value: t.customer?.name ?? 'Guest'),
                      _DetailRow(
                          label: 'Payment',
                          value: t.paymentMethod.toUpperCase()),
                      _DetailRow(
                        label: 'Status',
                        value: t.paymentStatus.toUpperCase(),
                        valueColor: t.paymentStatus == 'paid'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Items',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (t.items != null)
                  ...t.items!.map(
                    (item) => GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      tintColor: theme.colorScheme.primary,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product?.name ?? 'Product',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${item.quantity} x ${_currency.format(item.price)}',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: theme
                                        .colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _currency.format(item.subtotal),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currency.format(t.total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
],
          ),
            );
        }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}