/**
 * Coach Route — POST /api/coach
 *
 * Thin route handler that delegates to the coach service.
 * No business logic here — just request/response plumbing.
 */

import { Router } from "express";
import { handleCoachRequest } from "../services/coach_service.ts";
import type { CoachRequest } from "../types/index.ts";

const router = Router();

router.post("/", async (req, res) => {
  try {
    const coachReq: CoachRequest = {
      userMessage: req.body.userMessage,
      nexiiState: req.body.nexiiState,
      budgetProgress: req.body.budgetProgress,
      completedTasksCount: req.body.completedTasksCount,
      totalTasksCount: req.body.totalTasksCount,
      progressContext: req.body.progressContext,
      contextMood: req.body.contextMood,
      provider: req.body.provider,
      userAge: req.body.userAge,
      hasDoneCheckIn: req.body.hasDoneCheckIn,
      checkInMood: req.body.checkInMood,
      checkInEnergy: req.body.checkInEnergy,
      checkInMotivation: req.body.checkInMotivation,
      checkInStress: req.body.checkInStress,
      checkInSleep: req.body.checkInSleep,
      focusTimerMode: req.body.focusTimerMode,
      timerType: req.body.timerType,
    };

    const result = await handleCoachRequest(coachReq);
    return res.json(result);
  } catch (error) {
    console.error("Coach route error:", error);
    return res.status(500).json({ text: "Une erreur interne est survenue.", provider: "local" });
  }
});

export default router;
