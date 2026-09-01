/**
 * Intelligence Route — POST /api/intelligence
 *
 * Placeholder route for the Intelligence Engine (Step 5).
 * Currently returns 501 Not Implemented for any request.
 * Will be activated when intelligence nodes are implemented.
 */

import { Router } from "express";
import {
  processIntelligenceRequest,
  getRegisteredNodes,
} from "../services/intelligence/index.ts";
import type { IntelligenceRequest } from "../types/index.ts";

const router = Router();

/**
 * GET /api/intelligence/nodes — List registered intelligence nodes.
 */
router.get("/nodes", (_req, res) => {
  return res.json({ nodes: getRegisteredNodes() });
});

/**
 * POST /api/intelligence — Process an intelligence request.
 */
router.post("/", async (req, res) => {
  const intelligenceReq: IntelligenceRequest = {
    nodeId: req.body.nodeId,
    userId: req.body.userId,
    payload: req.body.payload || {},
  };

  if (!intelligenceReq.nodeId) {
    return res.status(400).json({ error: "nodeId is required" });
  }

  const result = await processIntelligenceRequest(intelligenceReq);

  if (!result) {
    return res.status(501).json({
      error: `Intelligence node '${intelligenceReq.nodeId}' is not yet implemented`,
      availableNodes: getRegisteredNodes(),
    });
  }

  return res.json(result);
});

export default router;
