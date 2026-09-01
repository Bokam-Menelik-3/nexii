import { CoachRequest } from '../types/index';

export class ContextBuilder {
  static buildMinimalContext(req: CoachRequest): string {
    const ageInfo = req.userAge ? `Âge: ${req.userAge} ans` : '';
    const stateInfo = `Énergie Mentale: ${req.nexiiState}/100`;
    const moodInfo = `Humeur: ${req.contextMood}`;
    const tasksInfo = `Tâches: ${req.completedTasksCount} / ${req.totalTasksCount} complétées`;

    return `
[Contexte Utilisateur Actuel]
${ageInfo}
${stateInfo}
${moodInfo}
${tasksInfo}
`.trim();
  }
}
