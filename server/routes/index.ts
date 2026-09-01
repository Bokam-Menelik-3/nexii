/**
 * Route Aggregator — Mounts all API routes on the Express app.
 *
 * Central place to register routes. Adding new routes in future steps
 * only requires adding a line here.
 */

import { Router } from "express";
import coachRouter from "./coach.ts";
import tasksRouter from "./tasks.ts";
import intelligenceRouter from "./intelligence.ts";

const apiRouter = Router();

apiRouter.use("/coach", coachRouter);
apiRouter.use("/tasks", tasksRouter);
apiRouter.use("/intelligence", intelligenceRouter);

export default apiRouter;
