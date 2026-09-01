import { IntelligenceRequest, IntelligenceResponse } from "../types/index.ts";

/**
 * RecommendNode
 * - Aggregates anticipate + understand to emit a short action plan
 * - Input: progressContext, insights, recommendations (from anticipate)
 * - Output: prioritized small list of actions with reasons
 */
export class RecommendNode {
  static async process(req: IntelligenceRequest): Promise<IntelligenceResponse> {
    try {
      const payload = req.payload || {};
      const recs = (payload.recommendations || []) as Array<any>;
      const insights = (payload.insights || {}) as Record<string, any>;

      // prioritize: reduce_load > create_first_task > reinforce_focus
      const prioritized: Array<Record<string, unknown>> = [];
      for (const r of recs) {
        if (r.action === "reduce_load") prioritized.unshift(r);
        else prioritized.push(r);
      }

      // attach short rationale
      const actions = prioritized.map((r) => ({ ...r, reason: r.action === "reduce_load" ? "Surcharge détectée" : insights.summary || "amélioration détectée" }));

      return { nodeId: "recommend", result: { actions }, provider: "local" };
    } catch (e) {
      return { nodeId: "recommend", result: { error: String(e) }, provider: "local" };
    }
  }
}
