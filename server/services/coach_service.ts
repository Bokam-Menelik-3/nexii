/**
 * Coach Service — Business logic for the /api/coach endpoint.
 *
 * Handles Gemini prompt construction and response extraction.
 * Falls back to local heuristics when Gemini is unavailable or errors.
 */

import { getGeminiClient } from "./gemini_service.ts";
import { getLocalHeuristicResponse } from "../fallbacks/coach_fallback.ts";
import { ContextBuilder } from "./context_builder.ts";
import { orchestrateIntelligence } from "./intelligence_orchestrator.ts";
import type { CoachRequest, CoachResponse } from "../types/index.ts";

/**
 * Processes a coach request.
 * Returns Gemini-powered response when available, local heuristic otherwise.
 */
export async function handleCoachRequest(
  req: CoachRequest
): Promise<CoachResponse> {
  const {
    userMessage,
    nexiiState,
    budgetProgress = 0,
    completedTasksCount,
    totalTasksCount,
    contextMood,
    provider = "gemini",
    userAge,
    hasDoneCheckIn,
    checkInMood,
    checkInEnergy,
    checkInMotivation,
    checkInStress,
    checkInSleep,
    focusTimerMode,
    timerType,
  } = req;

  const client = getGeminiClient();

  // If provider is heuristic or if Gemini is not initialized, return rule-based advice
  if (provider === "local" || !client) {
    return {
      text: getLocalHeuristicResponse(
        userMessage,
        nexiiState,
        budgetProgress,
        completedTasksCount,
        totalTasksCount,
        contextMood,
        userAge
      ),
      provider: "local",
    };
  }

  try {
    let checkInContext = "";
    if (hasDoneCheckIn) {
      checkInContext = `
      L'utilisateur a fait son bilan aujourd'hui :
      - Humeur : ${checkInMood}/5
      - Énergie : ${checkInEnergy}/5
      - Motivation : ${checkInMotivation}/5
      - Niveau de stress : ${checkInStress}/5
      - Qualité du sommeil : ${checkInSleep}/5
      `;
    }
    
    const userContext = ContextBuilder.buildMinimalContext(req);

    // Orchestrate deterministic intelligence and include a compact summary in the prompt
    let intelligenceContext = {};
    try {
      intelligenceContext = await orchestrateIntelligence(req);
    } catch (e) {
      // swallow errors from intelligence orchestrator to keep coach flow resilient
      console.error('Intelligence orchestrator error:', e);
      intelligenceContext = {};
    }

    const prompt = `
      Tu es Nexii, un coach de vie IA doux, empathique, et axé sur la productivité équilibrée et la santé mentale.
      
      ${userContext}
      \n
      IntelligenceSummary: ${JSON.stringify(intelligenceContext)}
      - Mode actuel du minuteur : ${focusTimerMode || "Non défini"} (${timerType || "Pomodoro"})
      ${checkInContext}

      Instructions d'adaptation dynamique et personnalisation :
      1. Si l'utilisateur a complété son bilan quotidien, utilise ABSOLUMENT ces détails de bien-être (énergie, stress, sommeil) pour personnaliser tes conseils en profondeur.
      2. RECOMANDE activement un cycle d'étude ou de travail Pomodoro idéal selon ses métriques de bilan :
         - Si l'énergie est basse (< 3) ou si le stress est élevé (> 3) ou si le sommeil est mauvais (< 3) : Conseille d'utiliser le mode Pomodoro **Protection (15 min de focus, 5 min de pause)** ou **Fatigué (20 min de focus, 10 min de pause)** pour préserver la santé mentale et éviter le burn-out.
         - Si l'énergie et la motivation sont bonnes (>= 3) et le stress est modéré : Conseille le mode Pomodoro **Productif (25 min de focus, 5 min de pause)** ou **Flow (40 min de focus, 5 min de pause)** pour capitaliser sur cet élan.
      3. Offre des encouragements bienveillants et pragmatiques, sans jamais culpabiliser.
      4. ADAPTE SUBTILEMENT ton ton, ton langage et tes métaphores de sagesse selon l'âge de l'utilisateur :
         - Si l'utilisateur est un adolescent (<19 ans), privilégie des encouragements doux liés aux études, à l'école, à la créativité et à la construction saine de soi.
         - S'il s'agit d'un jeune adulte (19-25 ans), propose des réflexions sur les passions, les choix de carrière, les études supérieures et l'indépendance naissante.
         - S'il s'agit d'un adulte actif (26-45 ans), cible le stress de la vie professionnelle, l'équilibre vie pro/perso et la charge mentale du quotidien.
         - S'il s'agit d'un senior ou d'une personne expérimentée (>45 ans), oriente tes propos vers la sérénité profonde, le recul, la transmission de sagesse et la tranquillité de l'esprit.
      5. Rédige une réponse courte (2 à 4 phrases maximum), chaleureuse, amicale et constructive en français.
      
      IMPORTANT: Réponds TOUJOURS au format JSON strict avec la structure suivante :
      {
        "text": "Ta réponse textuelle à l'utilisateur.",
        "intent": {
          "action": "create_task",
          "title": "Titre de la tâche"
        } 
      }
      N'ajoute pas l'objet "intent" si aucune action (création de tâche, etc.) n'est pertinente.
      Renvoie UNIQUEMENT le JSON, sans bloc de code markdown.
      
      Message de l'utilisateur : "${userMessage}"
    `;

    const response = await client.models.generateContent({
      model: "gemini-3.6-flash",
      contents: prompt,
    });

    let replyText = "";
    let intent: Record<string, unknown> | undefined = undefined;

    if (response.text) {
      try {
        const parsed = JSON.parse(response.text.replace(/```json/g, '').replace(/```/g, '').trim());
        replyText = parsed.text || response.text;
        intent = parsed.intent;
      } catch (e) {
        replyText = response.text;
      }
    } else {
      replyText = getLocalHeuristicResponse(
        userMessage, nexiiState, budgetProgress, completedTasksCount, totalTasksCount, contextMood, userAge
      );
    }

    return { text: replyText, provider: "gemini", intent };
  } catch (error) {
    console.error("Gemini API error:", error);
    return {
      text: getLocalHeuristicResponse(
        userMessage,
        nexiiState,
        budgetProgress,
        completedTasksCount,
        totalTasksCount,
        contextMood,
        userAge
      ),
      provider: "local",
    };
  }
}
