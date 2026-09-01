import { ContextBuilder } from '../services/context_builder';
import { orchestrateIntelligence } from '../services/intelligence_orchestrator';

async function main(){
  const req: any = {
    userMessage: 'How am I doing?',
    nexiiState: 80,
    completedTasksCount: 2,
    totalTasksCount: 5,
    contextMood: 'neutre',
    provider: 'gemini',
    userAge: 30,
    progressContext: {
      totalTasks: 5,
      completedTasks: 2,
      focusMinutes: 120,
      activeDays: 4,
      goalsCount: 2,
      tasksLinkedToGoals: 1,
    },
    focusTimerMode: 'Pomodoro',
    timerType: '25/5',
    hasDoneCheckIn: false,
  };

  const userContext = ContextBuilder.buildMinimalContext(req as any);
  const intelligenceContext = await orchestrateIntelligence(req as any);

  const prompt = `Tu es Nexii, un coach de vie IA doux, empathique, et axé sur la productivité équilibrée et la santé mentale.

${userContext}

IntelligenceSummary: ${JSON.stringify(intelligenceContext)}
- Mode actuel du minuteur : ${req.focusTimerMode || 'Non défini'} (${req.timerType || 'Pomodoro'})
Message de l'utilisateur : "${req.userMessage}"
`;

  console.log('---COMPOSED PROMPT---');
  console.log(prompt);
  console.log('---END PROMPT---');
}

main().catch((e)=>{ console.error(e); process.exit(1); });
