/**
 * Shared TypeScript types for Nexii Backend.
 *
 * These types mirror the JSON contracts expected by the Flutter client
 * (NexiiApiClient, CoachApiResponse, GenerateTasksApiResponse, Task).
 * Do NOT change field names without updating the Flutter side.
 */

// ─── Coach ───────────────────────────────────────────────────────────

export interface CoachRequest {
  userMessage: string;
  nexiiState: number;
  budgetProgress?: number;
  completedTasksCount: number;
  totalTasksCount: number;
  contextMood: string;
  provider?: "gemini" | "local";
  userAge?: number | null;
  progressContext?: Record<string, unknown>;
  hasDoneCheckIn?: boolean;
  checkInMood?: number;
  checkInEnergy?: number;
  checkInMotivation?: number;
  checkInStress?: number;
  checkInSleep?: number;
  focusTimerMode?: string;
  timerType?: string;
}

export interface CoachResponse {
  text: string;
  provider: "gemini" | "local";
  intent?: Record<string, unknown>;
}

// ─── Task Generation ─────────────────────────────────────────────────

export interface GenerateTasksRequest {
  nexiiState: number;
  mood: string;
  lang?: string;
  userAge?: number | null;
}

export interface GeneratedTask {
  title: string;
  category: string;
  priority: string;
  urgency: string;
  difficulty: string;
  energyNeeded: string;
  duration: string;
  subtasks: string[];
}

export interface GenerateTasksResponse {
  tasks: GeneratedTask[];
}

// ─── Intelligence Engine (Step 5 placeholder) ────────────────────────

/**
 * Base interface for intelligence node requests.
 * Each intelligence node (Comprend, Anticipe, Apprend, Optimise, Digital Twin)
 * will extend this with its own fields when implemented in Step 5.
 */
export interface IntelligenceRequest {
  nodeId: string;
  userId?: string;
  payload: Record<string, unknown>;
}

export interface IntelligenceResponse {
  nodeId: string;
  result: Record<string, unknown>;
  provider: "gemini" | "local";
}
