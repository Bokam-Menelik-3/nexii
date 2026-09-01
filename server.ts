/**
 * Nexii Server Entry Point
 *
 * This file is now the thin entry point that:
 *   1. Loads environment variables
 *   2. Imports the configured Express app (with routes, CORS, etc.)
 *   3. Sets up Vite middleware in development
 *   4. Starts the HTTP server
 *
 * All business logic, routes, services, and fallbacks live in server/ modules.
 */

import path from "path";
import { createServer as createViteServer } from "vite";
import dotenv from "dotenv";
import app from "./server/app.ts";

dotenv.config();

const PORT = 3000;

// Vite middleware for development
async function startServer() {
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    const express = await import("express");
    app.use(express.default.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

startServer();
