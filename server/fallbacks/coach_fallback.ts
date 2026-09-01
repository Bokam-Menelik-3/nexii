/**
 * Coach Fallback — Local heuristic responses when Gemini is unavailable.
 *
 * This module provides rule-based coaching responses that work entirely offline.
 * It must be preserved as-is to ensure the app functions without network/API access.
 */

/**
 * Generates a local heuristic coaching response based on user context.
 * Adapts tone by age group and detects keywords for stress, fatigue, budget, etc.
 */
export function getLocalHeuristicResponse(
  msg: string,
  nexiiState: number,
  budgetProgress: number,
  completedTasks: number,
  totalTasks: number,
  mood: string,
  userAge?: number | null
): string {
  const cleanMsg = (msg || "").toLowerCase();
  const safeNexiiState = nexiiState ?? 50;
  const safeBudgetProgress = budgetProgress ?? 0;
  const safeMood = mood || "";

  let ageAdvice = "";
  if (userAge) {
    if (userAge <= 18) {
      ageAdvice =
        " Prenez soin de vous à l'école et gardez du temps pour jouer et explorer ! 🎒";
    } else if (userAge <= 25) {
      ageAdvice =
        " C'est le moment idéal pour poser vos fondations et dessiner vos rêves d'avenir avec sérénité ! 🎓";
    } else if (userAge <= 45) {
      ageAdvice =
        " Rappelez-vous que votre réussite professionnelle ne doit jamais se faire au détriment de votre santé mentale. 💼";
    } else {
      ageAdvice =
        " Votre riche parcours est une force ; savourez chaque instant avec calme et bienveillance. 🧘";
    }
  }

  if (safeNexiiState < 35) {
    return (
      "ATTENTION SURCHARGE : Votre niveau de fatigue est très élevé. Je vous conseille vivement d'alléger vos tâches du jour. Que diriez-vous de réduire votre prochaine session Focus à 15 minutes de travail suivies de 15 minutes de repos ?" +
      ageAdvice
    );
  }

  if (
    cleanMsg.includes("stress") ||
    cleanMsg.includes("anxi") ||
    cleanMsg.includes("peur") ||
    cleanMsg.includes("angoiss")
  ) {
    return (
      "Je ressens de l'anxiété. Fermons les yeux un court instant. Prenons une inspiration calme ensemble sur 4 secondes... bloquez 4 secondes... et expirez lentement sur 4 secondes. Ressentez-vous la tension s'apaiser ?" +
      ageAdvice
    );
  }

  if (
    cleanMsg.includes("fatig") ||
    cleanMsg.includes("crev") ||
    cleanMsg.includes("sommeil") ||
    cleanMsg.includes("épuis")
  ) {
    return (
      "Votre corps vous envoie un signal précieux. Accordez-vous une pause obligatoire sans écrans de 5 minutes. Allez boire un verre d'eau fraîche ou étirez votre dos doucement." +
      ageAdvice
    );
  }

  if (
    cleanMsg.includes("budget") ||
    cleanMsg.includes("dépens") ||
    cleanMsg.includes("argent") ||
    cleanMsg.includes("finan")
  ) {
    if (safeBudgetProgress > 80) {
      return (
        `Alerte Budget ! Votre stress financier est élevé (${safeBudgetProgress.toFixed(0)}% dépensé). Faisons l'impasse sur les achats superflus aujourd'hui pour retrouver de la sérénité.` +
        ageAdvice
      );
    }
    return (
      "Maîtriser son budget est essentiel pour l'esprit libre. Rappelez-vous que chaque petit choix conscient aujourd'hui protège votre liberté financière de demain." +
      ageAdvice
    );
  }

  if (
    cleanMsg.includes("bonjour") ||
    cleanMsg.includes("salut") ||
    cleanMsg.includes("hello")
  ) {
    return (
      "Bonjour Aventurier ! Comment se passe votre journée aujourd'hui ? Je suis là pour vous écouter et vous guider avec bienveillance." +
      ageAdvice
    );
  }

  if (
    cleanMsg.includes("merci") ||
    cleanMsg.includes("cool") ||
    cleanMsg.includes("génial")
  ) {
    return (
      "C'est un réel plaisir d'être à vos côtés. Prenez soin de vous, un pas à la fois. Vous faites un travail formidable pour votre équilibre !" +
      ageAdvice
    );
  }

  return (
    `J'ai bien reçu votre message. Votre Nexii State est de ${safeNexiiState.toFixed(0)}% (${safeMood}). Travaillons ensemble pas à pas aujourd'hui.` +
    ageAdvice
  );
}
