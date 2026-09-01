import { IntelligenceRequest, IntelligenceResponse } from "../types/index.ts";

/**
 * PulseNode
 * - Detects overload or opportunities to reduce friction.
 * - Input: progressContext and insights
 * - Output: pulse object with severity, recommended chargeReduction, reasons
 */
export class PulseNode {
  static async process(req: IntelligenceRequest): Promise<IntelligenceResponse> {
    const payload = req.payload || {};
    const ctx = (payload.progressContext || {}) as Record<string, any>;
    const insights = (payload.insights || {}) as Record<string, any>;

    try {
      const focused = Number(ctx.focusMinutes ?? 0);
      const activeDays = Number(ctx.activeDays ?? 0);
      const completionRate = Number(ctx.completedTasks ?? 0) / Math.max(1, Number(ctx.totalTasks ?? 0));

      let severity: "low" | "moderate" | "high" = "low";
      const reasons: string[] = [];
      let chargeReduction = 0; // percent

      if (activeDays === 0) {
        severity = "low";
        reasons.push("no_activity");
      } else {
        if (completionRate < 0.25) {
          severity = "high";
          reasons.push("low_completion_rate");
          chargeReduction = 40;
        } else if (completionRate < 0.5) {
          severity = "moderate";
          reasons.push("moderate_completion_rate");
          chargeReduction = 25;
        }

        if (focused < 30 && completionRate < 0.5) {
          reasons.push("low_focus_low_completion");
        }
      }

      // Positive pulse: if improving significantly
      if ((insights?.summary as string) === "improving") {
        reasons.push("improvement_detected");
        if (severity === "low") chargeReduction = 0;
      }

      const pulse = {
        severity,
        chargeReduction,
        reasons,
        detectedAt: new Date().toISOString(),
      };

      return { nodeId: "pulse", result: pulse, provider: "local" };
    } catch (e) {
      return { nodeId: "pulse", result: { error: String(e) }, provider: "local" };
    }
  }
}
