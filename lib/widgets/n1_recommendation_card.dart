import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../intelligence/models/intelligence_models.dart';
import '../providers/app_state_provider.dart';

class NexiiN1RecommendationCard extends StatelessWidget {
  const NexiiN1RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final summary = state.currentN1Summary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Do not display a fake or forced card if no recommendation/action/friction exists
    if (summary.primaryAction == null && summary.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final primaryAction = summary.primaryAction;
    final recommendationText = summary.recommendations.isNotEmpty
        ? summary.recommendations.first
        : (summary.primaryReason.isNotEmpty
            ? summary.primaryReason
            : state.translate('n1_default_recommendation'));

    final actionLabel = _getActionLabel(context, state, primaryAction);
    final isInteractive = _isActionInteractive(primaryAction);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2563eb).withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xff2563eb).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xff2563eb),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.translate('n1_header_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xff2563eb),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff2563eb).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.translate('n1_badge_label'),
                  style: const TextStyle(
                    color: Color(0xff2563eb),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current State Summary
          Text(
            summary.currentStateSummary,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),

          // Primary Recommendation Message
          Text(
            recommendationText,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),

          // Primary Action Button (if valid and interactive)
          if (primaryAction != null && isInteractive && actionLabel != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563eb),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                icon: const Icon(Icons.bolt, size: 16),
                label: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                onPressed: () =>
                    _executeAction(context, state, primaryAction),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isActionInteractive(IntelligentAction? action) {
    if (action == null) return false;

    final targetId = action.targetId;
    if (targetId == 'toggleRecoveryMode' ||
        targetId == 'toggleCrisisMode' ||
        targetId == 'applyPulseAction' ||
        targetId == 'applyAIStrategy' ||
        targetId == 'startFocus' ||
        targetId == 'startTask' ||
        (action.actionId.startsWith('action:decomposeTask:')) ||
        action.actionType == IntelligentActionType.startTask ||
        action.actionType == IntelligentActionType.startFocus) {
      return true;
    }

    return false;
  }

  String? _getActionLabel(
      BuildContext context, AppStateProvider state, IntelligentAction? action) {
    if (action == null) return null;

    final targetId = action.targetId;
    if (targetId == 'toggleRecoveryMode') {
      return state.translate('n1_action_recovery_mode');
    }
    if (targetId == 'toggleCrisisMode') {
      return state.translate('n1_action_crisis_mode');
    }
    if (targetId == 'applyPulseAction') {
      return state.translate('n1_action_pulse');
    }
    if (targetId == 'applyAIStrategy') {
      return state.translate('n1_action_ai_strategy');
    }
    if (targetId == 'startFocus' ||
        action.actionType == IntelligentActionType.startFocus) {
      return state.translate('n1_action_start_focus');
    }
    if (action.actionId.startsWith('action:decomposeTask:')) {
      return state.translate('n1_action_decompose_task');
    }
    if (action.actionType == IntelligentActionType.startTask) {
      return state.translate('n1_action_start_task');
    }

    return null;
  }

  void _executeAction(
      BuildContext context, AppStateProvider state, IntelligentAction action) {
    final targetId = action.targetId;

    if (targetId == 'toggleRecoveryMode') {
      state.toggleRecoveryMode();
    } else if (targetId == 'toggleCrisisMode') {
      state.toggleCrisisMode();
    } else if (targetId == 'applyPulseAction') {
      state.applyPulseAction();
    } else if (targetId == 'applyAIStrategy') {
      state.applyAIStrategy();
    } else if (targetId == 'startFocus' ||
        action.actionType == IntelligentActionType.startFocus) {
      state.setTabIndex(2); // Focus tab
    } else if (action.actionId.startsWith('action:decomposeTask:')) {
      final taskId = action.targetId ??
          action.actionId.replaceFirst('action:decomposeTask:', '');
      if (taskId.isNotEmpty) {
        state.decomposeTaskToMicroActions(taskId);
      }
    } else if (action.actionType == IntelligentActionType.startTask) {
      state.setTabIndex(1); // Tasks tab
    }
  }
}
