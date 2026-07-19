import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _budgetLimitController = TextEditingController();
  String _selectedCategory = 'Alimentation';
  bool _isExpense = true;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _budgetLimitController.dispose();
    super.dispose();
  }

  void _showAddTransactionDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Ajouter une transaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre de la transaction',
                        hintText: 'Supermarché, Salaire, Cafétéria...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Montant (FCFA)',
                        hintText: '5000',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Dépense'),
                            selected: _isExpense,
                            selectedColor: const Color(0xffef4444).withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: _isExpense ? const Color(0xffef4444) : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              setDialogState(() {
                                _isExpense = true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Revenu'),
                            selected: !_isExpense,
                            selectedColor: const Color(0xff22c55e).withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: !_isExpense ? const Color(0xff22c55e) : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              setDialogState(() {
                                _isExpense = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                      items: ['Alimentation', 'Loisirs', 'Abonnements', 'Transport', 'Santé', 'Salaire', 'Autre']
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(state.translate('cancel_btn')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    final amountText = _amountController.text.trim();
                    final amount = double.tryParse(amountText);

                    if (title.isNotEmpty && amount != null && amount > 0) {
                      state.addTransaction(title, amount, _selectedCategory, _isExpense);
                      _titleController.clear();
                      _amountController.clear();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBudgetLimitDialog(BuildContext context, AppStateProvider state) {
    _budgetLimitController.text = state.totalBudget.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Définir le Budget Mensuel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez votre limite budgétaire globale pour ce mois en FCFA.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _budgetLimitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  labelText: 'Limite du Budget (FCFA)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(state.translate('cancel_btn')),
            ),
            ElevatedButton(
              onPressed: () {
                final text = _budgetLimitController.text.trim();
                final val = double.tryParse(text);
                if (val != null && val >= 0) {
                  state.updateBudget(val);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    double progress = 0.0;
    if (state.totalBudget > 0) {
      progress = (state.spentBudget / state.totalBudget).clamp(0.0, 1.0);
    }

    // Stress index based on spending percentage
    double stressIndex = (progress * 10).clamp(0.0, 10.0);
    String stressLabel = "Calme";
    Color stressColor = const Color(0xff22c55e);

    if (stressIndex > 7.5) {
      stressLabel = "Stress Élevé";
      stressColor = const Color(0xffef4444);
    } else if (stressIndex > 4.5) {
      stressLabel = "Vigilance";
      stressColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Color(0xff22c55e)),
            const SizedBox(width: 8),
            Text(
              state.translate('budget_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget Main Visual Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            state.translate('remain_budget'),
                            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, size: 18, color: Colors.grey),
                          onPressed: () => _showEditBudgetLimitDialog(context, state),
                          tooltip: 'Modifier la limite',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.remainingBudget.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: state.remainingBudget >= 0 ? const Color(0xff22c55e) : const Color(0xffef4444),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat(state.translate('budget_total'), '${state.totalBudget.toStringAsFixed(0)} FCFA'),
                        _buildMiniStat(state.translate('spent_amount'), '${state.spentBudget.toStringAsFixed(0)} FCFA'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(context).dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.8 ? const Color(0xffef4444) : const Color(0xff2563eb),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stress Financier Indicator Card (matches React)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: stressColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.bolt, color: stressColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate('financial_stress'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Calculé par rapport au rythme d\'achat',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          stressLabel,
                          style: TextStyle(fontWeight: FontWeight.bold, color: stressColor, fontSize: 13),
                        ),
                        Text(
                          'Indice : ${stressIndex.toStringAsFixed(1)}/10',
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.translate('recent_trans'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xff22c55e)),
                    onPressed: () => _showAddTransactionDialog(context, state),
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Transaction List
              if (state.transactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      'Aucune transaction enregistrée.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = state.transactions[index];
                    final String title = tx['title'] ?? '';
                    final double amount = (tx['amount'] as num).toDouble();
                    final String category = tx['category'] ?? 'Autre';
                    final bool isNegative = tx['isNegative'] ?? true;

                    final amountSign = isNegative ? '-' : '+';
                    final amountText = "$amountSign${amount.abs().toStringAsFixed(0)} FCFA";

                    return _buildTransactionTile(
                      context,
                      title,
                      amountText,
                      category,
                      isNegative,
                      onDelete: () {
                        state.deleteTransaction(index);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, state),
        backgroundColor: const Color(0xff22c55e),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    String title,
    String amount,
    String subtitle,
    bool isNegative, {
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isNegative ? const Color(0xffef4444).withOpacity(0.1) : const Color(0xff22c55e).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isNegative ? Icons.trending_down : Icons.trending_up,
            color: isNegative ? const Color(0xffef4444) : const Color(0xff22c55e),
            size: 18,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isNegative ? const Color(0xffef4444) : const Color(0xff22c55e),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
