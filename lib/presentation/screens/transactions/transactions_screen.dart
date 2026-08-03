import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/category_chip.dart';
import '../home/app_drawer.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final List<String> types = ['All', 'Stock Added', 'Sold', 'Returned', 'Damaged'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchAllTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransactionProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(color: AppColors.whiteColor)),
        backgroundColor: AppColors.backgroundColor,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: types.map((t) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CategoryChip(
                  label: t,
                  isSelected: tp.selectedType == t || (tp.selectedType.isEmpty && t == 'All'),
                  onTap: () => tp.filterByType(t == 'All' ? '' : t),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => tp.fetchAllTransactions(),
              child: tp.filteredTransactions.isEmpty
                  ? const Center(child: Text('No transactions found', style: TextStyle(color: AppColors.subtitleText)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tp.filteredTransactions.length,
                      itemBuilder: (context, index) {
                        return TransactionTile(
                          transaction: tp.filteredTransactions[index],
                          productName: 'Product',
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
