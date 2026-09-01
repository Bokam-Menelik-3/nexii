/**
 * Minimal Intelligence Orchestrator for Coach
 * - Executes nodes in dependency order using the existing registry.
 * - Builds a compact intelligence context composed of successful node outputs.
 * - Resilient to node errors or missing nodes.
 */

import type { CoachRequest } from "../types/index.ts";
import type { IntelligenceResponse } from "../types/index.ts";
import {
  processIntelligenceRequest,
  getRegisteredNodes,
} from "./intelligence/index.ts";

type IntelligenceContext = Record<string, unknown>;

export async function orchestrateIntelligence(
  req: CoachRequest,
  options?: { simulateFailNodes?: string[] }
): Promise<IntelligenceContext> {
  const out: IntelligenceContext = {};

  const progressContext = (req as any).progressContext || {};

  const simulate = new Set(options?.simulateFailNodes || []);

  async function safeCall(nodeId: string, payload: Record<string, unknown>) {
    if (simulate.has(nodeId)) {
      // Simulate failure for testing
      return { nodeId, result: { error: 'simulated_failure' }, provider: 'local' } as IntelligenceResponse;
    }
    try {
      const resp = await processIntelligenceRequest({ nodeId, payload, userId: undefined });
      return resp as IntelligenceResponse | null;
    } catch (e) {
      return { nodeId, result: { error: String(e) }, provider: 'local' } as IntelligenceResponse;
    }
  }

  // Order: observe -> understand -> pulse -> anticipate -> recommend
  // Optionals: measure, aura, living_goals
  // 1) observe
  const observeResp = await safeCall("observe", { progressContext });
  if (observeResp && !('error' in (observeResp.result || {}))) {
    out.observations = observeResp.result;
  } else if (observeResp && observeResp.result?.error) {
    out.observations_error = observeResp.result.error;
  }

  // 2) understand
  const understandResp = await safeCall("understand", {
    progressContext,
    observations: out.observations || {},
  });
  if (understandResp && !('error' in (understandResp.result || {}))) {
    out.understanding = understandResp.result;
  } else if (understandResp && understandResp.result?.error) {
    out.understanding_error = understandResp.result.error;
  }

  // 3) pulse
  const pulseResp = await safeCall("pulse", {
    progressContext,
    observations: out.observations || {},
    insights: out.understanding || {},
  });
  if (pulseResp && !('error' in (pulseResp.result || {}))) {
    out.pulse = pulseResp.result;
  } else if (pulseResp && pulseResp.result?.error) {
    out.pulse_error = pulseResp.result.error;
  }

  // 4) anticipate
  const anticipateResp = await safeCall("anticipate", {
    progressContext,
    observations: out.observations || {},
    pulse: out.pulse || {},
    insights: out.understanding || {},
  });
  if (anticipateResp && !('error' in (anticipateResp.result || {}))) {
    out.anticipation = anticipateResp.result;
  } else if (anticipateResp && anticipateResp.result?.error) {
    out.anticipation_error = anticipateResp.result.error;
  }

  // 5) recommend (use anticipate + understanding + pulse)
  const recommendResp = await safeCall("recommend", {
    progressContext,
    insights: out.understanding || {},
    pulse: out.pulse || {},
    recommendations: (out.anticipation && (out.anticipation as any).recommendations) || [],
  });
  if (recommendResp && !('error' in (recommendResp.result || {}))) {
    out.recommendations = recommendResp.result;
  } else if (recommendResp && recommendResp.result?.error) {
    out.recommendations_error = recommendResp.result.error;
  }

  // Optionals
  const measureResp = await safeCall("measure", { progressContext });
  if (measureResp && !('error' in (measureResp.result || {}))) out.metrics = measureResp.result;
  if (measureResp && measureResp.result?.error) out.metrics_error = measureResp.result.error;

  const auraResp = await safeCall("aura", { progressContext });
  if (auraResp && !('error' in (auraResp.result || {}))) out.aura = auraResp.result;
  if (auraResp && auraResp.result?.error) out.aura_error = auraResp.result.error;

  const lgResp = await safeCall("living_goals", { progressContext });
  if (lgResp && !('error' in (lgResp.result || {}))) out.livingGoals = lgResp.result;
  if (lgResp && lgResp.result?.error) out.livingGoals_error = lgResp.result.error;

  // Keep output compact: remove empty objects
  Object.keys(out).forEach((k) => {
    const v = (out as any)[k];
    if (v == null) delete (out as any)[k];
  });

  return out;
}

export type { IntelligenceContext };
