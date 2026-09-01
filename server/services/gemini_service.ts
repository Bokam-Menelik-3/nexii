/**
 * Gemini Service — Isolated AI client management.
 *
 * Single responsibility: initialize and provide the GoogleGenAI client.
 * API key stays server-side only (from process.env.GEMINI_API_KEY).
 */

import { GoogleGenAI } from "@google/genai";

let aiClient: GoogleGenAI | null = null;

/**
 * Returns a cached GoogleGenAI client, or null if the API key is not configured.
 * Thread-safe singleton pattern — only one client is ever created.
 */
export function getGeminiClient(): GoogleGenAI | null {
  if (!aiClient && process.env.GEMINI_API_KEY) {
    try {
      aiClient = new GoogleGenAI({
        apiKey: process.env.GEMINI_API_KEY,
        httpOptions: {
          headers: {
            "User-Agent": "aistudio-build",
          },
        },
      });
    } catch (e) {
      console.error("Failed to initialize Gemini Client:", e);
    }
  }
  return aiClient;
}

/**
 * Reset the cached client (useful for testing).
 */
export function resetGeminiClient(): void {
  aiClient = null;
}
