import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI } from "@google/genai";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(express.json());

const PORT = 3000;

// Initialize Gemini Client
let ai: GoogleGenAI | null = null;
try {
  if (process.env.GEMINI_API_KEY) {
    ai = new GoogleGenAI({
      apiKey: process.env.GEMINI_API_KEY,
      httpOptions: {
        headers: {
          'User-Agent': 'aistudio-build',
        }
      }
    });
  }
} catch (e) {
  console.error("Failed to initialize Gemini Client:", e);
}

// API Routes
app.post("/api/coach", async (req, res) => {
  const { 
    userMessage, 
    nexiiState, 
    budgetProgress, 
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
    timerType
  } = req.body;

  // If provider is heuristic or if Gemini is not initialized, return high-fidelity rule-based advice
  if (provider === "local" || !ai) {
    return res.json({ 
      text: getLocalHeuristicResponse(userMessage, nexiiState, budgetProgress, completedTasksCount, totalTasksCount, contextMood, userAge),
      provider: "local"
    });
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

    const prompt = `
      Tu es Nexii, un coach de vie IA doux, empathique, et axé sur la productivité équilibrée et la santé mentale.
      
      Informations d'état actuelles de l'utilisateur :
      - Nexii State (Indice de bien-être actuel / Aura) : ${nexiiState}% (Surcharge si < 30%, Fatigué si < 60%, Productif si < 80%, Flow State si >= 80%)
      - Taux d'accomplissement des tâches : ${completedTasksCount}/${totalTasksCount}
      - Progression du budget : ${budgetProgress}% dépensé.
      - Humeur générale : ${contextMood}
      - Mode actuel du minuteur : ${focusTimerMode || 'Non défini'} (${timerType || 'Pomodoro'})
      - Âge de l'utilisateur : ${userAge ? `${userAge} ans` : 'Non spécifié'}
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
      
      Message de l'utilisateur : "${userMessage}"
    `;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
    });

    const reply = response.text || getLocalHeuristicResponse(userMessage, nexiiState, budgetProgress, completedTasksCount, totalTasksCount, contextMood, userAge);
    return res.json({ text: reply, provider: "gemini" });
  } catch (error) {
    console.error("Gemini API error:", error);
    return res.json({ 
      text: getLocalHeuristicResponse(userMessage, nexiiState, budgetProgress, completedTasksCount, totalTasksCount, contextMood, userAge),
      provider: "local"
    });
  }
});


// API Route for AI task recommendations based on user's current states
app.post("/api/tasks/generate", async (req, res) => {
  const { nexiiState, mood, lang, userAge } = req.body;

  if (!ai) {
    return res.json({ tasks: getLocalHeuristicTasks(nexiiState, mood, lang) });
  }

  try {
    const prompt = `
      Génère exactement 3 tâches de vie personnalisées et pertinentes sous forme d'un tableau JSON.
      Chaque tâche doit aider l'utilisateur à équilibrer sa productivité et sa santé mentale de manière constructive.
      
      Informations d'état actuelles de l'utilisateur :
      - Niveau d'énergie / Wellness score : ${nexiiState}%
      - Humeur déclarée : ${mood}
      - Âge de l'utilisateur : ${userAge ? `${userAge} ans` : 'Non spécifié'}
      - Langue de réponse demandée : ${lang || 'fr'} (les textes doivent être rédigés entièrement dans cette langue, qu'il s'agisse de 'fr' (français), 'en' (anglais) ou 'es' (espagnol))
      
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

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
      }
    });

    const text = response.text;
    if (text) {
      try {
        const parsed = JSON.parse(text.trim());
        if (Array.isArray(parsed)) {
          return res.json({ tasks: parsed });
        }
      } catch (err) {
        console.error("Failed to parse Gemini tasks output:", text, err);
      }
    }
    
    return res.json({ tasks: getLocalHeuristicTasks(nexiiState, mood, lang) });
  } catch (error) {
    console.error("Gemini task generation error:", error);
    return res.json({ tasks: getLocalHeuristicTasks(nexiiState, mood, lang) });
  }
});


// Helper for local heuristic tasks fallback
function getLocalHeuristicTasks(nexiiState: number, mood: string, lang: string): any[] {
  const isBas = nexiiState < 50;
  
  if (lang === 'en') {
    return [
      {
        title: isBas ? "Cardiac Coherence Breathing (5 min)" : "Establish high-priority tasks",
        category: isBas ? "Zen" : "Pro",
        priority: "Medium",
        urgency: "Medium",
        difficulty: "Easy",
        energyNeeded: "Low",
        duration: "5 min",
        subtasks: ["Sit comfortably with eyes closed", "Inhale 4s, hold 4s, exhale 4s"]
      },
      {
        title: "Track today's primary expenses",
        category: "Finance",
        priority: "Low",
        urgency: "Low",
        difficulty: "Easy",
        energyNeeded: "Low",
        duration: "10 min",
        subtasks: ["List your last 2 active purchases", "Check balance to prevent financial fatigue"]
      },
      {
        title: isBas ? "Relaxing stretching break" : "Clear workspace of distractions",
        category: "Perso",
        priority: "Medium",
        urgency: "Low",
        difficulty: "Easy",
        energyNeeded: "Low",
        duration: "10 min",
        subtasks: ["Do soft shoulder rolls and neck stretches", "Drink 250ml of clean freshwater"]
      }
    ];
  } else if (lang === 'es') {
    return [
      {
        title: isBas ? "Respiración de coherencia cardíaca (5 min)" : "Establecer tareas prioritarias",
        category: isBas ? "Zen" : "Pro",
        priority: "Media",
        urgency: "Media",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "5 min",
        subtasks: ["Sentarse cómodamente con ojos cerrados", "Inhalar 4s, retener 4s, exhalar 4s"]
      },
      {
        title: "Registrar los gastos principales de hoy",
        category: "Finance",
        priority: "Baja",
        urgency: "Baja",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "10 min",
        subtasks: ["Enumerar las últimas 2 compras activas", "Evitar fatiga financiera revisando saldos"]
      },
      {
        title: isBas ? "Pausa de estiramientos relajantes" : "Limpiar escritorio de distracciones",
        category: "Perso",
        priority: "Media",
        urgency: "Baja",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "10 min",
        subtasks: ["Hacer estiramientos de cuello y hombros", "Beber un vaso de agua fresca limpia"]
      }
    ];
  } else {
    // Default French
    return [
      {
        title: isBas ? "Cohérence cardiaque guidée (5 min)" : "Définir les priorités absolues",
        category: isBas ? "Zen" : "Pro",
        priority: "Moyenne",
        urgency: "Moyenne",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "5 min",
        subtasks: ["S'installer au calme les yeux fermés", "Inspirer sur 4s, bloquer 4s, expirer sur 4s"]
      },
      {
        title: "Suivi des dépenses prioritaires du jour",
        category: "Finance",
        priority: "Basse",
        urgency: "Basse",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "10 min",
        subtasks: ["Lister les 2 derniers achats actifs", "Éviter la charge financière en faisant le point"]
      },
      {
        title: isBas ? "Pause étirements de décompression" : "Désencombrer l'espace de travail",
        category: "Perso",
        priority: "Moyenne",
        urgency: "Basse",
        difficulty: "Facile",
        energyNeeded: "Bas",
        duration: "10 min",
        subtasks: ["Faire 5 étirements du cou et des épaules", "Boire un grand verre d'eau fraîche filtrée"]
      }
    ];
  }
}



// Helper for local heuristic fallback
function getLocalHeuristicResponse(
  msg: string, 
  nexiiState: number, 
  budgetProgress: number, 
  completedTasks: number, 
  totalTasks: number, 
  mood: string,
  userAge?: number | null
): string {
  const cleanMsg = msg.toLowerCase();
  
  let ageAdvice = "";
  if (userAge) {
    if (userAge <= 18) {
      ageAdvice = " Prenez soin de vous à l'école et gardez du temps pour jouer et explorer ! 🎒";
    } else if (userAge <= 25) {
      ageAdvice = " C'est le moment idéal pour poser vos fondations et dessiner vos rêves d'avenir avec sérénité ! 🎓";
    } else if (userAge <= 45) {
      ageAdvice = " Rappelez-vous que votre réussite professionnelle ne doit jamais se faire au détriment de votre santé mentale. 💼";
    } else {
      ageAdvice = " Votre riche parcours est une force ; savourez chaque instant avec calme et bienveillance. 🧘";
    }
  }

  if (nexiiState < 35) {
    return "ATTENTION SURCHARGE : Votre niveau de fatigue est très élevé. Je vous conseille vivement d'alléger vos tâches du jour. Que diriez-vous de réduire votre prochaine session Focus à 15 minutes de travail suivies de 15 minutes de repos ?" + ageAdvice;
  }
  
  if (cleanMsg.includes('stress') || cleanMsg.includes('anxi') || cleanMsg.includes('peur') || cleanMsg.includes('angoiss')) {
    return "Je ressens de l'anxiété. Fermons les yeux un court instant. Prenons une inspiration calme ensemble sur 4 secondes... bloquez 4 secondes... et expirez lentement sur 4 secondes. Ressentez-vous la tension s'apaiser ?" + ageAdvice;
  }
  
  if (cleanMsg.includes('fatig') || cleanMsg.includes('crev') || cleanMsg.includes('sommeil') || cleanMsg.includes('épuis')) {
    return "Votre corps vous envoie un signal précieux. Accordez-vous une pause obligatoire sans écrans de 5 minutes. Allez boire un verre d'eau fraîche ou étirez votre dos doucement." + ageAdvice;
  }
  
  if (cleanMsg.includes('budget') || cleanMsg.includes('dépens') || cleanMsg.includes('argent') || cleanMsg.includes('finan')) {
    if (budgetProgress > 80) {
      return `Alerte Budget ! Votre stress financier est élevé (${budgetProgress.toFixed(0)}% dépensé). Faisons l'impasse sur les achats superflus aujourd'hui pour retrouver de la sérénité.` + ageAdvice;
    }
    return "Maîtriser son budget est essentiel pour l'esprit libre. Rappelez-vous que chaque petit choix conscient aujourd'hui protège votre liberté financière de demain." + ageAdvice;
  }

  if (cleanMsg.includes('bonjour') || cleanMsg.includes('salut') || cleanMsg.includes('hello')) {
    return "Bonjour Aventurier ! Comment se passe votre journée aujourd'hui ? Je suis là pour vous écouter et vous guider avec bienveillance." + ageAdvice;
  }

  if (cleanMsg.includes('merci') || cleanMsg.includes('cool') || cleanMsg.includes('génial')) {
    return "C'est un réel plaisir d'être à vos côtés. Prenez soin de vous, un pas à la fois. Vous faites un travail formidable pour votre équilibre !" + ageAdvice;
  }

  return `J'ai bien reçu votre message. Votre Nexii State est de ${nexiiState.toFixed(0)}% (${mood}). Travaillons ensemble pas à pas aujourd'hui.` + ageAdvice;
}

// Vite middleware for development
async function startServer() {
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    app.get('*', (req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

startServer();
