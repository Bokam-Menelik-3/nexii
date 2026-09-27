import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NEXII — Financial Living Screen
// Source : AppStateProvider.totalBudget / spentBudget / remainingBudget /
//          transactions
// Actions: addTransaction · deleteTransaction · updateBudget
// Aucun mock — Aucune nouvelle logique financière
// ─────────────────────────────────────────────────────────────────────────────

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

  static const _green = Color(0xff22c55e);
  static const _red = Color(0xffef4444);
  static const _blue = Color(0xff2563eb);

  static const _categories = [
    'Alimentation',
    'Loisirs',
    'Abonnements',
    'Transport',
    'Santé',
    'Salaire',
    'Autre',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _budgetLimitController.dispose();
    super.dispose();
  }

  // ─── ACTION : Ajouter une transaction ───────────────────────────────────────

  void _showAddTransactionDialog(BuildContext context, AppStateProvider state) {
    _titleController.clear();
    _amountController.clear();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Ajouter une transaction',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre de la transaction',
                    hintText: 'Supermarché, Salaire, Cafétéria…',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                // Montant
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
                // Type
                const Text('Type',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Dépense'),
                        selected: _isExpense,
                        selectedColor: _red.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: _isExpense ? _red : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setDs(() => _isExpense = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Revenu'),
                        selected: !_isExpense,
                        selectedColor: _green.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: !_isExpense ? _green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setDs(() => _isExpense = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Catégorie
                const Text('Catégorie',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (val) {
                    if (val != null) setDs(() => _selectedCategory = val);
                  },
                  items: _categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(state.translate('cancel_btn')),
            ),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final amount = double.tryParse(_amountController.text.trim());
                if (title.isNotEmpty && amount != null && amount > 0) {
                  state.addTransaction(title, amount, _selectedCategory, _isExpense);
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACTION : Définir le budget mensuel ─────────────────────────────────────

  void _showEditBudgetLimitDialog(BuildContext context, AppStateProvider state) {
    _budgetLimitController.text = state.totalBudget.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Définir le Budget Mensuel',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(state.translate('cancel_btn')),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_budgetLimitController.text.trim());
              if (val != null && val >= 0) {
                state.updateBudget(val);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ── Valeurs réelles calculées depuis transactions ──
    double totalIncome = 0;
    double totalExpenses = 0;
    final Map<String, double> byCategory = {};

    for (final tx in state.transactions) {
      final amount = (tx['amount'] as num).toDouble();
      final isNeg = tx['isNegative'] as bool? ?? true;
      if (isNeg) {
        totalExpenses += amount;
        final cat = tx['category'] as String? ?? 'Autre';
        byCategory[cat] = (byCategory[cat] ?? 0) + amount;
      } else {
        totalIncome += amount;
      }
    }

    // ── Budget progress ────────────────────────────────
    final double progress = state.totalBudget > 0
        ? (state.spentBudget / state.totalBudget).clamp(0.0, 1.0)
        : 0.0;
    final bool hasBudget = state.totalBudget > 0;
    final bool overBudget = state.remainingBudget < 0;

    // Stress index — ratio budget utilisé (données réelles)
    final double stressIndex = (progress * 10).clamp(0.0, 10.0);

    // Catégories triées par montant décroissant
    final sortedCats = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: _green),
            const SizedBox(width: 8),
            Text(
              state.translate('budget_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_outlined,
              size: 20,
              color: theme.iconTheme.color?.withValues(alpha: 0.65),
            ),
            tooltip: 'Définir le budget',
            onPressed: () => _showEditBudgetLimitDialog(context, state),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. HERO — Situation actuelle ──────────────────────────────
              _HeroCard(
                state: state,
                progress: progress,
                overBudget: overBudget,
                hasBudget: hasBudget,
                stressIndex: stressIndex,
                isDark: isDark,
                onSetBudget: () => _showEditBudgetLimitDialog(context, state),
              ),
              const SizedBox(height: 16),

              // ── 2. FLUX — Entrées / Sorties ───────────────────────────────
              if (state.transactions.isNotEmpty) ...[
                _FluxCard(totalIncome: totalIncome, totalExpenses: totalExpenses),
                const SizedBox(height: 16),
              ],

              // ── 3. DÉPENSES PAR CATÉGORIE ─────────────────────────────────
              if (sortedCats.isNotEmpty) ...[
                _CategoriesCard(cats: sortedCats, totalExpenses: totalExpenses),
                const SizedBox(height: 16),
              ],

              // ── 4. TRANSACTIONS ────────────────────────────────────────────
              _buildTransactionsSection(context, state),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, state),
        backgroundColor: _green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ─── SECTION TRANSACTIONS ────────────────────────────────────────────────────

  Widget _buildTransactionsSection(BuildContext context, AppStateProvider state) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.translate('recent_trans'),
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: _green),
              onPressed: () => _showAddTransactionDialog(context, state),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 44, color: Colors.grey.withValues(alpha: 0.45)),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucune transaction enregistrée.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ajoutez votre première opération via le bouton +',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
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
              final String title = tx['title'] as String? ?? '';
              final double amount = (tx['amount'] as num).toDouble();
              final String category = tx['category'] as String? ?? 'Autre';
              final bool isNeg = tx['isNegative'] as bool? ?? true;
              final amountText = '${isNeg ? '-' : '+'}${amount.abs().toStringAsFixed(0)} FCFA';
              return _TransactionTile(
                title: title,
                amountText: amountText,
                category: category,
                isNegative: isNeg,
                onDelete: () => state.deleteTransaction(index),
              );
            },
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD — Situation actuelle
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.state,
    required this.progress,
    required this.overBudget,
    required this.hasBudget,
    required this.stressIndex,
    required this.isDark,
    required this.onSetBudget,
  });

  final AppStateProvider state;
  final double progress;
  final bool overBudget;
  final bool hasBudget;
  final double stressIndex;
  final bool isDark;
  final VoidCallback onSetBudget;

  static const _green = Color(0xff22c55e);
  static const _red = Color(0xffef4444);
  static const _blue = Color(0xff2563eb);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color statusColor = overBudget
        ? _red
        : progress > 0.8
            ? Colors.orange
            : _green;
    final String statusLabel = overBudget
        ? 'Dépassé'
        : progress > 0.8
            ? 'Vigilance'
            : 'Maîtrisé';

    final glowColor = hasBudget ? statusColor : _blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: isDark ? 0.18 : 0.09),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.translate('remain_budget'),
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              if (hasBudget) _StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),

          // Montant principal ou invite à définir le budget
          if (hasBudget)
            Text(
              '${state.remainingBudget.toStringAsFixed(0)} FCFA',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: overBudget ? _red : _green,
                height: 1.1,
              ),
            )
          else
            GestureDetector(
              onTap: onSetBudget,
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: _blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Définir mon budget mensuel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _blue,
                    ),
                  ),
                ],
              ),
            ),

          if (hasBudget) ...[
            const SizedBox(height: 20),
            // Budget total | Dépensé
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: state.translate('budget_total'),
                    value: '${state.totalBudget.toStringAsFixed(0)} FCFA',
                    color: _blue,
                  ),
                ),
                Container(width: 1, height: 36, color: theme.dividerColor),
                Expanded(
                  child: _MiniStat(
                    label: state.translate('spent_amount'),
                    value: '${state.spentBudget.toStringAsFixed(0)} FCFA',
                    color: _red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% utilisé',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  '${state.translate('financial_stress')} : ${stressIndex.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLUX CARD — Entrées / Sorties
// ─────────────────────────────────────────────────────────────────────────────

class _FluxCard extends StatelessWidget {
  const _FluxCard({required this.totalIncome, required this.totalExpenses});

  final double totalIncome;
  final double totalExpenses;

  static const _green = Color(0xff22c55e);
  static const _red = Color(0xffef4444);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FluxItem(
              icon: Icons.trending_up_rounded,
              label: 'Entrées',
              amount: totalIncome,
              color: _green,
            ),
          ),
          Container(width: 1, height: 52, color: theme.dividerColor),
          Expanded(
            child: _FluxItem(
              icon: Icons.trending_down_rounded,
              label: 'Sorties',
              amount: totalExpenses,
              color: _red,
            ),
          ),
        ],
      ),
    );
  }
}

class _FluxItem extends StatelessWidget {
  const _FluxItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${amount.toStringAsFixed(0)} FCFA',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORIES CARD — Dépenses par catégorie
// ─────────────────────────────────────────────────────────────────────────────

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({required this.cats, required this.totalExpenses});

  final List<MapEntry<String, double>> cats;
  final double totalExpenses;

  static const _blue = Color(0xff2563eb);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = cats.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dépenses par catégorie',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...top.map((entry) {
            final pct =
                totalExpenses > 0 ? (entry.value / totalExpenses * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      Text(
                        '${entry.value.toStringAsFixed(0)} FCFA · ${pct.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalExpenses > 0
                          ? (entry.value / totalExpenses).clamp(0.0, 1.0)
                          : 0.0,
                      backgroundColor: theme.dividerColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSACTION TILE
// ─────────────────────────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.amountText,
    required this.category,
    required this.isNegative,
    required this.onDelete,
  });

  final String title;
  final String amountText;
  final String category;
  final bool isNegative;
  final VoidCallback onDelete;

  static const _green = Color(0xff22c55e);
  static const _red = Color(0xffef4444);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isNegative ? _red : _green;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isNegative ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            color: color,
            size: 18,
          ),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle:
            Text(category, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amountText,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: color),
            ),
            const SizedBox(width: 4),
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

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: color),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
