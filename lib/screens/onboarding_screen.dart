import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 1;

  // Answers
  String _selectedGoal = '📚 Études';
  String _selectedStyle = '🌱 Petites étapes régulières';
  String _selectedMood = '🙂 Bien';

  // Auth fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      if (_step < 5) _step++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_step > 1) _step--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _step > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: _prevStep,
              )
            : null,
        actions: [
          _buildLangButton(state, const Locale('fr', 'FR'), 'FR'),
          _buildLangButton(state, const Locale('en', 'US'), 'EN'),
          _buildLangButton(state, const Locale('es', 'ES'), 'ES'),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(context, state, isDark),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, AppStateProvider state, bool isDark) {
    switch (_step) {
      case 1:
        return _buildStep1Welcome(context, isDark);
      case 2:
        return _buildStep2Promise(context, isDark);
      case 3:
        return _buildStep3Discovery(context, isDark);
      case 4:
        return _buildStep4AIPersonalization(context, isDark);
      case 5:
        return _buildStep5AccountCreation(context, state, isDark);
      default:
        return _buildStep1Welcome(context, isDark);
    }
  }

  // ÉCRAN 1 — L'Accueil émotionnel
  Widget _buildStep1Welcome(BuildContext context, bool isDark) {
    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff2563eb).withValues(alpha: 0.12),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff2563eb).withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 64,
              color: Color(0xff2563eb),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '✨ Nexii',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Transforme tes intentions\nen progrès réel.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.4,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
              child: const Text(
                'Commencer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ÉCRAN 2 — Présentation de la promesse
  Widget _buildStep2Promise(BuildContext context, bool isDark) {
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Nexii t\'aide à :',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildPromiseCard(
            icon: Icons.track_changes,
            color: const Color(0xff2563eb),
            title: '🎯 Clarifier tes objectifs',
            desc: 'Décompose tes plus grandes ambitions en plans d\'action clairs.',
          ),
          const SizedBox(height: 16),
          _buildPromiseCard(
            icon: Icons.bolt,
            color: const Color(0xff8b5cf6),
            title: '🧠 Comprendre ton énergie',
            desc: 'Aura & Mental Battery mesurent ton état pour optimiser ton rythme.',
          ),
          const SizedBox(height: 16),
          _buildPromiseCard(
            icon: Icons.speed,
            color: const Color(0xff10b981),
            title: '⚡ Avancer avec un meilleur rythme',
            desc: 'Des sessions Focus immersives et une IA copilote bienveillante.',
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Continuer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPromiseCard({required IconData icon, required Color color, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ÉCRAN 3 — Découverte de l'utilisateur
  Widget _buildStep3Discovery(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(3),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apprenons à nous connaître 🧬', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Nexii s\'adapte à ta personnalité dès le départ.', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 24),

          // Question 1
          const Text('1. Quel est ton objectif principal ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['📚 Études', '🚀 Projet personnel', '💼 Travail', '🌱 Développement', '💰 Finance'].map((goal) {
              final sel = _selectedGoal == goal;
              return ChoiceChip(
                label: Text(goal),
                selected: sel,
                selectedColor: const Color(0xff2563eb),
                labelStyle: TextStyle(color: sel ? Colors.white : null, fontWeight: FontWeight.w600),
                onSelected: (val) {
                  if (val) setState(() => _selectedGoal = goal);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Question 2
          const Text('2. Comment veux-tu progresser ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '🔥 Défis ambitieux',
              '🌱 Petites étapes régulières',
              '🧠 Comprendre et apprendre',
              '⚡ Être plus organisé'
            ].map((style) {
              final sel = _selectedStyle == style;
              return ChoiceChip(
                label: Text(style),
                selected: sel,
                selectedColor: const Color(0xff8b5cf6),
                labelStyle: TextStyle(color: sel ? Colors.white : null, fontWeight: FontWeight.w600),
                onSelected: (val) {
                  if (val) setState(() => _selectedStyle = style);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Question 3
          const Text('3. Comment te sens-tu aujourd\'hui ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['😔 Fatigué', '😐 Normal', '🙂 Bien', '🤩 Motivé', '🧘 Serein'].map((mood) {
              final sel = _selectedMood == mood;
              return ChoiceChip(
                label: Text(mood),
                selected: sel,
                selectedColor: const Color(0xff10b981),
                labelStyle: TextStyle(color: sel ? Colors.white : null, fontWeight: FontWeight.w600),
                onSelected: (val) {
                  if (val) setState(() => _selectedMood = mood);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Générer mon profil Nexii ⚡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ÉCRAN 4 — Première personnalisation IA
  Widget _buildStep4AIPersonalization(BuildContext context, bool isDark) {
    return Padding(
      key: const ValueKey(4),
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xff10b981).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 56, color: Color(0xff10b981)),
          ),
          const SizedBox(height: 24),
          const Text(
            '✨ Ton espace Nexii est prêt.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'D\'après tes réponses, Nexii a configuré ton copilote :',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xff2563eb).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _buildPersonaRow(Icons.flag, '🎯 Priorité :', _selectedGoal, const Color(0xff2563eb)),
                const Divider(height: 24),
                _buildPersonaRow(Icons.bolt, '⚡ Style :', _selectedStyle, const Color(0xff8b5cf6)),
                const Divider(height: 24),
                _buildPersonaRow(Icons.mood, '🙂 État initial :', _selectedMood, const Color(0xff10b981)),
                const Divider(height: 24),
                _buildPersonaRow(Icons.play_circle, '🌱 Première étape :', 'Créer ta première mission', const Color(0xfff59e0b)),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Créer ton espace Nexii', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPersonaRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ÉCRAN 5 — Création du compte
  Widget _buildStep5AccountCreation(BuildContext context, AppStateProvider state, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(5),
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Créer ton espace Nexii 👤',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sauvegarde tes données et synchronise ta progression.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 28),

          // Google Auth Option
          OutlinedButton.icon(
            onPressed: () {
              // Quick demo login
              _nameController.text = 'Explorateur Nexii';
              state.completeOnboarding('Explorateur Nexii', '2000-01-01');
            },
            icon: const Icon(Icons.g_mobiledata, size: 28, color: Color(0xff2563eb)),
            label: const Text('Continuer avec Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('OU', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),

          // Name
          const Text('Nom complet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Alexandre Nexera',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Email
          const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'alexandre@nexera.io',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Password
          const Text('Mot de passe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                state.completeOnboarding(name, '2000-01-01');
              } else {
                state.completeOnboarding('Explorateur Nexii', '2000-01-01');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2563eb),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
            ),
            child: const Text('Commencer l\'aventure 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(AppStateProvider state, Locale locale, String label) {
    final isSelected = state.currentLocale.languageCode == locale.languageCode;
    return GestureDetector(
      onTap: () => state.setLocale(locale),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff2563eb) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? const Color(0xff2563eb) : Colors.grey.shade400),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
