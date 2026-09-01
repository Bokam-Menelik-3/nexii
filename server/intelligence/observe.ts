import { IntelligenceRequest, IntelligenceResponse } from "../types/index.ts";

/**
 * ObserveNode
 * - Input: payload.progressContext (compact weekly summary), optional profile
 * - Output: observations about recent activity (deltas, missing data flags)
 */
export class ObserveNode {
  static async process(req: IntelligenceRequest): Promise<IntelligenceResponse> {
    const payload = req.payload || {};
    const ctx = (payload.progressContext || {}) as Record<string, any>;

    const observations: Record<string, unknown> = {};

    try {
      const totalTasks = Number(ctx.totalTasks ?? 0);
      const completedTasks = Number(ctx.completedTasks ?? 0);
      const completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0;
      const focusMinutes = Number(ctx.focusMinutes ?? 0);
      const activeDays = Number(ctx.activeDays ?? 0);
      const goalsCount = Number(ctx.goalsCount ?? 0);

      observations.totalTasks = totalTasks;
      observations.completedTasks = completedTasks;
      observations.completionRate = completionRate;
      observations.focusMinutes = focusMinutes;
      observations.activeDays = activeDays;
      observations.goalsCount = goalsCount;

      // simple flags
      observations.hasTasks = totalTasks > 0;
      observations.hasFocus = focusMinutes > 0;
      observations.isActive = activeDays > 0;

      // detect rapid changes if baseline provided
      const baseline = ctx.baselineSnapshot as Record<string, any> | undefined;
      if (baseline) {
        const baseCompleted = Number(baseline.completedTasks ?? 0);
        const baseTotal = Number(baseline.totalTasks ?? 0);
        const baseRate = baseTotal > 0 ? baseCompleted / baseTotal : 0;
        observations.deltaCompletionRate = completionRate - baseRate;
      }

      return {
        nodeId: "observe",
        result: observations,
        provider: "local",
      };
    } catch (e) {
      return {
        nodeId: "observe",
        result: { error: String(e) },
        provider: "local",
      };
    }
  }
}
