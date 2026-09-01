/**
 * Nexii Express App — Middleware and CORS configuration.
 *
 * Creates and configures the Express application with:
 *   - CORS headers for Flutter mobile, web, and AI Studio preview
 *   - JSON body parsing
 *   - API routes mounted under /api
 *
 * This module exports the configured `app` without starting the server,
 * allowing server.ts to handle Vite middleware and listen().
 */

import express from "express";
import apiRouter from "./routes/index.ts";

const app = express();

// Enable CORS for external devices, Flutter Web and AI Studio preview
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept, Authorization"
  );
  res.header(
    "Access-Control-Allow-Methods",
    "GET, POST, OPTIONS, PUT, DELETE, PATCH"
  );
  if (req.method === "OPTIONS") {
    return res.sendStatus(200);
  }
  next();
});

app.use(express.json());

// Mount all API routes under /api
app.use("/api", apiRouter);

export default app;
