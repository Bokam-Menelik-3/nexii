/**
 * Task Service — Business logic for the /api/tasks/generate endpoint.
 *
 * Handles Gemini prompt construction for task generation and response parsing.
 * Falls back to local heuristic tasks when Gemini is unavailable or errors.
 */

import { getGeminiClient } from "./gemini_service.ts";
import { getLocalHeuristicTasks } from "../fallbacks/task_fallback.ts";
import type {
  GenerateTasksRequest,
  GenerateTasksResponse,
  GeneratedTask,
} from "../types/index.ts";

/**
 * Processes a task generation request.
 * Returns Gemini-generated tasks when available, local heuristic tasks otherwise.
 */
export async function handleGenerateTasksRequest(
  req: GenerateTasksRequest
): Promise<GenerateTasksResponse> {
  const { nexiiState, mood, lang = "fr", userAge } = req;

  const client = getGeminiClient();
  if (!client) {
    return { tasks: getLocalHeuristicTasks(nexiiState, mood, lang) };
  }

  try {
    const prompt = `
      Génère exactement 3 tâches de vie personnalisées et pertinentes sous forme d'un tableau JSON.
      Chaque tâche doit aider l'utilisateur à équilibrer sa productivité et sa santé mentale de manière constructive.
      
      Informations d'état actuelles de l'utilisateur :
      - Niveau d'énergie / Wellness score : ${nexiiState}%
      - Humeur déclarée : ${mood}
      - Âge de l'utilisateur : ${userAge ? `${userAge} ans` : "Non spécifié"}
      - Langue de réponse demandée : ${lang || "fr"} (les textes doivent être rédigés entièrement dans cette langue, qu'il s'agisse de 'fr' (français), 'en' (anglais) ou 'es' (espagnol))
      
      Règles pour les tâches générées :
      1. Si le niveau d'énergie est bas (< 50%), suggère des tâches douces de la catégorie "Zen" ou "Perso", de difficulté "Facile" et avec une énergie requise "Bas". Exemple: respiration guidée, marche de 5 min.
      2. Si le niveau d'énergie est élevé (>= 75%), propose des tâches plus engageantes de la catégorie "Pro" ou "Finance". Exemple: bilan des tâches en cours, planification financière active.
      3. Chaque tâche doit comporter exactement :
         - "title": Titre court et engageant.
         - "category": Uniquement parmi "Pro", "Perso", "Zen", "Finance".
         - "priority": Uniquement parmi "Haute", "Moyenne", "Basse".
         - "urgency": Uniquement parmi "Haute", "Moyenne", "Basse".
         - "difficulty": Uniquement parmi "Facile", "Moyen", "Difficile".
         - "energyNeeded": Uniquement parmi "Bas", "Moyen", "Élevé".
         - "duration": Durée estimée (ex: "15 min", "45 min", "1 h").
         - "subtasks": Un tableau de exactement 2 sous-tâches concrètes (chaque élément étant un texte court de moins de 60 caractères).

      Retourne UNIQUEMENT le code JSON brut, sans mise en forme markdown (pas de blocs \`\`\`json), juste un tableau d'objets conforme à ce format :
      [
        {
          "title": "Titre",
          "category": "Zen",
          "priority": "Moyenne",
          "urgency": "Basse",
          "difficulty": "Facile",
          "energyNeeded": "Bas",
          "duration": "10 min",
          "subtasks": ["Sous-tâche 1", "Sous-tâche 2"]
        }
      ]
    `;

    const response = await client.models.generateContent({
      model: "gemini-3.6-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
      },
    });

    const text = response.text;
    if (text) {
      try {
        const parsed = JSON.parse(text.trim());
        if (Array.isArray(parsed)) {
          return { tasks: parsed as GeneratedTask[] };
        }
      } catch (err) {
        console.error("Failed to parse Gemini tasks output:", text, err);
      }
    }

    return { tasks: getLocalHeuristicTasks(nexiiState, mood, lang) };
  } catch (error) {
    console.error("Gemini task generation error:", error);
    return { tasks: getLocalHeuristicTasks(nexiiState, mood, lang) };
  }
}
