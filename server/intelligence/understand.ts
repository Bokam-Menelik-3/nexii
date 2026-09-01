import { IntelligenceRequest, IntelligenceResponse } from "../types/index.ts";

/**
 * UnderstandNode
 * - Consumes observations and progressContext
 * - Produces concise facts about what's changing and likely causes
 */
export class UnderstandNode {
  static async process(req: IntelligenceRequest): Promise<IntelligenceResponse> {
    try {
      const payload = req.payload || {};
      const observations = (payload.observations || {}) as Record<string, any>;
      const insights: Record<string, unknown> = {};

      const completionRate = Number(observations.completionRate ?? 0);
      const deltaCompletionRate = Number(observations.deltaCompletionRate ?? 0);
      const focusMinutes = Number(observations.focusMinutes ?? 0);
      const hasTasks = Boolean(observations.hasTasks);

      if (!hasTasks) {
        insights.summary = "no_tasks";
        insights.message = "Aucune tâche enregistrée cette semaine.";
      } else {
        const trend = deltaCompletionRate > 0.05 ? "improving" : deltaCompletionRate < -0.05 ? "declining" : "stable";
        insights.summary = trend;
        insights.completionRate = completionRate;
        insights.delta = deltaCompletionRate;
        if (focusMinutes >= 60 && deltaCompletionRate > 0) {
          insights.note = "focus_is_working";
        }
      }

      return {
        nodeId: "understand",
        result: insights,
        provider: "local",
      };
    } catch (e) {
      return {
        nodeId: "understand",
        result: { error: String(e) },
        provider: "local",
      };
    }
  }
}
