/**
 * Task Fallback — Local heuristic task generation when Gemini is unavailable.
 *
 * Returns pre-defined tasks adapted to the user's energy level and language.
 * Must be preserved to ensure the app functions without network/API access.
 */

import type { GeneratedTask } from "../types/index.ts";

/**
 * Generates fallback tasks based on energy state, mood, and language.
 */
export function getLocalHeuristicTasks(
  nexiiState: number,
  mood: string,
  lang: string
): GeneratedTask[] {
  const isBas = (nexiiState ?? 50) < 50;
  const safeLang = lang || "fr";

  if (lang === "en") {
    return [
      {
        title: isBas
          ? "Cardiac Coherence Breathing (5 min)"
          : "Establish high-priority tasks",
        category: isBas ? "Zen" : "Pro",
        priority: "Medium",
        urgency: "Medium",
        difficulty: "Easy",
        energyNeeded: "Low",
        duration: "5 min",
        subtasks: [
          "Sit comfortably with eyes closed",
          "Inhale 4s, hold 4s, exhale 4s",
        ],
      },
      {
        title: "Track today's primary expenses",
        category: "Finance",
        priority: "Low",
        urgency: "Low",
        difficulty: "Easy",
        energyNeeded: "Low",
        duration: "10 min",
        subtasks: [
          "List your last 2 active purchases",
          "Check balance to prevent financial fatigue",
        ],
      },
      {
        title: isBas
          ? "Relaxing stretching break"
          : "Clear workspace of distractions",
        category: "Perso",
        priority: "Medium",
        urgency: "Low",
        difficulty: "Easy",
        energyNeeded: "Low",
        duration: "10 min",
        subtasks: [
          "Do soft shoulder rolls and neck stretches",
          "Drink 250ml of clean freshwater",
        ],
      },
    ];
  } else if (lang === "es") {
    return [
      {
        title: isBas
          ? "Respiración de coherencia cardíaca (5 min)"
          : "Establecer tareas prioritarias",
        category: isBas ? "Zen" : "Pro",
        priority: "Media",
        urgency: "Media",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "5 min",
        subtasks: [
          "Sentarse cómodamente con ojos cerrados",
          "Inhalar 4s, retener 4s, exhalar 4s",
        ],
      },
      {
        title: "Registrar los gastos principales de hoy",
        category: "Finance",
        priority: "Baja",
        urgency: "Baja",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "10 min",
        subtasks: [
          "Enumerar las últimas 2 compras activas",
          "Evitar fatiga financiera revisando saldos",
        ],
      },
      {
        title: isBas
          ? "Pausa de estiramientos relajantes"
          : "Limpiar escritorio de distracciones",
        category: "Perso",
        priority: "Media",
        urgency: "Baja",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "10 min",
        subtasks: [
          "Hacer estiramientos de cuello y hombros",
          "Beber un vaso de agua fresca limpia",
        ],
      },
    ];
  } else {
    // Default French
    return [
      {
        title: isBas
          ? "Cohérence cardiaque guidée (5 min)"
          : "Définir les priorités absolues",
        category: isBas ? "Zen" : "Pro",
        priority: "Moyenne",
        urgency: "Moyenne",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "5 min",
        subtasks: [
          "S'installer au calme les yeux fermés",
          "Inspirer sur 4s, bloquer 4s, expirer sur 4s",
        ],
      },
      {
        title: "Suivi des dépenses prioritaires du jour",
        category: "Finance",
        priority: "Basse",
        urgency: "Basse",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "10 min",
        subtasks: [
          "Lister les 2 derniers achats actifs",
          "Éviter la charge financière en faisant le point",
        ],
      },
      {
        title: isBas
          ? "Pause étirements de décompression"
          : "Désencombrer l'espace de travail",
        category: "Perso",
        priority: "Moyenne",
        urgency: "Basse",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "10 min",
        subtasks: [
          "Faire 5 étirements du cou et des épaules",
          "Boire un grand verre d'eau fraîche filtrée",
        ],
      },
    ];
  }
}
