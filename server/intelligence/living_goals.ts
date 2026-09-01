import { IntelligenceRequest, IntelligenceResponse } from "../types/index.ts";

/**
 * LivingGoalsNode
 * - Summarizes user goals relevance and mapping to tasks
 * - Input: progressContext
 * - Output: counts and percent of goals with linked tasks
 */
export class LivingGoalsNode {
  static async process(req: IntelligenceRequest): Promise<IntelligenceResponse> {
    try {
      const payload = req.payload || {};
      const ctx = (payload.progressContext || {}) as Record<string, any>;
      const goalsCount = Number(ctx.goalsCount ?? 0);
      const tasksLinked = Number(ctx.tasksLinkedToGoals ?? 0);
      const pctLinked = goalsCount > 0 ? Math.min(1, tasksLinked / (goalsCount || 1)) : 0;

      return {
        nodeId: "living_goals",
        result: { goalsCount, tasksLinked, pctLinked },
        provider: "local",
      };
    } catch (e) {
      return { nodeId: "living_goals", result: { error: String(e) }, provider: "local" };
    }
  }
}
