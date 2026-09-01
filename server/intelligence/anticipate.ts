import { IntelligenceRequest, IntelligenceResponse } from "../types/index.ts";

/**
 * AnticipateNode
 * - Produces near-term recommendations based on progress and pulse
 * - Input: progressContext, insights, pulse
 * - Output: recommended actions (e.g., reduce load, prioritize task X)
 */
export class AnticipateNode {
  static async process(req: IntelligenceRequest): Promise<IntelligenceResponse> {
    try {
      const payload = req.payload || {};
      const ctx = (payload.progressContext || {}) as Record<string, any>;
      const pulse = (payload.pulse || {}) as Record<string, any>;
      const insights = (payload.insights || {}) as Record<string, any>;

      const recommendations: Array<Record<string, unknown>> = [];

      // If high severity pulse -> recommend reducing today's load
      if (pulse.severity === "high") {
        recommendations.push({ action: "reduce_load", label: "Réduire la charge d'aujourd'hui", params: { percent: pulse.chargeReduction } });
      }

      // If improvement detected, recommend reinforcing behavior
      if (insights.summary === "improving") {
        recommendations.push({ action: "reinforce_focus", label: "Poursuivre les sessions Focus", params: {} });
      }

      // If no tasks, suggest creating a 1st task aligned to goal
      if (!ctx.totalTasks || Number(ctx.totalTasks) === 0) {
        recommendations.push({ action: "create_first_task", label: "Créer votre première tâche", params: { suggestedTitle: "Première tâche pour votre objectif" } });
      }

      return { nodeId: "anticipate", result: { recommendations }, provider: "local" };
    } catch (e) {
      return { nodeId: "anticipate", result: { error: String(e) }, provider: "local" };
    }
  }
}
