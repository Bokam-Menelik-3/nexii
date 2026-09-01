import { IntelligenceRequest, IntelligenceResponse } from "../types/index.ts";

/**
 * MeasureNode
 * - Produces compact measurement metrics from progressContext for reporting
 * - Input: progressContext
 * - Output: normalized metrics (numbers) and present flags
 */
export class MeasureNode {
  static async process(req: IntelligenceRequest): Promise<IntelligenceResponse> {
    try {
      const ctx = (req.payload?.progressContext || {}) as Record<string, any>;
      const totalTasks = Number(ctx.totalTasks ?? 0);
      const completedTasks = Number(ctx.completedTasks ?? 0);
      const completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0;
      const focusMinutes = Number(ctx.focusMinutes ?? 0);
      const activeDays = Number(ctx.activeDays ?? 0);

      const metrics = {
        totalTasks,
        completedTasks,
        completionRate: Math.round(completionRate * 100) / 100,
        focusMinutes,
        activeDays,
      };

      return { nodeId: "measure", result: metrics, provider: "local" };
    } catch (e) {
      return { nodeId: "measure", result: { error: String(e) }, provider: "local" };
    }
  }
}
