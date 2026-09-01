import { IntelligenceRequest, IntelligenceResponse } from "../types/index.ts";

/**
 * AuraNode
 * - Computes a simplified aura score from progressContext (0-100)
 * - Input: progressContext
 * - Output: aura score and category
 */
export class AuraNode {
  static async process(req: IntelligenceRequest): Promise<IntelligenceResponse> {
    try {
      const ctx = (req.payload?.progressContext || {}) as Record<string, any>;
      const completionRate = Number(ctx.totalTasks) > 0 ? Number(ctx.completedTasks) / Number(ctx.totalTasks) : 0;
      const focusMinutes = Number(ctx.focusMinutes ?? 0);
      const activeDays = Number(ctx.activeDays ?? 0);

      // Weighted simple formula
      const score = Math.round(
        Math.min(
          100,
          (completionRate * 60) + Math.min(30, (focusMinutes / 60) * 30) + Math.min(10, activeDays)
        )
      );

      const category = score >= 75 ? "high" : score >= 50 ? "medium" : "low";

      return { nodeId: "aura", result: { score, category }, provider: "local" };
    } catch (e) {
      return { nodeId: "aura", result: { error: String(e) }, provider: "local" };
    }
  }
}
