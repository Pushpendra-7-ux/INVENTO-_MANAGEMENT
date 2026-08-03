import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/transaction_entity.dart';
import 'touchable_scale.dart';
import 'info_row.dart';

class TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;
  final String? productName;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.productName,
  });

  void _showTransactionDetail(BuildContext context, _TransactionTypeConfig typeConfig) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.subtitleText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: typeConfig.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeConfig.icon, color: typeConfig.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayTitle,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          '${transaction.transactionType} • ${transaction.quantity} units',
                          style: TextStyle(color: typeConfig.color, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.borderColor, height: 1),
              const SizedBox(height: 16),
              InfoRow(label: 'Transaction ID', value: transaction.id),
              InfoRow(label: 'Product ID', value: transaction.productId),
              InfoRow(label: 'Timestamp', value: transaction.date.toLocal().toString().split('.')[0]),
              InfoRow(label: 'Processed By', value: transaction.userName ?? 'System Admin'),
              if (transaction.remarks?.isNotEmpty == true)
                InfoRow(label: 'Remarks', value: transaction.remarks!),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String get _displayTitle {
    final name = productName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final id = transaction.productId.trim();
    if (id.isNotEmpty) return 'Product #$id';
    return 'Inventory Item';
  }

  @override
  Widget build(BuildContext context) {
    final typeConfig = _getTypeConfig(transaction.transactionType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TouchableScale(
        onTap: () => _showTransactionDetail(context, typeConfig),
        onLongPress: () => _showTransactionDetail(context, typeConfig),
        borderRadius: BorderRadius.circular(12),
        glowColor: typeConfig.color,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: AppColors.cardColor,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ColoredBox(color: typeConfig.color, child: const SizedBox(width: 4)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: typeConfig.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(typeConfig.icon, color: typeConfig.color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _displayTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${transaction.transactionType}  ·  x${transaction.quantity} units',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: typeConfig.color,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(transaction.date),
                            style: const TextStyle(
                              color: AppColors.subtitleText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _TransactionTypeConfig _getTypeConfig(String type) {
    switch (type.toLowerCase()) {
      case 'stock added':
      case 'added':
        return _TransactionTypeConfig(AppColors.successColor, Icons.add_circle);
      case 'sold':
        return _TransactionTypeConfig(AppColors.gradient2, Icons.shopping_cart);
      case 'returned':
        return _TransactionTypeConfig(AppColors.infoColor, Icons.replay);
      case 'damaged':
        return _TransactionTypeConfig(AppColors.warningColor, Icons.warning);
      case 'deleted':
        return _TransactionTypeConfig(AppColors.errorColor, Icons.delete);
      default:
        return _TransactionTypeConfig(AppColors.gradient1, Icons.swap_horiz);
    }
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class _TransactionTypeConfig {
  final Color color;
  final IconData icon;

  _TransactionTypeConfig(this.color, this.icon);
}
