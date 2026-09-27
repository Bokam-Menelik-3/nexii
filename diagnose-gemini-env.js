#!/usr/bin/env node
/**
 * Diagnostic temporaire UNIQUEMENT pour vérifier le runtime GEMINI_API_KEY
 * Ce fichier sera supprimé après diagnostic
 */

import dotenv from "dotenv";

// Simule exactement ce que server.ts fait à la ligne 7
dotenv.config();

// Vérifie si la clé est maintenant disponible
const hasKey = process.env.GEMINI_API_KEY !== undefined && process.env.GEMINI_API_KEY !== "";

console.log("\n=== GEMINI RUNTIME CHECK ===\n");
console.log(`GEMINI_API_KEY_RUNTIME=${hasKey ? "PRESENT" : "MISSING"}`);

// Simule aussi le getGeminiClient() check
if (hasKey) {
  console.log(`getGeminiClient_can_init=YES`);
} else {
  console.log(`getGeminiClient_can_init=NO`);
}

console.log("\n=== FILE CHECKS ===\n");
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.join(__dirname, ".env");
const envExists = fs.existsSync(envPath);
console.log(`file_.env=${envExists ? "EXISTS" : "NOT_FOUND"}`);

if (envExists) {
  const envContent = fs.readFileSync(envPath, "utf-8");
  const hasGeminiLine = envContent.includes("GEMINI_API_KEY");
  console.log(`GEMINI_API_KEY_in_.env=${hasGeminiLine ? "YES" : "NO"}`);
}

console.log("\n=== EXECUTION ORDER ===\n");
console.log("dotenv_load_order=OK");
console.log(`(dotenv.config() called BEFORE accessing process.env.GEMINI_API_KEY)\n`);
