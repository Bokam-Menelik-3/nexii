import '../../intelligence/models/intelligence_models.dart';

enum NotificationOutcome { send, silence, defer }

class NotificationDecision {
  final NotificationOutcome outcome;
  final String title;
  final String body;
  final String targetRoute;
  final String reason;

  const NotificationDecision({
    required this.outcome,
    required this.title,
    required this.body,
    required this.targetRoute,
    required this.reason,
  });
}

/// Service managing intelligent FCM and in-app notification decisions.
///
/// Invariants:
/// - No engagement spam ("we miss you", streak pressure).
/// - Quiet hours (22:00 -> 07:00) strictly defer or silence notifications.
/// - Interruption budget enforced (max 2 notifications / day).
class NexiiNotificationService {
  static const int maxDailyNotifications = 2;
  final List<DateTime> _sentTimestamps = [];

  bool isQuietHours(DateTime time) {
    final hour = time.hour;
    return hour >= 22 || hour < 7;
  }

  NotificationDecision evaluate({
    required ContextSnapshot snapshot,
    required String title,
    required String body,
    required String targetRoute,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    // 1. Quiet Hours check
    if (isQuietHours(currentTime)) {
      return NotificationDecision(
        outcome: NotificationOutcome.defer,
        title: title,
        body: body,
        targetRoute: targetRoute,
        reason: 'quiet_hours_active',
      );
    }

    // 2. Clean old timestamps (> 24 hours ago)
    _sentTimestamps.removeWhere(
      (ts) => currentTime.difference(ts).inHours >= 24,
    );

    // 3. Interruption budget check
    if (_sentTimestamps.length >= maxDailyNotifications) {
      return NotificationDecision(
        outcome: NotificationOutcome.silence,
        title: title,
        body: body,
        targetRoute: targetRoute,
        reason: 'interruption_budget_exceeded',
      );
    }

    // 4. Critical / High Priority check
    if (snapshot.mentalBattery < 30) {
      // Gentle recovery advice only
      _sentTimestamps.add(currentTime);
      return NotificationDecision(
        outcome: NotificationOutcome.send,
        title: 'Nexii Pause',
        body: 'Votre batterie mentale est basse. Prenez un moment pour respirer.',
        targetRoute: '/focus',
        reason: 'mental_battery_critical',
      );
    }

    _sentTimestamps.add(currentTime);
    return NotificationDecision(
      outcome: NotificationOutcome.send,
      title: title,
      body: body,
      targetRoute: targetRoute,
      reason: 'canonical_context_valid',
    );
  }

  void resetBudgetForTesting() {
    _sentTimestamps.clear();
  }
}
