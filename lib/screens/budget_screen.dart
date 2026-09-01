import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<BudgetProvider>().loadTransactions();
      } catch (_) {}
    });
  }

  Future<void> _openTransactionDialog({TransactionItem? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final amountController = TextEditingController(
        text: existing != null ? existing.amount.toString() : '');
    final date = existing?.date ?? DateTime.now();
    String type = existing?.type ?? 'expense';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existing == null
                  ? 'Nouvelle transaction'
                  : 'Modifier la transaction'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Montant'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(
                          value: 'expense', child: Text('Dépense')),
                      DropdownMenuItem(value: 'income', child: Text('Revenu')),
                    ],
                    onChanged: (v) => setState(() => type = v ?? type),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount =
                        double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (title.isEmpty || amount <= 0) {
                      return;
                    }
                    final transaction = (existing ??
                            TransactionItem(
                              id: '',
                              title: '',
                              amount: 0,
                              type: 'expense',
                              date: DateTime.now(),
                            ))
                        .copyWith(
                      title: title,
                      amount: amount,
                      type: type,
                      date: date,
                    );
                    Navigator.of(ctx).pop(true);
                    if (existing == null) {
                      context
                          .read<BudgetProvider>()
                          .addTransaction(transaction.copyWith(id: ''));
                    } else {
                      context
                          .read<BudgetProvider>()
                          .updateTransaction(transaction);
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok == true && existing != null) {
      await context.read<BudgetProvider>().loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BudgetProvider>();

    final summaryCards = [
      _SummaryCard(
          label: 'Solde',
          value: '${prov.balance.toStringAsFixed(2)} €',
          color: Colors.green),
      _SummaryCard(
          label: 'Revenus',
          value: '${prov.totalIncome.toStringAsFixed(2)} €',
          color: Colors.blue),
      _SummaryCard(
          label: 'Dépenses',
          value: '${prov.totalExpense.toStringAsFixed(2)} €',
          color: Colors.orange),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTransactionDialog(),
        child: const Icon(Icons.add),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: summaryCards,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: prov.transactions.length,
                    itemBuilder: (context, index) {
                      final t = prov.transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(t.title),
                          subtitle: Text(
                              '${t.type == 'income' ? 'Revenu' : 'Dépense'} • ${t.date.toLocal().toString().split(' ')[0]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${t.amount.toStringAsFixed(2)} €',
                                  style: TextStyle(
                                      color: t.type == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () =>
                                    _openTransactionDialog(existing: t),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                                onPressed: () => prov.deleteTransaction(t.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
