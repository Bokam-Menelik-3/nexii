/**
 * Intelligence Engine — Placeholder for Step 5.
 *
 * This module will host the backend intelligence nodes:
 *   - Comprend (understand_service)
 *   - Anticipe (anticipate_service)
 *   - Apprend (learning_service)
 *   - Optimise (optimize_service)
 *   - Digital Twin (digital_twin_service)
 *
 * For now, it exports a no-op registry that future services will register into.
 * This ensures the architecture is ready without premature implementation.
 */

import type {
  IntelligenceRequest,
  IntelligenceResponse,
} from "../../types/index.ts";

/**
 * Registry of intelligence node handlers.
 * Each node ID maps to an async handler function.
 */
const nodeHandlers: Map<
  string,
  (req: IntelligenceRequest) => Promise<IntelligenceResponse>
> = new Map();

/**
 * Register an intelligence node handler.
 */
export function registerNode(
  nodeId: string,
  handler: (req: IntelligenceRequest) => Promise<IntelligenceResponse>
): void {
  nodeHandlers.set(nodeId, handler);
}

// Register core local nodes if present
// Static imports for core nodes. These files exist under server/intelligence.
import { ObserveNode } from "../../intelligence/observe";
import { UnderstandNode } from "../../intelligence/understand";
import { PulseNode } from "../../intelligence/pulse";
import { AnticipateNode } from "../../intelligence/anticipate";
import { LivingGoalsNode } from "../../intelligence/living_goals";
import { AuraNode } from "../../intelligence/aura";
import { RecommendNode } from "../../intelligence/recommend";
import { MeasureNode } from "../../intelligence/measure";

// Register if available
try {
  if (ObserveNode) registerNode("observe", ObserveNode.process);
} catch (_) {}
try {
  if (UnderstandNode) registerNode("understand", UnderstandNode.process);
} catch (_) {}
try {
  if (PulseNode) registerNode("pulse", PulseNode.process);
} catch (_) {}
try {
  if (AnticipateNode) registerNode("anticipate", AnticipateNode.process);
} catch (_) {}
try {
  if (LivingGoalsNode) registerNode("living_goals", LivingGoalsNode.process);
} catch (_) {}
try {
  if (AuraNode) registerNode("aura", AuraNode.process);
} catch (_) {}
try {
  if (RecommendNode) registerNode("recommend", RecommendNode.process);
} catch (_) {}
try {
  if (MeasureNode) registerNode("measure", MeasureNode.process);
} catch (_) {}

/**
 * Process an intelligence request by routing to the appropriate node handler.
 * Returns null if the node is not registered.
 */
export async function processIntelligenceRequest(
  req: IntelligenceRequest
): Promise<IntelligenceResponse | null> {
  const handler = nodeHandlers.get(req.nodeId);
  if (!handler) {
    return null;
  }
  return handler(req);
}

/**
 * Get list of registered node IDs.
 */
export function getRegisteredNodes(): string[] {
  return Array.from(nodeHandlers.keys());
}
