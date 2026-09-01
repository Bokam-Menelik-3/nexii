/**
 * Tasks Route — POST /api/tasks/generate
 *
 * Thin route handler that delegates to the task service.
 * No business logic here — just request/response plumbing.
 */

import { Router } from "express";
import { handleGenerateTasksRequest } from "../services/task_service.ts";
import type { GenerateTasksRequest } from "../types/index.ts";

const router = Router();

router.post("/generate", async (req, res) => {
  try {
    const taskReq: GenerateTasksRequest = {
      nexiiState: req.body.nexiiState,
      mood: req.body.mood,
      lang: req.body.lang,
      userAge: req.body.userAge,
    };

    const result = await handleGenerateTasksRequest(taskReq);
    return res.json(result);
  } catch (error) {
    console.error("Tasks route error:", error);
    return res.status(500).json({ tasks: [] });
  }
});

export default router;
