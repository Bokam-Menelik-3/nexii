import React, { useState, useEffect, useRef } from 'react';
import { 
  motion, 
  AnimatePresence 
} from 'motion/react';
import { 
  Home, 
  Award, 
  CheckSquare, 
  Timer, 
  Brain, 
  Wallet, 
  User, 
  Copy, 
  Check, 
  Globe, 
  Moon, 
  Sun, 
  Send, 
  Plus, 
  TrendingDown, 
  TrendingUp, 
  Folder, 
  FileCode, 
  ChevronRight, 
  Sparkles, 
  Volume2,
  Clock,
  Wifi,
  Battery,
  Layers,
  HelpCircle,
  FileText,
  Play,
  Pause,
  RotateCcw,
  BookOpen,
  Bell,
  Trash2,
  MapPin,
  Gift,
  Cake,
  Flame,
  Star
} from 'lucide-react';
import { FLUTTER_FILES, FlutterFile } from './data/flutter_files';
import confetti from 'canvas-confetti';

// Translation Dictionaries
interface TranslationSet {
  app_name: string;
  welcome_back: string;
  calm_message: string;
  tab_home: string;
  tab_missions: string;
  tab_tasks: string;
  tab_focus: string;
  tab_coach: string;
  tab_budget: string;
  tab_profile: string;
  settings_theme: string;
  settings_lang: string;
  missions_title: string;
  tasks_title: string;
  focus_title: string;
  coach_title: string;
  budget_title: string;
  profile_title: string;
  level_badge: string;
  joined_date: string;
  sound_picker: string;
  start_timer: string;
  pause_timer: string;
  add_task: string;
  placeholder_add_task: string;
  placeholder_chat: string;
  aura_title: string;
  aura_desc: string;
  quick_view: string;
  remain_budget: string;
  budget_total: string;
  spent_amount: string;
  recent_trans: string;
  mood_title: string;
  daily_tasks: string;
  all_completed: string;
  recommended_focus: string;
  start_action: string;
  overall_progress: string;
  claim_xp: string;
  reward_claimed: string;
  cat_label: string;
  prio_label: string;
  difficulty_easy: string;
  difficulty_medium: string;
  difficulty_hard: string;
  category_daily: string;
  category_weekly: string;
  category_special: string;
  financial_stress: string;
  stress_index: string;
  savings_target: string;
  activity_streak: string;
  streak_desc: string;
  active_state: string;
  recovery_action: string;
  reduce_pomodoro: string;
  recover_5m: string;
  validate_day: string;
  already_validated: string;
  agenda_title: string;
  add_event: string;
  placeholder_event: string;
  time_label: string;
  no_events: string;
  stats_title: string;
  focus_hours: string;
  challenges_completed: string;
  success_rate: string;
  cardiac_coherence_short: string;
  device_options: string;
  onboarding_title: string;
  onboarding_desc: string;
  onboarding_name_label: string;
  onboarding_birthdate_label: string;
  onboarding_submit: string;
  edit_profile_btn: string;
  edit_profile_title: string;
  save_profile_btn: string;
  cancel_btn: string;
  system_notifications_title: string;
  system_notifications_desc: string;
  system_notifications_btn_enable: string;
  system_notifications_btn_enabled: string;
}

const TRANSLATIONS: Record<string, TranslationSet> = {
  fr: {
    app_name: "Nexii",
    welcome_back: "Bonjour, Aventurier",
    calm_message: "Prenez une grande inspiration. Tout est sous contrôle.",
    tab_home: "Accueil",
    tab_missions: "Missions",
    tab_tasks: "Tâches",
    tab_focus: "Focus",
    tab_coach: "Coach",
    tab_budget: "Budget",
    tab_profile: "Profil",
    settings_theme: "Thème Sombre",
    settings_lang: "Langue",
    missions_title: "Vos Défis Quotidiens",
    tasks_title: "Liste des Tâches",
    focus_title: "Espace Focus",
    coach_title: "Coach de Vie",
    budget_title: "Gestion Budgétaire",
    profile_title: "Votre Espace Nexii",
    level_badge: "Aventurier Niveau 5",
    joined_date: "Membre depuis Juillet 2026",
    sound_picker: "Sons d'Ambiance",
    start_timer: "DÉMARRER",
    pause_timer: "PAUSE",
    add_task: "Ajouter une tâche",
    placeholder_add_task: "Faire de la cohérence cardiaque...",
    placeholder_chat: "Discutez avec votre coach...",
    aura_title: "Aura du Jour : Sereine",
    aura_desc: "Votre score de bien-être est à 84% aujourd'hui. Continuez ainsi !",
    quick_view: "Aperçu de votre journée",
    remain_budget: "Reste à dépenser ce mois-ci",
    budget_total: "Budget Total",
    spent_amount: "Dépensé",
    recent_trans: "Dernières transactions",
    mood_title: "Votre humeur du jour",
    daily_tasks: "Tâches quotidiennes",
    all_completed: "Toutes les tâches terminées !",
    recommended_focus: "Focus recommandé",
    start_action: "Démarrer",
    overall_progress: "Progression générale",
    claim_xp: "VALIDER ET RÉCLAMER XP",
    reward_claimed: "RECOMPENSE RÉCUPÉRÉE",
    cat_label: "Cat :",
    prio_label: "Prio :",
    difficulty_easy: "Facile",
    difficulty_medium: "Moyen",
    difficulty_hard: "Difficile",
    category_daily: "Quotidien",
    category_weekly: "Hebdomadaire",
    category_special: "Spécial",
    financial_stress: "Stress Financier",
    stress_index: "Indice :",
    savings_target: "Cible d'épargne",
    activity_streak: "Série d'activité",
    streak_desc: "Restez actif chaque jour pour augmenter votre série !",
    active_state: "Actif",
    recovery_action: "Temps de récupération suggéré par l'IA",
    reduce_pomodoro: "Réduire Pomodoro à 15m",
    recover_5m: "Récupérer 5 minutes",
    validate_day: "Valider ma journée ! 🔥 (+1 Jour d'affilé)",
    already_validated: "Journée validée ! 🔥",
    agenda_title: "Mon Agenda Bien-être",
    add_event: "Ajouter à l'agenda",
    placeholder_event: "Séance Yoga, Gym, Méditer...",
    time_label: "Heure :",
    no_events: "Aucun événement prévu pour ce jour.",
    stats_title: "Statistiques Générales",
    focus_hours: "Heures Focus",
    challenges_completed: "Défis Réussis",
    success_rate: "Taux Réussite",
    cardiac_coherence_short: "Cohérence Card.",
    device_options: "Options de l'appareil",
    onboarding_title: "Complétez votre profil",
    onboarding_desc: "Veuillez entrer vos informations pour personnaliser votre expérience sur Nexii.",
    onboarding_name_label: "Nom complet",
    onboarding_birthdate_label: "Date de naissance",
    onboarding_submit: "Valider et démarrer",
    edit_profile_btn: "Modifier mes infos",
    edit_profile_title: "Modifier mes informations",
    save_profile_btn: "Enregistrer les modifications",
    cancel_btn: "Annuler",
    system_notifications_title: "Notifications Hors-App (Système)",
    system_notifications_desc: "Activer les alertes sur votre bureau/téléphone pour les rappels de bien-être et fins de sessions de concentration Pomodoro.",
    system_notifications_btn_enable: "Activer les notifications",
    system_notifications_btn_enabled: "Notifications activées ✓"
  },
  en: {
    app_name: "Nexii",
    welcome_back: "Welcome back, Adventurer",
    calm_message: "Take a deep breath. Everything is under control.",
    tab_home: "Home",
    tab_missions: "Missions",
    tab_tasks: "Tasks",
    tab_focus: "Focus",
    tab_coach: "Coach",
    tab_budget: "Budget",
    tab_profile: "Profile",
    settings_theme: "Dark Theme",
    settings_lang: "Language",
    missions_title: "Your Daily Quests",
    tasks_title: "Task Checklist",
    focus_title: "Concentration Space",
    coach_title: "Life Coach AI",
    budget_title: "Budget Planning",
    profile_title: "Your Nexii Hub",
    level_badge: "Adventurer Level 5",
    joined_date: "Member since July 2026",
    sound_picker: "Ambient Sounds",
    start_timer: "START TIMER",
    pause_timer: "PAUSE",
    add_task: "Add new task",
    placeholder_add_task: "Practice mindful breathing...",
    placeholder_chat: "Message your AI Coach...",
    aura_title: "Today's Aura: Serene",
    aura_desc: "Your well-being score is at 84% today. Keep it up!",
    quick_view: "Your Day at a Glance",
    remain_budget: "Remaining to spend this month",
    budget_total: "Total Budget",
    spent_amount: "Spent",
    recent_trans: "Recent Transactions",
    mood_title: "Your mood of the day",
    daily_tasks: "Daily tasks",
    all_completed: "All tasks completed!",
    recommended_focus: "Recommended focus",
    start_action: "Start",
    overall_progress: "Overall progress",
    claim_xp: "VALIDATE AND CLAIM XP",
    reward_claimed: "REWARD CLAIMED",
    cat_label: "Cat:",
    prio_label: "Prio:",
    difficulty_easy: "Easy",
    difficulty_medium: "Medium",
    difficulty_hard: "Hard",
    category_daily: "Daily",
    category_weekly: "Weekly",
    category_special: "Special",
    financial_stress: "Financial Stress",
    stress_index: "Index:",
    savings_target: "Savings target",
    activity_streak: "Activity Streak",
    streak_desc: "Stay active every day to boost your streak!",
    active_state: "Active",
    recovery_action: "Recovery time suggested by AI",
    reduce_pomodoro: "Reduce Pomodoro to 15m",
    recover_5m: "Recover 5 minutes",
    validate_day: "Validate my day! 🔥 (+1 Day)",
    already_validated: "Day validated! 🔥",
    agenda_title: "My Wellness Agenda",
    add_event: "Add to agenda",
    placeholder_event: "Yoga session, Gym, Meditate...",
    time_label: "Time:",
    no_events: "No events scheduled for this day.",
    stats_title: "General Statistics",
    focus_hours: "Focus Hours",
    challenges_completed: "Quests Completed",
    success_rate: "Success Rate",
    cardiac_coherence_short: "Cardiac Coherence",
    device_options: "Device Options",
    onboarding_title: "Complete your profile",
    onboarding_desc: "Please enter your information to personalize your Nexii experience.",
    onboarding_name_label: "Full Name",
    onboarding_birthdate_label: "Birthdate",
    onboarding_submit: "Submit and start",
    edit_profile_btn: "Edit profile info",
    edit_profile_title: "Edit My Information",
    save_profile_btn: "Save Changes",
    cancel_btn: "Cancel",
    system_notifications_title: "Off-App Notifications (System)",
    system_notifications_desc: "Enable system-level desktop/mobile alerts for wellness breaks and completed Pomodoro concentration sessions.",
    system_notifications_btn_enable: "Enable notifications",
    system_notifications_btn_enabled: "Notifications enabled ✓"
  },
  es: {
    app_name: "Nexii",
    welcome_back: "Bienvenido, Aventurero",
    calm_message: "Inhala profundamente. Todo está bajo control.",
    tab_home: "Inicio",
    tab_missions: "Misiones",
    tab_tasks: "Tareas",
    tab_focus: "Enfoque",
    tab_coach: "Coach AI",
    tab_budget: "Presupuesto",
    tab_profile: "Perfil",
    settings_theme: "Tema Oscuro",
    settings_lang: "Idioma",
    missions_title: "Tus Desafíos Diarios",
    tasks_title: "Lista de Tareas",
    focus_title: "Espacio de Enfoque",
    coach_title: "Coach de Vida",
    budget_title: "Gestión Presupuestaria",
    profile_title: "Tu Espacio Nexii",
    level_badge: "Aventurero Nivel 5",
    joined_date: "Miembro desde Julio 2026",
    sound_picker: "Sonidos de Ambiente",
    start_timer: "INICIAR",
    pause_timer: "PAUSA",
    add_task: "Añadir tarea",
    placeholder_add_task: "Hacer coherencia cardíaca...",
    placeholder_chat: "Chatea con tu coach...",
    aura_title: "Aura de hoy: Serena",
    aura_desc: "Tu nivel de bienestar es del 84% hoy. ¡Sigue así!",
    quick_view: "Resumen de tu día",
    remain_budget: "Restante para gastar este mes",
    budget_total: "Presupuesto Total",
    spent_amount: "Gastado",
    recent_trans: "Últimas transacciones",
    mood_title: "Tu estado de ánimo hoy",
    daily_tasks: "Tareas diarias",
    all_completed: "¡Todas las tareas completadas!",
    recommended_focus: "Enfoque recomendado",
    start_action: "Iniciar",
    overall_progress: "Progreso general",
    claim_xp: "VALIDAR Y RECLAMAR XP",
    reward_claimed: "RECOMPENSA RECLAMADA",
    cat_label: "Cat:",
    prio_label: "Prio:",
    difficulty_easy: "Fácil",
    difficulty_medium: "Medio",
    difficulty_hard: "Difícil",
    category_daily: "Diario",
    category_weekly: "Semanal",
    category_special: "Especial",
    financial_stress: "Estrés Financiero",
    stress_index: "Índice:",
    savings_target: "Criterio de ahorro",
    activity_streak: "Série de actividad",
    streak_desc: "¡Mantente activo todos los días para aumentar tu racha!",
    active_state: "Activo",
    recovery_action: "Tiempo de recuperación sugerido por IA",
    reduce_pomodoro: "Reducir Pomodoro a 15m",
    recover_5m: "Recuperar 5 minutes",
    validate_day: "¡Validar mi día! 🔥 (+1 Día)",
    already_validated: "¡Día validado! 🔥",
    agenda_title: "Mi Agenda de Bienestar",
    add_event: "Añadir a la agenda",
    placeholder_event: "Sesión de yoga, gimnasio, meditar...",
    time_label: "Hora:",
    no_events: "No hay eventos programados para este día.",
    stats_title: "Estadísticas Generales",
    focus_hours: "Horas de Enfoque",
    challenges_completed: "Desafíos Logrados",
    success_rate: "Tasa de Éxito",
    cardiac_coherence_short: "Coherencia Card.",
    device_options: "Opciones del Dispositivo",
    onboarding_title: "Complete su perfil",
    onboarding_desc: "Por favor, ingrese sus datos para personalizar su experiencia en Nexii.",
    onboarding_name_label: "Nombre completo",
    onboarding_birthdate_label: "Fecha de nacimiento",
    onboarding_submit: "Validar e iniciar",
    edit_profile_btn: "Modificar mis datos",
    edit_profile_title: "Modificar mis datos",
    save_profile_btn: "Guardar modificaciones",
    cancel_btn: "Cancelar",
    system_notifications_title: "Notificaciones Fuera de la App (Sistema)",
    system_notifications_desc: "Activa alertas de sistema en tu escritorio o móvil para recordatorios de bienestar y fin de sesiones Pomodoro.",
    system_notifications_btn_enable: "Activar notificaciones",
    system_notifications_btn_enabled: "Notificaciones activadas ✓"
  }
};

// Simulated Coach AI Responders
interface ChatResponse {
  fr: string;
  en: string;
  es: string;
}

const CHAT_RESPONSES: Record<string, ChatResponse> = {
  stress: {
    fr: "Je comprends tout à fait. Fermez les yeux un instant. Inspirons ensemble sur 4 secondes... retenons 4 secondes... et expirons sur 4 secondes. Ressentez-vous la tension se dissiper ?",
    en: "I completely understand. Close your eyes for a moment. Let's inhale together for 4 seconds... hold for 4... and exhale for 4. Feel that tension starting to fade away?",
    es: "Lo entiendo completamente. Cierra los ojos por un momento. Inhalemos juntos durante 4 segundos... mantengamos 4... y exhalemos durante 4. ¿Sientes que la tensión disminuye?"
  },
  fatigue: {
    fr: "Votre corps vous envoie un signal important. Prenez une vraie pause de 5 minutes sans écrans. Une courte marche ou s'étirer doucement peut relancer votre énergie sans stress.",
    en: "Your body is sending you an important signal. Take a true 5-minute break away from screens. A short walk or a gentle stretch can recharge your energy without stress.",
    es: "Tu cuerpo te está enviando una señal importante. Tómate un verdadero descanso de 5 minutos de las pantallas. Una caminata corta o un estiramiento suave pueden renovar tu energía sin estrés."
  },
  budget: {
    fr: "Gérer ses finances est un excellent pas vers la paix d'esprit. Rappelez-vous que chaque petit choix conscient aujourd'hui protège votre liberté de demain. Commençons par trier vos dépenses fixes !",
    en: "Managing finances is a huge step towards peace of mind. Remember, every conscious micro-choice today protects your freedom tomorrow. Let's list your fixed expenses first!",
    es: "Administrar tus finanzas es un gran paso hacia la tranquilidad mental. Recuerda que cada pequeña decisión consciente hoy protege tu libertad mañana. ¡Comencemos por tus gastos fijos!"
  },
  salut: {
    fr: "Bonjour Aventurier ! Comment se passe votre journée aujourd'hui ? Je suis là pour vous écouter et vous guider avec calme.",
    en: "Hello Adventurer! How is your day going today? I am here to listen and guide you with serenity.",
    es: "¡Hola Aventurero! ¿Cómo va tu día hoy? Estoy aquí para escucharte y guiarte con serenidad."
  },
  merci: {
    fr: "C'est un réel plaisir. Prenez soin de vous, un pas à la fois. Vous faites un travail formidable pour votre bien-être !",
    en: "It is a true pleasure. Take care of yourself, one step at a time. You are doing wonderful work for your wellness!",
    es: "Es un verdadero placer. Cuídate mucho, paso a paso. ¡Estás haciendo un trabajo increíble para tu bienestar!"
  },
  default: {
    fr: "C'est noté. Prenez un moment pour respirer. Nexii est conçu pour vous aider à progresser sans vous surcharger de stress. Quel aspect de votre journée aimeriez-vous apaiser maintenant ?",
    en: "I hear you. Take a moment to just breathe. Nexii is designed to help you progress without feeling overwhelmed. Which part of your day would you like to bring calm to?",
    es: "Te escucho. Tómate un momento para respirar profundamente. Nexii está diseñado para ayudarte a progresar sin abrumarte. ¿Qué parte de tu día te gustaría calmar ahora?"
  }
};

import { auth, db } from './firebase';
import { 
  onAuthStateChanged, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signOut as firebaseSignOut,
  sendPasswordResetEmail,
  GoogleAuthProvider,
  signInWithCredential,
  updateProfile,
  signInWithPopup
} from 'firebase/auth';
import { doc, getDoc, setDoc, collection, onSnapshot, query, orderBy, addDoc, updateDoc, limit } from 'firebase/firestore';
import { 
  Cloud, 
  CloudOff, 
  Lock, 
  UserPlus, 
  LogOut, 
  RefreshCw, 
  AlertCircle,
  Coins,
  Calendar
} from 'lucide-react';

const DEMO_MISSIONS = [
  {
    id: 1,
    title: 'Méditer 10 minutes',
    category: 'Quotidien',
    difficulty: 'Facile',
    xp: 50,
    description: 'Prenez du recul et respirez profondément pour calmer l\'esprit.',
    progress: 1.0,
    completed: true,
    claimed: false,
  },
  {
    id: 2,
    title: 'Limiter le budget loisirs',
    category: 'Quotidien',
    difficulty: 'Moyen',
    xp: 120,
    description: 'Évitez les dépenses de divertissement superflues aujourd\'hui.',
    progress: 0.7,
    completed: false,
    claimed: false,
  },
  {
    id: 3,
    title: 'Compléter 15 tâches',
    category: 'Hebdomadaire',
    difficulty: 'Difficile',
    xp: 300,
    description: 'Maintenez votre rythme de travail sans surcharge mentale.',
    progress: 0.4,
    completed: false,
    claimed: false,
  },
  {
    id: 4,
    title: '3 sessions Focus de suite',
    category: 'Spécial',
    difficulty: 'Moyen',
    xp: 150,
    description: 'Terminez trois Pomodoro d\'affilée sans distraction.',
    progress: 1.0,
    completed: true,
    claimed: false,
  }
];

const DEMO_TASKS = [
  {
    id: 1,
    title: 'Rédiger l\'introduction du projet',
    category: 'Pro',
    priority: 'Haute',
    completed: true,
    expanded: false,
    subtasks: [
      { id: 11, title: 'Faire le benchmark des concurrents', completed: true },
      { id: 12, title: 'Rédiger la structure de la thèse', completed: true },
    ]
  },
  {
    id: 2,
    title: 'Faire 10 minutes de cohérence cardiaque',
    category: 'Zen',
    priority: 'Haute',
    completed: false,
    expanded: true,
    subtasks: [
      { id: 21, title: 'Lancer l\'application Nexii Focus', completed: true },
      { id: 22, title: 'Respirer profondément au calme', completed: false },
    ]
  },
  {
    id: 3,
    title: 'Acheter les légumes de saison',
    category: 'Perso',
    priority: 'Moyenne',
    completed: false,
    expanded: false,
    subtasks: []
  },
  {
    id: 4,
    title: 'Vérifier les abonnements mensuels',
    category: 'Finance',
    priority: 'Basse',
    completed: false,
    expanded: false,
    subtasks: [
      { id: 41, title: 'Annuler l\'essai gratuit streaming', completed: false }
    ]
  }
];

const DEMO_MESSAGES = [
  { 
    id: 1, 
    text: "Bonjour ! J'ai analysé votre journée. Vous avez été très productif mais vous n'avez pas encore pris de pause bien-être. Voudriez-vous faire une micro-méditation de 2 minutes maintenant ?", 
    isUser: false 
  },
  { 
    id: 2, 
    text: "Oui, je veux bien. J'ai eu une matinée assez intense.", 
    isUser: true 
  },
  { 
    id: 3, 
    text: "Parfait. Installez-vous confortablement. Commençons par inspirer par le nez pendant 4 secondes...", 
    isUser: false 
  },
];

const DEMO_TRANSACTIONS = [
  { id: 1, title: 'Supermarché Bio', amount: -24.50, category: 'Alimentation', date: 'Aujourd\'hui' },
  { id: 2, title: 'Remboursement Cinéma', amount: 12.00, category: 'Loisirs', date: 'Hier' },
  { id: 3, title: 'Abonnement Musique', amount: -9.99, category: 'Abonnement', date: '28 Juin' },
  { id: 4, title: 'Prime Mensuelle', amount: 50.00, category: 'Bonus', date: '25 Juin' },
  { id: 5, title: 'Facture Électricité', amount: -65.00, category: 'Maison', date: '22 Juin' },
];

const DEMO_COMMUNITY_POSTS = [
  {
    id: 'cp1',
    author: 'Sarah M.',
    avatarColor: '#ec4899',
    time: 'Il y a 10 min',
    text: "Aujourd'hui, j'ai fait 25 min de focus avec le son \"Pluie en Forêt\". Ça m'a complètement vidé la tête avant mes révisions ! 🌧️🌲",
    likes: 14,
    hasLiked: false,
    tag: '#Zen'
  },
  {
    id: 'cp2',
    author: 'Thomas L.',
    avatarColor: '#3b82f6',
    time: 'Il y a 1 h',
    text: "Rappel amical : buvez un grand verre d'eau, redressez-vous et détendez vos épaules ! Le stress physique alimente le stress mental. 💧✨",
    likes: 28,
    hasLiked: true,
    tag: '#BienEtre'
  },
  {
    id: 'cp3',
    author: 'Marc-Antoine',
    avatarColor: '#f59e0b',
    time: 'Il y a 3 h',
    text: "La cohérence cardiaque de ce matin m'a aidé à surmonter mon anxiété avant ma présentation client. Nexii a vu juste en me la recommandant ! 🧘‍♂️",
    likes: 19,
    hasLiked: false,
    tag: '#Productivité'
  }
];


const convertCurrency = (amount: number, from: 'EUR' | 'USD' | 'XAF', to: 'EUR' | 'USD' | 'XAF'): number => {
  if (from === to) return amount;
  let inEur = amount;
  if (from === 'USD') {
    inEur = amount / 1.10;
  } else if (from === 'XAF') {
    inEur = amount / 655.957;
  }
  
  if (to === 'EUR') {
    return inEur;
  } else if (to === 'USD') {
    return inEur * 1.10;
  } else if (to === 'XAF') {
    return inEur * 655.957;
  }
  return amount;
};


const convertIsoToDisplay = (iso: string): string => {
  if (!iso) return '';
  const parts = iso.split('-');
  if (parts.length === 3) {
    const [year, month, day] = parts;
    return `${day}/${month}/${year}`;
  }
  return iso;
};

const convertDisplayToIso = (display: string): string => {
  if (!display) return '';
  const parts = display.split('/');
  if (parts.length === 3) {
    const [day, month, year] = parts;
    if (day.length === 2 && month.length === 2 && year.length === 4) {
      return `${year}-${month}-${day}`;
    }
  }
  return '';
};

const isValidDate = (day: number, month: number, year: number): boolean => {
  if (year < 1900 || year > new Date().getFullYear()) return false;
  if (month < 1 || month > 12) return false;
  const monthLengths = [31, (year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0)) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return day >= 1 && day <= monthLengths[month - 1];
};

const handleTypedDateChange = (
  rawVal: string,
  setText: (val: string) => void,
  setIso: (val: string) => void
) => {
  let digits = rawVal.replace(/[^\d]/g, '').slice(0, 8);
  let formatted = digits;
  if (digits.length > 2) {
    formatted = digits.slice(0, 2) + '/' + digits.slice(2);
  }
  if (digits.length > 4) {
    formatted = formatted.slice(0, 5) + '/' + digits.slice(4, 8);
  }
  setText(formatted);
  
  if (digits.length === 8) {
    const day = digits.slice(0, 2);
    const month = digits.slice(2, 4);
    const year = digits.slice(4, 8);
    const dNum = parseInt(day, 10);
    const mNum = parseInt(month, 10);
    const yNum = parseInt(year, 10);
    
    if (isValidDate(dNum, mNum, yNum)) {
      setIso(`${year}-${month}-${day}`);
    } else {
      setIso('');
    }
  } else {
    setIso('');
  }
};


const calculateAge = (birthdateStr: string): number => {
  if (!birthdateStr) return 28;
  const birthDate = new Date(birthdateStr);
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
};

const playBirthdayChime = () => {
  try {
    const AudioContext = window.AudioContext || (window as any).webkitAudioContext;
    if (!AudioContext) return;
    const ctx = new AudioContext();
    const now = ctx.currentTime;
    
    const playNote = (freq: number, start: number, duration: number, type: OscillatorType = 'triangle') => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      
      osc.type = type;
      osc.frequency.setValueAtTime(freq, start);
      
      gain.gain.setValueAtTime(0.12, start);
      gain.gain.exponentialRampToValueAtTime(0.001, start + duration);
      
      osc.connect(gain);
      gain.connect(ctx.destination);
      
      osc.start(start);
      osc.stop(start + duration);
    };
    
    // Play happy birthday chime notes!
    // G4 (392), G4 (392), A4 (440), G4 (392), C5 (523), B4 (494)
    playNote(392.00, now, 0.15);
    playNote(392.00, now + 0.18, 0.15);
    playNote(440.00, now + 0.36, 0.3);
    playNote(392.00, now + 0.66, 0.3);
    playNote(523.25, now + 0.96, 0.3);
    playNote(493.88, now + 1.26, 0.6);
  } catch (err) {
    console.error("Audio error:", err);
  }
};

const isTodayBirthday = (birthdateStr: string | null): boolean => {
  if (!birthdateStr) return false;
  try {
    const birthDate = new Date(birthdateStr);
    const today = new Date();
    return birthDate.getDate() === today.getDate() && birthDate.getMonth() === today.getMonth();
  } catch (e) {
    return false;
  }
};

const getAgeSegmentLabel = (age: number | null, lang: 'fr' | 'en' | 'es') => {
  if (!age) return null;
  if (age <= 18) {
    return {
      fr: "Suivi : Adolescent 🎒",
      en: "Tracking: Teenager 🎒",
      es: "Seguimiento: Adolescente 🎒"
    }[lang] || "Suivi : Adolescent 🎒";
  }
  if (age <= 25) {
    return {
      fr: "Suivi : Jeune Adulte 🎓",
      en: "Tracking: Young Adult 🎓",
      es: "Seguimiento: Joven Adulto 🎓"
    }[lang] || "Suivi : Jeune Adulte 🎓";
  }
  if (age <= 45) {
    return {
      fr: "Suivi : Adulte Actif 💼",
      en: "Tracking: Active Adult 💼",
      es: "Seguimiento: Adulto Activo 💼"
    }[lang] || "Suivi : Adulte Actif 💼";
  }
  return {
    fr: "Suivi : Sénior / Expérimenté 🧘",
    en: "Tracking: Experienced / Senior 🧘",
    es: "Seguimiento: Senior / Experimentado 🧘"
  }[lang] || "Suivi : Sénior / Expérimenté 🧘";
};

class AmbientSynth {
  private ctx: AudioContext | null = null;
  private rainNode: AudioBufferSourceNode | null = null;
  private oceanNode: AudioBufferSourceNode | null = null;
  private noiseNode: AudioBufferSourceNode | null = null;
  private lfo: OscillatorNode | null = null;
  private mainGain: GainNode | null = null;
  private dropletInterval: any = null;

  constructor() {}

  init() {
    if (this.ctx) return;
    const AudioContextClass = (window as any).AudioContext || (window as any).webkitAudioContext;
    if (!AudioContextClass) return;
    try {
      this.ctx = new AudioContextClass();
      this.mainGain = this.ctx.createGain();
      this.mainGain.gain.setValueAtTime(0.4, this.ctx.currentTime);
      this.mainGain.connect(this.ctx.destination);
    } catch (e) {
      console.error("Failed to initialize AudioContext", e);
    }
  }

  private createBrownNoiseBuffer(): AudioBuffer | null {
    if (!this.ctx) return null;
    const bufferSize = 10 * this.ctx.sampleRate;
    const noiseBuffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const output = noiseBuffer.getChannelData(0);
    let lastOut = 0.0;
    for (let i = 0; i < bufferSize; i++) {
      const white = Math.random() * 2 - 1;
      output[i] = (lastOut + (0.02 * white)) / 1.02;
      lastOut = output[i];
      output[i] *= 3.5;
    }
    return noiseBuffer;
  }

  private createPinkNoiseBuffer(): AudioBuffer | null {
    if (!this.ctx) return null;
    const bufferSize = 2 * this.ctx.sampleRate;
    const noiseBuffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const output = noiseBuffer.getChannelData(0);
    let b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
    for (let i = 0; i < bufferSize; i++) {
      const white = Math.random() * 2 - 1;
      b0 = 0.99886 * b0 + white * 0.0555179;
      b1 = 0.99332 * b1 + white * 0.0750759;
      b2 = 0.96900 * b2 + white * 0.1538520;
      b3 = 0.86650 * b3 + white * 0.3104856;
      b4 = 0.55000 * b4 + white * 0.5329522;
      b5 = -0.7616 * b5 - white * 0.0168980;
      output[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
      output[i] *= 0.11;
      b6 = white * 0.115926;
    }
    return noiseBuffer;
  }

  stopAll() {
    if (this.dropletInterval) {
      clearInterval(this.dropletInterval);
      this.dropletInterval = null;
    }
    try {
      if (this.rainNode) {
        this.rainNode.stop();
        this.rainNode = null;
      }
      if (this.oceanNode) {
        this.oceanNode.stop();
        this.oceanNode = null;
      }
      if (this.noiseNode) {
        this.noiseNode.stop();
        this.noiseNode = null;
      }
      if (this.lfo) {
        this.lfo.stop();
        this.lfo = null;
      }
    } catch (e) {
      // already stopped or not started
    }
  }

  playRain() {
    this.init();
    if (!this.ctx || !this.mainGain) return;
    this.stopAll();

    try {
      this.ctx.resume();
    } catch (e) {}

    const noiseBuffer = this.createPinkNoiseBuffer();
    if (!noiseBuffer) return;

    try {
      const source = this.ctx.createBufferSource();
      source.buffer = noiseBuffer;
      source.loop = true;

      const filter = this.ctx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(800, this.ctx.currentTime);

      source.connect(filter);
      filter.connect(this.mainGain);
      source.start(0);
      this.rainNode = source;
    } catch (e) {
      console.error("Rain playback failed", e);
    }

    this.dropletInterval = setInterval(() => {
      if (!this.ctx || !this.mainGain) return;
      if (Math.random() > 0.4) {
        try {
          const osc = this.ctx.createOscillator();
          const gain = this.ctx.createGain();
          osc.connect(gain);
          gain.connect(this.mainGain);

          const now = this.ctx.currentTime;
          const startFreq = 800 + Math.random() * 600;
          osc.frequency.setValueAtTime(startFreq, now);
          osc.frequency.exponentialRampToValueAtTime(100 + Math.random() * 200, now + 0.15);

          gain.gain.setValueAtTime(0, now);
          gain.gain.linearRampToValueAtTime(0.08 + Math.random() * 0.05, now + 0.02);
          gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.15);

          osc.start(now);
          osc.stop(now + 0.16);
        } catch (e) {}
      }
    }, 400);
  }

  playOcean() {
    this.init();
    if (!this.ctx || !this.mainGain) return;
    this.stopAll();

    try {
      this.ctx.resume();
    } catch (e) {}

    const noiseBuffer = this.createBrownNoiseBuffer();
    if (!noiseBuffer) return;

    try {
      const source = this.ctx.createBufferSource();
      source.buffer = noiseBuffer;
      source.loop = true;

      const filter = this.ctx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(300, this.ctx.currentTime);

      const waveGain = this.ctx.createGain();
      waveGain.gain.setValueAtTime(0.15, this.ctx.currentTime);

      const lfo = this.ctx.createOscillator();
      lfo.frequency.setValueAtTime(0.08, this.ctx.currentTime); // 12.5s cycles

      const lfoGain = this.ctx.createGain();
      lfoGain.gain.setValueAtTime(0.1, this.ctx.currentTime);

      lfo.connect(lfoGain);
      lfoGain.connect(waveGain.gain);

      const filterLfoGain = this.ctx.createGain();
      filterLfoGain.gain.setValueAtTime(200, this.ctx.currentTime);
      lfo.connect(filterLfoGain);
      filterLfoGain.connect(filter.frequency);

      source.connect(filter);
      filter.connect(waveGain);
      waveGain.connect(this.mainGain);

      source.start(0);
      lfo.start(0);

      this.oceanNode = source;
      this.lfo = lfo;
    } catch (e) {
      console.error("Ocean playback failed", e);
    }
  }

  playWhiteNoise() {
    this.init();
    if (!this.ctx || !this.mainGain) return;
    this.stopAll();

    try {
      this.ctx.resume();
    } catch (e) {}

    const noiseBuffer = this.createBrownNoiseBuffer();
    if (!noiseBuffer) return;

    try {
      const source = this.ctx.createBufferSource();
      source.buffer = noiseBuffer;
      source.loop = true;

      const filter = this.ctx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(450, this.ctx.currentTime);

      source.connect(filter);
      filter.connect(this.mainGain);
      source.start(0);

      this.noiseNode = source;
    } catch (e) {
      console.error("White noise playback failed", e);
    }
  }

  setVolume(volume: number) {
    this.init();
    if (!this.mainGain || !this.ctx) return;
    try {
      this.mainGain.gain.setValueAtTime(volume * 0.4, this.ctx.currentTime);
    } catch (e) {}
  }

  playByName(name: string) {
    const lowerName = name.toLowerCase();
    if (lowerName.includes('pluie') || lowerName.includes('rain') || lowerName.includes('forest')) {
      this.playRain();
    } else if (lowerName.includes('vague') || lowerName.includes('ocean') || lowerName.includes('waves') || lowerName.includes('ola') || lowerName.includes('mar')) {
      this.playOcean();
    } else if (lowerName.includes('bruit') || lowerName.includes('noise') || lowerName.includes('blanco') || lowerName.includes('ruido')) {
      this.playWhiteNoise();
    } else {
      this.stopAll();
    }
  }
}

const getSoundTranslation = (sound: string, currentLang: string) => {
  if (sound === 'Pluie en Forêt') {
    if (currentLang === 'en') return 'Forest Rain';
    if (currentLang === 'es') return 'Lluvia en Bosque';
    return 'Pluie en Forêt';
  }
  if (sound === 'Vagues d\'Océan') {
    if (currentLang === 'en') return 'Ocean Waves';
    if (currentLang === 'es') return 'Olas del Océano';
    return 'Vagues d\'Océan';
  }
  if (sound === 'Bruit Blanc') {
    if (currentLang === 'en') return 'White Noise';
    if (currentLang === 'es') return 'Ruido Blanco';
    return 'Bruit Blanc';
  }
  if (sound === 'Silence') {
    if (currentLang === 'en') return 'Silence';
    if (currentLang === 'es') return 'Silencio';
    return 'Silence';
  }
  return sound;
};

export default function App() {
  // Mobile Simulator States
  const [lang, setLang] = useState<'fr' | 'en' | 'es'>('fr');
  const [isDarkMode, setIsDarkMode] = useState<boolean>(false);
  const [activeTab, setActiveTab] = useState<number>(0);

  // Notification States
  const [notifications, setNotifications] = useState<Array<{ id: number; title: string; content: string; date: string; read: boolean; type: 'success' | 'info' | 'warning' | 'xp' }>>([
    { id: 1, title: 'Bienvenue sur Nexii ! 🚀', content: 'Votre compagnon ultime de bien-être, concentration et finances est prêt. Explorez vos tableaux de bord !', date: new Date().toISOString(), read: false, type: 'info' }
  ]);
  const [showNotifications, setShowNotifications] = useState<boolean>(false);
  const [systemNotificationsEnabled, setSystemNotificationsEnabled] = useState<boolean>(() => {
    if (typeof window !== 'undefined' && 'Notification' in window) {
      return Notification.permission === 'granted';
    }
    return false;
  });

  const requestNotificationPermission = async () => {
    if (typeof window === 'undefined' || !('Notification' in window)) {
      alert(lang === 'fr' ? "Les notifications système ne sont pas supportées par votre navigateur." : "System notifications are not supported by your browser.");
      return;
    }
    try {
      const permission = await Notification.requestPermission();
      if (permission === 'granted') {
        setSystemNotificationsEnabled(true);
        new Notification("Nexii 🚀", {
          body: lang === 'fr' ? "Super ! Les notifications système hors-application sont maintenant activées." : "Superb! Off-app system notifications are now enabled.",
        });
      } else {
        setSystemNotificationsEnabled(false);
        alert(lang === 'fr' ? "Permission de notification refusée. Veuillez l'activer dans les paramètres de votre navigateur." : "Notification permission denied. Please enable it in your browser settings.");
      }
    } catch (err) {
      console.error("Error requesting notification permission:", err);
    }
  };

  const sendSystemNotification = (title: string, body: string) => {
    if (typeof window !== 'undefined' && 'Notification' in window && Notification.permission === 'granted') {
      try {
        new Notification(title, {
          body,
          icon: "/favicon.ico"
        });
      } catch (err) {
        console.error("Failed to send system notification:", err);
      }
    }
  };

  // Authentication & Offline States
  const [user, setUser] = useState<any>(null);
  const [authEmail, setAuthEmail] = useState('');
  const [authPassword, setAuthPassword] = useState('');
  const [authName, setAuthName] = useState('');
  const [authBirthdate, setAuthBirthdate] = useState('');
  const [authBirthdateText, setAuthBirthdateText] = useState('');
  const [authMode, setAuthMode] = useState<'login' | 'register' | 'forgot'>('login');
  const [authError, setAuthError] = useState('');
  const [onboardingName, setOnboardingName] = useState('');
  const [onboardingBirthdate, setOnboardingBirthdate] = useState('');
  const [onboardingBirthdateText, setOnboardingBirthdateText] = useState('');
  const [editName, setEditName] = useState('');
  const [editBirthdate, setEditBirthdate] = useState('');
  const [editBirthdateText, setEditBirthdateText] = useState('');
  const [isEditingProfile, setIsEditingProfile] = useState(false);
  const [profileError, setProfileError] = useState('');
  const [userAge, setUserAge] = useState<number | null>(null);
  const [userBirthdate, setUserBirthdate] = useState<string | null>(null);
  const [feedbackRating, setFeedbackRating] = useState<number>(5);
  const [feedbackComment, setFeedbackComment] = useState<string>('');
  const [isSubmittingFeedback, setIsSubmittingFeedback] = useState<boolean>(false);
  const [isOffline, setIsOffline] = useState(false);
  const [isSyncing, setIsSyncing] = useState(false);
  const [pendingSync, setPendingSync] = useState(false);
  const [isProfileLoaded, setIsProfileLoaded] = useState(false);
  
  // Mood Selector State
  const [selectedMood, setSelectedMood] = useState<number>(2); // default to "🙂 Bien"
  const moods = [
    { emoji: '😞', label: { fr: 'Stressé', en: 'Stressed', es: 'Estresado' } },
    { emoji: '😐', label: { fr: 'Neutre', en: 'Neutral', es: 'Neutro' } },
    { emoji: '🙂', label: { fr: 'Bien', en: 'Good', es: 'Bien' } },
    { emoji: '🤩', label: { fr: 'Inspiré', en: 'Inspired', es: 'Inspirado' } },
    { emoji: '🧘', label: { fr: 'Serein', en: 'Serene', es: 'Sereno' } }
  ];

  // User XP State
  const [userXp, setUserXp] = useState<number>(0);
  const [userLevel, setUserLevel] = useState<number>(1);
  const [userStreak, setUserStreak] = useState<number>(1);
  const [focusMinutes, setFocusMinutes] = useState<number>(0);

  const [lastCheckInDate, setLastCheckInDate] = useState<string>('');
  const [lastMissionsResetDate, setLastMissionsResetDate] = useState<string>('');
  const [currency, setCurrency] = useState<'EUR' | 'USD' | 'XAF'>('EUR');
  const [savingsGoals, setSavingsGoals] = useState<Array<{ id: number; title: string; targetAmount: number; savedAmount: number }>>([
    { id: 1, title: 'Épargne de secours', targetAmount: 1000, savedAmount: 400 }
  ]);
  const [showAddGoal, setShowAddGoal] = useState(false);
  const [goalTitle, setGoalTitle] = useState('');
  const [goalTarget, setGoalTarget] = useState('');
  const [goalSaved, setGoalSaved] = useState('');
  const [missionsSubTab, setMissionsSubTab] = useState<'challenges' | 'agenda'>('challenges');
  const [selectedAgendaDate, setSelectedAgendaDate] = useState<string>(new Date().toISOString().split('T')[0]);
  const [agendaEvents, setAgendaEvents] = useState<any[]>([
    { id: 1, title: 'Méditation du matin 🧘', time: '08:30', dayStr: new Date().toISOString().split('T')[0] },
    { id: 2, title: 'Repas conscient 🍎', time: '12:30', dayStr: new Date().toISOString().split('T')[0] },
    { id: 3, title: 'Yoga de fin de journée 🤸', time: '18:00', dayStr: new Date().toISOString().split('T')[0] },
  ]);
  const [newEventTitle, setNewEventTitle] = useState<string>('');
  const [newEventTime, setNewEventTime] = useState<string>('09:00');

  const getFreshMissions = () => [
    {
      id: 101,
      title: 'Échanger avec le Coach AI',
      category: 'Mental',
      difficulty: 'Facile',
      xp: 50,
      description: 'Envoyez un message à votre Coach de Vie AI dans l\'onglet Coach.',
      progress: 0.0,
      completed: false,
      claimed: false,
      targetType: 'coach'
    },
    {
      id: 102,
      title: 'Lancer une session Focus',
      category: 'Focus',
      difficulty: 'Moyen',
      xp: 100,
      description: 'Démarrez un Pomodoro de concentration dans l\'onglet Focus.',
      progress: 0.0,
      completed: false,
      claimed: false,
      targetType: 'focus'
    },
    {
      id: 103,
      title: 'Ajouter ou compléter une tâche',
      category: 'Action',
      difficulty: 'Facile',
      xp: 50,
      description: 'Ajoutez une nouvelle tâche ou complétez-en une existante.',
      progress: 0.0,
      completed: false,
      claimed: false,
      targetType: 'tasks'
    },
    {
      id: 104,
      title: 'Enregistrer une transaction',
      category: 'Finance',
      difficulty: 'Moyen',
      xp: 80,
      description: 'Ajoutez un revenu ou une dépense dans l\'onglet Budget.',
      progress: 0.0,
      completed: false,
      claimed: false,
      targetType: 'budget'
    }
  ];

  // Missions Screen State
  const [missions, setMissions] = useState<any[]>([]);

  // Tasks Screen State (with collapsible subtasks, priorities and tags)
  const [tasks, setTasks] = useState<any[]>([]);
  const [newTaskTitle, setNewTaskTitle] = useState('');
  const [newTaskCategory, setNewTaskCategory] = useState('Pro');
  const [newTaskPriority, setNewTaskPriority] = useState('Moyenne');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedTaskCategory, setSelectedTaskCategory] = useState('Toutes');
  const [selectedTaskPriority, setSelectedTaskPriority] = useState('Toutes');
  const [isGeneratingTasks, setIsGeneratingTasks] = useState(false);

  // Tasks Sub-tab ('list' | 'sport')
  const [tasksSubTab, setTasksSubTab] = useState<'list' | 'sport'>('list');

  // Sport Tracking States
  const [workouts, setWorkouts] = useState<any[]>([]);
  const [newWorkoutType, setNewWorkoutType] = useState<string>('Course à pied');
  const [newWorkoutDuration, setNewWorkoutDuration] = useState<string>('');
  const [newWorkoutIntensity, setNewWorkoutIntensity] = useState<string>('Moyenne');
  const [newWorkoutDate, setNewWorkoutDate] = useState<string>(new Date().toISOString().split('T')[0]);

  // Focus Timer States
  const [timerSeconds, setTimerSeconds] = useState(1500); // 25:00 default
  const [timerRunning, setTimerRunning] = useState(false);
  const [initialDuration, setInitialDuration] = useState(1500);
  const [timerType, setTimerType] = useState<'Pomodoro' | 'Coherence'>('Pomodoro');
  const [breathPhase, setBreathPhase] = useState<'inhale' | 'exhale'>('inhale');
  const [selectedSound, setSelectedSound] = useState('Pluie en Forêt');
  const [soundVolume, setSoundVolume] = useState(0.5);
  const [pomodoroSession, setPomodoroSession] = useState(1);
  const timerIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const ambientSynthRef = useRef<AmbientSynth | null>(null);

  if (!ambientSynthRef.current) {
    ambientSynthRef.current = new AmbientSynth();
  }

  // Coach AI Chat States
  const [messages, setMessages] = useState<any[]>([]);
  const [chatInput, setChatInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [isVoiceMode, setIsVoiceMode] = useState(false);

  const isVoiceModeRef = useRef(isVoiceMode);
  useEffect(() => {
    isVoiceModeRef.current = isVoiceMode;
  }, [isVoiceMode]);

  const [recognitionActive, setRecognitionActive] = useState(false);
  const [speechError, setSpeechError] = useState<string | null>(null);
  const recognitionRef = useRef<any>(null);
  const handleSendMessageRef = useRef<any>(null);

  const speakText = (text: string) => {
    if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
      window.speechSynthesis.cancel();
      
      const cleaned = text
        .replace(/[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E6}-\u{1F1FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1F100}-\u{1F1FF}\u{1F200}-\u{1F2FF}\u{2B50}\u{2600}-\u{26FF}]/gu, '')
        .replace(/🎤|🗣️|✨|🧘‍♂️|🧘|🤸|🍎/g, '')
        .replace(/\[Coach Vocal\]/gi, '')
        .replace(/\[Vocal User\]/gi, '')
        .trim();

      const utterance = new SpeechSynthesisUtterance(cleaned);
      utterance.lang = lang === 'fr' ? 'fr-FR' : lang === 'es' ? 'es-ES' : 'en-US';
      
      // Friendly, natural-sounding voice configurations
      utterance.pitch = 1.05; // Slightly warmer, more welcoming and melodic
      utterance.rate = 0.98;  // A relaxed, natural conversation speed

      const voices = window.speechSynthesis.getVoices();
      const matchingVoices = voices.filter(v => 
        v.lang.toLowerCase().replace('_', '-').startsWith(utterance.lang.toLowerCase().slice(0, 2))
      );

      if (matchingVoices.length > 0) {
        // Prioritize premium/high-quality voices
        let selectedVoice = matchingVoices.find(v => v.name.toLowerCase().includes('google') && !v.name.toLowerCase().includes('low-quality'));
        
        if (!selectedVoice) {
          selectedVoice = matchingVoices.find(v => v.name.toLowerCase().includes('natural') || v.name.toLowerCase().includes('premium'));
        }
        
        if (!selectedVoice) {
          // MacOS/iOS high-quality French voices
          selectedVoice = matchingVoices.find(v => v.name.toLowerCase().includes('thomas') || v.name.toLowerCase().includes('aurelie') || v.name.toLowerCase().includes('audrey') || v.name.toLowerCase().includes('samantha'));
        }
        
        if (!selectedVoice) {
          selectedVoice = matchingVoices[0];
        }
        
        utterance.voice = selectedVoice;
      }
      
      window.speechSynthesis.speak(utterance);
    }
  };

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const SpeechRecognitionClass = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
      if (SpeechRecognitionClass) {
        const rec = new SpeechRecognitionClass();
        rec.continuous = false;
        rec.interimResults = false;
        rec.lang = lang === 'fr' ? 'fr-FR' : lang === 'es' ? 'es-ES' : 'en-US';

        rec.onstart = () => {
          setRecognitionActive(true);
          setSpeechError(null);
        };

        rec.onend = () => {
          setRecognitionActive(false);
        };

        rec.onresult = (event: any) => {
          const transcript = event.results[0][0].transcript;
          if (transcript) {
            setMessages(prev => [...prev, {
              id: Date.now(),
              text: `🎤 [Vocal User] "${transcript}"`,
              isUser: true
            }]);
            if (handleSendMessageRef.current) {
              handleSendMessageRef.current(transcript);
            }
          }
        };

        rec.onerror = (event: any) => {
          console.error("Speech recognition error:", event.error);
          setRecognitionActive(false);
          if (event.error === 'not-allowed') {
            setSpeechError(lang === 'fr' 
              ? "Accès micro refusé. Veuillez autoriser le micro ou ouvrir l'app en nouvel onglet."
              : "Microphone access denied. Please allow microphone or open the app in a new tab."
            );
          } else if (event.error === 'no-speech') {
            setSpeechError(lang === 'fr'
              ? "Aucun son détecté. Parlez plus fort !"
              : "No speech detected. Speak louder!"
            );
          } else {
            setSpeechError(lang === 'fr'
              ? `Erreur micro : ${event.error}`
              : `Mic error: ${event.error}`
            );
          }
        };

        recognitionRef.current = rec;
      }
    }
  }, [lang]);

  useEffect(() => {
    if (recognitionRef.current) {
      recognitionRef.current.lang = lang === 'fr' ? 'fr-FR' : lang === 'es' ? 'es-ES' : 'en-US';
    }
  }, [lang]);

  const toggleSpeechRecognition = () => {
    if (!recognitionRef.current) {
      setSpeechError(lang === 'fr' 
        ? "La reconnaissance vocale n'est pas supportée par ce navigateur (ex: Safari iOS sans permissions). Utilisez la Simulation !"
        : "Speech recognition is not supported by your browser. Use the Simulation button!"
      );
      return;
    }
    setSpeechError(null);
    if (recognitionActive) {
      recognitionRef.current.stop();
    } else {
      try {
        if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
          window.speechSynthesis.cancel();
        }
        recognitionRef.current.start();
      } catch (e) {
        console.error("Speech recognition start failed:", e);
        setSpeechError(lang === 'fr' ? "Impossible de lancer le micro." : "Failed to start microphone.");
      }
    }
  };
  const [coachPersonality, setCoachPersonality] = useState<'Bienveillant' | 'Direct' | 'Analytique' | 'Calme' | 'Motivant'>('Bienveillant');

  // Daily Check-In/Bilan States
  const [showCheckInModal, setShowCheckInModal] = useState(false);
  const [checkInMood, setCheckInMood] = useState(3);
  const [checkInEnergy, setCheckInEnergy] = useState(3);
  const [checkInMotivation, setCheckInMotivation] = useState(3);
  const [checkInStress, setCheckInStress] = useState(3);
  const [checkInSleep, setCheckInSleep] = useState(3);
  const [hasDoneCheckIn, setHasDoneCheckIn] = useState(false);
  const [lastManualCheckInDate, setLastManualCheckInDate] = useState<string>('');

  // Focus Timer Preset Mode State
  const [focusTimerMode, setFocusTimerMode] = useState<'Flow' | 'Productif' | 'Fatigué' | 'Protection'>('Productif');

  // Business Model & Premium State
  const [showEconomicModal, setShowEconomicModal] = useState(false);
  const [isPremium, setIsPremium] = useState(false);

  // Smart Task Details States
  const [newTaskUrgency, setNewTaskUrgency] = useState('Moyenne');
  const [newTaskDifficulty, setNewTaskDifficulty] = useState('Moyen');
  const [newTaskEnergy, setNewTaskEnergy] = useState('Moyenne');
  const [newTaskDuration, setNewTaskDuration] = useState(30);
  const [showAdvancedTaskOptions, setShowAdvancedTaskOptions] = useState(false);

  // Budget & Transactions States
  const [totalBudget, setTotalBudget] = useState<number>(0);
  const [spentAmount, setSpentAmount] = useState<number>(0);
  const [transactions, setTransactions] = useState<any[]>([]);

  // Synchronize spentAmount with transactions to prevent any out-of-sync or corrupt database values
  useEffect(() => {
    const isDemo = transactions.length === DEMO_TRANSACTIONS.length && 
      transactions.every((t, i) => DEMO_TRANSACTIONS[i] && t.id === DEMO_TRANSACTIONS[i].id);
    if (isDemo) {
      setSpentAmount(479.50);
    } else {
      const computedSpent = transactions.reduce((sum: number, tx: any) => {
        if (tx && typeof tx.amount === 'number' && tx.amount < 0) {
          return sum + Math.abs(tx.amount);
        }
        return sum;
      }, 0);
      setSpentAmount(computedSpent);
    }
  }, [transactions]);

  const showAddTransaction_state = useState(false);
  const [showAddTransaction, setShowAddTransaction] = showAddTransaction_state;
  const [transTitle, setTransTitle] = useState('');
  const [transAmount, setTransAmount] = useState('');
  const [transCategory, setTransCategory] = useState('Alimentation');
  const [transIsExpense, setTransIsExpense] = useState(true);

  // File Explorer States
  const [selectedFile, setSelectedFile] = useState<FlutterFile>(FLUTTER_FILES[1]); // default to main.dart
  const [copiedPath, setCopiedPath] = useState<string | null>(null);

  // Community States
  const [communityPosts, setCommunityPosts] = useState<any[]>(DEMO_COMMUNITY_POSTS);
  const [newPostText, setNewPostText] = useState('');

  // Real-time Community Posts sync from Firestore
  useEffect(() => {
    if (!user) {
      // Fallback to demo posts when not logged in
      setCommunityPosts(DEMO_COMMUNITY_POSTS);
      return;
    }
    const q = query(
      collection(db, 'community_posts'),
      orderBy('timestamp', 'desc'),
      limit(50)
    );
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const posts: any[] = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        posts.push({
          id: doc.id,
          author: data.author || 'Anonyme',
          authorId: data.authorId || '',
          avatarColor: data.avatarColor || '#6366f1',
          time: data.time || 'Récemment',
          text: data.text || '',
          likes: data.likes || 0,
          hasLiked: data.likedBy ? data.likedBy.includes(user.uid) : false,
          likedBy: data.likedBy || [],
          tag: data.tag || '#BienEtre'
        });
      });
      if (posts.length > 0) {
        setCommunityPosts(posts);
      } else {
        setCommunityPosts(DEMO_COMMUNITY_POSTS);
      }
    }, (error) => {
      console.error("Error fetching community posts:", error);
    });
    return () => unsubscribe();
  }, [user]);

  // Advanced Gamification and AI Provider States
  const [selectedAiProvider, setSelectedAiProvider] = useState<'gemini' | 'openai' | 'claude' | 'local'>('gemini');
  const [showAiSettings, setShowAiSettings] = useState<boolean>(false);
  const [profileActiveSubTab, setProfileActiveSubTab] = useState<'prefs' | 'badges' | 'stats'>('badges');
  const [recoveryOverlay, setRecoveryOverlay] = useState<boolean>(false);
  const [recoverySeconds, setRecoverySeconds] = useState<number>(300);
  const [recoveryRunning, setRecoveryRunning] = useState<boolean>(false);
  const [candlesLit, setCandlesLit] = useState<boolean>(true);
  const [birthdayWishMade, setBirthdayWishMade] = useState<boolean>(false);
  const [claimedBadges, setClaimedBadges] = useState<number[]>([]);
  const [xpLogs, setXpLogs] = useState<Array<{ id: number; action: string; xp: number; date: string }>>([
    { id: 1, action: "Série d'activité atteinte", xp: 150, date: "Aujourd'hui" },
    { id: 2, action: "Budget mensuel stabilisé", xp: 100, date: "Hier" },
    { id: 3, action: "Session Focus complétée", xp: 50, date: "28 Juin" },
  ]);



  const awardXp = (amount: number, reason: string) => {
    let nextXp = userXp;
    let nextLevel = userLevel;
    const max = 2000;
    
    const potentialXp = nextXp + amount;
    let isLevelUp = false;
    if (potentialXp >= max) {
      nextLevel += 1;
      nextXp = potentialXp - max;
      alert(`🎉 FÉLICITATIONS ! Vous passez au Niveau ${nextLevel} ! 🎉`);
      isLevelUp = true;
    } else {
      nextXp = potentialXp;
    }
    
    setUserXp(nextXp);
    setUserLevel(nextLevel);
    setXpLogs(prev => [
      { id: Date.now(), action: reason, xp: amount, date: "À l'instant" },
      ...prev
    ]);

    // Construct fresh notifications list
    const newNotifications = [...notifications];
    if (isLevelUp) {
      newNotifications.unshift({
        id: Date.now() + 1,
        title: lang === 'fr' ? 'Niveau supérieur ! 🚀' : lang === 'es' ? '¡Nivel superado! 🚀' : 'Level Up! 🚀',
        content: lang === 'fr' 
          ? `Félicitations, vous avez atteint le Niveau ${nextLevel} ! Continuez vos efforts.` 
          : lang === 'es'
          ? `¡Felicidades, has alcanzado el Nivel ${nextLevel}! Sigue así.`
          : `Congratulations, you reached Level ${nextLevel}! Keep up the good work.`,
        date: new Date().toISOString(),
        read: false,
        type: 'success'
      });
    }
    
    newNotifications.unshift({
      id: Date.now(),
      title: lang === 'fr' ? 'XP Gagné ! ✨' : lang === 'es' ? '¡XP Ganado! ✨' : 'XP Earned! ✨',
      content: lang === 'fr'
        ? `+${amount} XP obtenus pour : ${reason}`
        : lang === 'es'
        ? `+${amount} XP obtenidos por: ${reason}`
        : `+${amount} XP earned for: ${reason}`,
      date: new Date().toISOString(),
      read: false,
      type: 'xp'
    });

    setNotifications(newNotifications);
    triggerSync(tasks, missions, transactions, totalBudget, spentAmount, nextXp, nextLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, newNotifications);
  };

  const t = TRANSLATIONS[lang];

  const getCurrencySymbol = (cur: 'EUR' | 'USD' | 'XAF') => {
    if (cur === 'USD') return '$';
    if (cur === 'XAF') return 'FCFA';
    return '€';
  };

  const getTransactionCategoryTotals = () => {
    const totals: Record<string, number> = {
      'Alimentation': 0,
      'Loisirs': 0,
      'Maison': 0,
      'Abonnement': 0,
      'Bonus': 0
    };
    
    transactions.forEach(t => {
      if (t.amount < 0) {
        const amt = Math.abs(t.amount);
        const cat = t.category || 'Alimentation';
        const normalizedCat = cat === 'Abonnements' ? 'Abonnement' : cat;
        if (totals[normalizedCat] !== undefined) {
          totals[normalizedCat] += amt;
        } else {
          totals['Alimentation'] += amt;
        }
      }
    });
    
    return totals;
  };

  const getWellnessHistory = () => {
    const base = getWellnessScore();
    const completedCount = tasks.filter(t => t.completed).length;
    return [
      Math.max(30, Math.min(100, 55 + (userStreak > 1 ? 10 : 0))),
      Math.max(30, Math.min(100, 60 + completedCount * 2)),
      Math.max(30, Math.min(100, 48 + selectedMood * 5)),
      Math.max(30, Math.min(100, 65 + (focusMinutes > 0 ? 10 : 0))),
      Math.max(30, Math.min(100, 58 + completedCount * 3)),
      Math.max(30, Math.min(100, 70 + (userLevel > 1 ? 5 : 0))),
      base
    ];
  };

  const getFocusHistory = () => {
    return [
      Math.max(15, Math.min(90, 25 + (userLevel > 1 ? 15 : 0))),
      Math.max(15, Math.min(90, 50 + (userStreak > 2 ? 10 : 0))),
      Math.max(15, Math.min(90, 45 - (selectedMood < 2 ? 10 : 0))),
      Math.max(15, Math.min(90, 30 + (focusMinutes > 30 ? 20 : 0))),
      Math.max(15, Math.min(90, 20 + (tasks.filter(t => t.completed).length * 5))),
      Math.max(15, Math.min(90, 40 + (userStreak * 2))),
      focusMinutes
    ];
  };

  const getUserInitials = () => {
    if (!user) return 'AN';
    const name = user.displayName || user.email || '';
    if (!name) return 'AN';
    const cleanName = name.includes('@') ? name.split('@')[0] : name;
    const parts = cleanName.trim().split(/[\s._-]+/);
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return parts[0][0]?.toUpperCase() || 'AN';
  };

  const getWellnessScore = () => {
    const moodBonus = selectedMood * 10;
    const taskBonus = tasks.length > 0 ? Math.round((tasks.filter(t => t.completed).length / tasks.length) * 10) : 5;
    return Math.min(100, 50 + moodBonus + taskBonus);
  };

  // Dynamic Aura Calculation (based on 5 main pillars from specification)
  // Pillar 1: Objectifs (25 pts)
  const goalsPillarScore = Math.round(20 + (userLevel > 2 ? 5 : 2)); // 25 max, based on personal goals & progress
  // Pillar 2: Gestion des tâches (25 pts)
  const tasksCompletedRatio = tasks.length > 0 ? (tasks.filter(tk => tk.completed).length / tasks.length) : 0.5;
  const tasksPillarScore = Math.round(tasksCompletedRatio * 25);
  // Pillar 3: Focus (20 pts)
  const focusPillarScore = Math.min(20, Math.round((focusMinutes / 120) * 20));
  // Pillar 4: Bien-être (25 pts)
  const wellnessPillarScore = hasDoneCheckIn 
    ? Math.round(((checkInMood + checkInEnergy + checkInMotivation + (6 - checkInStress)) / 20) * 25)
    : Math.round(((selectedMood + 1 + 3 + 3 + 3) / 16) * 25); // fallback based on mood selection
  // Pillar 5: Bonus (5 pts)
  const bonusPillarScore = Math.min(5, userStreak >= 5 ? 5 : userStreak);

  const auraPercentage = Math.min(100, Math.max(10, goalsPillarScore + tasksPillarScore + focusPillarScore + wellnessPillarScore + bonusPillarScore));

  const getAuraDetails = () => {
    let label = '';
    let description = '';
    
    if (auraPercentage >= 85) {
      label = lang === 'fr' ? 'Sereine' : lang === 'en' ? 'Serene' : 'Serena';
      description = lang === 'fr' 
        ? 'Votre esprit est calme et vos objectifs sont atteints. Une harmonie parfaite !' 
        : lang === 'en' 
        ? 'Your mind is calm and your goals are met. Perfect harmony!' 
        : 'Tu mente está tranquila y tus objetivos cumplidos. ¡Armonía perfecta!';
    } else if (auraPercentage >= 65) {
      label = lang === 'fr' ? 'Équilibrée' : lang === 'en' ? 'Balanced' : 'Equilibrada';
      description = lang === 'fr'
        ? 'Bonne humeur et productivité stable. Vous avancez avec équilibre.'
        : lang === 'en'
        ? 'Good mood and stable productivity. You are moving forward with balance.'
        : 'Buen humor y productividad estable. Estás avanzando con equilibrio.';
    } else if (auraPercentage >= 45) {
      label = lang === 'fr' ? 'Neutre' : lang === 'en' ? 'Neutral' : 'Neutra';
      description = lang === 'fr'
        ? 'Journée tranquille. Continuez vos tâches à votre rythme sans stress.'
        : lang === 'en'
        ? 'Quiet day. Continue your tasks at your own pace without stress.'
        : 'Día tranquilo. Sigue con tus tareas a tu propio ritmo sin estrés.';
    } else if (auraPercentage >= 25) {
      label = lang === 'fr' ? 'Agitée' : lang === 'en' ? 'Restless' : 'Agitada';
      description = lang === 'fr'
        ? 'Quelques tensions ou retard de tâches. Prenez une micro-pause de respiration.'
        : lang === 'en'
        ? 'Some tensions or delayed tasks. Take a quick mindful breathing break.'
        : 'Algunas tensiones o tareas retrasadas. Tómate un breve descanso para respirar.';
    } else {
      label = lang === 'fr' ? 'Surchargée' : lang === 'en' ? 'Overloaded' : 'Sobrecargada';
      description = lang === 'fr'
        ? 'Trop de stress ou de tâches en suspens. Laissez tomber le superflu pour aujourd\'hui !'
        : lang === 'en'
        ? 'Too much stress or pending tasks. Let go of the unnecessary for today!'
        : 'Demasiado estrés o tareas pendientes. ¡Olvida lo innecesario por hoy!';
    }
    let ageCustomMessage = '';
    if (userAge) {
      if (userAge <= 18) {
        ageCustomMessage = lang === 'fr' 
          ? " En tant qu'adolescent, l'équilibre entre vos études et votre bien-être est votre plus grande force."
          : lang === 'es'
          ? " Como adolescente, el equilibrio entre tus estudios y tu bienestar es tu mayor fuerza."
          : " As a teenager, balancing your studies and your well-being is your greatest strength.";
      } else if (userAge <= 25) {
        ageCustomMessage = lang === 'fr'
          ? " À cette étape de jeune adulte, cultivez vos passions tout en restant ancré dans le présent."
          : lang === 'es'
          ? " En esta etapa de joven adulto, cultiva tus pasiones mientras te mantienes conectado con el presente."
          : " At this young adult stage, cultivate your passions while staying grounded in the present.";
      } else if (userAge <= 45) {
        ageCustomMessage = lang === 'fr'
          ? " Pour un adulte actif, préserver votre santé mentale au milieu du tumulte est essentiel."
          : lang === 'es'
          ? " Para un adulto activo, preservar tu salud mental en medio del ajetreo es esencial."
          : " For an active adult, preserving your mental health amidst the hustle is essential.";
      } else {
        ageCustomMessage = lang === 'fr'
          ? " Votre sagesse et votre expérience guident votre chemin vers une sérénité profonde."
          : lang === 'es'
          ? " Tu sabiduría y experiencia guían tu camino hacia una profunda serenidad."
          : " Your wisdom and experience guide your path to deep serenity.";
      }
    }
    return { label, description: description + ageCustomMessage };
  };

  const aura = {
    percentage: auraPercentage,
    label: getAuraDetails().label,
    description: getAuraDetails().description
  };

  const badgeCategories = [
    {
      id: 'productivity',
      title: lang === 'fr' ? 'Productivité' : 'Productivity',
      badges: [
        {
          id: 1,
          name: lang === 'fr' ? 'Maître d’œuvre' : 'Task Master',
          desc: lang === 'fr' ? 'Compléter au moins une tâche dans l’application.' : 'Complete at least one task.',
          xpReward: 50,
          unlocked: tasks.some(t => t.completed),
          icon: '🎯'
        },
        {
          id: 2,
          name: lang === 'fr' ? 'Grand Organisateur' : 'Super Organizer',
          desc: lang === 'fr' ? 'Compléter 3 tâches ou plus.' : 'Complete 3 or more tasks.',
          xpReward: 100,
          unlocked: tasks.filter(t => t.completed).length >= 3,
          icon: '👑'
        }
      ]
    },
    {
      id: 'wellbeing',
      title: lang === 'fr' ? 'Bien-être' : 'Well-being',
      badges: [
        {
          id: 3,
          name: lang === 'fr' ? 'Esprit Calme' : 'Calm Mind',
          desc: lang === 'fr' ? 'Déclarer une humeur sereine ou positive.' : 'Log a serene or positive mood.',
          xpReward: 50,
          unlocked: selectedMood >= 2,
          icon: '🧘'
        },
        {
          id: 4,
          name: lang === 'fr' ? 'Aura Étoilée' : 'Star Aura',
          desc: lang === 'fr' ? 'Atteindre un score d’aura de 75% ou plus.' : 'Achieve an aura score of 75% or higher.',
          xpReward: 100,
          unlocked: auraPercentage >= 75,
          icon: '✨'
        }
      ]
    },
    {
      id: 'finance',
      title: lang === 'fr' ? 'Finance' : 'Finance',
      badges: [
        {
          id: 5,
          name: lang === 'fr' ? 'Épargne Nexii' : 'Nexii Savings',
          desc: lang === 'fr' ? 'Avoir dépensé moins de 50% de son budget total.' : 'Spend less than 50% of total budget.',
          xpReward: 100,
          unlocked: totalBudget > 0 && spentAmount <= totalBudget * 0.5,
          icon: '💰'
        },
        {
          id: 6,
          name: lang === 'fr' ? 'Sérénité Financière' : 'Financial Serenity',
          desc: lang === 'fr' ? 'Garder un stress financier faible (budget non dépassé).' : 'Keep financial stress low (within budget).',
          xpReward: 80,
          unlocked: totalBudget > 0 && spentAmount < totalBudget,
          icon: '🛡️'
        }
      ]
    },
    {
      id: 'focus',
      title: lang === 'fr' ? 'Focus' : 'Focus',
      badges: [
        {
          id: 7,
          name: lang === 'fr' ? 'Focus Booster' : 'Focus Starter',
          desc: lang === 'fr' ? 'Accumuler au moins 15 minutes de concentration.' : 'Accumulate 15+ minutes of focus.',
          xpReward: 50,
          unlocked: focusMinutes >= 15,
          icon: '⚡'
        },
        {
          id: 8,
          name: lang === 'fr' ? 'Zen Laser' : 'Zen Laser Focus',
          desc: lang === 'fr' ? 'Accumuler au moins 60 minutes de concentration.' : 'Accumulate 60+ minutes of focus.',
          xpReward: 120,
          unlocked: focusMinutes >= 60,
          icon: '🔮'
        }
      ]
    },
    {
      id: 'streak',
      title: lang === 'fr' ? 'Série' : 'Streak',
      badges: [
        {
          id: 9,
          name: lang === 'fr' ? 'Flambeau' : 'Activity Spark',
          desc: lang === 'fr' ? 'Maintenir une série d’activité de 3 jours ou plus.' : 'Maintain a 3+ day activity streak.',
          xpReward: 100,
          unlocked: userStreak >= 3,
          icon: '🔥'
        },
        {
          id: 10,
          name: lang === 'fr' ? 'Constance Nexii' : 'Nexii Consistency',
          desc: lang === 'fr' ? 'Atteindre une série d’activité de 10 jours ou plus.' : 'Achieve a 10+ day activity streak.',
          xpReward: 200,
          unlocked: userStreak >= 10,
          icon: '⏳'
        }
      ]
    }
  ];

  const syncStateRef = useRef({
    tasks,
    missions,
    transactions,
    totalBudget,
    spentAmount,
    userXp,
    userLevel,
    selectedMood,
    lang,
    isDarkMode,
    userStreak,
    focusMinutes,
    lastCheckInDate,
    agendaEvents,
    lastMissionsResetDate,
    currency,
    savingsGoals,
    notifications
  });

  useEffect(() => {
    syncStateRef.current = {
      tasks,
      missions,
      transactions,
      totalBudget,
      spentAmount,
      userXp,
      userLevel,
      selectedMood,
      lang,
      isDarkMode,
      userStreak,
      focusMinutes,
      lastCheckInDate,
      agendaEvents,
      lastMissionsResetDate,
      currency,
      savingsGoals,
      notifications
    };
  }, [
    tasks,
    missions,
    transactions,
    totalBudget,
    spentAmount,
    userXp,
    userLevel,
    selectedMood,
    lang,
    isDarkMode,
    userStreak,
    focusMinutes,
    lastCheckInDate,
    agendaEvents,
    lastMissionsResetDate,
    currency,
    savingsGoals,
    notifications
  ]);

  // --- High-Fidelity Firebase Authentication & Sync handlers ---
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      setUser(currentUser);
      if (currentUser) {
        setOnboardingName(currentUser.displayName || '');
        setOnboardingBirthdate('');
        setOnboardingBirthdateText('');
        setIsSyncing(true);
        setIsProfileLoaded(false);
        try {
          const userDoc = await getDoc(doc(db, 'users', currentUser.uid));
          if (userDoc.exists()) {
            const data = userDoc.data();
            
            const todayStr = new Date().toISOString().split('T')[0];
            const lastReset = data.lastMissionsResetDate || '';
            let finalMissions = data.missions || [];
            let finalReset = lastReset;

            if (lastReset !== todayStr) {
              finalMissions = getFreshMissions();
              finalReset = todayStr;
            }

            // AUTO CHECK-IN SYSTEM
            let finalCheckIn = data.lastCheckInDate || '';
            let finalStreak = data.userStreak !== undefined ? data.userStreak : 0;
            let finalXp = data.userXp !== undefined ? data.userXp : 0;
            let finalLevel = data.userLevel !== undefined ? data.userLevel : 5;
            let finalNotifs = data.notifications || [];

            if (finalCheckIn !== todayStr) {
              finalStreak = finalStreak + 1;
              finalCheckIn = todayStr;
              finalXp = finalXp + 50;
              if (finalXp >= 100) {
                finalLevel += 1;
                finalXp = finalXp - 100;
              }
              const currentLang = data.lang || 'fr';
              const autoCheckInNotif = {
                id: Date.now(),
                title: currentLang === 'es' ? '¡Racha actualizada! 🔥' : currentLang === 'en' ? 'Streak Updated! 🔥' : 'Série d\'activité mise à jour ! 🔥',
                content: currentLang === 'es' 
                  ? `Has mantenido tu racha de ${finalStreak} días seguidos de forma automática hoy.`
                  : currentLang === 'en'
                  ? `You automatically kept your streak of ${finalStreak} days today.`
                  : `Vous avez automatiquement conservé votre série d'activité de ${finalStreak} jours d'affilée aujourd'hui.`,
                date: new Date().toISOString(),
                read: false,
                type: 'success' as const
              };
              finalNotifs = [autoCheckInNotif, ...finalNotifs];
            }

            if (data.tasks) setTasks(data.tasks);
            if (data.birthdate !== undefined) {
              setUserBirthdate(data.birthdate);
              setUserAge(calculateAge(data.birthdate));
            } else if (data.age !== undefined) {
              setUserAge(data.age);
            }
            if (data.name !== undefined) {
              setOnboardingName(data.name);
            }
            if (data.transactions) {
              setTransactions(data.transactions);
              const computedSpent = data.transactions.reduce((sum: number, tx: any) => {
                if (tx && typeof tx.amount === 'number' && tx.amount < 0) {
                  return sum + Math.abs(tx.amount);
                }
                return sum;
              }, 0);
              setSpentAmount(computedSpent);
            } else {
              setTransactions([]);
              setSpentAmount(0);
            }
            if (data.totalBudget !== undefined) setTotalBudget(data.totalBudget);
            
            // Set our updated auto-check-in states:
            setUserXp(finalXp);
            setUserLevel(finalLevel);
            setLastCheckInDate(finalCheckIn);
            setUserStreak(finalStreak);
            setNotifications(finalNotifs);

            if (data.lastManualCheckInDate === todayStr) {
              setHasDoneCheckIn(true);
              if (data.checkInMood !== undefined) setCheckInMood(data.checkInMood);
              if (data.checkInEnergy !== undefined) setCheckInEnergy(data.checkInEnergy);
              if (data.checkInMotivation !== undefined) setCheckInMotivation(data.checkInMotivation);
              if (data.checkInStress !== undefined) setCheckInStress(data.checkInStress);
              if (data.checkInSleep !== undefined) setCheckInSleep(data.checkInSleep);
            } else {
              setHasDoneCheckIn(false);
            }
            if (data.lastManualCheckInDate !== undefined) {
              setLastManualCheckInDate(data.lastManualCheckInDate);
            }

            if (data.selectedMood !== undefined) setSelectedMood(data.selectedMood);
            if (data.lang !== undefined) setLang(data.lang);
            if (data.isDarkMode !== undefined) setIsDarkMode(data.isDarkMode);
            if (data.focusMinutes !== undefined) setFocusMinutes(data.focusMinutes);
            if (data.agendaEvents !== undefined) setAgendaEvents(data.agendaEvents);
            if (data.currency !== undefined) setCurrency(data.currency);
            if (data.savingsGoals !== undefined) setSavingsGoals(data.savingsGoals);
            if (data.workouts !== undefined) setWorkouts(data.workouts);
            
            setMissions(finalMissions);
            setLastMissionsResetDate(finalReset);

            if (lastReset !== todayStr || data.lastCheckInDate !== todayStr) {
              // Trigger sync with the fresh missions, streak, and notifications immediately so it gets persisted
              triggerSync(
                data.tasks || [],
                finalMissions,
                data.transactions || [],
                data.totalBudget !== undefined ? data.totalBudget : totalBudget,
                data.spentAmount !== undefined ? data.spentAmount : spentAmount,
                finalXp,
                finalLevel,
                data.selectedMood !== undefined ? data.selectedMood : selectedMood,
                data.lang !== undefined ? data.lang : lang,
                data.isDarkMode !== undefined ? data.isDarkMode : isDarkMode,
                finalStreak,
                data.focusMinutes !== undefined ? data.focusMinutes : focusMinutes,
                finalCheckIn,
                data.agendaEvents !== undefined ? data.agendaEvents : agendaEvents,
                finalReset,
                data.currency !== undefined ? data.currency : currency,
                data.savingsGoals !== undefined ? data.savingsGoals : savingsGoals,
                finalNotifs
              );
            }
          } else {
            // New user without a database profile! Clear local profile state to trigger onboarding
            setUserAge(null);
            setUserBirthdate(null);
          }
        } catch (err) {
          console.error("Firestore retrieval error:", err);
        } finally {
          setIsSyncing(false);
          setIsProfileLoaded(true);
        }
      } else {
        setIsProfileLoaded(false);
      }
    });
    return () => unsubscribe();
  }, []);

  // Trigger Birthday Confetti once on load
  useEffect(() => {
    if (isProfileLoaded && userBirthdate && isTodayBirthday(userBirthdate)) {
      const t = setTimeout(() => {
        triggerBirthdayConfetti();
      }, 1000);
      return () => clearTimeout(t);
    }
  }, [isProfileLoaded, userBirthdate]);

  const triggerSync = async (
    currentTasks = tasks, 
    currentMissions = missions, 
    currentTransactions = transactions, 
    currentBudget = totalBudget,
    currentSpent = spentAmount,
    currentXp = userXp,
    currentLevel = userLevel,
    currentMood = selectedMood,
    currentLang = lang,
    currentDarkMode = isDarkMode,
    currentStreak = userStreak,
    currentFocusMinutes = focusMinutes,
    currentLastCheckInDate = lastCheckInDate,
    currentAgendaEvents = agendaEvents,
    currentLastMissionsResetDate = lastMissionsResetDate,
    currentCurrency = currency,
    currentSavingsGoals = savingsGoals,
    currentNotifications = notifications,
    currentAge = userAge,
    currentBirthdate = userBirthdate,
    currentWorkouts = workouts,
    currentName = user?.displayName || onboardingName || '',
    currentLastManualCheckInDate = lastManualCheckInDate,
    currentCheckInMood = checkInMood,
    currentCheckInEnergy = checkInEnergy,
    currentCheckInMotivation = checkInMotivation,
    currentCheckInStress = checkInStress,
    currentCheckInSleep = checkInSleep
  ) => {
    if (!auth.currentUser) return;
    if (isOffline) {
      setPendingSync(true);
      return;
    }
    setIsSyncing(true);
    try {
      await setDoc(doc(db, 'users', auth.currentUser.uid), {
        tasks: currentTasks,
        missions: currentMissions,
        transactions: currentTransactions,
        totalBudget: currentBudget,
        spentAmount: currentSpent,
        userXp: currentXp,
        userLevel: currentLevel,
        selectedMood: currentMood,
        lang: currentLang,
        isDarkMode: currentDarkMode,
        userStreak: currentStreak,
        focusMinutes: currentFocusMinutes,
        lastCheckInDate: currentLastCheckInDate,
        lastMissionsResetDate: currentLastMissionsResetDate,
        agendaEvents: currentAgendaEvents,
        currency: currentCurrency,
        savingsGoals: currentSavingsGoals,
        notifications: currentNotifications,
        age: currentAge,
        birthdate: currentBirthdate,
        workouts: currentWorkouts,
        name: currentName,
        lastManualCheckInDate: currentLastManualCheckInDate,
        checkInMood: currentCheckInMood,
        checkInEnergy: currentCheckInEnergy,
        checkInMotivation: currentCheckInMotivation,
        checkInStress: currentCheckInStress,
        checkInSleep: currentCheckInSleep,
        updatedAt: new Date().toISOString()
      });
      setPendingSync(false);
    } catch (err) {
      console.error("Cloud synchronisation failed:", err);
    } finally {
      setIsSyncing(false);
    }
  };

  // Process pending synchronisations when online connectivity is restored
  useEffect(() => {
    if (!isOffline && pendingSync && auth.currentUser) {
      triggerSync();
    }
  }, [isOffline]);

  // Dynamically apply document root dark mode class for Tailwind support
  useEffect(() => {
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDarkMode]);

  // Daily check to reset missions when the day rolls over (even if app is left open)
  useEffect(() => {
    if (!user?.uid) return;
    
    const checkReset = () => {
      const todayStr = new Date().toISOString().split('T')[0];
      const currentResetDate = syncStateRef.current.lastMissionsResetDate;
      if (currentResetDate && currentResetDate !== todayStr) {
        const freshMissions = getFreshMissions();
        setMissions(freshMissions);
        setLastMissionsResetDate(todayStr);
        
        const s = syncStateRef.current;
        triggerSync(
          s.tasks,
          freshMissions,
          s.transactions,
          s.totalBudget,
          s.spentAmount,
          s.userXp,
          s.userLevel,
          s.selectedMood,
          s.lang,
          s.isDarkMode,
          s.userStreak,
          s.focusMinutes,
          s.lastCheckInDate,
          s.agendaEvents,
          todayStr
        );
      }
    };

    // Run immediately
    checkReset();

    // Check periodically every 10 minutes
    const intervalId = setInterval(checkReset, 10 * 60 * 1000);
    return () => clearInterval(intervalId);
  }, [lastMissionsResetDate, user?.uid]);

  // Background agenda reminder checker (Off-app system notifications)
  useEffect(() => {
    if (!user?.uid) return;
    
    // We keep track of triggered event times to prevent multiple firings within the same minute
    const triggeredEventsToday = new Set<string>();

    const checkAgendaReminders = () => {
      const todayStr = new Date().toISOString().split('T')[0];
      const now = new Date();
      const currentHHMM = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
      const triggerKey = `${todayStr}-${currentHHMM}`;

      if (triggeredEventsToday.has(triggerKey)) return;

      const matchingEvents = agendaEvents.filter(ev => ev.dayStr === todayStr && ev.time === currentHHMM);
      
      if (matchingEvents.length > 0) {
        triggeredEventsToday.add(triggerKey);
        
        matchingEvents.forEach(ev => {
          sendSystemNotification(
            lang === 'fr' ? 'Rappel d\'agenda 📅' : lang === 'es' ? 'Recordatorio de agenda 📅' : 'Agenda Reminder 📅',
            ev.title
          );

          setNotifications(prev => {
            const exists = prev.some(n => n.title.includes(ev.title) && Math.abs(Date.now() - n.id) < 60000);
            if (exists) return prev;
            return [
              {
                id: Date.now(),
                title: lang === 'fr' ? 'Rappel Agenda ⏱️' : lang === 'es' ? 'Recordatorio Agenda ⏱️' : 'Agenda Reminder ⏱️',
                content: ev.title,
                date: new Date().toISOString(),
                read: false,
                type: 'info' as const
              },
              ...prev
            ];
          });
        });
      }
    };

    // Run immediately and every 15 seconds for precise minute matching
    checkAgendaReminders();
    const interval = setInterval(checkAgendaReminders, 15000);
    return () => clearInterval(interval);
  }, [agendaEvents, lang, user?.uid]);

  const enterDemoMode = (demoEmail?: string, name?: string) => {
    setUser({
      uid: 'demo-user-12345',
      displayName: name || 'Alexandre Nexii',
      email: demoEmail || 'nexii.demo@gmail.com',
      isDemo: true
    });
    setUserAge(28); // Standard active adult age for Demo mode
    setUserBirthdate('1998-07-14');
    setIsProfileLoaded(true);
    setAuthError('');
    setTasks(DEMO_TASKS);
    setMissions(DEMO_MISSIONS);
    setTransactions(DEMO_TRANSACTIONS);
    setTotalBudget(800.00);
    setSpentAmount(479.50);
    setUserXp(1250);
    setUserLevel(5);
    setSelectedMood(2);
    setMessages(DEMO_MESSAGES);
    setUserStreak(12);
    setFocusMinutes(765);
    setWorkouts([
      { id: 1001, type: 'Course à pied', duration: 45, intensity: 'Moyenne', calories: 450, date: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split('T')[0] },
      { id: 1002, type: 'Musculation', duration: 60, intensity: 'Intense', calories: 468, date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString().split('T')[0] },
      { id: 1003, type: 'Yoga', duration: 30, intensity: 'Douce', calories: 72, date: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000).toISOString().split('T')[0] }
    ]);
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError('');
    if (!authEmail || !authPassword) {
      setAuthError('Veuillez remplir tous les champs.');
      return;
    }
    setIsSyncing(true);
    try {
      await signInWithEmailAndPassword(auth, authEmail, authPassword);
      setAuthEmail('');
      setAuthPassword('');
    } catch (err: any) {
      console.warn("Auth error, offering demo mode:", err);
      if (err.code === 'auth/operation-not-allowed') {
        setAuthError("L'authentification par email/mot de passe n'est pas activée dans votre console Firebase. Vous pouvez cliquer sur le bouton 'Mode Démo' ci-dessous pour tester l'application.");
      } else {
        setAuthError(err.message || "Erreur d'authentification.");
      }
    } finally {
      setIsSyncing(false);
    }
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError('');
    if (!authEmail || !authPassword) {
      setAuthError(lang === 'fr' ? 'Veuillez remplir tous les champs.' : lang === 'es' ? 'Por favor complete todos los campos.' : 'Please fill all fields.');
      return;
    }
    setIsSyncing(true);
    try {
      await createUserWithEmailAndPassword(auth, authEmail, authPassword);
      setAuthEmail('');
      setAuthPassword('');
      setAuthName('');
      setAuthBirthdate('');
      setAuthBirthdateText('');
    } catch (err: any) {
      console.warn("Register error, offering demo mode:", err);
      if (err.code === 'auth/operation-not-allowed') {
        setAuthError("L'inscription par email/mot de passe n'est pas activée dans votre console Firebase. Vous pouvez cliquer sur le bouton 'Mode Démo' ci-dessous pour tester l'application.");
      } else {
        setAuthError(err.message || "Erreur lors de la création du compte.");
      }
    } finally {
      setIsSyncing(false);
    }
  };

  const handleCompleteOnboarding = async (onboardingName: string, onboardingBirthdate: string) => {
    if (!user) return;
    setAuthError('');
    if (!onboardingName || !onboardingBirthdateText) {
      setAuthError(lang === 'fr' ? 'Veuillez remplir tous les champs.' : lang === 'es' ? 'Por favor complete todos los campos.' : 'Please fill all fields.');
      return;
    }
    if (!onboardingBirthdate) {
      setAuthError(lang === 'fr' ? 'Veuillez entrer une date de naissance valide au format JJ/MM/AAAA.' : lang === 'es' ? 'Por favor, introduzca una fecha de nacimiento válida (DD/MM/AAAA).' : 'Please enter a valid birthdate (DD/MM/YYYY).');
      return;
    }
    const computedAge = calculateAge(onboardingBirthdate);
    if (computedAge < 1 || computedAge > 120) {
      setAuthError(lang === 'fr' ? 'Veuillez indiquer une date de naissance valide.' : lang === 'es' ? 'Por favor ingrese una fecha de nacimiento válida.' : 'Please enter a valid birthdate.');
      return;
    }
    setIsSyncing(true);
    try {
      // Update Auth Profile display name
      if (!user.isDemo && auth.currentUser) {
        await updateProfile(auth.currentUser, { displayName: onboardingName });
      }
      
      const seedTasks: any[] = [];
      const initialMissions = getFreshMissions();
      const initialAgenda = [
        { id: 1, title: 'Méditation du matin 🧘', time: '08:30', dayStr: new Date().toISOString().split('T')[0] },
        { id: 2, title: 'Repas conscient 🍎', time: '12:30', dayStr: new Date().toISOString().split('T')[0] },
        { id: 3, title: 'Yoga de fin de journée 🤸', time: '18:00', dayStr: new Date().toISOString().split('T')[0] },
      ];
      const todayStr = new Date().toISOString().split('T')[0];

      await setDoc(doc(db, 'users', user.uid), {
        tasks: seedTasks,
        missions: initialMissions,
        transactions: [],
        totalBudget: 0,
        spentAmount: 0,
        userXp: 0,
        userLevel: 5,
        selectedMood: 2,
        lang,
        isDarkMode,
        userStreak: 1,
        focusMinutes: 0,
        lastCheckInDate: todayStr,
        lastMissionsResetDate: todayStr,
        agendaEvents: initialAgenda,
        currency,
        savingsGoals: [],
        notifications: [],
        age: computedAge,
        birthdate: onboardingBirthdate,
        name: onboardingName,
        updatedAt: new Date().toISOString()
      });

      setUserAge(computedAge);
      setUserBirthdate(onboardingBirthdate);
      setTasks(seedTasks);
      setMissions(initialMissions);
      setAgendaEvents(initialAgenda);
      setLastMissionsResetDate(todayStr);
      setLastCheckInDate(todayStr);
      setUserStreak(1);
      
      // Update local user state representation
      setUser({ ...user, displayName: onboardingName });
    } catch (err: any) {
      console.error("Onboarding setup error:", err);
      setAuthError(err.message || "Erreur lors de la finalisation du profil.");
    } finally {
      setIsSyncing(false);
    }
  };

  const startEditingProfile = () => {
    setEditName(user?.displayName || '');
    setEditBirthdate(userBirthdate || '');
    setEditBirthdateText(userBirthdate ? convertIsoToDisplay(userBirthdate) : '');
    setProfileError('');
    setIsEditingProfile(true);
  };

  const handleSaveProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;
    setProfileError('');
    if (!editName || !editBirthdateText) {
      setProfileError(lang === 'fr' ? 'Veuillez remplir tous les champs.' : lang === 'es' ? 'Por favor complete todos los campos.' : 'Please fill all fields.');
      return;
    }
    if (!editBirthdate) {
      setProfileError(lang === 'fr' ? 'Veuillez entrer une date de naissance valide au format JJ/MM/AAAA.' : lang === 'es' ? 'Por favor, introduzca una fecha de naissance de valide (DD/MM/AAAA).' : 'Please enter a valid birthdate (DD/MM/YYYY).');
      return;
    }
    const computedAge = calculateAge(editBirthdate);
    if (computedAge < 1 || computedAge > 120) {
      setProfileError(lang === 'fr' ? 'Veuillez indiquer une date de naissance valide.' : lang === 'es' ? 'Por favor ingrese una fecha de nacimiento válida.' : 'Please enter a valid birthdate.');
      return;
    }
    setIsSyncing(true);
    try {
      if (!user.isDemo && auth.currentUser) {
        await updateProfile(auth.currentUser, { displayName: editName });
      }
      setUser({ ...user, displayName: editName });
      setUserAge(computedAge);
      setUserBirthdate(editBirthdate);
      
      await triggerSync(
        tasks,
        missions,
        transactions,
        totalBudget,
        spentAmount,
        userXp,
        userLevel,
        selectedMood,
        lang,
        isDarkMode,
        userStreak,
        focusMinutes,
        lastCheckInDate,
        agendaEvents,
        lastMissionsResetDate,
        currency,
        savingsGoals,
        notifications,
        computedAge,
        editBirthdate,
        workouts,
        editName
      );
      
      setIsEditingProfile(false);
    } catch (err: any) {
      console.error("Save profile error:", err);
      setProfileError(err.message || "Erreur lors de la sauvegarde.");
    } finally {
      setIsSyncing(false);
    }
  };

  const handleSubmitFeedback = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) {
      alert(lang === 'fr' ? "Veuillez vous connecter pour envoyer votre retour !" : lang === 'es' ? "¡Inicie sesión para enviar sus comentarios!" : "Please sign in to send feedback!");
      return;
    }
    const commentText = feedbackComment.trim();
    if (!commentText) {
      alert(lang === 'fr' ? "Veuillez écrire un commentaire avant d'envoyer." : lang === 'es' ? "Por favor escriba un comentario antes de enviar." : "Please write a comment before sending.");
      return;
    }

    setIsSubmittingFeedback(true);
    try {
      const feedbackData = {
        rating: feedbackRating,
        comment: commentText,
        userEmail: user.email || '',
        userLevel: userLevel || 1,
        userXp: userXp || 0,
        timestamp: new Date().toISOString()
      };

      await addDoc(collection(db, 'users', user.uid, 'feedback'), feedbackData);
      
      setFeedbackComment('');
      setFeedbackRating(5);
      
      alert(lang === 'fr' 
        ? "Merci pour vos retours ! Votre avis a bien été enregistré. 💜" 
        : lang === 'es'
        ? "¡Gracias por sus comentarios! Su opinión ha sido registrada con éxito. 💜"
        : "Thank you for your feedback! Your opinion has been registered. 💜"
      );
    } catch (err: any) {
      console.error("Error submitting feedback:", err);
      alert(lang === 'fr' 
        ? "Une erreur est survenue lors de l'envoi de votre retour." 
        : lang === 'es'
        ? "Ocurrió un error al enviar sus comentarios."
        : "An error occurred while submitting your feedback."
      );
    } finally {
      setIsSubmittingFeedback(false);
    }
  };

  const triggerBirthdayConfetti = () => {
    playBirthdayChime();
    
    const duration = 4 * 1000;
    const end = Date.now() + duration;

    (function frame() {
      confetti({
        particleCount: 3,
        angle: 60,
        spread: 55,
        origin: { x: 0 },
        colors: ['#ec4899', '#a855f7', '#3b82f6', '#10b981', '#f59e0b']
      });
      confetti({
        particleCount: 3,
        angle: 120,
        spread: 55,
        origin: { x: 1 },
        colors: ['#ec4899', '#a855f7', '#3b82f6', '#10b981', '#f59e0b']
      });

      if (Date.now() < end) {
        requestAnimationFrame(frame);
      }
    }());

    confetti({
      particleCount: 150,
      spread: 85,
      origin: { y: 0.6 },
      colors: ['#ec4899', '#a855f7', '#3b82f6', '#10b981', '#f59e0b', '#f43f5e']
    });
  };

  const handleForgotPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError('');
    if (!authEmail) {
      setAuthError('Veuillez entrer votre adresse email.');
      return;
    }
    setIsSyncing(true);
    try {
      await sendPasswordResetEmail(auth, authEmail);
      alert('Email de réinitialisation envoyé !');
      setAuthMode('login');
    } catch (err: any) {
      setAuthError(err.message || 'Erreur lors de l\'envoi de l\'email');
    } finally {
      setIsSyncing(false);
    }
  };

  const handleSignOut = async () => {
    try {
      await firebaseSignOut(auth);
    } catch (err) {
      console.error("SignOut error:", err);
    }
    setUser(null);
    setUserAge(null);
    setUserBirthdate(null);
    setIsProfileLoaded(false);
    setTasks([]);
    setMissions([]);
    setTransactions([]);
    setWorkouts([]);
    setTotalBudget(0);
    setSpentAmount(0);
    setUserXp(0);
    setUserLevel(1);
    setSelectedMood(2);
    setMessages([]);
    setUserStreak(1);
    setFocusMinutes(0);
    setAuthEmail('');
    setAuthPassword('');
    setAuthName('');
    setAuthBirthdate('');
    setAuthBirthdateText('');
    setAuthError('');
    setEditName('');
    setEditBirthdate('');
    setEditBirthdateText('');
    setIsEditingProfile(false);
    setProfileError('');
  };

  const handleGoogleSignIn = async () => {
    setAuthError('');
    setIsSyncing(true);
    try {
      const provider = new GoogleAuthProvider();
      await signInWithPopup(auth, provider);
    } catch (err: any) {
      console.warn("Google sign-in error, using local demo fallback:", err);
      enterDemoMode('alexandre.nexii@gmail.com', 'Alexandre Nexii');
    } finally {
      setIsSyncing(false);
    }
  };

  const selectMoodAndSync = (mIndex: number) => {
    setSelectedMood(mIndex);
    let nextStreak = userStreak;
    if (userStreak === 0) {
      nextStreak = 1;
      setUserStreak(1);
    }
    triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, mIndex, lang, isDarkMode, nextStreak);
  };

  // Breathing recovery countdown timer
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (recoveryOverlay && recoverySeconds > 0) {
      interval = setInterval(() => {
        setRecoverySeconds(prev => {
          if (prev <= 1) {
            setRecoveryOverlay(false);
            sendSystemNotification(
              lang === 'fr' ? 'Récupération Terminée 🧘✨' : lang === 'es' ? 'Recuperación Completada 🧘✨' : 'Recovery Completed 🧘✨',
              lang === 'fr' ? 'Votre temps de récupération est terminé. Vous êtes prêt à vous reconcentrer !' : 'Your recovery time has ended. You are ready to focus again!'
            );
            alert("Bravo ! Votre temps de récupération est terminé. Vous vous sentez plus serein ! 🧘✨");
            awardXp(40, "Session de récupération guidée");
            return 300;
          }
          return prev - 1;
        });
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [recoveryOverlay, recoverySeconds]);

  // Synchroniser le son d'ambiance avec l'état du minuteur et du choix sonore
  useEffect(() => {
    if (ambientSynthRef.current) {
      ambientSynthRef.current.setVolume(soundVolume);
      if (timerRunning && selectedSound !== 'Silence') {
        ambientSynthRef.current.playByName(selectedSound);
      } else {
        ambientSynthRef.current.stopAll();
      }
    }
    return () => {
      if (ambientSynthRef.current) {
        ambientSynthRef.current.stopAll();
      }
    };
  }, [timerRunning, selectedSound, soundVolume]);

  // Sync Focus Timer countdown
  useEffect(() => {
    if (timerRunning) {
      timerIntervalRef.current = setInterval(() => {
        setTimerSeconds((prev) => {
          if (prev <= 1) {
            setTimerRunning(false);
            // Increment Pomodoro session if in Pomodoro
            if (timerType === 'Pomodoro') {
              setPomodoroSession(s => s < 4 ? s + 1 : 1);
            }
            
            const addedXp = timerType === 'Coherence' ? 4 : 40;
            const addedMinutes = timerType === 'Coherence' ? 2 : Math.round(initialDuration / 60);

            let nextXp = userXp + addedXp;
            let nextLevel = userLevel;
            if (nextXp >= 2000) {
              nextLevel += 1;
              nextXp = nextXp - 2000;
              setUserLevel(nextLevel);
            }
            setUserXp(nextXp);

            let nextFocusMinutes = focusMinutes;
            setFocusMinutes((prevMin) => {
              nextFocusMinutes = prevMin + addedMinutes;
              return nextFocusMinutes;
            });

            // Auto-update focus mission if active
            const updatedMissions = missions.map(m => 
              m.targetType === 'focus' ? { ...m, progress: 1.0, completed: true } : m
            );
            setMissions(updatedMissions);

            let nextStreak = userStreak;
            if (userStreak === 0) {
              nextStreak = 1;
              setUserStreak(1);
            }

            const isCoherence = timerType === 'Coherence';
            const sessionTitle = isCoherence
              ? (lang === 'fr' ? 'Cohérence Cardiaque Réussie ! 🧘' : lang === 'es' ? '¡Coherencia Cardíaca Completada! 🧘' : 'Cardiac Coherence Cleared! 🧘')
              : (lang === 'fr' ? 'Session Focus Réussie ! ⏱️' : lang === 'es' ? '¡Sesión de Enfoque Completada! ⏱️' : 'Focus Session Cleared! ⏱️');

            const sessionContent = isCoherence
              ? (lang === 'fr'
                ? `Excellent travail ! Vous avez complété une session de 2 minutes de cohérence cardiaque.`
                : `Great job! You have completed a 2-minute cardiac coherence session.`)
              : (lang === 'fr'
                ? `Excellent travail ! Vous avez complété une session de ${addedMinutes} minutes de concentration.`
                : `Great job! You have successfully completed a ${addedMinutes}-minute focus session.`);

            const latestNotifications = [
              {
                id: Date.now() + 1,
                title: sessionTitle,
                content: sessionContent,
                date: new Date().toISOString(),
                read: false,
                type: 'success' as const
              },
              {
                id: Date.now(),
                title: lang === 'fr' ? 'XP Gagné ! ✨' : 'XP Earned! ✨',
                content: lang === 'fr' ? `+${addedXp} XP pour votre session.` : `+${addedXp} XP for your session.`,
                date: new Date().toISOString(),
                read: false,
                type: 'xp' as const
              },
              ...syncStateRef.current.notifications
            ];
            setNotifications(latestNotifications);

            // Sync to Firestore
            triggerSync(tasks, updatedMissions, transactions, totalBudget, spentAmount, nextXp, nextLevel, selectedMood, lang, isDarkMode, nextStreak, nextFocusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, latestNotifications);

            sendSystemNotification(sessionTitle, sessionContent);

            if (isCoherence) {
              alert(lang === 'fr' ? "Félicitations ! Votre séance de Cohérence Cardiaque est terminée. Vous gagnez +4 XP ! 💜" : "Congratulations! Your Cardiac Coherence session is complete. You earn +4 XP! 💜");
            } else {
              alert(lang === 'fr' ? "Félicitations ! Votre session Focus est terminée. Vous gagnez +40 XP ! ⏱️" : "Congratulations! Your focus session is complete. You earn +40 XP! ⏱️");
            }
            return isCoherence ? 120 : initialDuration;
          }
          return prev - 1;
        });
      }, 1000);
    } else {
      if (timerIntervalRef.current) clearInterval(timerIntervalRef.current);
    }
    return () => {
      if (timerIntervalRef.current) clearInterval(timerIntervalRef.current);
    };
  }, [timerRunning, initialDuration, userXp, userLevel, focusMinutes, missions, userStreak, selectedMood, lang, isDarkMode, timerType]);

  // Breathing animation cycle for Cardiac Coherence (5s inhale / 5s exhale = Resonance)
  useEffect(() => {
    let interval: NodeJS.Timeout | null = null;
    if (timerRunning && timerType === 'Coherence') {
      setBreathPhase('inhale');
      interval = setInterval(() => {
        setBreathPhase((prev) => (prev === 'inhale' ? 'exhale' : 'inhale'));
        try {
          const AudioContextClass = window.AudioContext || (window as any).webkitAudioContext;
          if (AudioContextClass) {
            const audioCtx = new AudioContextClass();
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            
            osc.type = 'sine';
            osc.frequency.setValueAtTime(392, audioCtx.currentTime); // G4 relaxing chime
            
            gain.gain.setValueAtTime(0, audioCtx.currentTime);
            gain.gain.linearRampToValueAtTime(0.04, audioCtx.currentTime + 0.1);
            gain.gain.exponentialRampToValueAtTime(0.00001, audioCtx.currentTime + 1.2);
            
            osc.start();
            osc.stop(audioCtx.currentTime + 1.5);
          }
        } catch (e) {
          console.warn(e);
        }
      }, 5000);
    } else {
      setBreathPhase('inhale');
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [timerRunning, timerType]);

  const formatTimer = (sec: number) => {
    const mins = Math.floor(sec / 60);
    const secs = sec % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const changeTimerPreset = (minutes: number) => {
    setTimerRunning(false);
    setInitialDuration(minutes * 60);
    setTimerSeconds(minutes * 60);
  };

  // Chat message send handler
  const handleSendMessage = (customText?: string) => {
    const inputToSend = customText || chatInput;
    if (!inputToSend.trim()) return;
    
    const userMsg = {
      id: Date.now(),
      text: inputToSend,
      isUser: true
    };
    
    setMessages(prev => [...prev, userMsg]);
    const textLower = inputToSend.toLowerCase();
    if (!customText) setChatInput('');
    setIsTyping(true);

    // Auto-update coach mission if active
    const updatedMissions = missions.map(m => 
      m.targetType === 'coach' ? { ...m, progress: 1.0, completed: true } : m
    );
    setMissions(updatedMissions);

    let nextStreak = userStreak;
    if (userStreak === 0) {
      nextStreak = 1;
      setUserStreak(1);
    }

    // AI Coach smart auto-reply
    setTimeout(async () => {
      let replyText = "";
      
      // Attempt full-stack AI call securely if not set to local
      if (selectedAiProvider !== 'local') {
        try {
          const response = await fetch('/api/coach', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              userMessage: inputToSend,
              nexiiState: getWellnessScore(),
              budgetProgress: totalBudget > 0 ? (spentAmount / totalBudget) * 100 : 0,
              completedTasksCount: tasks.filter(t => t.completed).length,
              totalTasksCount: tasks.length,
              contextMood: moods[selectedMood]?.label[lang] || 'Bien',
              provider: selectedAiProvider,
              userAge: userAge,
              hasDoneCheckIn: hasDoneCheckIn,
              checkInMood: checkInMood,
              checkInEnergy: checkInEnergy,
              checkInMotivation: checkInMotivation,
              checkInStress: checkInStress,
              checkInSleep: checkInSleep,
              focusTimerMode: focusTimerMode,
              timerType: timerType
            })
          });
          const data = await response.json();
          if (data && data.text) {
            replyText = data.text;
          }
        } catch (e) {
          console.error("Express AI Coach call failed, falling back to heuristic:", e);
        }
      }

      // Fallback heuristics
      if (!replyText) {
        let replyKey = 'default';
        if (textLower.includes('stress') || textLower.includes('anxi') || textLower.includes('peur') || textLower.includes('angoiss')) {
          replyKey = 'stress';
        } else if (textLower.includes('fatig') || textLower.includes('crev') || textLower.includes('sommeil') || textLower.includes('épuis')) {
          replyKey = 'fatigue';
        } else if (textLower.includes('argent') || textLower.includes('budget') || textLower.includes('finan') || textLower.includes('sous')) {
          replyKey = 'budget';
        } else if (textLower.includes('salut') || textLower.includes('bonjour') || textLower.includes('hello') || textLower.includes('hey')) {
          replyKey = 'salut';
        } else if (textLower.includes('merci') || textLower.includes('cool') || textLower.includes('génial')) {
          replyKey = 'merci';
        }
        replyText = CHAT_RESPONSES[replyKey as keyof typeof CHAT_RESPONSES][lang];
      }

      setMessages(prev => [...prev, {
        id: Date.now() + 1,
        text: replyText,
        isUser: false
      }]);
      setIsTyping(false);

      if (isVoiceModeRef.current) {
        speakText(replyText);
      }

      // Award dynamic well-being XP
      awardXp(15, lang === 'fr' ? 'Interaction Coach IA' : 'AI Coach Interaction');
    }, 1000);

    triggerSync(tasks, updatedMissions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, nextStreak);
  };

  useEffect(() => {
    handleSendMessageRef.current = handleSendMessage;
  }, [handleSendMessage]);

  // Add customized tasks in the interactive list
  const handleAddTask = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTaskTitle.trim()) return;
    const newTask = {
      id: Date.now(),
      title: newTaskTitle,
      category: newTaskCategory,
      priority: newTaskPriority,
      urgency: newTaskUrgency,
      difficulty: newTaskDifficulty,
      energyNeeded: newTaskEnergy,
      duration: newTaskDuration,
      completed: false,
      expanded: false,
      subtasks: []
    };
    const updated = [...tasks, newTask];
    setTasks(updated);
    setNewTaskTitle('');

    // Auto-update task mission progress
    const updatedMissions = missions.map(m => 
      m.targetType === 'tasks' ? { ...m, progress: 1.0, completed: true } : m
    );
    setMissions(updatedMissions);

    let nextStreak = userStreak;
    if (userStreak === 0) {
      nextStreak = 1;
      setUserStreak(1);
    }

    triggerSync(updated, updatedMissions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, nextStreak);
  };

  // Asynchronous generation of AI-recommended tasks via Gemini
  const generateAiTasks = async () => {
    setIsGeneratingTasks(true);
    try {
      const response = await fetch('/api/tasks/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          nexiiState: getWellnessScore(),
          mood: moods[selectedMood]?.label[lang] || 'Bien',
          lang: lang,
          userAge: userAge
        })
      });
      const data = await response.json();
      if (data && data.tasks) {
        const newTasksList = data.tasks.map((t: any, index: number) => ({
          id: Date.now() + index,
          title: t.title,
          category: t.category,
          priority: t.priority,
          urgency: t.urgency || 'Moyenne',
          difficulty: t.difficulty || 'Moyen',
          energyNeeded: t.energyNeeded || 'Moyenne',
          duration: parseInt(t.duration) || 30,
          completed: false,
          expanded: false,
          subtasks: t.subtasks ? t.subtasks.map((st: string, sIdx: number) => ({
            id: Date.now() + index * 100 + sIdx,
            title: st,
            completed: false
          })) : []
        }));
        const updated = [...tasks, ...newTasksList];
        setTasks(updated);
        
        // Award XP for utilizing Gemini AI task recommender!
        awardXp(40, lang === 'fr' ? "Recommandations IA Générées" : "AI Recommendations Generated");
        
        // Append a notification message in Coach log
        setMessages(prev => [...prev, {
          id: Date.now(),
          text: lang === 'fr' ? "✨ Nexii a analysé votre état énergétique et a ajouté 3 tâches sur-mesure à votre checklist !" :
                lang === 'es' ? "✨ ¡Nexii analizó tu energía y añadió 3 tareas personalizadas a tu checklist!" :
                "✨ Nexii analyzed your energy state and added 3 custom tasks to your checklist!",
          isUser: false
        }]);
        
        triggerSync(updated, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak);
      }
    } catch (err) {
      console.error("Failed to generate AI tasks:", err);
    } finally {
      setIsGeneratingTasks(false);
    }
  };

  // Sport Tracking Handlers
  const handleAddWorkout = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newWorkoutDuration) return;
    const durationMin = parseInt(newWorkoutDuration, 10);
    if (isNaN(durationMin) || durationMin <= 0) return;

    // Calculate calories dynamically based on activity type & intensity
    let kcalPerMin = 7;
    switch (newWorkoutType) {
      case 'Course à pied': kcalPerMin = 10; break;
      case 'Musculation': kcalPerMin = 6; break;
      case 'Yoga': kcalPerMin = 3; break;
      case 'Cyclisme': kcalPerMin = 8; break;
      case 'Natation': kcalPerMin = 9; break;
      case 'Marche': kcalPerMin = 4; break;
      case 'Boxe': kcalPerMin = 11; break;
      case 'Football': kcalPerMin = 9; break;
      case 'Danse': kcalPerMin = 6; break;
      default: kcalPerMin = 7;
    }

    let multiplier = 1.0;
    if (newWorkoutIntensity === 'Douce') multiplier = 0.8;
    if (newWorkoutIntensity === 'Intense') multiplier = 1.3;

    const calculatedCalories = Math.round(durationMin * kcalPerMin * multiplier);

    const workoutObj = {
      id: Date.now(),
      type: newWorkoutType,
      duration: durationMin,
      intensity: newWorkoutIntensity,
      calories: calculatedCalories,
      date: newWorkoutDate || new Date().toISOString().split('T')[0]
    };

    const updatedWorkouts = [workoutObj, ...workouts];
    setWorkouts(updatedWorkouts);
    setNewWorkoutDuration('');

    // Reward: Give a nice well-being XP bonus of 25 XP for working out!
    let nextXp = userXp + 25;
    let nextLevel = userLevel;
    if (nextXp >= 100) {
      nextLevel += 1;
      nextXp = nextXp - 100;
      setNotifications(prev => [
        {
          id: Date.now(),
          title: lang === 'fr' ? '🌟 Niveau Supérieur !' : '🌟 Level Up!',
          content: lang === 'fr' 
            ? `Félicitations ! Vous avez atteint le niveau ${nextLevel} grâce à votre séance de sport. Continuez ainsi !` 
            : `Congrats! You reached level ${nextLevel} thanks to your workout session. Keep it up!`,
          date: new Date().toISOString(),
          read: false,
          type: 'xp'
        },
        ...prev
      ]);
    }

    triggerSync(
      tasks,
      missions,
      transactions,
      totalBudget,
      spentAmount,
      nextXp,
      nextLevel,
      selectedMood,
      lang,
      isDarkMode,
      userStreak,
      focusMinutes,
      lastCheckInDate,
      agendaEvents,
      lastMissionsResetDate,
      currency,
      savingsGoals,
      notifications,
      userAge,
      userBirthdate,
      updatedWorkouts
    );
  };

  const handleDeleteWorkout = (id: number) => {
    const updated = workouts.filter(w => w.id !== id);
    setWorkouts(updated);
    triggerSync(
      tasks,
      missions,
      transactions,
      totalBudget,
      spentAmount,
      userXp,
      userLevel,
      selectedMood,
      lang,
      isDarkMode,
      userStreak,
      focusMinutes,
      lastCheckInDate,
      agendaEvents,
      lastMissionsResetDate,
      currency,
      savingsGoals,
      notifications,
      userAge,
      userBirthdate,
      updated
    );
  };

  const handleCopyCode = (code: string, path: string) => {
    navigator.clipboard.writeText(code);
    setCopiedPath(path);
    setTimeout(() => setCopiedPath(null), 2000);
  };

  // Toggle checklist tasks
  const toggleTask = (id: number) => {
    const task = tasks.find(t => t.id === id);
    const wasCompleted = task ? task.completed : false;
    const updated = tasks.map(t => t.id === id ? { ...t, completed: !t.completed } : t);
    setTasks(updated);

    // Auto-update task mission progress if a task is completed
    const hasCompleted = updated.some(t => t.completed);
    let updatedMissions = missions;
    if (hasCompleted) {
      updatedMissions = missions.map(m => 
        m.targetType === 'tasks' ? { ...m, progress: 1.0, completed: true } : m
      );
      setMissions(updatedMissions);
    }

    let nextStreak = userStreak;
    if (userStreak === 0) {
      nextStreak = 1;
      setUserStreak(1);
    }

    const newNotifications = [...notifications];
    if (task && !wasCompleted) {
      newNotifications.unshift({
        id: Date.now(),
        title: lang === 'fr' ? 'Tâche accomplie ! ✅' : lang === 'es' ? '¡Tarea completada! ✅' : 'Task Completed! ✅',
        content: lang === 'fr' 
          ? `Félicitations, vous avez terminé la tâche : "${task.title}"` 
          : lang === 'es'
          ? `Felicidades, has terminado la tarea: "${task.title}"`
          : `Congratulations, you completed the task: "${task.title}"`,
        date: new Date().toISOString(),
        read: false,
        type: 'success'
      });
      setNotifications(newNotifications);
    }

    triggerSync(updated, updatedMissions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, nextStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, newNotifications);
  };

  // Toggle subtasks
  const toggleSubtask = (taskId: number, subtaskId: number) => {
    let completedSubtaskTitle = '';
    let parentTaskTitle = '';
    let becameCompleted = false;

    const updated = tasks.map(t => {
      if (t.id === taskId) {
        parentTaskTitle = t.title;
        const subtask = t.subtasks.find(st => st.id === subtaskId);
        if (subtask && !subtask.completed) {
          completedSubtaskTitle = subtask.title;
        }
        const updatedSubtasks = t.subtasks.map(st => st.id === subtaskId ? { ...st, completed: !st.completed } : st);
        const allCompleted = updatedSubtasks.length > 0 && updatedSubtasks.every(st => st.completed);
        if (allCompleted && !t.completed) {
          becameCompleted = true;
        }
        return {
          ...t,
          subtasks: updatedSubtasks,
          completed: allCompleted
        };
      }
      return t;
    });
    setTasks(updated);

    // Auto-update task mission progress if a task/subtask is completed
    const hasCompleted = updated.some(t => t.completed);
    let updatedMissions = missions;
    if (hasCompleted) {
      updatedMissions = missions.map(m => 
        m.targetType === 'tasks' ? { ...m, progress: 1.0, completed: true } : m
      );
      setMissions(updatedMissions);
    }

    let nextStreak = userStreak;
    if (userStreak === 0) {
      nextStreak = 1;
      setUserStreak(1);
    }

    const newNotifications = [...notifications];
    if (completedSubtaskTitle) {
      newNotifications.unshift({
        id: Date.now(),
        title: lang === 'fr' ? 'Sous-tâche validée ! ☑️' : lang === 'es' ? '¡Subtarea validada! ☑️' : 'Subtask Cleared! ☑️',
        content: lang === 'fr'
          ? `Sous-tâche "${completedSubtaskTitle}" validée pour la tâche "${parentTaskTitle}".`
          : `Subtask "${completedSubtaskTitle}" cleared under task "${parentTaskTitle}".`,
        date: new Date().toISOString(),
        read: false,
        type: 'success'
      });
      
      if (becameCompleted) {
        newNotifications.unshift({
          id: Date.now() + 1,
          title: lang === 'fr' ? 'Tâche accomplie ! ✅' : 'Task Completed! ✅',
          content: lang === 'fr' 
            ? `Toutes les sous-tâches de "${parentTaskTitle}" ont été complétées !`
            : `All subtasks for "${parentTaskTitle}" have been successfully completed!`,
          date: new Date().toISOString(),
          read: false,
          type: 'success'
        });
      }
      setNotifications(newNotifications);
    }

    triggerSync(updated, updatedMissions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, nextStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, newNotifications);
  };

  // Toggle expanded task
  const toggleTaskExpanded = (id: number, e: React.MouseEvent) => {
    e.stopPropagation();
    setTasks(prev => prev.map(t => t.id === id ? { ...t, expanded: !t.expanded } : t));
  };

  // Claim Mission XP
  const claimMissionXp = (id: number) => {
    let nextXp = userXp;
    let nextLevel = userLevel;
    let missionTitle = '';
    let missionXpVal = 0;
    
    const updatedMissions = missions.map(m => {
      if (m.id === id) {
        if (!m.claimed) {
          missionTitle = m.title;
          missionXpVal = m.xp;
          const potentialXp = nextXp + m.xp;
          if (potentialXp >= 2000) {
            nextLevel += 1;
            nextXp = potentialXp - 2000;
            alert(`🎉 FÉLICITATIONS ! Vous passez au Niveau ${nextLevel} ! 🎉`);
          } else {
            nextXp = potentialXp;
          }
        }
        return { ...m, claimed: true };
      }
      return m;
    });

    setMissions(updatedMissions);
    setUserXp(nextXp);
    setUserLevel(nextLevel);

    const newNotifications = [...notifications];
    if (missionTitle) {
      newNotifications.unshift({
        id: Date.now(),
        title: lang === 'fr' ? 'Défi accompli ! 🏆' : lang === 'es' ? '¡Desafío cumplido! 🏆' : 'Challenge Completed! 🏆',
        content: lang === 'fr'
          ? `Vous avez réclamé +${missionXpVal} XP pour le défi : "${missionTitle}"`
          : lang === 'es'
          ? `Has reclamado +${missionXpVal} XP por el desafío: "${missionTitle}"`
          : `You claimed +${missionXpVal} XP for challenge: "${missionTitle}"`,
        date: new Date().toISOString(),
        read: false,
        type: 'success'
      });
      setNotifications(newNotifications);
    }

    triggerSync(tasks, updatedMissions, transactions, totalBudget, spentAmount, nextXp, nextLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, newNotifications);
  };

  // Add Transaction Handler
  const handleAddTransaction = (e: React.FormEvent) => {
    e.preventDefault();
    const amountNum = parseFloat(transAmount);
    if (!transTitle.trim() || isNaN(amountNum)) return;

    const finalAmount = transIsExpense ? -Math.abs(amountNum) : Math.abs(amountNum);
    const newTrans = {
      id: Date.now(),
      title: transTitle,
      amount: finalAmount,
      category: transCategory,
      date: 'Aujourd\'hui',
      isNegative: transIsExpense
    };

    const updatedTrans = [newTrans, ...transactions];
    const nextSpent = transIsExpense ? spentAmount + Math.abs(amountNum) : spentAmount - Math.abs(amountNum);

    setTransactions(updatedTrans);
    setSpentAmount(nextSpent);
    setTransTitle('');
    setTransAmount('');
    setShowAddTransaction(false);

    // Auto-update budget mission if active
    const updatedMissions = missions.map(m => 
      m.targetType === 'budget' ? { ...m, progress: 1.0, completed: true } : m
    );
    setMissions(updatedMissions);

    let nextStreak = userStreak;
    if (userStreak === 0) {
      nextStreak = 1;
      setUserStreak(1);
    }

    triggerSync(tasks, updatedMissions, updatedTrans, totalBudget, nextSpent, userXp, userLevel, selectedMood, lang, isDarkMode, nextStreak, focusMinutes);
  };

  // Delete Transaction Handler
  const handleDeleteTransaction = (id: number) => {
    const transToDelete = transactions.find(t => t.id === id);
    if (!transToDelete) return;
    
    const updatedTrans = transactions.filter(t => t.id !== id);
    const isExpense = transToDelete.amount < 0;
    const amountVal = Math.abs(transToDelete.amount);
    const nextSpent = isExpense ? spentAmount - amountVal : spentAmount + amountVal;
    
    setTransactions(updatedTrans);
    setSpentAmount(nextSpent);
    
    triggerSync(tasks, missions, updatedTrans, totalBudget, nextSpent, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, notifications);
  };

  // Delete Task Handler
  const handleDeleteTask = (id: number, e: React.MouseEvent) => {
    e.stopPropagation();
    const updated = tasks.filter(t => t.id !== id);
    setTasks(updated);
    
    // Auto-update task mission progress
    const updatedMissions = missions.map(m => 
      m.targetType === 'tasks' ? { ...m, progress: Math.min(1.0, updated.filter(t => t.completed).length / Math.max(1, updated.length)) } : m
    );
    setMissions(updatedMissions);

    triggerSync(updated, updatedMissions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, notifications);
  };

  // Currency Converter and Switch Handler
  const handleCurrencyChange = (newCurrency: 'EUR' | 'USD' | 'XAF') => {
    if (newCurrency === currency) return;
    const nextTotalBudget = convertCurrency(totalBudget, currency, newCurrency);
    const nextSpentAmount = convertCurrency(spentAmount, currency, newCurrency);
    const updatedTrans = transactions.map(t => ({
      ...t,
      amount: convertCurrency(t.amount, currency, newCurrency)
    }));
    const updatedGoals = savingsGoals.map(g => ({
      ...g,
      targetAmount: convertCurrency(g.targetAmount || 0, currency, newCurrency),
      savedAmount: convertCurrency(g.savedAmount || 0, currency, newCurrency)
    }));

    setTotalBudget(nextTotalBudget);
    setSpentAmount(nextSpentAmount);
    setTransactions(updatedTrans);
    setSavingsGoals(updatedGoals);
    setCurrency(newCurrency);

    triggerSync(tasks, missions, updatedTrans, nextTotalBudget, nextSpentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, newCurrency, updatedGoals, notifications);
  };

  const handleAddSavingsGoal = (e: React.FormEvent) => {
    e.preventDefault();
    const targetNum = parseFloat(goalTarget);
    const savedNum = parseFloat(goalSaved) || 0;
    if (!goalTitle.trim() || isNaN(targetNum)) return;

    const newGoal = {
      id: Date.now(),
      title: goalTitle,
      targetAmount: targetNum,
      savedAmount: Math.min(savedNum, targetNum)
    };

    const updatedGoals = [...savingsGoals, newGoal];
    setSavingsGoals(updatedGoals);
    setGoalTitle('');
    setGoalTarget('');
    setGoalSaved('');
    setShowAddGoal(false);

    const newNotifications = [...notifications];
    newNotifications.unshift({
      id: Date.now(),
      title: lang === 'fr' ? 'Objectif d\'épargne créé ! 🎯' : lang === 'es' ? '¡Meta de ahorro creada! 🎯' : 'Savings Goal Created! 🎯',
      content: lang === 'fr'
        ? `Nouvel objectif : "${goalTitle}" (${targetNum} ${currency})`
        : `New goal: "${goalTitle}" (${targetNum} ${currency})`,
      date: new Date().toISOString(),
      read: false,
      type: 'success' as const
    });
    setNotifications(newNotifications);

    triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, updatedGoals, newNotifications);
  };

  const handleDeleteGoal = (id: number) => {
    const updatedGoals = savingsGoals.filter(g => g.id !== id);
    setSavingsGoals(updatedGoals);
    triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, updatedGoals);
  };

  const handleAddSavingsAmount = (id: number, amount: number) => {
    let goalTitleStr = '';
    let isCompletedNow = false;
    let newSavedTotal = 0;
    let targetVal = 0;

    const updatedGoals = savingsGoals.map(g => {
      if (g.id === id) {
        goalTitleStr = g.title;
        targetVal = g.targetAmount;
        const nextSaved = Math.min(g.targetAmount, g.savedAmount + amount);
        newSavedTotal = nextSaved;
        if (nextSaved >= g.targetAmount && g.savedAmount < g.targetAmount) {
          isCompletedNow = true;
        }
        return { ...g, savedAmount: nextSaved };
      }
      return g;
    });
    setSavingsGoals(updatedGoals);

    const newNotifications = [...notifications];
    if (isCompletedNow) {
      newNotifications.unshift({
        id: Date.now(),
        title: lang === 'fr' ? 'Objectif d\'épargne Atteint ! 🎉' : 'Savings Goal Reached! 🎉',
        content: lang === 'fr'
          ? `Félicitations ! Vous avez épargné la totalité de l'objectif "${goalTitleStr}" (${targetVal} ${currency}) !`
          : `Congratulations! You saved the full amount for goal "${goalTitleStr}" (${targetVal} ${currency})!`,
        date: new Date().toISOString(),
        read: false,
        type: 'success' as const
      });
      // Award extra 100 XP for completing a savings goal
      awardXp(100, lang === 'fr' ? `Objectif d'épargne "${goalTitleStr}" complété` : `Savings goal "${goalTitleStr}" completed`);
    } else if (goalTitleStr) {
      newNotifications.unshift({
        id: Date.now(),
        title: lang === 'fr' ? 'Épargne ajoutée ! 💰' : 'Savings added! 💰',
        content: lang === 'fr'
          ? `+${amount} ${currency} ajoutés à l'objectif "${goalTitleStr}" (${newSavedTotal}/${targetVal} ${currency})`
          : `+${amount} ${currency} added to goal "${goalTitleStr}" (${newSavedTotal}/${targetVal} ${currency})`,
        date: new Date().toISOString(),
        read: false,
        type: 'success' as const
      });
    }
    setNotifications(newNotifications);

    triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, updatedGoals, newNotifications);
  };

  // Filtering calculations
  const filteredTasksList = tasks.filter(t => {
    const matchesSearch = t.title.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedTaskCategory === 'Toutes' || t.category === selectedTaskCategory;
    const matchesPriority = selectedTaskPriority === 'Toutes' || t.priority === selectedTaskPriority;
    return matchesSearch && matchesCategory && matchesPriority;
  });

  // Budget calculations
  const remainingBudget = totalBudget - spentAmount;
  const budgetProgressPercent = Math.min((spentAmount / totalBudget) * 100, 100);
  
  // Stress financial calculation
  const stressLevel = budgetProgressPercent > 80 ? 'Élevé' : (budgetProgressPercent > 50 ? 'Modéré' : 'Faible');
  const stressColorClass = budgetProgressPercent > 80 ? 'text-red-500 bg-red-500/10' : (budgetProgressPercent > 50 ? 'text-amber-500 bg-amber-500/10' : 'text-emerald-500 bg-emerald-500/10');
  const stressBarColor = budgetProgressPercent > 80 ? 'bg-red-500' : (budgetProgressPercent > 50 ? 'bg-amber-500' : 'bg-emerald-500');
  const stressScore = Math.round(budgetProgressPercent / 10);

  return (
    <div className={`min-h-screen font-sans ${isDarkMode ? 'dark bg-slate-950 text-slate-100' : 'bg-slate-50 text-slate-800'} transition-colors duration-300 pb-16 relative overflow-hidden`}>
      {/* Premium Background Glow effects (Augmentation de la qualité Graphisme) */}
      <div className="absolute top-1/4 left-1/4 w-[400px] h-[400px] bg-blue-500/10 dark:bg-blue-600/5 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute bottom-1/3 right-1/4 w-[500px] h-[500px] bg-purple-500/10 dark:bg-purple-600/5 rounded-full blur-[130px] pointer-events-none" />
      <div className="absolute top-3/4 left-1/2 w-[350px] h-[350px] bg-emerald-500/5 dark:bg-emerald-600/5 rounded-full blur-[110px] pointer-events-none" />
      
      {/* Upper Brand bar */}
      <header className="border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900/80 backdrop-blur-md sticky top-0 z-50 transition-colors">
        <div className="max-w-7xl mx-auto px-6 py-4 flex flex-col md:flex-row justify-between items-center gap-4">
          <div className="flex items-center gap-3">
            <div className="bg-blue-600 text-white p-2.5 rounded-xl shadow-lg shadow-blue-600/20">
              <Sparkles className="w-6 h-6" />
            </div>
            <div>
              <h1 className="text-xl font-bold tracking-tight font-sans text-slate-900 dark:text-white flex items-center gap-2">
                Nexii <span className="text-xs bg-blue-100 text-blue-700 dark:bg-blue-900/50 dark:text-blue-300 px-2 py-0.5 rounded-full font-medium">Flutter SDK v3.0</span>
              </h1>
              <p className="text-xs text-slate-500 dark:text-slate-400">
                Fondations de l'application &amp; Explorateur d'Architecture Modulaire
              </p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            {/* Global Quick Language Control */}
            <div className="flex items-center bg-slate-100 dark:bg-slate-800 rounded-lg p-1 text-xs font-semibold">
              <button 
                onClick={() => setLang('fr')} 
                className={`px-2.5 py-1 rounded-md transition-all ${lang === 'fr' ? 'bg-blue-600 text-white shadow-sm' : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'}`}>
                FR
              </button>
              <button 
                onClick={() => setLang('en')} 
                className={`px-2.5 py-1 rounded-md transition-all ${lang === 'en' ? 'bg-blue-600 text-white shadow-sm' : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'}`}>
                EN
              </button>
              <button 
                onClick={() => setLang('es')} 
                className={`px-2.5 py-1 rounded-md transition-all ${lang === 'es' ? 'bg-blue-600 text-white shadow-sm' : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'}`}>
                ES
              </button>
            </div>

            {/* Global Light/Dark Selector */}
            <button 
              onClick={() => setIsDarkMode(!isDarkMode)} 
              className="p-2 rounded-lg bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-700 transition-all"
              title="Basculer le thème général">
              {isDarkMode ? <Sun className="w-4 h-4" /> : <Moon className="w-4 h-4" />}
            </button>
          </div>
        </div>
      </header>

      {/* Main Sandbox Grid */}
      <main className="max-w-7xl mx-auto px-4 md:px-6 mt-8 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        
        {/* LEFT COLUMN: The Beautiful M3 Mobile Simulator (lg:span-5) */}
        <section className="lg:col-span-5 flex flex-col items-center justify-center">
          <div className="w-full max-w-sm mb-2 flex justify-between items-center px-2">
            <span className="text-xs font-bold uppercase tracking-wider text-slate-400 flex items-center gap-1.5">
              <span className={`w-2 h-2 rounded-full inline-block ${isOffline ? 'bg-amber-500 animate-pulse' : 'bg-emerald-500 animate-ping'}`}></span>
              Nexii App
            </span>
            <div className="flex gap-2 items-center">
              {/* Interactive Network Simulator Toggle */}
              <button
                onClick={() => setIsOffline(!isOffline)}
                className={`flex items-center gap-1 text-[10px] px-2.5 py-1 rounded-full font-bold transition-all shadow-xs border ${
                  isOffline 
                    ? 'bg-amber-100 text-amber-800 border-amber-200 hover:bg-amber-200 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-900/60' 
                    : 'bg-emerald-100 text-emerald-800 border-emerald-200 hover:bg-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-900/60'
                }`}
                title="Simuler une panne de connexion internet"
              >
                {isOffline ? (
                  <>
                    <CloudOff className="w-3 h-3 text-amber-600" />
                    Hors-ligne (Hive)
                  </>
                ) : (
                  <>
                    <Cloud className="w-3 h-3 text-emerald-600" />
                    En ligne (Firestore)
                  </>
                )}
              </button>
              
              {pendingSync && (
                <span className="text-[9px] bg-amber-500 text-white font-bold px-2 py-0.5 rounded-full flex items-center gap-1 animate-bounce" title="Modifications en attente de synchronisation">
                  <RefreshCw className="w-2.5 h-2.5 animate-spin" />
                  Sync Queue
                </span>
              )}
            </div>
          </div>

          {/* Device Wrapper */}
          <div className="relative w-full max-w-[370px] aspect-[9/18.5] bg-slate-900 rounded-[50px] p-3.5 shadow-2xl border-4 border-slate-800 dark:border-slate-700 ring-12 ring-slate-900 ring-offset-2">
            
            {/* Top Notch / Dynamic Island speaker */}
            <div className="absolute top-6 left-1/2 -translate-x-1/2 w-32 h-6 bg-black rounded-full z-30 flex items-center justify-between px-4">
              <div className="w-3.5 h-3.5 rounded-full bg-slate-950 border border-slate-900/60 flex items-center justify-center">
                <span className="w-1 h-1 rounded-full bg-blue-900/80"></span>
              </div>
              <div className="w-12 h-1 bg-neutral-900 rounded-full"></div>
            </div>

            {/* Simulated Screen with Light / Dark independent mode */}
            <div className={`w-full h-full rounded-[38px] overflow-hidden flex flex-col select-none relative ${isDarkMode ? 'bg-slate-950 text-slate-100' : 'bg-slate-50 text-slate-900'} transition-colors duration-300`}>
              
              {/* Phone Status Bar */}
              <div className="h-10 pt-4 px-6 flex justify-between items-center text-xs font-semibold z-20">
                <span>08:45</span>
                <div className="flex items-center gap-1.5">
                  <Wifi className="w-3.5 h-3.5" />
                  <span className="text-[10px]">5G</span>
                  <Battery className="w-4 h-4 fill-current" />
                </div>
              </div>

              {/* Dynamic Screen View container */}
              <div className="flex-1 overflow-y-auto px-5 pt-2 pb-6 relative z-10 no-scrollbar">
                <AnimatePresence mode="wait">
                  {!user ? (
                    <motion.div
                      key="auth_view"
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -10 }}
                      transition={{ duration: 0.2 }}
                      className="h-full flex flex-col justify-center"
                    >
                      <div className="flex flex-col h-full justify-center space-y-4 py-2">
                        <div className="text-center space-y-1">
                          <div className="mx-auto bg-blue-600 text-white p-3 rounded-2xl w-fit shadow-lg shadow-blue-600/20 mb-1">
                            <Lock className="w-5 h-5" />
                          </div>
                          <h3 className="text-sm font-black tracking-tight text-slate-900 dark:text-white">Nexii Cloud</h3>
                          <p className="text-[10px] text-slate-500 max-w-[240px] mx-auto leading-normal">
                            {lang === 'fr' 
                              ? 'Connectez-vous pour activer la synchronisation bidirectionnelle.' 
                              : lang === 'en'
                              ? 'Sign in to enable automatic bidirectional cloud synchronization.'
                              : 'Inicie sesión para activar la sincronización bidireccional.'}
                          </p>
                        </div>

                        {authError && (
                          <div className="p-2.5 rounded-xl bg-red-500/10 border border-red-500/20 text-red-500 text-[10px] flex items-center gap-2">
                            <AlertCircle className="w-3.5 h-3.5 shrink-0" />
                            <span className="font-semibold leading-normal">{authError}</span>
                          </div>
                        )}

                        {authMode === 'login' && (
                          <form onSubmit={handleLogin} className="space-y-2.5">
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">Email</label>
                              <input
                                type="email"
                                required
                                placeholder="nexii@gmail.com"
                                value={authEmail}
                                onChange={(e) => setAuthEmail(e.target.value)}
                                className="w-full text-xs px-3 py-2 rounded-xl bg-slate-100 dark:bg-slate-900 border border-transparent focus:border-blue-600 focus:bg-transparent outline-none transition-all text-slate-700 dark:text-slate-200"
                              />
                            </div>
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">Mot de passe</label>
                              <input
                                type="password"
                                required
                                placeholder="••••••••"
                                value={authPassword}
                                onChange={(e) => setAuthPassword(e.target.value)}
                                className="w-full text-xs px-3 py-2 rounded-xl bg-slate-100 dark:bg-slate-900 border border-transparent focus:border-blue-600 focus:bg-transparent outline-none transition-all text-slate-700 dark:text-slate-200"
                              />
                            </div>
                            <button
                              type="submit"
                              disabled={isSyncing}
                              className="w-full text-xs font-bold bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-xl transition-all shadow-md shadow-blue-600/15 flex items-center justify-center gap-2 animate-pulse"
                            >
                              {isSyncing ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : 'Se connecter'}
                            </button>
                          </form>
                        )}

                        {authMode === 'register' && (
                          <form onSubmit={handleRegister} className="space-y-2.5">
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">Email</label>
                              <input
                                type="email"
                                required
                                placeholder="nexii@gmail.com"
                                value={authEmail}
                                onChange={(e) => setAuthEmail(e.target.value)}
                                className="w-full text-xs px-3 py-2 rounded-xl bg-slate-100 dark:bg-slate-900 border border-transparent focus:border-blue-600 focus:bg-transparent outline-none transition-all text-slate-700 dark:text-slate-200"
                              />
                            </div>
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">Mot de passe</label>
                              <input
                                type="password"
                                required
                                placeholder="••••••••"
                                value={authPassword}
                                onChange={(e) => setAuthPassword(e.target.value)}
                                className="w-full text-xs px-3 py-2 rounded-xl bg-slate-100 dark:bg-slate-900 border border-transparent focus:border-blue-600 focus:bg-transparent outline-none transition-all text-slate-700 dark:text-slate-200"
                              />
                            </div>
                            <button
                              type="submit"
                              disabled={isSyncing}
                              className="w-full text-xs font-bold bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-xl transition-all shadow-md shadow-blue-600/15 flex items-center justify-center gap-2"
                            >
                              {isSyncing ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : 'Créer un compte'}
                            </button>
                          </form>
                        )}

                        {authMode === 'forgot' && (
                          <form onSubmit={handleForgotPassword} className="space-y-2.5">
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">Email</label>
                              <input
                                type="email"
                                required
                                placeholder="nexii@gmail.com"
                                value={authEmail}
                                onChange={(e) => setAuthEmail(e.target.value)}
                                className="w-full text-xs px-3 py-2 rounded-xl bg-slate-100 dark:bg-slate-900 border border-transparent focus:border-blue-600 focus:bg-transparent outline-none transition-all text-slate-700 dark:text-slate-200"
                              />
                            </div>
                            <button
                              type="submit"
                              disabled={isSyncing}
                              className="w-full text-xs font-bold bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-xl transition-all shadow-md shadow-blue-600/15 flex items-center justify-center gap-2"
                            >
                              {isSyncing ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : "Réinitialiser"}
                            </button>
                          </form>
                        )}

                        <div className="space-y-2 pt-1 border-t border-slate-200/60 dark:border-slate-800">
                          <button
                            type="button"
                            onClick={handleGoogleSignIn}
                            disabled={isSyncing}
                            className="w-full py-2 bg-slate-100 dark:bg-slate-900 hover:bg-slate-200 dark:hover:bg-slate-800 text-xs font-bold rounded-xl flex items-center justify-center gap-2 transition-all text-slate-700 dark:text-slate-300 border border-slate-200/40 dark:border-slate-800"
                          >
                            <svg className="w-3.5 h-3.5 text-blue-600" viewBox="0 0 24 24">
                              <path
                                fill="currentColor"
                                d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                              />
                              <path
                                fill="currentColor"
                                d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                              />
                              <path
                                fill="currentColor"
                                d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                              />
                              <path
                                fill="currentColor"
                                d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                              />
                            </svg>
                            Google Sign-In
                          </button>

                          <button
                            type="button"
                            onClick={() => enterDemoMode()}
                            className="w-full py-2 bg-blue-600/10 hover:bg-blue-600/15 text-blue-600 dark:text-blue-400 text-xs font-bold rounded-xl flex items-center justify-center gap-2 transition-all border border-blue-600/20 shadow-xs"
                          >
                            <User className="w-3.5 h-3.5" />
                            Accéder en Mode Démo (Invité)
                          </button>

                          <div className="flex justify-between items-center text-[9px] text-blue-600 dark:text-blue-400 font-bold px-1.5">
                            {authMode === 'login' && (
                              <>
                                <button type="button" onClick={() => { setAuthMode('register'); setAuthError(''); }}>
                                  Créer un compte
                                </button>
                                <button type="button" onClick={() => { setAuthMode('forgot'); setAuthError(''); }}>
                                  Mot de passe oublié ?
                                </button>
                              </>
                            )}
                            {authMode === 'register' && (
                              <button type="button" onClick={() => { setAuthMode('login'); setAuthError(''); }} className="mx-auto">
                                Déjà inscrit ? Se connecter
                              </button>
                            )}
                            {authMode === 'forgot' && (
                              <button type="button" onClick={() => { setAuthMode('login'); setAuthError(''); }} className="mx-auto">
                                Retour à la connexion
                              </button>
                            )}
                          </div>
                        </div>
                      </div>
                    </motion.div>
                  ) : !isProfileLoaded ? (
                    <motion.div
                      key="profile_loading_view"
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      exit={{ opacity: 0 }}
                      className="h-full flex flex-col justify-center items-center space-y-4"
                    >
                      <RefreshCw className="w-8 h-8 text-blue-600 animate-spin" />
                      <p className="text-xs text-slate-500 font-medium">
                        {lang === 'fr' 
                          ? 'Chargement du profil...' 
                          : lang === 'es'
                          ? 'Cargando perfil...'
                          : 'Loading profile...'}
                      </p>
                    </motion.div>
                  ) : (userAge === null || userBirthdate === null || !userBirthdate || !(user?.displayName || onboardingName)) ? (
                    <motion.div
                      key="onboarding_view"
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -10 }}
                      transition={{ duration: 0.2 }}
                      className="h-full flex flex-col justify-center"
                    >
                      <form 
                        onSubmit={(e) => {
                          e.preventDefault();
                          handleCompleteOnboarding(onboardingName, onboardingBirthdate);
                        }} 
                        className="space-y-4 py-2"
                      >
                        <div className="text-center space-y-1">
                          <div className="mx-auto bg-blue-600 text-white p-3 rounded-2xl w-fit shadow-lg shadow-blue-600/20 mb-1">
                            <User className="w-5 h-5" />
                          </div>
                          <h3 className="text-sm font-black tracking-tight text-slate-900 dark:text-white">
                            {t.onboarding_title}
                          </h3>
                          <p className="text-[10px] text-slate-500 max-w-[240px] mx-auto leading-normal">
                            {t.onboarding_desc}
                          </p>
                        </div>

                        {authError && (
                          <div className="p-2.5 rounded-xl bg-red-500/10 border border-red-500/20 text-red-500 text-[10px] flex items-center gap-2">
                            <AlertCircle className="w-3.5 h-3.5 shrink-0" />
                            <span className="font-semibold leading-normal">{authError}</span>
                          </div>
                        )}

                        <div className="space-y-3">
                          <div className="space-y-1">
                            <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">
                              {t.onboarding_name_label}
                            </label>
                            <input
                              type="text"
                              required
                              placeholder="Alexandre Nexii"
                              value={onboardingName}
                              onChange={(e) => setOnboardingName(e.target.value)}
                              className="w-full text-xs px-3 py-2 rounded-xl bg-slate-100 dark:bg-slate-900 border border-transparent focus:border-blue-600 focus:bg-transparent outline-none transition-all text-slate-700 dark:text-slate-200"
                            />
                          </div>

                          <div className="space-y-1">
                            <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">
                              {t.onboarding_birthdate_label}
                            </label>
                            <input
                              type="text"
                              inputMode="numeric"
                              required
                              placeholder={lang === 'fr' ? 'JJ/MM/AAAA' : lang === 'es' ? 'DD/MM/AAAA' : 'DD/MM/YYYY'}
                              value={onboardingBirthdateText}
                              onChange={(e) => handleTypedDateChange(e.target.value, setOnboardingBirthdateText, setOnboardingBirthdate)}
                              className="w-full text-xs px-3 py-2 rounded-xl bg-slate-100 dark:bg-slate-900 border border-transparent focus:border-blue-600 focus:bg-transparent outline-none transition-all text-slate-700 dark:text-slate-200"
                            />
                          </div>

                          <button
                            type="submit"
                            disabled={isSyncing}
                            className="w-full text-xs font-bold bg-blue-600 hover:bg-blue-700 text-white py-2.5 rounded-xl transition-all shadow-md shadow-blue-600/15 flex items-center justify-center gap-2"
                          >
                            {isSyncing ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : t.onboarding_submit}
                          </button>

                          <button
                            type="button"
                            onClick={handleSignOut}
                            className="w-full text-xs font-semibold text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200 py-1 transition-all flex items-center justify-center gap-1.5"
                          >
                            {lang === 'fr' ? 'Se déconnecter' : lang === 'es' ? 'Cerrar sesión' : 'Sign out'}
                          </button>
                        </div>
                      </form>
                    </motion.div>
                  ) : (
                    <motion.div
                      key={activeTab}
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -10 }}
                      transition={{ duration: 0.2 }}
                      className="h-full flex flex-col"
                    >
                    {/* TAB 0: HOME */}
                    {activeTab === 0 && (
                      <div className="space-y-4">
                        <div className="flex justify-between items-center">
                          <h2 className="text-xl font-black font-sans tracking-tight">{t.app_name}</h2>
                          <div className="flex items-center gap-2">
                            <span className="text-[10px] font-bold text-amber-500 bg-amber-500/10 px-2 py-0.5 rounded-full">🔥 {userStreak} {lang === 'fr' ? 'Jours' : 'Days'}</span>
                            <button
                              onClick={() => setShowNotifications(true)}
                              className="relative p-1.5 rounded-xl bg-slate-100 dark:bg-slate-900 text-slate-600 dark:text-slate-300 hover:bg-slate-200 dark:hover:bg-slate-800 transition-all cursor-pointer flex items-center justify-center border border-slate-200/40 dark:border-slate-800"
                              title="Notifications"
                            >
                              <Bell className="w-3.5 h-3.5" />
                              {notifications.some(n => !n.read) && (
                                <span className="absolute -top-0.5 -right-0.5 w-2 h-2 bg-red-500 rounded-full border border-white dark:border-slate-950 animate-pulse"></span>
                              )}
                            </button>
                            <div className="w-8 h-8 rounded-full bg-blue-600 text-white font-bold flex items-center justify-center text-xs shadow-md shadow-blue-600/35">
                              {getUserInitials()}
                            </div>
                          </div>
                        </div>

                        <div>
                          {isTodayBirthday(userBirthdate) ? (
                            <>
                              <p className="text-base font-black font-sans text-pink-600 dark:text-pink-400 leading-tight animate-bounce">
                                {lang === 'fr' 
                                  ? `🎉 Joyeux Anniversaire, ${user?.displayName || 'Aventurier'} ! 🎂` 
                                  : lang === 'es'
                                  ? `🎉 ¡Feliz Cumpleaños, ${user?.displayName || 'Aventurero'}! 🎂`
                                  : `🎉 Happy Birthday, ${user?.displayName || 'Adventurer'}! 🎂`}
                              </p>
                              <p className="text-[11px] text-pink-500/80 mt-0.5 leading-relaxed font-sans font-bold">
                                {lang === 'fr'
                                  ? "Aujourd'hui est un jour spécial. Soufflez un peu et prenez soin de vous ! 🌸"
                                  : lang === 'es'
                                  ? "Hoy es un día especial. ¡Tómate un respiro y cuídate! 🌸"
                                  : "Today is a special day. Take a breather and treat yourself! 🌸"}
                              </p>
                            </>
                          ) : (
                            <>
                              <p className="text-base font-bold font-sans text-slate-800 dark:text-white leading-tight">
                                {lang === 'fr' 
                                  ? `Bonjour, ${user?.displayName || (user?.email ? user.email.split('@')[0] : 'Aventurier')}` 
                                  : lang === 'es'
                                  ? `Hola, ${user?.displayName || (user?.email ? user.email.split('@')[0] : 'Aventurero')}`
                                  : `Hello, ${user?.displayName || (user?.email ? user.email.split('@')[0] : 'Adventurer')}`}
                              </p>
                              <p className="text-[11px] text-slate-400 mt-0.5 leading-relaxed font-sans">
                                {t.calm_message}
                              </p>
                            </>
                          )}
                        </div>

                        {isTodayBirthday(userBirthdate) && (
                          <motion.div
                            initial={{ scale: 0.95, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            className="p-5 rounded-3xl bg-linear-to-br from-pink-500/15 via-purple-500/10 to-blue-500/15 dark:from-pink-950/40 dark:via-purple-950/20 dark:to-blue-950/40 border border-pink-500/30 dark:border-pink-900/50 shadow-xl relative overflow-hidden flex flex-col items-center text-center gap-4"
                          >
                            <div className="absolute -top-12 -left-12 w-24 h-24 bg-pink-500/20 rounded-full blur-2xl animate-pulse" />
                            <div className="absolute -bottom-12 -right-12 w-24 h-24 bg-purple-500/20 rounded-full blur-2xl animate-pulse" />
                            
                            <div className="absolute top-2 left-2 text-xl select-none opacity-40 animate-bounce">🎈</div>
                            <div className="absolute top-2 right-2 text-xl select-none opacity-40 animate-bounce delay-150">🎉</div>
                            <div className="absolute bottom-2 left-3 text-xl select-none opacity-30">🎁</div>
                            <div className="absolute bottom-2 right-3 text-xl select-none opacity-30">🍰</div>

                            <div className="relative z-10 w-full">
                              <span className="text-3xl">👑</span>
                              <h3 className="text-sm font-black text-pink-700 dark:text-pink-300 uppercase tracking-widest mt-1">
                                {lang === 'fr' 
                                  ? 'Votre Journée Spéciale !' 
                                  : lang === 'es'
                                  ? '¡Tu Día Especial!'
                                  : 'Your Special Day!'}
                              </h3>
                              
                              <p className="text-xs text-slate-700 dark:text-slate-200 font-medium px-2 mt-1 leading-relaxed">
                                {lang === 'fr'
                                  ? 'Faites un vœu et soufflez les bougies virtuelles de Nexii pour libérer la magie !'
                                  : lang === 'es'
                                  ? '¡Pide un deseo y sopla las velas virtuales de Nexii para liberar la magia!'
                                  : 'Make a wish and blow out Nexii\'s virtual candles to release the magic!'}
                              </p>
                            </div>

                            <div className="flex flex-col items-center my-1 relative">
                              <div className="flex gap-4 justify-center items-end h-10 relative z-10">
                                {[1, 2, 3].map((i) => (
                                  <div key={i} className="flex flex-col items-center">
                                    {candlesLit ? (
                                      <motion.div
                                        animate={{
                                          scale: [1, 1.25, 0.9, 1.15, 1],
                                          y: [0, -1.5, 0.5, -0.5, 0],
                                        }}
                                        transition={{
                                          duration: 0.5 + i * 0.1,
                                          repeat: Infinity,
                                          repeatType: "reverse"
                                        }}
                                        className="w-2.5 h-4 bg-gradient-to-t from-amber-400 via-orange-500 to-red-500 rounded-full blur-[0.5px] shadow-[0_0_8px_rgba(244,63,94,0.9)]"
                                      />
                                    ) : (
                                      <motion.div 
                                        initial={{ opacity: 0 }}
                                        animate={{ opacity: [0, 0.5, 0] }}
                                        transition={{ duration: 0.8 }}
                                        className="w-1.5 h-3 bg-slate-400 dark:bg-slate-500 rounded-full blur-[1px]" 
                                      />
                                    )}
                                    <div className="w-1.5 h-5 bg-linear-to-b from-blue-300 via-pink-400 to-yellow-300 rounded-t-xs shadow-xs" />
                                  </div>
                                ))}
                              </div>
                              
                              <div className="w-28 h-5 bg-pink-300 dark:bg-pink-400 rounded-t-lg shadow-md relative z-10">
                                <div className="absolute top-0 left-0 w-full flex justify-around">
                                  {[1, 2, 3, 4, 5].map((d) => (
                                    <div key={d} className="w-2.5 h-2.5 bg-white dark:bg-pink-100 rounded-b-full shadow-xs" />
                                  ))}
                                </div>
                              </div>
                              <div className="w-32 h-8 bg-amber-100 dark:bg-amber-900/60 rounded-b-lg border-t border-pink-200 dark:border-pink-900 shadow-lg relative z-0 flex items-center justify-center">
                                <span className="text-[9px] font-black text-pink-600/60 dark:text-pink-300/60 tracking-widest animate-pulse">BIRTHDAY</span>
                              </div>
                              <div className="w-36 h-2 bg-slate-200 dark:bg-slate-700 rounded-full shadow-xs -mt-0.5" />
                            </div>

                            <div className="w-full relative z-10">
                              <AnimatePresence mode="wait">
                                {birthdayWishMade ? (
                                  <motion.div
                                    key="wish_granted"
                                    initial={{ opacity: 0, scale: 0.9 }}
                                    animate={{ opacity: 1, scale: 1 }}
                                    exit={{ opacity: 0 }}
                                    className="space-y-3"
                                  >
                                    <div className="p-3 rounded-2xl bg-white/70 dark:bg-slate-900/70 border border-emerald-500/20 dark:border-emerald-900/30">
                                      <p className="text-xs font-black text-emerald-600 dark:text-emerald-400">
                                        ✨ {lang === 'fr' 
                                          ? 'Vœu enregistré dans les étoiles !' 
                                          : lang === 'es'
                                          ? '¡Deseo guardado en las estrellas!'
                                          : 'Wish recorded in the stars!'} ✨
                                      </p>
                                      <p className="text-[10px] text-slate-600 dark:text-slate-300 mt-1 leading-normal">
                                        {lang === 'fr'
                                          ? 'Que cette nouvelle année de vie vous apporte sérénité, paix profonde et accomplissement personnel.'
                                          : lang === 'es'
                                          ? 'Que este nuevo año de vida te traiga serenidad, paz profunda y realización personal.'
                                          : 'May this new year of life bring you serenity, deep peace, and personal fulfillment.'}
                                      </p>
                                    </div>
                                    <div className="flex gap-2 justify-center">
                                      <button
                                        type="button"
                                        onClick={triggerBirthdayConfetti}
                                        className="text-[11px] font-bold bg-pink-600 hover:bg-pink-700 text-white px-3 py-1.5 rounded-xl transition-all shadow-md shadow-pink-600/20 flex items-center gap-1 cursor-pointer"
                                      >
                                        🎉 {lang === 'fr' ? 'Confettis !' : 'Confetti!'}
                                      </button>
                                      <button
                                        type="button"
                                        onClick={() => {
                                          setCandlesLit(true);
                                          setBirthdayWishMade(false);
                                        }}
                                        className="text-[11px] font-semibold text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200 px-3 py-1.5 rounded-xl border border-slate-200 dark:border-slate-800 transition-all cursor-pointer"
                                      >
                                        🕯️ {lang === 'fr' ? 'Rallumer' : 'Relight'}
                                      </button>
                                    </div>
                                  </motion.div>
                                ) : (
                                  <motion.div
                                    key="blow_candles"
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    exit={{ opacity: 0 }}
                                    className="flex flex-col gap-2 items-center"
                                  >
                                    <button
                                      type="button"
                                      onClick={() => {
                                        setCandlesLit(false);
                                        setBirthdayWishMade(true);
                                        triggerBirthdayConfetti();
                                      }}
                                      className="w-full text-xs font-black bg-gradient-to-r from-pink-600 to-purple-600 hover:from-pink-700 hover:to-purple-700 text-white py-2.5 px-4 rounded-xl shadow-lg shadow-pink-600/30 transition-all hover:scale-[1.02] flex items-center justify-center gap-2 cursor-pointer"
                                    >
                                      💨 <span className="animate-pulse">{lang === 'fr' ? 'Souffler les bougies !' : lang === 'es' ? '¡Soplar las velas!' : 'Blow out the candles!'}</span> 🎂
                                    </button>
                                    
                                    <p className="text-[10px] text-slate-500 dark:text-slate-400 leading-normal mt-1">
                                      {lang === 'fr'
                                        ? 'Profitez de cet instant pour relâcher la pression. Aucune tâche secondaire n\'est requise aujourd\'hui !'
                                        : lang === 'es'
                                        ? 'Aprovecha este momento para relajarte. ¡No se requieren tareas secundarias hoy!'
                                        : 'Take this moment to release the pressure. No secondary tasks are required today!'}
                                    </p>
                                  </motion.div>
                                )}
                              </AnimatePresence>
                            </div>
                          </motion.div>
                        )}

                        {/* Daily Check-In / Activity Streak Widget */}
                        <div className="p-3.5 rounded-2xl bg-gradient-to-r from-amber-500/10 to-orange-500/10 dark:from-amber-950/20 dark:to-orange-950/20 border border-amber-500/20 dark:border-amber-900/30 shadow-xs flex flex-col gap-2">
                          <div className="flex justify-between items-center">
                            <div className="flex items-center gap-2">
                              <span className="text-xl">🔥</span>
                              <div>
                                <h4 className="text-xs font-bold text-slate-800 dark:text-slate-100">{t.activity_streak}</h4>
                                <p className="text-[9px] text-slate-500 dark:text-slate-400">{t.streak_desc}</p>
                              </div>
                            </div>
                            <span className="text-xs font-black text-amber-600 dark:text-amber-400 bg-amber-500/20 px-2.5 py-1 rounded-lg">
                              {userStreak} {lang === 'fr' ? 'Jours d\'affilée' : lang === 'es' ? 'Días seguidos' : 'Days Streak'}
                            </span>
                          </div>
                          
                          {!hasDoneCheckIn ? (
                            <button
                              type="button"
                              onClick={() => setShowCheckInModal(true)}
                              className="w-full text-center py-2.5 bg-purple-600 hover:bg-purple-700 text-white rounded-xl text-xs font-bold font-sans flex items-center justify-center gap-1.5 cursor-pointer shadow-md shadow-purple-600/10 transition-all hover:scale-[1.01]"
                            >
                              <span className="relative flex h-2 w-2">
                                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-purple-400 opacity-75"></span>
                                <span className="relative inline-flex rounded-full h-2 w-2 bg-white"></span>
                              </span>
                              <span>{lang === 'fr' ? 'Faire mon Bilan / Check-In 🌸 (+30 XP)' : 'Complete my Daily Check-In 🌸 (+30 XP)'}</span>
                            </button>
                          ) : (
                            <div className="space-y-2 bg-emerald-500/10 border border-emerald-500/20 dark:border-emerald-900/40 p-2.5 rounded-xl text-xs">
                              <p className="font-bold text-emerald-600 dark:text-emerald-400 flex items-center gap-1">
                                <span>✓</span>
                                <span>{lang === 'fr' ? 'Bilan quotidien complété ! ✨ (+30 XP reçus)' : 'Daily Check-In completed! ✨ (+30 XP received)'}</span>
                              </p>
                              <div className="grid grid-cols-5 gap-1 text-[9px] font-mono font-semibold text-slate-500 dark:text-slate-400 text-center">
                                <div className="bg-white dark:bg-slate-900 p-1 rounded border border-slate-100 dark:border-slate-800">
                                  <span className="block text-xs">🙂</span>
                                  <span>Hum: {checkInMood}/5</span>
                                </div>
                                <div className="bg-white dark:bg-slate-900 p-1 rounded border border-slate-100 dark:border-slate-800">
                                  <span className="block text-xs">⚡</span>
                                  <span>Éne: {checkInEnergy}/5</span>
                                </div>
                                <div className="bg-white dark:bg-slate-900 p-1 rounded border border-slate-100 dark:border-slate-800">
                                  <span className="block text-xs">🎯</span>
                                  <span>Mot: {checkInMotivation}/5</span>
                                </div>
                                <div className="bg-white dark:bg-slate-900 p-1 rounded border border-slate-100 dark:border-slate-800">
                                  <span className="block text-xs">🧘</span>
                                  <span>Str: {checkInStress}/5</span>
                                </div>
                                <div className="bg-white dark:bg-slate-900 p-1 rounded border border-slate-100 dark:border-slate-800">
                                  <span className="block text-xs">😴</span>
                                  <span>Som: {checkInSleep}/5</span>
                                </div>
                              </div>
                            </div>
                          )}
                        </div>

                        {/* Mood Selection Row */}
                        <div className="p-3 rounded-2xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm space-y-2">
                          <span className="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider block">{t.mood_title}</span>
                          <div className="flex justify-between items-center">
                            {moods.map((m, idx) => (
                              <button
                                key={idx}
                                onClick={() => selectMoodAndSync(idx)}
                                className={`flex flex-col items-center p-2 rounded-xl transition-all ${selectedMood === idx ? 'bg-blue-600/10 text-blue-600 border border-blue-600/20' : 'hover:bg-slate-50 dark:hover:bg-slate-800 border border-transparent'}`}
                              >
                                <span className="text-xl">{m.emoji}</span>
                                <span className="text-[9px] mt-1 text-slate-500 font-medium">{m.label[lang]}</span>
                              </button>
                            ))}
                          </div>
                        </div>

                        {/* Aura daily block */}
                        <div className="p-4 rounded-2xl bg-gradient-to-br from-blue-600 via-indigo-600 to-purple-600 text-white shadow-xl shadow-blue-600/15 flex items-center justify-between gap-4">
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2 mb-1.5">
                              <Sparkles className="w-4 h-4 text-yellow-300 animate-pulse shrink-0" />
                              <h3 className="font-bold text-sm tracking-wide truncate">
                                {lang === 'fr' ? `Aura : ${aura.label}` : lang === 'en' ? `Aura: ${aura.label}` : `Aura: ${aura.label}`}
                              </h3>
                            </div>
                            <p className="text-[11px] text-blue-100 leading-relaxed line-clamp-2 mb-1.5">
                              {aura.description}
                            </p>
                            <div className="text-[10px] text-blue-200 font-medium">
                              Niveau {userLevel} &bull; {userXp}/2000 XP
                            </div>
                          </div>
                          
                          {/* Circular Gauge */}
                          <div className="relative flex items-center justify-center w-20 h-20 shrink-0">
                            <svg className="w-full h-full transform -rotate-90">
                              <circle
                                cx="40"
                                cy="40"
                                r="32"
                                className="stroke-white/10"
                                strokeWidth="6"
                                fill="transparent"
                              />
                              <motion.circle
                                cx="40"
                                cy="40"
                                r="32"
                                className="stroke-emerald-300"
                                strokeWidth="6"
                                strokeDasharray={2 * Math.PI * 32}
                                initial={{ strokeDashoffset: 2 * Math.PI * 32 }}
                                animate={{ strokeDashoffset: 2 * Math.PI * 32 - (aura.percentage / 100) * (2 * Math.PI * 32) }}
                                transition={{ duration: 1.5, ease: "easeOut" }}
                                strokeLinecap="round"
                                fill="transparent"
                              />
                            </svg>
                            <div className="absolute flex flex-col items-center justify-center">
                              <span className="text-sm font-black text-white">{aura.percentage}%</span>
                            </div>
                          </div>
                        </div>

                        {/* Quick View list */}
                        <div className="space-y-3">
                          <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider">{t.quick_view}</h4>
                          
                          {/* Quick access tasks */}
                          <div className="p-3.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm flex items-center justify-between">
                            <div className="flex items-center gap-3">
                              <div className="p-2 rounded-lg bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400">
                                <CheckSquare className="w-4 h-4" />
                              </div>
                              <div>
                                <h5 className="text-xs font-bold">{t.daily_tasks}</h5>
                                <p className="text-[10px] text-slate-400 truncate w-40">
                                  {tasks.filter(tk => !tk.completed).map(tk => tk.title).join(' &bull; ') || t.all_completed}
                                </p>
                              </div>
                            </div>
                            <span className="text-[10px] font-bold text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 px-2 py-0.5 rounded-full">
                              {Math.round((tasks.filter(tk => tk.completed).length / tasks.length) * 100)}%
                            </span>
                          </div>

                          {/* Quick access focus */}
                          <div className="p-3.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm flex items-center justify-between">
                            <div className="flex items-center gap-3">
                              <div className="p-2 rounded-lg bg-purple-50 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400">
                                <Timer className="w-4 h-4" />
                              </div>
                              <div>
                                <h5 className="text-xs font-bold">{t.recommended_focus}</h5>
                                <p className="text-[10px] text-slate-400 truncate w-40">25 minutes &bull; {getSoundTranslation(selectedSound, lang)}</p>
                              </div>
                            </div>
                            <button 
                              onClick={() => setActiveTab(3)}
                              className="text-[10px] font-bold text-purple-600 dark:text-purple-400 hover:underline">
                              {t.start_action}
                            </button>
                          </div>
                        </div>
                      </div>
                    )}

                    {/* TAB 1: MISSIONS */}
                    {activeTab === 1 && (
                      <div className="space-y-4 flex flex-col h-full">
                        <div className="flex justify-between items-center mb-1">
                          <h2 className="text-lg font-bold font-sans">
                            {missionsSubTab === 'challenges' ? t.missions_title : t.agenda_title}
                          </h2>
                          <Award className="w-5 h-5 text-amber-500" />
                        </div>

                        {/* Segment Selector for Challenges / Agenda / Community */}
                        <div className="flex gap-1 p-1 bg-slate-100 dark:bg-slate-950 rounded-xl">
                          <button
                            onClick={() => setMissionsSubTab('challenges')}
                            className={`flex-1 text-[10px] font-black py-1.5 rounded-lg transition-all cursor-pointer ${missionsSubTab === 'challenges' ? 'bg-white dark:bg-slate-900 text-blue-600 dark:text-blue-400 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:text-slate-700'}`}
                          >
                            🏆 {lang === 'fr' ? 'Défis & XP' : lang === 'es' ? 'Desafíos' : 'Challenges'}
                          </button>
                          <button
                            onClick={() => setMissionsSubTab('agenda')}
                            className={`flex-1 text-[10px] font-black py-1.5 rounded-lg transition-all cursor-pointer ${missionsSubTab === 'agenda' ? 'bg-white dark:bg-slate-900 text-blue-600 dark:text-blue-400 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:text-slate-700'}`}
                          >
                            📅 {lang === 'fr' ? 'Agenda' : lang === 'es' ? 'Agenda' : 'Agenda'}
                          </button>
                          <button
                            onClick={() => setMissionsSubTab('community')}
                            className={`flex-1 text-[10px] font-black py-1.5 rounded-lg transition-all cursor-pointer ${missionsSubTab === 'community' ? 'bg-white dark:bg-slate-900 text-blue-600 dark:text-blue-400 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:text-slate-700'}`}
                          >
                            👥 {lang === 'fr' ? 'Communauté' : lang === 'es' ? 'Comunidad' : 'Community'}
                          </button>
                        </div>

                        {missionsSubTab === 'challenges' && (
                          <div className="space-y-3 flex-1 overflow-y-auto no-scrollbar">
                            {/* Overall Progress Block */}
                            <div className="p-4 rounded-xl bg-slate-100 dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-xs space-y-2">
                              <div className="flex justify-between items-center text-xs font-bold">
                                <span>{t.overall_progress}</span>
                                <span className="text-blue-600 dark:text-blue-400">
                                  {missions.filter(m => m.claimed).length} / {missions.length}
                                </span>
                              </div>
                              <div className="h-2 w-full bg-slate-200 dark:bg-slate-800 rounded-full overflow-hidden">
                                <div className="h-full bg-blue-600 rounded-full" style={{ width: `${(missions.filter(m => m.claimed).length / missions.length) * 100}%` }}></div>
                              </div>
                            </div>

                            {/* Missions scroll list */}
                            <div className="space-y-3">
                              {missions.map((mission) => {
                                const diffColors = mission.difficulty === 'Facile' 
                                  ? 'bg-emerald-50 text-emerald-700 border-emerald-100 dark:bg-emerald-950/30 dark:text-emerald-400 dark:border-emerald-900/50' 
                                  : (mission.difficulty === 'Moyen' 
                                    ? 'bg-amber-50 text-amber-700 border-amber-100 dark:bg-amber-950/30 dark:text-amber-400 dark:border-amber-900/50' 
                                    : 'bg-red-50 text-red-700 border-red-100 dark:bg-red-950/30 dark:text-red-400 dark:border-red-900/50');
                                
                                const difficultyTranslated = mission.difficulty === 'Facile' 
                                  ? t.difficulty_easy 
                                  : (mission.difficulty === 'Moyen' ? t.difficulty_medium : t.difficulty_hard);

                                const catTranslated = mission.category === 'Mental' 
                                  ? (lang === 'fr' ? 'Mental' : lang === 'es' ? 'Mental' : 'Mental')
                                  : (mission.category === 'Quotidien' ? t.category_daily : (mission.category === 'Hebdomadaire' ? t.category_weekly : t.category_special));

                                return (
                                  <div key={mission.id} className="p-3.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-xs space-y-2">
                                    <div className="flex justify-between items-start">
                                      <div className="space-y-1">
                                        <div className="flex items-center gap-2">
                                          <span className={`text-[8px] px-2 py-0.5 rounded-full font-bold uppercase border ${diffColors}`}>
                                            {difficultyTranslated}
                                          </span>
                                          <span className="text-[9px] text-slate-400 uppercase font-semibold">{catTranslated}</span>
                                        </div>
                                        <h3 className="text-xs font-bold text-slate-800 dark:text-slate-100">{mission.title}</h3>
                                      </div>
                                      <span className="text-[10px] font-bold text-purple-600 dark:text-purple-400 bg-purple-50 dark:bg-purple-950/40 px-2 py-0.5 rounded-md">
                                        +{mission.xp} XP
                                      </span>
                                    </div>
                                    <p className="text-[10px] text-slate-500 dark:text-slate-400 leading-normal">{mission.description}</p>
                                    
                                    <div className="flex items-center justify-between pt-1">
                                      <div className="w-24 h-1.5 bg-slate-100 dark:bg-slate-800 rounded-full overflow-hidden">
                                        <div className="h-full bg-blue-600 rounded-full" style={{ width: `${mission.progress * 100}%` }}></div>
                                      </div>
                                      <span className="text-[10px] font-bold text-slate-500">{(mission.progress * 100).toFixed(0)}%</span>
                                    </div>

                                    {mission.progress >= 1.0 && (
                                      <button
                                        onClick={() => claimMissionXp(mission.id)}
                                        disabled={mission.claimed}
                                        className={`w-full text-center py-1.5 rounded-lg text-[10px] font-bold tracking-wider transition-all ${mission.claimed ? 'bg-slate-100 dark:bg-slate-800 text-slate-400' : 'bg-emerald-500 hover:bg-emerald-600 text-white cursor-pointer'}`}
                                      >
                                        {mission.claimed ? t.reward_claimed : t.claim_xp}
                                      </button>
                                    )}
                                  </div>
                                );
                              })}
                            </div>
                          </div>
                        )}

                        {missionsSubTab === 'agenda' && (
                          <div className="space-y-4 flex-1 overflow-y-auto no-scrollbar">
                            {/* Horizontal Weekly Strip Calendar */}
                            <div className="flex justify-between items-center bg-slate-50 dark:bg-slate-950/80 p-2.5 rounded-2xl border border-slate-100 dark:border-slate-800">
                              {(() => {
                                const days = [];
                                const todayDate = new Date();
                                for (let i = -3; i <= 3; i++) {
                                  const d = new Date();
                                  d.setDate(todayDate.getDate() + i);
                                  const dayStr = d.toISOString().split('T')[0];
                                  days.push({
                                    dateStr: dayStr,
                                    dayNum: d.getDate(),
                                    dayLabel: d.toLocaleDateString(lang === 'fr' ? 'fr-FR' : lang === 'es' ? 'es-ES' : 'en-US', { weekday: 'short' }).slice(0, 3),
                                    monthLabel: d.toLocaleDateString(lang === 'fr' ? 'fr-FR' : lang === 'es' ? 'es-ES' : 'en-US', { month: 'short' }).slice(0, 3)
                                  });
                                }
                                return days.map((day) => {
                                  const isSelected = selectedAgendaDate === day.dateStr;
                                  return (
                                    <button
                                      key={day.dateStr}
                                      onClick={() => setSelectedAgendaDate(day.dateStr)}
                                      className={`flex flex-col items-center justify-center p-1.5 rounded-xl transition-all min-w-[36px] ${isSelected ? 'bg-blue-600 text-white shadow-md shadow-blue-600/15 font-black scale-105' : 'text-slate-500 hover:text-slate-800 dark:hover:text-slate-200'}`}
                                    >
                                      <span className="text-[7px] uppercase opacity-70 tracking-tight font-sans">{day.dayLabel}</span>
                                      <span className="text-xs font-bold leading-tight mt-0.5">{day.dayNum}</span>
                                      <span className="text-[7px] opacity-60 leading-none">{day.monthLabel}</span>
                                    </button>
                                  );
                                });
                              })()}
                            </div>

                            {/* Timeline section */}
                            <div className="space-y-2.5">
                              <div className="flex justify-between items-center px-1">
                                <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-widest">
                                  {lang === 'fr' ? 'Plannings de la journée' : lang === 'es' ? 'Planificación del día' : 'Day schedule'}
                                </h3>
                                <button
                                  type="button"
                                  onClick={() => {
                                    // Auto Planification Logic
                                    // We take the current uncompleted tasks and automatically schedule them in the agenda starting from 09:00 with 1 hour intervals!
                                    const uncompletedTasks = tasks.filter(tk => !tk.completed);
                                    if (uncompletedTasks.length === 0) {
                                      alert(lang === 'fr' ? "Aucune tâche active à planifier ! Ajoutez d'abord des tâches." : "No active tasks to schedule! Add some tasks first.");
                                      return;
                                    }
                                    let currentHour = 9;
                                    const nextEvents = [...agendaEvents];
                                    uncompletedTasks.forEach((task, idx) => {
                                      const scheduledTime = `${(currentHour + idx).toString().padStart(2, '0')}:00`;
                                      // Check if event already exists
                                      if (!nextEvents.some(ev => ev.dayStr === selectedAgendaDate && ev.time === scheduledTime)) {
                                        nextEvents.push({
                                          id: Date.now() + idx,
                                          title: `${task.title} ⚡ (Auto-Plan)`,
                                          time: scheduledTime,
                                          dayStr: selectedAgendaDate
                                        });
                                      }
                                    });
                                    setAgendaEvents(nextEvents);
                                    awardXp(20, lang === 'fr' ? "Auto-planification des tâches par l'IA" : "AI task auto-scheduling");
                                    alert(lang === 'fr' ? "Tâches planifiées intelligemment dans votre journée ! 📅✨" : "Tasks intelligently scheduled in your day! 📅✨");
                                    triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp + 20, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, nextEvents);
                                  }}
                                  className="text-[9px] bg-blue-600 hover:bg-blue-700 text-white font-extrabold px-2.5 py-1 rounded-lg transition-all flex items-center gap-1 cursor-pointer"
                                >
                                  ✨ Nexii Auto-Plan
                                </button>
                              </div>

                              {agendaEvents.filter(ev => ev.dayStr === selectedAgendaDate).length === 0 ? (
                                <div className="p-8 text-center bg-slate-50/50 dark:bg-slate-900/50 rounded-2xl border border-slate-100 dark:border-slate-850">
                                  <span className="text-2xl block mb-1">🕊️</span>
                                  <p className="text-xs font-medium text-slate-400 leading-normal">{t.no_events}</p>
                                </div>
                              ) : (
                                <div className="space-y-2">
                                  {agendaEvents
                                    .filter(ev => ev.dayStr === selectedAgendaDate)
                                    .sort((a, b) => a.time.localeCompare(b.time))
                                    .map((ev) => (
                                      <div key={ev.id} className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 shadow-xs flex items-center justify-between gap-3 text-xs">
                                        <div className="flex items-center gap-2.5">
                                          <span className="text-[10px] font-black text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-950/40 px-2 py-1 rounded-md font-mono">
                                            {ev.time}
                                          </span>
                                          <span className="font-semibold text-slate-800 dark:text-slate-200">{ev.title}</span>
                                        </div>
                                        <button
                                          onClick={() => {
                                            const nextEvents = agendaEvents.filter(item => item.id !== ev.id);
                                            setAgendaEvents(nextEvents);
                                            triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, nextEvents);
                                          }}
                                          className="p-1 hover:bg-red-50 dark:hover:bg-red-950/30 text-slate-400 hover:text-red-500 rounded-md transition-colors"
                                        >
                                          &times;
                                        </button>
                                      </div>
                                    ))}
                                </div>
                              )}
                            </div>

                            {/* Add event form */}
                            <form 
                              onSubmit={(e) => {
                                e.preventDefault();
                                if (!newEventTitle.trim()) return;
                                const newEv = {
                                  id: Date.now(),
                                  title: newEventTitle,
                                  time: newEventTime,
                                  dayStr: selectedAgendaDate
                                };
                                const nextEvents = [...agendaEvents, newEv];
                                setAgendaEvents(nextEvents);
                                setNewEventTitle('');
                                triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, nextEvents);
                              }} 
                              className="p-3 bg-slate-50 dark:bg-slate-900 rounded-2xl border border-slate-100 dark:border-slate-850 space-y-2.5"
                            >
                              <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest block">{t.add_event}</span>
                              <div className="flex gap-2">
                                <input
                                  type="text"
                                  required
                                  placeholder={t.placeholder_event}
                                  value={newEventTitle}
                                  onChange={(e) => setNewEventTitle(e.target.value)}
                                  className="flex-1 bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-xs px-2.5 py-1.5 rounded-xl outline-none text-slate-850 dark:text-slate-150"
                                />
                                <input
                                  type="time"
                                  required
                                  value={newEventTime}
                                  onChange={(e) => setNewEventTime(e.target.value)}
                                  className="bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-xs px-2 py-1.5 rounded-xl outline-none w-[75px] font-mono font-semibold"
                                />
                                <button type="submit" className="px-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-black transition-all flex items-center justify-center cursor-pointer shadow-md shadow-blue-600/10">
                                  +
                                </button>
                              </div>
                            </form>
                          </div>
                        )}

                        {missionsSubTab === 'community' && (
                          <div className="space-y-3.5 flex-1 overflow-y-auto no-scrollbar text-xs">
                            {/* Collaborative Challenges Card */}
                            <div className="p-3.5 rounded-2xl bg-gradient-to-tr from-indigo-500/10 to-blue-500/10 border border-indigo-500/10 space-y-2.5">
                              <div className="flex items-center gap-1.5 font-bold text-indigo-600 dark:text-indigo-400">
                                <span>🚀</span>
                                <span className="text-[10px] uppercase font-black tracking-wider">Quêtes Collectives Nexii</span>
                              </div>
                              <p className="text-[10px] text-slate-500 leading-relaxed">Associez vos forces avec la communauté mondiale Nexii pour débloquer des multiplicateurs d'XP !</p>
                              
                              <div className="space-y-2.5">
                                <div className="space-y-1">
                                  <div className="flex justify-between items-center text-[9px] font-bold text-slate-700 dark:text-slate-300">
                                    <span>🧘 Focus Solidaire</span>
                                    <span>7 450 / 10 000 min</span>
                                  </div>
                                  <div className="h-1.5 w-full bg-slate-100 dark:bg-slate-950 rounded-full overflow-hidden">
                                    <div className="h-full bg-indigo-500 rounded-full" style={{ width: '74.5%' }}></div>
                                  </div>
                                </div>

                                <div className="space-y-1">
                                  <div className="flex justify-between items-center text-[9px] font-bold text-slate-700 dark:text-slate-300">
                                    <span>🌟 Aura Positive Collective</span>
                                    <span>81.5 / 85.0 Aura Moyenne</span>
                                  </div>
                                  <div className="h-1.5 w-full bg-slate-100 dark:bg-slate-950 rounded-full overflow-hidden">
                                    <div className="h-full bg-blue-500 rounded-full" style={{ width: '95%' }}></div>
                                  </div>
                                </div>
                              </div>
                            </div>

                            {/* Leaderboard Section */}
                            <div className="p-3 bg-white dark:bg-slate-900 rounded-2xl border border-slate-100 dark:border-slate-800 space-y-2.5">
                              <div className="flex justify-between items-center px-1">
                                <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Classement Aura (Hebdomadaire)</h3>
                                <span className="text-[9px] bg-amber-100 text-amber-800 px-2 py-0.5 rounded-full font-bold">Guilde Nexii</span>
                              </div>
                              <div className="space-y-2">
                                {[
                                  { rank: 1, name: 'Lucas ⭐', aura: 94, avatar: '🧙‍♂️' },
                                  { rank: 2, name: 'Nexeradesign237 (Vous)', aura: aura.percentage, avatar: '🤖', isMe: true },
                                  { rank: 3, name: 'Sophie', aura: 82, avatar: '👩‍⚕️' },
                                  { rank: 4, name: 'Alexandre', aura: 78, avatar: '👨‍🚀' }
                                ].map((u) => (
                                  <div key={u.rank} className={`flex items-center justify-between p-2 rounded-xl border ${u.isMe ? 'bg-blue-50/50 border-blue-200 dark:bg-blue-950/20 dark:border-blue-900/60 font-bold' : 'bg-slate-50/30 border-slate-100 dark:border-slate-850'}`}>
                                    <div className="flex items-center gap-2">
                                      <span className="text-xs font-black text-slate-400 w-3.5">{u.rank}</span>
                                      <span className="text-sm shrink-0">{u.avatar}</span>
                                      <span className="text-slate-700 dark:text-slate-300 text-xs">{u.name}</span>
                                    </div>
                                    <div className="flex items-center gap-1">
                                      <span className="text-xs font-mono font-black text-purple-600 dark:text-purple-400">{u.aura}</span>
                                      <span className="text-[8px] text-slate-400 uppercase tracking-widest">Aura</span>
                                    </div>
                                  </div>
                                ))}
                              </div>
                            </div>

                            {/* Write a post card */}
                            <div className="p-3 bg-white dark:bg-slate-900 rounded-2xl border border-slate-100 dark:border-slate-800 space-y-2">
                              <div className="flex gap-2.5 items-start">
                                <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-white text-xs font-black">
                                  ✍️
                                </div>
                                <textarea
                                  placeholder={lang === 'fr' ? "Quoi de neuf aujourd'hui ? Partagez une réussite..." : lang === 'es' ? "¿Qué hay de nuevo hoy? Comparte un éxito..." : "What's new today? Share an achievement..."}
                                  value={newPostText}
                                  onChange={(e) => setNewPostText(e.target.value)}
                                  className="flex-1 bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-850 rounded-xl p-2 text-xs outline-none focus:border-indigo-500 h-16 resize-none text-slate-850 dark:text-slate-150"
                                />
                              </div>
                              <div className="flex justify-end">
                                <button
                                  type="button"
                                  onClick={async () => {
                                    if (!newPostText.trim()) return;
                                    if (!user) {
                                      alert(lang === 'fr' ? "Veuillez vous connecter pour publier !" : "Please sign in to post!");
                                      return;
                                    }
                                    const authorName = user.displayName || user.email?.split('@')[0] || 'Aventurier';
                                    const newPostData = {
                                      author: authorName,
                                      authorId: user.uid,
                                      avatarColor: '#6366f1',
                                      text: newPostText,
                                      likes: 0,
                                      likedBy: [],
                                      time: lang === 'fr' ? "À l'instant" : "Just now",
                                      tag: '#BienEtre',
                                      timestamp: new Date().getTime()
                                    };
                                    try {
                                      await addDoc(collection(db, 'community_posts'), newPostData);
                                      setNewPostText('');
                                      awardXp(15, "Partage d'une réussite");
                                    } catch (err) {
                                      console.error("Error creating post:", err);
                                    }
                                  }}
                                  className="px-3 py-1.5 bg-indigo-600 hover:bg-indigo-700 text-white font-black rounded-lg text-[10px] cursor-pointer shadow-xs transition-all flex items-center gap-1"
                                >
                                  <span>🚀</span>
                                  <span>{lang === 'fr' ? 'Partager' : lang === 'es' ? 'Compartir' : 'Share'}</span>
                                </button>
                              </div>
                            </div>

                            {/* Goal Sharing Feed with Real Likes/Hearts */}
                            <div className="p-3 bg-white dark:bg-slate-900 rounded-2xl border border-slate-100 dark:border-slate-800 space-y-2.5">
                              <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Flux de Motivation Partagé</h3>
                              <div className="space-y-2">
                                {communityPosts.map((post) => (
                                  <div key={post.id} className="p-2.5 rounded-xl bg-slate-50/50 dark:bg-slate-950 border border-slate-100 dark:border-slate-850 space-y-1.5">
                                    <div className="flex justify-between items-center text-[9px]">
                                      <div className="flex items-center gap-1.5">
                                        <div 
                                          className="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-black"
                                          style={{ backgroundColor: post.avatarColor }}
                                        >
                                          {post.author[0].toUpperCase()}
                                        </div>
                                        <span className="font-bold text-slate-600 dark:text-slate-400">@{post.author}</span>
                                      </div>
                                      <span className="text-[8px] text-slate-400">{post.time}</span>
                                    </div>
                                    <p className="text-[10px] text-slate-700 dark:text-slate-300 font-sans italic">"{post.text}"</p>
                                    <div className="flex justify-between items-center text-[9px] pt-1">
                                      <span className="text-[8px] text-slate-400">{post.tag || '✨ Partagé via Nexii'}</span>
                                      <button 
                                        type="button"
                                        onClick={async () => {
                                          if (!user) {
                                            alert(lang === 'fr' ? "Veuillez vous connecter pour aimer !" : "Please sign in to like!");
                                            return;
                                          }
                                          const isLiked = post.hasLiked;
                                          const updatedLikedBy = isLiked
                                            ? (post.likedBy || []).filter((uid: string) => uid !== user.uid)
                                            : [...(post.likedBy || []), user.uid];
                                          const diff = isLiked ? -1 : 1;
                                          try {
                                            await setDoc(doc(db, 'community_posts', post.id), {
                                              author: post.author || 'Anonyme',
                                              authorId: post.authorId || '',
                                              avatarColor: post.avatarColor || '#6366f1',
                                              time: post.time || 'Récemment',
                                              text: post.text || '',
                                              likedBy: updatedLikedBy,
                                              likes: Math.max(0, (post.likes || 0) + diff),
                                              tag: post.tag || '#BienEtre',
                                              timestamp: post.timestamp || Date.now()
                                            }, { merge: true });
                                            if (!isLiked) {
                                              awardXp(5, "Encouragement de la communauté");
                                            }
                                          } catch (err) {
                                            console.error("Error liking post:", err);
                                          }
                                        }}
                                        className={`font-black flex items-center gap-1 cursor-pointer transition-all ${post.hasLiked ? 'text-red-500' : 'text-slate-400 hover:text-red-500'}`}
                                      >
                                        <span>{post.hasLiked ? '❤️' : '🤍'}</span>
                                        <span>{post.likes}</span>
                                      </button>
                                    </div>
                                  </div>
                                ))}
                              </div>
                            </div>
                          </div>
                        )}
                      </div>
                    )}

                    {/* TAB 2: TASKS */}
                    {activeTab === 2 && (
                      <div className="space-y-4 flex flex-col h-full">
                        <div className="flex justify-between items-center">
                          <h2 className="text-lg font-bold font-sans">{t.tasks_title}</h2>
                          <CheckSquare className="w-5 h-5 text-blue-600" />
                        </div>

                        {/* Sub-tab selection: Checklist vs. Sport Tracker */}
                        <div className="flex bg-slate-100 dark:bg-slate-900 p-1 rounded-xl">
                          <button
                            type="button"
                            onClick={() => setTasksSubTab('list')}
                            className={`flex-1 text-center py-2 text-xs font-bold rounded-lg transition-all flex items-center justify-center gap-1.5 ${tasksSubTab === 'list' ? 'bg-white dark:bg-slate-800 text-blue-600 dark:text-blue-400 shadow-xs' : 'text-slate-500 hover:text-slate-700'}`}
                          >
                            <CheckSquare className="w-3.5 h-3.5" />
                            {lang === 'fr' ? 'Tâches de Vie' : lang === 'es' ? 'Tareas de Vida' : 'Life Tasks'}
                          </button>
                          <button
                            type="button"
                            onClick={() => setTasksSubTab('sport')}
                            className={`flex-1 text-center py-2 text-xs font-bold rounded-lg transition-all flex items-center justify-center gap-1.5 ${tasksSubTab === 'sport' ? 'bg-white dark:bg-slate-800 text-emerald-600 dark:text-emerald-400 shadow-xs' : 'text-slate-500 hover:text-slate-700'}`}
                          >
                            <span className="text-sm">🏋️</span>
                            {lang === 'fr' ? 'Suivi Sportif' : lang === 'es' ? 'Seguimiento' : 'Sport Tracker'}
                          </button>
                        </div>

                        {tasksSubTab === 'list' ? (
                          <>
                            {isTodayBirthday(userBirthdate) && (
                          <motion.div
                            initial={{ opacity: 0, y: -5 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="p-3 bg-amber-500/10 border border-amber-500/20 dark:border-amber-900/30 rounded-2xl flex items-start gap-2.5"
                          >
                            <span className="text-lg">🎂</span>
                            <div>
                              <p className="text-[11px] font-black text-amber-800 dark:text-amber-400">
                                {lang === 'fr' 
                                  ? "Un peu de douceur pour votre anniversaire !" 
                                  : lang === 'es'
                                  ? "¡Un poco de amabilidad por tu cumpleaños!"
                                  : "A little kindness for your birthday!"}
                              </p>
                              <p className="text-[10px] text-amber-700/95 dark:text-amber-300/90 leading-normal mt-0.5 font-sans">
                                {lang === 'fr'
                                  ? "C'est l'occasion idéale de lever le pied. Essayez de ne pas surcharger votre liste aujourd'hui et privilégiez les tâches douces (catégorie Zen)."
                                  : lang === 'es'
                                  ? "Es la oportunidad perfecta para tomártelo con calma. Intenta no sobrecargar tu lista hoy y prioriza las tareas suaves (categoría Zen)."
                                  : "It's the perfect opportunity to slow down. Try not to overload your list today and prioritize gentle tasks (Zen category)."}
                              </p>
                            </div>
                          </motion.div>
                        )}

                        {/* Search and Filter Inputs */}
                        <div className="space-y-2">
                          <div className="flex gap-2">
                            <input
                              type="text"
                              placeholder={lang === 'fr' ? "Rechercher une tâche..." : lang === 'es' ? "Buscar tarea..." : "Search task..."}
                              value={searchQuery}
                              onChange={(e) => setSearchQuery(e.target.value)}
                              className="flex-1 bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 text-xs px-3 py-2 rounded-xl outline-none focus:border-blue-500"
                            />
                            <select
                              value={selectedTaskPriority}
                              onChange={(e) => setSelectedTaskPriority(e.target.value)}
                              className="bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 text-xs px-2.5 py-2 rounded-xl outline-none focus:border-blue-500 font-medium text-slate-600 dark:text-slate-300 min-w-[110px]"
                            >
                              <option value="Toutes">🚨 {lang === 'fr' ? 'Prio : Toutes' : lang === 'es' ? 'Prio: Todas' : 'Prio: All'}</option>
                              <option value="Haute">🔴 {lang === 'fr' ? 'Haute' : lang === 'es' ? 'Alta' : 'High'}</option>
                              <option value="Moyenne">🟡 {lang === 'fr' ? 'Moyenne' : lang === 'es' ? 'Media' : 'Medium'}</option>
                              <option value="Basse">🟢 {lang === 'fr' ? 'Basse' : lang === 'es' ? 'Baja' : 'Low'}</option>
                            </select>
                          </div>
                          
                          <div className="flex gap-1 overflow-x-auto pb-1 text-[10px] scrollbar-none">
                            {['Toutes', 'Pro', 'Zen', 'Finance', 'Perso'].map((cat) => (
                              <button
                                key={cat}
                                onClick={() => setSelectedTaskCategory(cat)}
                                className={`px-3 py-1 rounded-full whitespace-nowrap transition-all ${selectedTaskCategory === cat ? 'bg-blue-600 text-white font-bold' : 'bg-white dark:bg-slate-900 text-slate-500 border border-slate-100 dark:border-slate-800'}`}
                              >
                                {cat}
                              </button>
                            ))}
                          </div>
                        </div>

                        {/* Gemini AI Task Suggester Card (Premium AI Feature) */}
                        <div className="p-3 bg-linear-to-r from-blue-600/10 via-indigo-600/10 to-purple-600/10 dark:from-blue-950/30 dark:via-indigo-950/20 dark:to-purple-950/30 rounded-2xl border border-blue-500/20 dark:border-blue-900/40 flex flex-col gap-2 shadow-xs">
                          <div className="flex justify-between items-center">
                            <span className="text-[9px] font-black uppercase tracking-wider text-indigo-600 dark:text-indigo-400 flex items-center gap-1">
                              <Sparkles className="w-3 h-3 animate-pulse text-yellow-500" />
                              Recommandations IA Gemini
                            </span>
                            <span className="text-[8px] bg-indigo-100 dark:bg-indigo-950/40 text-indigo-700 dark:text-indigo-300 px-1.5 py-0.5 rounded-full font-bold">Smart Sync</span>
                          </div>
                          <p className="text-[9px] text-slate-500 dark:text-slate-400 leading-normal">
                            Générez instantanément 3 tâches personnalisées adaptées à votre énergie ({getWellnessScore()}%) et votre humeur.
                          </p>
                          <button
                            type="button"
                            disabled={isGeneratingTasks}
                            onClick={generateAiTasks}
                            className={`w-full py-1.5 px-3 rounded-lg text-[9px] font-bold text-white transition-all flex items-center justify-center gap-1.5 cursor-pointer ${
                              isGeneratingTasks
                                ? 'bg-indigo-400 dark:bg-indigo-900/50 cursor-not-allowed animate-pulse'
                                : 'bg-indigo-600 hover:bg-indigo-700 hover:shadow-md hover:shadow-indigo-600/15'
                            }`}
                          >
                            {isGeneratingTasks ? (
                              <>
                                <RefreshCw className="w-2.5 h-2.5 animate-spin" />
                                <span>Génération en cours...</span>
                              </>
                            ) : (
                              <>
                                <span>✨</span>
                                <span>Générer 3 Tâches Personnalisées</span>
                              </>
                            )}
                          </button>
                        </div>

                        {/* Add task form */}
                        <form onSubmit={handleAddTask} className="bg-white dark:bg-slate-900 p-3 rounded-xl border border-slate-100 dark:border-slate-800 space-y-2">
                          <div className="flex gap-2">
                            <input 
                              type="text"
                              placeholder={t.placeholder_add_task}
                              value={newTaskTitle}
                              onChange={(e) => setNewTaskTitle(e.target.value)}
                              className="flex-1 bg-slate-50 dark:bg-slate-950 border border-transparent text-xs px-3 py-2 rounded-lg outline-none focus:bg-white focus:border-blue-500"
                            />
                            <button 
                              type="submit"
                              className="px-3 rounded-lg bg-blue-600 text-white hover:bg-blue-700 transition-colors flex items-center justify-center">
                              <Plus className="w-4 h-4" />
                            </button>
                          </div>
                          <div className="grid grid-cols-2 gap-2 text-[9px] pt-1.5 border-t border-slate-100 dark:border-slate-800/50">
                            <div className="flex gap-1.5 items-center justify-between">
                              <span className="text-slate-400 font-bold">Catégorie</span>
                              <select 
                                value={newTaskCategory} 
                                onChange={(e) => setNewTaskCategory(e.target.value)}
                                className="bg-slate-100 dark:bg-slate-800 rounded px-1 py-0.5 outline-none cursor-pointer text-slate-700 dark:text-slate-300"
                              >
                                <option value="Pro">💼 Pro</option>
                                <option value="Zen">🧘 Zen</option>
                                <option value="Perso">🏠 Perso</option>
                                <option value="Finance">💰 Finance</option>
                              </select>
                            </div>
                            <div className="flex gap-1.5 items-center justify-between">
                              <span className="text-slate-400 font-bold">Priorité</span>
                              <select 
                                value={newTaskPriority} 
                                onChange={(e) => setNewTaskPriority(e.target.value)}
                                className="bg-slate-100 dark:bg-slate-800 rounded px-1 py-0.5 outline-none cursor-pointer text-slate-700 dark:text-slate-300"
                              >
                                <option value="Haute">🔴 Haute</option>
                                <option value="Moyenne">🟡 Moyenne</option>
                                <option value="Basse">🟢 Basse</option>
                              </select>
                            </div>
                          </div>

                          {/* Toggler button for advanced task attributes */}
                          <div className="flex justify-center pt-0.5">
                            <button
                              type="button"
                              onClick={() => setShowAdvancedTaskOptions(!showAdvancedTaskOptions)}
                              className="text-[8px] font-bold text-slate-400 hover:text-slate-600 dark:hover:text-slate-300 transition-colors cursor-pointer"
                            >
                              {showAdvancedTaskOptions ? 'Options simples ▴' : 'Options avancées ▾'}
                            </button>
                          </div>

                          {showAdvancedTaskOptions && (
                            <div className="grid grid-cols-2 gap-2 text-[9px] pt-1.5 border-t border-slate-100/50 dark:border-slate-800/30">
                              <div className="flex gap-1.5 items-center justify-between">
                                <span className="text-slate-400 font-bold">Urgence</span>
                                <select 
                                  value={newTaskUrgency} 
                                  onChange={(e) => setNewTaskUrgency(e.target.value)}
                                  className="bg-slate-100 dark:bg-slate-800 rounded px-1 py-0.5 outline-none cursor-pointer text-slate-700 dark:text-slate-300"
                                >
                                  <option value="Haute">🔥 Urgente</option>
                                  <option value="Moyenne">📅 Normale</option>
                                  <option value="Basse">⏳ Flexible</option>
                                </select>
                              </div>
                              <div className="flex gap-1.5 items-center justify-between">
                                <span className="text-slate-400 font-bold">Difficulté</span>
                                <select 
                                  value={newTaskDifficulty} 
                                  onChange={(e) => setNewTaskDifficulty(e.target.value)}
                                  className="bg-slate-100 dark:bg-slate-800 rounded px-1 py-0.5 outline-none cursor-pointer text-slate-700 dark:text-slate-300"
                                >
                                  <option value="Facile">🟢 Facile</option>
                                  <option value="Moyen">🟡 Moyen</option>
                                  <option value="Difficile">🔴 Difficile</option>
                                </select>
                              </div>
                              <div className="flex gap-1.5 items-center justify-between">
                                <span className="text-slate-400 font-bold">Énergie</span>
                                <select 
                                  value={newTaskEnergy} 
                                  onChange={(e) => setNewTaskEnergy(e.target.value)}
                                  className="bg-slate-100 dark:bg-slate-800 rounded px-1 py-0.5 outline-none cursor-pointer text-slate-700 dark:text-slate-300"
                                >
                                  <option value="Basse">⚡ Éco</option>
                                  <option value="Moyenne">⚡ Moyenne</option>
                                  <option value="Haute">⚡ Élevée</option>
                                </select>
                              </div>
                              <div className="flex gap-1.5 items-center justify-between">
                                <span className="text-slate-400 font-bold">Durée</span>
                                <select 
                                  value={newTaskDuration} 
                                  onChange={(e) => setNewTaskDuration(parseInt(e.target.value))}
                                  className="bg-slate-100 dark:bg-slate-800 rounded px-1 py-0.5 outline-none cursor-pointer text-slate-700 dark:text-slate-300"
                                >
                                  <option value={15}>15 min</option>
                                  <option value={30}>30 min</option>
                                  <option value={45}>45 min</option>
                                  <option value={60}>60 min</option>
                                </select>
                              </div>
                            </div>
                          )}
                        </form>

                        {/* Checklist items */}
                        <div className="space-y-2.5 overflow-y-auto max-h-[190px] pr-1 no-scrollbar">
                          {filteredTasksList.map((task) => {
                            const hasSubtasks = task.subtasks && task.subtasks.length > 0;
                            const completedSub = hasSubtasks ? task.subtasks.filter(s => s.completed).length : 0;
                            const totalSub = hasSubtasks ? task.subtasks.length : 0;
                            
                            return (
                              <div 
                                key={task.id}
                                className={`rounded-xl border transition-all ${
                                  task.completed 
                                    ? 'bg-slate-100/50 dark:bg-slate-900/40 border-slate-200 dark:border-slate-800/60 opacity-60' 
                                    : 'bg-white dark:bg-slate-900 border-slate-100 dark:border-slate-800 shadow-sm'
                                }`}
                              >
                                <div 
                                  onClick={() => toggleTask(task.id)}
                                  className="p-3 cursor-pointer flex items-center justify-between"
                                >
                                  <div className="flex items-center gap-3">
                                    <div className={`w-4 h-4 rounded border flex items-center justify-center transition-colors ${
                                      task.completed ? 'bg-blue-600 border-blue-600 text-white' : 'border-slate-300 dark:border-slate-600'
                                    }`}>
                                      {task.completed && <Check className="w-3 h-3" />}
                                    </div>
                                    <div>
                                      <h4 className={`text-xs font-medium font-sans ${task.completed ? 'line-through text-slate-400' : ''}`}>
                                        {task.title}
                                      </h4>
                                      <div className="flex flex-wrap items-center gap-1.5 mt-1">
                                        <span className="text-[8px] bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-300 px-1.5 py-0.5 rounded font-bold font-sans">{task.category}</span>
                                        <span className={`text-[8px] px-1.5 py-0.5 rounded font-bold font-sans ${task.priority === 'Haute' ? 'bg-red-50 text-red-500' : (task.priority === 'Moyenne' ? 'bg-amber-50 text-amber-500' : 'bg-blue-50 text-blue-500')}`}>{task.priority}</span>
                                        {task.urgency && (
                                          <span className="text-[8px] bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-300 px-1.5 py-0.5 rounded font-medium">{task.urgency === 'Haute' ? '🔥 Urgent' : '📅 Normal'}</span>
                                        )}
                                        {task.energyNeeded && (
                                          <span className="text-[8px] bg-purple-50 dark:bg-purple-950/40 text-purple-600 dark:text-purple-300 px-1.5 py-0.5 rounded font-medium">⚡ {task.energyNeeded}</span>
                                        )}
                                        {task.duration && (
                                          <span className="text-[8px] bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-300 px-1.5 py-0.5 rounded font-medium">⏳ {task.duration}m</span>
                                        )}
                                        {/* AI Recommendation Badge: Recommend if high priority or urgent */}
                                        {(task.priority === 'Haute' || task.urgency === 'Haute') && !task.completed && (
                                          <span className="text-[8px] bg-purple-600 text-white px-1.5 py-0.5 rounded font-bold animate-pulse">✨ Recommandé Nexii</span>
                                        )}
                                        {hasSubtasks && (
                                          <span className="text-[8px] text-slate-400 font-medium">{completedSub}/{totalSub} sous-tâches</span>
                                        )}
                                      </div>
                                    </div>
                                  </div>
                                  <div className="flex items-center gap-1.5">
                                    {hasSubtasks && (
                                      <button 
                                        onClick={(e) => toggleTaskExpanded(task.id, e)}
                                        className="p-1 hover:bg-slate-100 dark:hover:bg-slate-800 rounded"
                                      >
                                        <ChevronRight className={`w-3.5 h-3.5 transform transition-transform ${task.expanded ? 'rotate-90' : ''}`} />
                                      </button>
                                    )}
                                    <button 
                                      onClick={(e) => handleDeleteTask(task.id, e)}
                                      className="p-1 text-slate-300 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-950/20 rounded transition-all"
                                      title="Supprimer la tâche"
                                    >
                                      <Trash2 className="w-3.5 h-3.5" />
                                    </button>
                                  </div>
                                </div>

                                {hasSubtasks && task.expanded && (
                                  <div className="px-3 pb-3 pt-1 border-t border-slate-50 dark:border-slate-800/50 bg-slate-50/50 dark:bg-slate-950/20 rounded-b-xl space-y-2">
                                    {task.subtasks.map(sub => (
                                      <div 
                                        key={sub.id}
                                        onClick={() => toggleSubtask(task.id, sub.id)}
                                        className="flex items-center gap-2 cursor-pointer py-0.5"
                                      >
                                        <div className={`w-3.5 h-3.5 rounded border flex items-center justify-center transition-colors ${
                                          sub.completed ? 'bg-emerald-500 border-emerald-500 text-white' : 'border-slate-300 dark:border-slate-600'
                                        }`}>
                                          {sub.completed && <Check className="w-2.5 h-2.5" />}
                                        </div>
                                        <span className={`text-[11px] ${sub.completed ? 'line-through text-slate-400' : 'text-slate-600 dark:text-slate-300'}`}>{sub.title}</span>
                                      </div>
                                    ))}
                                  </div>
                                )}
                              </div>
                            );
                          })}
                        </div>
                      </>
                    ) : (
                      <div className="space-y-4 flex flex-col h-full overflow-y-auto no-scrollbar pb-6">
                        {/* Stats Cards Row */}
                        <div className="grid grid-cols-3 gap-2">
                          <div className="p-2.5 rounded-xl bg-blue-50/50 dark:bg-blue-950/20 border border-blue-100/50 dark:border-blue-900/30 text-center space-y-0.5 shadow-sm">
                            <span className="text-base">🏆</span>
                            <p className="text-[10px] text-slate-400 font-sans">{lang === 'fr' ? 'Séances' : lang === 'es' ? 'Sesiones' : 'Sessions'}</p>
                            <p className="text-sm font-black font-sans text-slate-800 dark:text-slate-100">{workouts.length}</p>
                          </div>
                          <div className="p-2.5 rounded-xl bg-emerald-50/50 dark:bg-emerald-950/20 border border-emerald-100/50 dark:border-emerald-900/30 text-center space-y-0.5 shadow-sm">
                            <span className="text-base">⏱️</span>
                            <p className="text-[10px] text-slate-400 font-sans">{lang === 'fr' ? 'Durée' : lang === 'es' ? 'Duración' : 'Duration'}</p>
                            <p className="text-xs font-black font-sans text-slate-800 dark:text-slate-100">
                              {(() => {
                                const tot = workouts.reduce((acc, curr) => acc + curr.duration, 0);
                                if (tot >= 60) {
                                  const hrs = Math.floor(tot / 60);
                                  const mins = tot % 60;
                                  return mins > 0 ? `${hrs}h ${mins}m` : `${hrs}h`;
                                }
                                return `${tot} min`;
                              })()}
                            </p>
                          </div>
                          <div className="p-2.5 rounded-xl bg-orange-50/50 dark:bg-orange-950/20 border border-orange-100/50 dark:border-orange-900/30 text-center space-y-0.5 shadow-sm">
                            <span className="text-base">🔥</span>
                            <p className="text-[10px] text-slate-400 font-sans font-sans">Calories</p>
                            <p className="text-sm font-black font-sans text-slate-800 dark:text-slate-100">
                              {workouts.reduce((acc, curr) => acc + curr.calories, 0)} kcal
                            </p>
                          </div>
                        </div>

                        {/* Add Workout Form */}
                        <form onSubmit={handleAddWorkout} className="bg-white dark:bg-slate-900 p-3 rounded-2xl border border-slate-100 dark:border-slate-800 space-y-3 shadow-sm">
                          <h3 className="text-xs font-black text-slate-700 dark:text-slate-300 flex items-center gap-1.5 uppercase tracking-wider">
                            <span>🏋️‍♂️</span> {lang === 'fr' ? 'Enregistrer une séance' : lang === 'es' ? 'Registrar sesión' : 'Log a Session'}
                          </h3>
                          
                          <div className="grid grid-cols-2 gap-2 text-[10px]">
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold text-slate-400 uppercase">{lang === 'fr' ? 'Activité' : 'Activity'}</label>
                              <select 
                                value={newWorkoutType} 
                                onChange={(e) => setNewWorkoutType(e.target.value)}
                                className="w-full bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-lg p-2 outline-none text-xs"
                              >
                                <option value="Course à pied">🏃 {lang === 'fr' ? 'Course à pied' : 'Running'}</option>
                                <option value="Musculation">🏋️ {lang === 'fr' ? 'Musculation' : 'Weight Training'}</option>
                                <option value="Yoga">🧘 Yoga / Pilates</option>
                                <option value="Cyclisme">🚴 {lang === 'fr' ? 'Cyclisme' : 'Cycling'}</option>
                                <option value="Natation">🏊 {lang === 'fr' ? 'Natation' : 'Swimming'}</option>
                                <option value="Marche">🚶 {lang === 'fr' ? 'Marche' : 'Walking'}</option>
                                <option value="Boxe">🥊 Boxe / Arts Martiaux</option>
                                <option value="Football">⚽ Football</option>
                                <option value="Danse">💃 Danse</option>
                                <option value="Autre">🤸 {lang === 'fr' ? 'Autre' : 'Other'}</option>
                              </select>
                            </div>
                            
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold text-slate-400 uppercase">{lang === 'fr' ? 'Durée (minutes)' : 'Duration (minutes)'}</label>
                              <input 
                                type="number"
                                required
                                min="1"
                                max="480"
                                placeholder="ex: 30"
                                value={newWorkoutDuration}
                                onChange={(e) => setNewWorkoutDuration(e.target.value)}
                                className="w-full bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-lg p-2 outline-none text-xs"
                              />
                            </div>
                          </div>

                          <div className="grid grid-cols-2 gap-2 text-[10px]">
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold text-slate-400 uppercase">Intensité</label>
                              <select 
                                value={newWorkoutIntensity} 
                                onChange={(e) => setNewWorkoutIntensity(e.target.value)}
                                className="w-full bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-lg p-2 outline-none text-xs font-bold text-slate-700 dark:text-slate-300"
                              >
                                <option value="Douce">🟢 {lang === 'fr' ? 'Douce' : 'Gentle'}</option>
                                <option value="Moyenne">🟡 {lang === 'fr' ? 'Moyenne' : 'Moderate'}</option>
                                <option value="Intense">🔴 {lang === 'fr' ? 'Intense' : 'High'}</option>
                              </select>
                            </div>

                            <div className="space-y-1">
                              <label className="text-[9px] font-bold text-slate-400 uppercase">Date</label>
                              <input 
                                type="date"
                                required
                                value={newWorkoutDate}
                                onChange={(e) => setNewWorkoutDate(e.target.value)}
                                className="w-full bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-lg p-2 outline-none text-xs"
                              />
                            </div>
                          </div>

                          <button 
                            type="submit"
                            className="w-full py-2.5 rounded-xl bg-emerald-600 text-white hover:bg-emerald-700 transition-colors flex items-center justify-center gap-1.5 text-xs font-bold shadow-sm"
                          >
                            <span>💪</span> {lang === 'fr' ? 'Enregistrer la séance' : lang === 'es' ? 'Grabar entraînement' : 'Save Workout'}
                          </button>
                        </form>

                        {/* Workout History */}
                        <div className="space-y-2">
                          <h3 className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">{lang === 'fr' ? 'Historique des activités' : lang === 'es' ? 'Historial de actividades' : 'Activity History'}</h3>
                          
                          {workouts.length === 0 ? (
                            <div className="bg-slate-50 dark:bg-slate-950/40 border border-dashed border-slate-200 dark:border-slate-800 rounded-2xl p-6 text-center space-y-2">
                              <span className="text-3xl animate-bounce">🏃‍♀️</span>
                              <p className="text-xs text-slate-500 font-sans leading-relaxed">
                                {lang === 'fr' 
                                  ? 'Aucune séance enregistrée pour le moment. Bougez et enregistrez vos activités sportives !' 
                                  : lang === 'es'
                                  ? 'Ningún entrenamiento registrado. ¡Mantente activo y graba tus sesiones!'
                                  : 'No workouts recorded yet. Keep active and save your progress!'}
                              </p>
                            </div>
                          ) : (
                            <div className="space-y-2 max-h-[190px] overflow-y-auto pr-1 no-scrollbar">
                              {workouts.map((work) => {
                                // Map sports to emojis
                                let emoji = '🏃';
                                switch (work.type) {
                                  case 'Course à pied': emoji = '🏃'; break;
                                  case 'Musculation': emoji = '🏋️'; break;
                                  case 'Yoga': emoji = '🧘'; break;
                                  case 'Cyclisme': emoji = '🚴'; break;
                                  case 'Natation': emoji = '🏊'; break;
                                  case 'Marche': emoji = '🚶'; break;
                                  case 'Boxe': emoji = '🥊'; break;
                                  case 'Football': emoji = '⚽'; break;
                                  case 'Danse': emoji = '💃'; break;
                                  default: emoji = '🤸';
                                }

                                return (
                                  <div 
                                    key={work.id}
                                    className="bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-xl p-3 flex items-center justify-between shadow-xs transition-all hover:border-slate-200 dark:hover:border-slate-700"
                                  >
                                    <div className="flex items-center gap-3">
                                      <div className="w-9 h-9 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800/50 flex items-center justify-center text-lg shadow-2xs">
                                        {emoji}
                                      </div>
                                      <div>
                                        <h4 className="text-xs font-bold text-slate-800 dark:text-white leading-tight">
                                          {work.type}
                                        </h4>
                                        <div className="flex items-center gap-1.5 mt-0.5">
                                          <span className={`text-[8px] font-bold px-1.5 py-0.5 rounded ${work.intensity === 'Intense' ? 'bg-red-50 dark:bg-red-950/30 text-red-600 dark:text-red-400' : (work.intensity === 'Moyenne' ? 'bg-amber-50 dark:bg-amber-950/30 text-amber-600 dark:text-amber-400' : 'bg-emerald-50 dark:bg-emerald-950/30 text-emerald-600 dark:text-emerald-400')}`}>{work.intensity}</span>
                                          <span className="text-[8px] text-slate-400">{work.duration} min</span>
                                          <span className="text-[8px] text-slate-400">•</span>
                                          <span className="text-[8px] text-slate-400">{new Date(work.date).toLocaleDateString(lang === 'fr' ? 'fr-FR' : lang === 'es' ? 'es-ES' : 'en-US', { day: 'numeric', month: 'short' })}</span>
                                        </div>
                                      </div>
                                    </div>
                                    
                                    <div className="flex items-center gap-3">
                                      <div className="text-right">
                                        <p className="text-xs font-black text-slate-800 dark:text-slate-100 font-mono">{work.calories} kcal</p>
                                      </div>
                                      <button 
                                        type="button"
                                        onClick={() => handleDeleteWorkout(work.id)}
                                        className="p-1.5 text-slate-400 hover:text-red-500 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-950 transition-all"
                                      >
                                        <Trash2 className="w-3.5 h-3.5" />
                                      </button>
                                    </div>
                                  </div>
                                );
                              })}
                            </div>
                          )}
                        </div>
                      </div>
                    )}
                  </div>
                )}

                {/* TAB 3: FOCUS TIMER */}
                    {activeTab === 3 && (
                      <div className="space-y-4 flex flex-col items-center justify-center h-full pt-1">
                        <div className="w-full flex justify-between items-center mb-1">
                          <h2 className="text-lg font-bold font-sans mr-auto">{t.focus_title}</h2>
                          <Volume2 className="w-4 h-4 text-purple-500 animate-pulse" />
                        </div>

                        {/* Mode Selection Toggler */}
                        <div className="flex bg-slate-100 dark:bg-slate-800/80 p-1 rounded-xl w-full max-w-[280px] mx-auto mb-1 text-xs">
                          <button
                            type="button"
                            onClick={() => {
                              setTimerType('Pomodoro');
                              setTimerRunning(false);
                              setInitialDuration(1500);
                              setTimerSeconds(1500);
                            }}
                            className={`flex-1 py-1.5 rounded-lg text-center font-bold transition-all cursor-pointer ${
                              timerType === 'Pomodoro'
                                ? 'bg-white dark:bg-slate-900 text-slate-800 dark:text-white shadow-xs font-black'
                                : 'text-slate-400 hover:text-slate-600'
                            }`}
                          >
                            🍅 Pomodoro
                          </button>
                          <button
                            type="button"
                            onClick={() => {
                              setTimerType('Coherence');
                              setTimerRunning(false);
                              setInitialDuration(120);
                              setTimerSeconds(120);
                            }}
                            className={`flex-1 py-1.5 rounded-lg text-center font-bold transition-all cursor-pointer ${
                              timerType === 'Coherence'
                                ? 'bg-white dark:bg-slate-900 text-slate-800 dark:text-white shadow-xs font-black'
                                : 'text-slate-400 hover:text-slate-600'
                            }`}
                          >
                            🧘 {lang === 'fr' ? 'Cohérence' : 'Coherence'}
                          </button>
                        </div>

                        {/* Pomodoro Session tracker dots / Coherence Subtitle */}
                        {timerType === 'Pomodoro' ? (
                          <div className="flex gap-1.5 items-center text-[10px] text-slate-400 mb-1">
                            <span>Session {pomodoroSession} / 4</span>
                            <div className="flex gap-1">
                              {[1, 2, 3, 4].map(s => (
                                <div key={s} className={`w-2 h-2 rounded-full ${s < pomodoroSession ? 'bg-purple-600' : (s === pomodoroSession ? 'bg-purple-600 animate-pulse' : 'bg-slate-300')}`}></div>
                              ))}
                            </div>
                          </div>
                        ) : (
                          <div className="text-[10px] text-slate-400 font-semibold mb-1 flex items-center gap-1">
                            <span>Respiration Cohérente (Cycle 5s / 5s)</span>
                          </div>
                        )}

                        {/* Central Breathing Ring */}
                        <div className="relative flex items-center justify-center py-4">
                          {/* Pulsing visual halo */}
                          <div 
                            style={{
                              transform: timerRunning && timerType === 'Coherence' && breathPhase === 'inhale' ? 'scale(1.3)' : 'scale(1.0)'
                            }}
                            className={`absolute w-44 h-44 rounded-full border border-purple-500/30 transition-transform duration-[5000ms] ease-in-out ${
                              timerRunning && timerType === 'Pomodoro' ? 'animate-ping' : ''
                            }`}
                          ></div>
                          
                          <div 
                            style={{
                              transform: timerRunning && timerType === 'Coherence' && breathPhase === 'inhale' ? 'scale(1.15)' : 'scale(1.0)'
                            }}
                            className="w-40 h-40 rounded-full bg-white dark:bg-slate-900 border-4 border-purple-500/20 flex flex-col items-center justify-center shadow-xl relative z-10 transition-transform duration-[5000ms] ease-in-out"
                          >
                            <span className="text-3xl font-extrabold font-mono tracking-wider text-slate-900 dark:text-white">
                              {formatTimer(timerSeconds)}
                            </span>
                            <span className="text-[10px] text-purple-600 dark:text-purple-400 font-bold mt-1 tracking-widest uppercase">
                              {timerRunning ? (
                                timerType === 'Coherence' ? (
                                  breathPhase === 'inhale' ? (lang === 'fr' ? 'INSPIRER ▴' : 'INHALE ▴') : (lang === 'fr' ? 'EXPIRER ▾' : 'EXHALE ▾')
                                ) : (lang === 'fr' ? 'RESPIRER' : lang === 'es' ? 'RESPIRA' : 'BREATHE')
                              ) : (
                                timerType === 'Coherence' ? (lang === 'fr' ? 'COHÉRENCE' : 'COHERENCE') : 'POMODORO'
                              )}
                            </span>
                          </div>
                        </div>

                        {/* Adaptive Pomodoro Preset Modes - only for Pomodoro */}
                        {timerType === 'Pomodoro' && (
                          <div className="w-full space-y-1.5 bg-white dark:bg-slate-900 p-2.5 rounded-xl border border-slate-100 dark:border-slate-800">
                            <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider block px-1">Mode de Concentration Adaptatif</label>
                            <div className="grid grid-cols-4 gap-1">
                              {[
                                { id: 'Flow', label: 'Flow', dur: 40, desc: '40/5 min' },
                                { id: 'Productif', label: 'Productif', dur: 25, desc: '25/5 min' },
                                { id: 'Fatigué', label: 'Fatigué', dur: 20, desc: '20/10 min' },
                                { id: 'Protection', label: 'Protection', dur: 15, desc: '15/5 min' }
                              ].map(m => (
                                <button
                                  key={m.id}
                                  type="button"
                                  onClick={() => {
                                    setFocusTimerMode(m.id as any);
                                    changeTimerPreset(m.dur);
                                  }}
                                  className={`py-1.5 px-1 rounded-xl text-center border transition-all cursor-pointer ${
                                    focusTimerMode === m.id
                                      ? 'bg-purple-600 border-purple-600 text-white font-black shadow-xs'
                                      : 'bg-slate-50 dark:bg-slate-950 border-slate-100 dark:border-slate-800 text-slate-500 hover:text-slate-900 hover:border-slate-300'
                                  }`}
                                >
                                  <span className="block text-[9px] font-bold">{m.label}</span>
                                  <span className="block text-[8px] opacity-75">{m.desc}</span>
                                </button>
                              ))}
                            </div>
                          </div>
                        )}

                        {/* Sound Picker */}
                        <div className="w-full space-y-2 bg-white dark:bg-slate-900 p-2.5 rounded-xl border border-slate-100 dark:border-slate-800">
                          <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider block px-1">{t.sound_picker}</label>
                          <div className="flex gap-1 overflow-x-auto pb-1 text-[10px] scrollbar-none">
                            {['Pluie en Forêt', 'Vagues d\'Océan', 'Bruit Blanc', 'Silence'].map((sound) => (
                              <button
                                key={sound}
                                onClick={() => setSelectedSound(sound)}
                                className={`px-2.5 py-1 rounded-full whitespace-nowrap transition-all ${selectedSound === sound ? 'bg-purple-600 text-white font-bold' : 'bg-slate-100 dark:bg-slate-800 text-slate-500 hover:text-slate-900'}`}
                              >
                                {sound}
                              </button>
                            ))}
                          </div>

                          {/* Volume Control */}
                          {selectedSound !== 'Silence' && (
                            <div className="flex items-center gap-2 px-1 pt-1.5 border-t border-slate-50 dark:border-slate-800/50">
                              <Volume2 className="w-3.5 h-3.5 text-purple-500 shrink-0" />
                              <input 
                                type="range" 
                                min="0" 
                                max="1" 
                                step="0.05"
                                value={soundVolume}
                                onChange={(e) => setSoundVolume(parseFloat(e.target.value))}
                                className="w-full h-1 bg-slate-100 dark:bg-slate-800 rounded-lg appearance-none cursor-pointer accent-purple-600"
                              />
                              <span className="text-[9px] font-mono font-bold text-slate-400 w-6 text-right">
                                {Math.round(soundVolume * 100)}%
                              </span>
                            </div>
                          )}
                        </div>

                        {/* Action buttons */}
                        <div className="flex gap-3 justify-center items-center pt-1">
                          <button 
                            onClick={() => {
                              setTimerSeconds(initialDuration);
                              setTimerRunning(false);
                            }}
                            className="p-2.5 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-200 transition-colors">
                            <RotateCcw className="w-4 h-4" />
                          </button>

                          <button
                            onClick={() => setTimerRunning(!timerRunning)}
                            className="px-6 py-2.5 rounded-full bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs tracking-wider transition-all shadow-md shadow-blue-600/20 flex items-center gap-2"
                          >
                            {timerRunning ? <Pause className="w-3.5 h-3.5" /> : <Play className="w-3.5 h-3.5" />}
                            {timerRunning ? t.pause_timer : t.start_timer}
                          </button>

                          {/* Instant skip to finish session */}
                          <button 
                            onClick={() => {
                              setTimerSeconds(2);
                              setTimerRunning(true);
                            }}
                            className="p-2.5 rounded-full bg-purple-100 text-purple-600 dark:bg-purple-950 dark:text-purple-300 hover:bg-purple-200 transition-colors"
                            title="Simuler fin de session"
                          >
                            ⏭️
                          </button>
                        </div>
                      </div>
                    )}

                    {/* TAB 4: COACH AI */}
                    {activeTab === 4 && (
                      <div className="flex flex-col h-[350px]">
                        <div className="flex justify-between items-center mb-2">
                          <h2 className="text-sm font-bold font-sans text-purple-600 dark:text-purple-400 flex items-center gap-1.5">
                            <Brain className="w-4 h-4" />
                            {t.coach_title} AI
                          </h2>
                          <div className="flex items-center gap-1.5">
                            <select
                              value={selectedAiProvider}
                              onChange={(e: any) => setSelectedAiProvider(e.target.value)}
                              className="text-[9px] bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 px-2 py-1 rounded-lg font-bold outline-none border-none cursor-pointer hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors"
                            >
                              <option value="gemini">Google Gemini</option>
                              <option value="openai">OpenAI GPT-4</option>
                              <option value="claude">Claude 3.5</option>
                              <option value="local">Moteur Local</option>
                            </select>
                            <span className="text-[9px] bg-purple-100 text-purple-800 dark:bg-purple-900/50 dark:text-purple-300 px-2.5 py-1 rounded-full font-bold">Actif</span>
                          </div>
                        </div>

                        {/* Coach Personality Selector (Fonction 1) */}
                        <div className="mb-2 bg-slate-50 dark:bg-slate-900/50 p-1.5 rounded-xl border border-slate-100 dark:border-slate-850/60 flex items-center justify-between gap-1.5 overflow-x-auto scrollbar-none">
                          <span className="text-[9px] font-bold text-slate-400 uppercase tracking-wider shrink-0 px-1">Personnalité :</span>
                          <div className="flex gap-1">
                            {['Bienveillant', 'Direct', 'Analytique', 'Calme', 'Motivant'].map((p) => (
                              <button
                                key={p}
                                type="button"
                                onClick={() => {
                                  setCoachPersonality(p as any);
                                  // Update greeting/system prompt based on personality
                                  const systemMsg = p === 'Bienveillant' ? "Nexii passe en mode Bienveillant. Je suis là pour t'écouter avec compassion." :
                                                    p === 'Direct' ? "Nexii passe en mode Direct. Je serai franc et axé sur l'action brute !" :
                                                    p === 'Analytique' ? "Nexii passe en mode Analytique. Analysons tes statistiques avec précision." :
                                                    p === 'Calme' ? "Nexii passe en mode Calme. Respire profondément, avançons sereinement." :
                                                    "Nexii passe en mode Motivant. Donne tout aujourd'hui ! Tu as le pouvoir d'accomplir de grandes choses !";
                                  setMessages(prev => [...prev, {
                                    id: Date.now(),
                                    text: `✨ ${systemMsg}`,
                                    isUser: false
                                  }]);
                                }}
                                className={`text-[8px] px-2.5 py-0.5 rounded-full font-extrabold transition-all shrink-0 cursor-pointer ${coachPersonality === p ? 'bg-purple-600 text-white shadow-xs' : 'bg-slate-100 dark:bg-slate-800 text-slate-500 hover:text-slate-700'}`}
                              >
                                {p}
                              </button>
                            ))}
                          </div>
                        </div>

                        {/* Vocal mode toggle button (Fonction 8) */}
                        <div className="mb-2 flex gap-1.5">
                          <button
                            type="button"
                            onClick={() => {
                              const nextVoiceMode = !isVoiceMode;
                              setIsVoiceMode(nextVoiceMode);
                              if (nextVoiceMode) {
                                const greetText = lang === 'fr' ? "Salut ! Je t'écoute. Comment te sens-tu aujourd'hui ?" :
                                                  lang === 'es' ? "¡Hola! Te escucho. ¿Cómo te sientes hoy?" :
                                                  "Hi! I'm listening. How are you feeling today?";
                                speakText(greetText);
                                setTimeout(() => {
                                  setMessages(prev => [...prev, {
                                    id: Date.now() + 50,
                                    text: `🎤 [Coach Vocal] ${greetText}`,
                                    isUser: false
                                  }]);
                                }, 800);
                              } else {
                                if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
                                  window.speechSynthesis.cancel();
                                }
                                if (recognitionActive && recognitionRef.current) {
                                  recognitionRef.current.stop();
                                }
                              }
                            }}
                            className={`flex-1 py-1 px-3 rounded-xl border text-[10px] font-black tracking-wide flex items-center justify-center gap-1.5 transition-all cursor-pointer ${isVoiceMode ? 'bg-red-500 text-white border-red-500 animate-pulse' : 'bg-white dark:bg-slate-900 text-slate-700 dark:text-slate-300 border-slate-100 dark:border-slate-800 hover:bg-slate-50'}`}
                          >
                            <span>🎤</span>
                            <span>{isVoiceMode ? 'Désactiver le Coach Vocal' : 'Activer le Coach Vocal Nexii'}</span>
                          </button>
                        </div>

                        {/* Adaptive State Coach Warning */}
                        {getWellnessScore() < 50 && !isVoiceMode && (
                          <div className="mb-2.5 p-3 bg-red-500/10 dark:bg-red-500/5 border border-red-500/20 rounded-xl text-[10px] text-red-600 dark:text-red-400 space-y-1.5 animate-fadeIn">
                            <div className="flex items-center gap-1.5 font-bold">
                              <Sparkles className="w-3.5 h-3.5 text-red-500 animate-pulse" />
                              <span>Conseil d'adaptation Nexii</span>
                            </div>
                            <p className="font-sans leading-tight">Votre score d'énergie est très bas ({getWellnessScore()}%). L'IA recommande d'ajuster le Pomodoro et de planifier un temps de récupération.</p>
                            <div className="flex gap-2 pt-0.5">
                              <button 
                                onClick={() => {
                                  setInitialDuration(15 * 60);
                                  setTimerSeconds(15 * 60);
                                  awardXp(10, "Adaptation Pomodoro par l'IA");
                                  alert("Pomodoro adapté à 15 minutes de concentration pour préserver votre énergie ! 🧘");
                                }}
                                className="px-2.5 py-1 bg-red-600 hover:bg-red-700 text-white font-extrabold rounded-lg text-[8px] transition-all"
                              >
                                Réduire Pomodoro à 15m
                              </button>
                              <button 
                                onClick={() => {
                                  setRecoveryOverlay(true);
                                  setRecoverySeconds(300);
                                  setRecoveryRunning(true);
                                  awardXp(15, "Temps de récupération suggéré par l'IA");
                                }}
                                className="px-2.5 py-1 bg-slate-800 dark:bg-slate-200 text-white dark:text-slate-900 font-extrabold rounded-lg text-[8px] transition-all"
                              >
                                Récupérer 5 minutes
                              </button>
                            </div>
                          </div>
                        )}

                        {isVoiceMode ? (
                          /* Vocal visualization if active */
                          <div className="flex-1 bg-gradient-to-b from-purple-900/10 to-blue-900/10 dark:from-purple-950/20 dark:to-blue-950/20 rounded-2xl border border-purple-500/20 p-4 flex flex-col items-center justify-center space-y-4 animate-fadeIn">
                            {speechError && (
                              <div className="w-full bg-red-500/10 border border-red-500/20 text-red-600 dark:text-red-400 rounded-xl p-2.5 text-center text-[9px] font-extrabold leading-normal animate-fadeIn">
                                ⚠️ {speechError}
                              </div>
                            )}
                            <div className="relative flex items-center justify-center">
                              {/* Glowing voice ripple circles */}
                              <div className={`absolute w-20 h-20 rounded-full ${recognitionActive ? 'bg-red-500/20 animate-ping' : 'bg-purple-500/15 animate-ping'} duration-1000`}></div>
                              <div className={`absolute w-24 h-24 rounded-full ${recognitionActive ? 'bg-red-500/10 animate-pulse' : 'bg-blue-500/10 animate-pulse'} duration-1500`}></div>
                              <button
                                type="button"
                                onClick={toggleSpeechRecognition}
                                className={`w-16 h-16 rounded-full bg-gradient-to-tr ${recognitionActive ? 'from-red-600 to-rose-500 shadow-red-500/30' : 'from-purple-600 to-blue-500 shadow-purple-500/30'} flex items-center justify-center text-white text-xl shadow-lg hover:scale-105 active:scale-95 transition-all cursor-pointer`}
                                title="Cliquer pour parler"
                              >
                                {recognitionActive ? '🔴' : '🎙️'}
                              </button>
                            </div>
                            <div className="text-center space-y-1.5 w-full">
                              <span className={`text-[10px] font-black ${recognitionActive ? 'text-red-500 animate-pulse' : 'text-purple-600 dark:text-purple-400'} uppercase tracking-widest block`}>
                                {recognitionActive ? 'Nexii vous écoute...' : 'Nexii Vocal est en attente...'}
                              </span>
                              
                              {/* Audio bars bouncing */}
                              <div className="flex gap-1 justify-center items-end h-6">
                                {[1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1].map((b, i) => (
                                  <div
                                    key={i}
                                    style={{ 
                                      animationDelay: `${i * 0.08}s`, 
                                      animationDuration: recognitionActive ? '0.4s' : '0.8s',
                                      height: recognitionActive ? '100%' : '30%' 
                                    }}
                                    className={`w-1 bg-gradient-to-t ${recognitionActive ? 'from-red-500 to-rose-400' : 'from-purple-600 to-blue-500'} rounded-full animate-bounce`}
                                  ></div>
                                ))}
                              </div>

                              <p className="text-[10px] text-slate-400 italic max-w-xs mx-auto text-center line-clamp-2 px-2">
                                {recognitionActive 
                                  ? '"Parlez maintenant... Votre parole s\'affichera automatiquement."' 
                                  : '"Cliquez sur le micro pour parler réellement, ou simulez une entrée avec le bouton."'}
                              </p>
                            </div>
                            <div className="flex gap-2 w-full max-w-[280px]">
                              <button
                                type="button"
                                onClick={toggleSpeechRecognition}
                                className={`flex-1 text-[9px] font-extrabold py-1.5 px-3 rounded-xl transition-all cursor-pointer shadow-xs border text-center ${recognitionActive ? 'bg-red-500 text-white border-red-500' : 'bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 border-transparent hover:bg-slate-200'}`}
                              >
                                {recognitionActive ? 'Arrêter le micro' : 'Parler au micro'}
                              </button>
                              <button
                                type="button"
                                onClick={() => {
                                  // Simulate user voice command input
                                  const simulatedVoiceInputs = [
                                    "Je me sens un peu fatigué aujourd'hui mais j'ai des devoirs importants à rendre.",
                                    "Aujourd'hui, j'ai une énergie au top ! Planifie mes tâches les plus dures.",
                                    "Je me sens stressé par mon budget."
                                  ];
                                  const randomInput = simulatedVoiceInputs[Math.floor(Math.random() * simulatedVoiceInputs.length)];
                                  setMessages(prev => [...prev, {
                                    id: Date.now(),
                                    text: `🎤 [Vocal User] "${randomInput}"`,
                                    isUser: true
                                  }]);
                                  handleSendMessage(randomInput);
                                }}
                                className="flex-1 text-[9px] bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 hover:text-purple-600 hover:border-purple-500 font-extrabold px-3 py-1.5 rounded-xl transition-all cursor-pointer shadow-xs"
                              >
                                🗣️ Simuler la voix
                              </button>
                            </div>
                          </div>
                        ) : (
                          <>
                            {/* Message log */}
                        <div className="flex-1 overflow-y-auto space-y-2.5 pr-1 py-1 text-[11px] no-scrollbar">
                          {messages.map((msg) => (
                            <div 
                              key={msg.id}
                              className={`p-3 rounded-2xl max-w-[85%] leading-relaxed ${
                                msg.isUser 
                                  ? 'bg-blue-600 text-white ml-auto rounded-tr-none' 
                                  : 'bg-white dark:bg-slate-900 text-slate-700 dark:text-slate-300 mr-auto rounded-tl-none border border-slate-100 dark:border-slate-800'
                              }`}
                            >
                              <p className="font-sans text-[11px]">{msg.text}</p>
                            </div>
                          ))}
                          {isTyping && (
                            <div className="p-3 rounded-2xl max-w-[40%] bg-white dark:bg-slate-900 mr-auto rounded-tl-none border border-slate-100 dark:border-slate-800 flex items-center justify-center gap-1">
                              <span className="w-1.5 h-1.5 rounded-full bg-purple-500 animate-bounce"></span>
                              <span className="w-1.5 h-1.5 rounded-full bg-purple-500 animate-bounce delay-100"></span>
                              <span className="w-1.5 h-1.5 rounded-full bg-purple-500 animate-bounce delay-200"></span>
                            </div>
                          )}
                        </div>

                        {/* Chat interactive suggest bar */}
                        <div className="flex gap-1 overflow-x-auto py-1.5 scrollbar-none">
                          {[
                            { tag: 'stress', text: 'Je me sens un peu envahi par le stress aujourd\'hui...' },
                            { tag: 'fatigue', text: 'Je me sens très fatigué, comment retrouver de l\'énergie ?' },
                            { tag: 'budget', text: 'Je stresse pour mes dépenses ce mois-ci, que faire ?' },
                            { tag: 'merci', text: 'Merci beaucoup pour tes précieux conseils !' }
                          ].map((keywordObj) => (
                            <button
                              key={keywordObj.tag}
                              onClick={() => handleSendMessage(keywordObj.text)}
                              className="text-[9px] whitespace-nowrap bg-slate-100 dark:bg-slate-900 border border-slate-200/50 dark:border-slate-800 px-2.5 py-1 rounded-full text-slate-500 hover:text-blue-600 hover:border-blue-500 transition-all font-sans"
                            >
                              #{keywordObj.tag}
                            </button>
                          ))}
                        </div>

                        {/* Chat input bar */}
                        <div className="flex gap-2 pt-1 border-t border-slate-100 dark:border-slate-800/80">
                          <input 
                            type="text"
                            placeholder={t.placeholder_chat}
                            value={chatInput}
                            onChange={(e) => setChatInput(e.target.value)}
                            onKeyDown={(e) => { if (e.key === 'Enter') handleSendMessage(); }}
                            className="flex-1 bg-white dark:bg-slate-900 border border-slate-150 dark:border-slate-800 text-xs px-3.5 py-2.5 rounded-full outline-none focus:border-blue-500"
                          />
                          <button 
                            onClick={() => handleSendMessage()}
                            className="p-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-full flex items-center justify-center transition-colors">
                            <Send className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </>
                    )}
                  </div>
                )}

                    {/* TAB 5: BUDGET */}
                    {activeTab === 5 && (
                      <div className="space-y-4">
                        <div className="flex justify-between items-center">
                          <h2 className="text-lg font-bold font-sans">{t.budget_title}</h2>
                          <button 
                            onClick={() => setShowAddTransaction(!showAddTransaction)}
                            className="p-1 text-blue-600 hover:bg-blue-50 dark:hover:bg-slate-800 rounded-full"
                          >
                            <Plus className="w-5 h-5" />
                          </button>
                        </div>

                        {/* Form to add custom expense/income dynamically */}
                        {showAddTransaction && (
                          <form onSubmit={handleAddTransaction} className="p-3 bg-blue-50/50 dark:bg-slate-900 rounded-xl border border-blue-100 dark:border-slate-800 space-y-2 text-xs">
                            <div className="flex gap-2 justify-between">
                              <span className="font-bold">
                                {lang === 'fr' ? 'Nouvelle transaction' : lang === 'es' ? 'Nueva transacción' : 'New transaction'}
                              </span>
                              <div className="flex gap-1">
                                <button type="button" onClick={() => setTransIsExpense(true)} className={`px-2 py-0.5 rounded text-[10px] ${transIsExpense ? 'bg-red-500 text-white font-bold' : 'bg-slate-200 text-slate-600 dark:bg-slate-850 dark:text-slate-300'}`}>
                                  {lang === 'fr' ? 'Dépense' : lang === 'es' ? 'Gasto' : 'Expense'}
                                </button>
                                <button type="button" onClick={() => setTransIsExpense(false)} className={`px-2 py-0.5 rounded text-[10px] ${!transIsExpense ? 'bg-emerald-500 text-white font-bold' : 'bg-slate-200 text-slate-600 dark:bg-slate-850 dark:text-slate-300'}`}>
                                  {lang === 'fr' ? 'Revenu' : lang === 'es' ? 'Ingreso' : 'Income'}
                                </button>
                              </div>
                            </div>
                            <input 
                              type="text" 
                              required
                              placeholder={lang === 'fr' ? 'Libellé (ex: Courses Carrefour)' : lang === 'es' ? 'Concepto (ej: Compras Supermercado)' : 'Label (e.g. Groceries)'} 
                              value={transTitle}
                              onChange={(e) => setTransTitle(e.target.value)}
                              className="w-full bg-white dark:bg-slate-950 px-2 py-1 rounded border border-slate-200 dark:border-slate-800 outline-none"
                            />
                            <div className="flex gap-2">
                              <input 
                                type="number" 
                                required
                                step="0.01"
                                placeholder={`${lang === 'fr' ? 'Montant' : lang === 'es' ? 'Monto' : 'Amount'} (${getCurrencySymbol(currency)})`} 
                                value={transAmount}
                                onChange={(e) => setTransAmount(e.target.value)}
                                className="flex-1 bg-white dark:bg-slate-950 px-2 py-1 rounded border border-slate-200 dark:border-slate-800 outline-none"
                              />
                              <select 
                                value={transCategory}
                                onChange={(e) => setTransCategory(e.target.value)}
                                className="bg-white dark:bg-slate-950 px-2 py-1 rounded border border-slate-200 dark:border-slate-800 text-[11px]"
                              >
                                <option value="Alimentation">{lang === 'fr' ? 'Alimentation' : lang === 'es' ? 'Alimentación' : 'Food'}</option>
                                <option value="Loisirs">{lang === 'fr' ? 'Loisirs' : lang === 'es' ? 'Ocio' : 'Leisure'}</option>
                                <option value="Maison">{lang === 'fr' ? 'Maison' : lang === 'es' ? 'Casa' : 'Home'}</option>
                                <option value="Abonnement">{lang === 'fr' ? 'Abonnement' : lang === 'es' ? 'Suscripción' : 'Subscription'}</option>
                                <option value="Bonus">{lang === 'fr' ? 'Bonus' : lang === 'es' ? 'Bono' : 'Bonus'}</option>
                              </select>
                            </div>
                            <button type="submit" className="w-full py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded font-bold uppercase text-[9px]">
                              {lang === 'fr' ? 'Ajouter' : lang === 'es' ? 'Añadir' : 'Add'}
                            </button>
                          </form>
                        )}

                        {/* Remaining balance widget */}
                        <div className="bg-white dark:bg-slate-900 p-4 rounded-2xl border border-slate-150 dark:border-slate-800 shadow-sm text-center space-y-1.5">
                          <span className="text-[10px] uppercase font-bold tracking-widest text-slate-400 block">{t.remain_budget}</span>
                          <span className={`text-2xl font-extrabold block ${remainingBudget >= 0 ? 'text-emerald-500' : 'text-red-500'}`}>{remainingBudget.toFixed(2)} {getCurrencySymbol(currency)}</span>
                          
                          <div className="flex justify-between text-[11px] text-slate-400 pt-2 border-t border-slate-100 dark:border-slate-800/60 font-sans">
                            <div>
                              <span>{t.budget_total}</span>
                              <p className="font-bold text-slate-700 dark:text-slate-300">{totalBudget.toFixed(2)} {getCurrencySymbol(currency)}</p>
                            </div>
                            <div>
                              <span>{t.spent_amount}</span>
                              <p className="font-bold text-slate-700 dark:text-slate-300">{spentAmount.toFixed(2)} {getCurrencySymbol(currency)}</p>
                            </div>
                          </div>

                          <div className="h-1.5 w-full bg-slate-100 dark:bg-slate-800 rounded-full overflow-hidden mt-1">
                            <div className="h-full bg-blue-600 rounded-full transition-all" style={{ width: `${budgetProgressPercent}%` }}></div>
                          </div>
                          <span className="text-[10px] text-slate-400 block pt-1">
                            {budgetProgressPercent.toFixed(0)}% {lang === 'fr' ? 'utilisé' : lang === 'es' ? 'utilizado' : 'used'}
                          </span>
                        </div>

                        {/* Financial Stress Gauge Widget */}
                        <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-150 dark:border-slate-800 flex items-center gap-3">
                          <div className={`p-2 rounded-full ${stressColorClass}`}>
                            <Brain className="w-5 h-5" />
                          </div>
                          <div className="flex-1 space-y-1">
                            <div className="flex justify-between text-xs font-bold">
                              <span>{lang === 'fr' ? 'Stress Financier' : lang === 'es' ? 'Estrés Financiero' : 'Financial Stress'}</span>
                              <span className={budgetProgressPercent > 80 ? 'text-red-500' : (budgetProgressPercent > 50 ? 'text-amber-500' : 'text-emerald-500')}>{stressLevel}</span>
                            </div>
                            <div className="h-1.5 w-full bg-slate-100 dark:bg-slate-800 rounded-full overflow-hidden">
                              <div className={`h-full ${stressBarColor}`} style={{ width: `${stressScore * 10}%` }}></div>
                            </div>
                            <span className="text-[9px] text-slate-400 block font-sans">
                              {lang === 'fr' ? 'Indice' : lang === 'es' ? 'Índice' : 'Index'} : {stressScore}/10
                            </span>
                          </div>
                        </div>

                        {/* Recent ledger */}
                        <div className="space-y-2 max-h-[340px] overflow-y-auto no-scrollbar">
                          <h3 className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">{t.recent_trans}</h3>
                          
                          {transactions.length === 0 ? (
                            <div className="p-4 text-center text-xs text-slate-400 bg-white dark:bg-slate-900 border border-slate-150 dark:border-slate-850 rounded-xl">
                              {lang === 'fr' ? 'Aucune transaction enregistrée.' : lang === 'es' ? 'No hay transacciones registradas.' : 'No transactions recorded.'}
                            </div>
                          ) : (
                            transactions.map(t => {
                              const isNegative = t.amount < 0;
                              return (
                                <div key={t.id} className="p-2.5 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 shadow-xs flex items-center justify-between text-xs group transition-all">
                                  <div className="flex items-center gap-2">
                                    <div className={`p-1 rounded-full ${isNegative ? 'bg-red-50 text-red-500 dark:bg-red-950/20 dark:text-red-400' : 'bg-emerald-50 text-emerald-500 dark:bg-emerald-950/20 dark:text-emerald-400'}`}>
                                      {isNegative ? <TrendingDown className="w-3 h-3" /> : <TrendingUp className="w-3 h-3" />}
                                    </div>
                                    <div>
                                      <h4 className="font-bold">{t.title}</h4>
                                      <span className="text-[9px] text-slate-400">{t.category} &bull; {t.date}</span>
                                    </div>
                                  </div>
                                  <div className="flex items-center gap-2">
                                    <span className={`font-bold ${isNegative ? 'text-red-500' : 'text-emerald-500'}`}>
                                      {isNegative ? '' : '+'}{t.amount.toFixed(2)} {getCurrencySymbol(currency)}
                                    </span>
                                    <button
                                      type="button"
                                      onClick={() => handleDeleteTransaction(t.id)}
                                      className="p-1 text-slate-300 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-950/20 rounded transition-all"
                                      title="Supprimer la transaction"
                                    >
                                      <Trash2 className="w-3.5 h-3.5" />
                                    </button>
                                  </div>
                                </div>
                              );
                            })
                          )}
                        </div>
                      </div>
                    )}

                    {/* TAB 6: PROFILE */}
                    {activeTab === 6 && (
                      <div className="space-y-4">
                        <div className="flex justify-between items-center mb-1">
                          <h2 className="text-lg font-bold font-sans">{t.profile_title}</h2>
                          <User className="w-5 h-5 text-indigo-500" />
                        </div>

                        {/* Hero profile card */}
                        <div className="p-4 bg-white dark:bg-slate-900 rounded-2xl border border-slate-150 dark:border-slate-800 shadow-sm flex items-center gap-3">
                          <div className="w-12 h-12 rounded-full bg-blue-600 text-white font-black text-sm flex items-center justify-center">
                            {getUserInitials()}
                          </div>
                          <div className="flex-1 min-w-0">
                            <h3 className="text-xs font-bold truncate">{user?.displayName || user?.email || 'Alexandre Nexii'}</h3>
                            <div className="flex flex-wrap gap-1 items-center mt-1">
                              <span className="text-[9px] text-purple-600 dark:text-purple-400 font-bold bg-purple-500/10 px-1.5 py-0.5 rounded">
                                {t.level_badge} ({userLevel})
                              </span>
                              {userAge && (
                                <span className="text-[9px] text-indigo-600 dark:text-indigo-400 font-bold bg-indigo-500/10 px-1.5 py-0.5 rounded">
                                  {userAge} ans
                                </span>
                              )}
                            </div>
                            {userAge && (
                              <p className="text-[9px] font-semibold text-emerald-600 dark:text-emerald-400 mt-1">
                                {getAgeSegmentLabel(userAge, lang)}
                              </p>
                            )}
                            <p className="text-[8px] text-slate-400 truncate mt-0.5">{user?.email || t.joined_date}</p>
                          </div>
                        </div>

                        {/* Streak Widget */}
                        <div className="p-3 bg-gradient-to-r from-amber-500/10 to-orange-500/10 dark:from-amber-950/20 dark:to-orange-950/20 rounded-xl border border-amber-500/20 flex items-center justify-between text-xs">
                          <div className="flex items-center gap-2">
                            <span className="text-xl">🔥</span>
                            <div>
                              <span className="font-bold text-slate-700 dark:text-slate-200">Série d'activité</span>
                              <p className="text-[9px] text-slate-400">Restez actif chaque jour pour augmenter votre série !</p>
                            </div>
                          </div>
                          <span className="text-xs font-black text-amber-600 dark:text-amber-400 bg-amber-500/20 px-2.5 py-1 rounded-lg">
                            {userStreak} {lang === 'fr' ? 'Jours' : 'Days'}
                          </span>
                        </div>

                        {/* Profile Subtabs selector */}
                        <div className="flex gap-1.5 p-1 bg-slate-100 dark:bg-slate-950 rounded-xl">
                          {[
                            { id: 'badges', label: lang === 'fr' ? 'Badges' : 'Badges' },
                            { id: 'stats', label: lang === 'fr' ? 'Stats' : 'Stats' },
                            { id: 'prefs', label: lang === 'fr' ? 'Préférences' : 'Settings' }
                          ].map(sub => (
                            <button
                              key={sub.id}
                              onClick={() => setProfileActiveSubTab(sub.id as any)}
                              className={`flex-1 text-[10px] font-bold py-1.5 rounded-lg transition-all ${profileActiveSubTab === sub.id ? 'bg-white dark:bg-slate-900 text-blue-600 dark:text-blue-400 shadow-sm' : 'text-slate-400 dark:text-slate-500 hover:text-slate-700 dark:hover:text-slate-300'}`}
                            >
                              {sub.label}
                            </button>
                          ))}
                        </div>

                        {/* SUBTAB 1: BADGES & GAMIFICATION */}
                        {profileActiveSubTab === 'badges' && (
                          <div className="space-y-3.5">
                            {/* Badges list */}
                            <div className="p-3.5 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 space-y-3">
                              <div className="flex justify-between items-center">
                                <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Badges & Succès</h4>
                                <span className="text-[9px] bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400 px-2 py-0.5 rounded-full font-bold">
                                  {badgeCategories.flatMap(c => c.badges).filter(b => b.unlocked).length} / 10 Unlocked
                                </span>
                              </div>

                              <div className="space-y-2.5 max-h-[190px] overflow-y-auto pr-1 no-scrollbar">
                                {badgeCategories.map(cat => (
                                  <div key={cat.id} className="space-y-1.5">
                                    <span className="text-[8px] font-extrabold text-slate-400 uppercase tracking-wider block">{cat.title}</span>
                                    <div className="space-y-1.5">
                                      {cat.badges.map(b => {
                                        const isClaimed = claimedBadges.includes(b.id);
                                        return (
                                          <div 
                                            key={b.id} 
                                            className={`p-2.5 rounded-xl border flex items-center justify-between transition-all ${
                                              b.unlocked 
                                                ? 'bg-blue-50/20 dark:bg-blue-950/10 border-blue-500/20' 
                                                : 'bg-slate-50/50 dark:bg-slate-950/30 border-slate-100 dark:border-slate-800/50 opacity-55'
                                            }`}
                                          >
                                            <div className="flex items-center gap-2.5 min-w-0">
                                              <span className="text-xl">{b.icon}</span>
                                              <div className="min-w-0">
                                                <h5 className="text-[10px] font-bold text-slate-800 dark:text-slate-200 truncate">{b.name}</h5>
                                                <p className="text-[8px] text-slate-400 line-clamp-1">{b.desc}</p>
                                              </div>
                                            </div>

                                            {b.unlocked ? (
                                              isClaimed ? (
                                                <span className="text-[8px] font-bold text-slate-400 bg-slate-100 dark:bg-slate-800 px-2 py-0.5 rounded-md">
                                                  Reçu
                                                </span>
                                              ) : (
                                                <button
                                                  onClick={() => {
                                                    setClaimedBadges(prev => [...prev, b.id]);
                                                    awardXp(b.xpReward, `Badge débloqué: ${b.name}`);
                                                    alert(`Félicitations ! Vous réclamez +${b.xpReward} XP pour le badge "${b.name}" ! 🌟`);
                                                  }}
                                                  className="text-[8px] font-black bg-blue-600 hover:bg-blue-700 text-white px-2 py-1 rounded-md transition-all shadow-sm"
                                                >
                                                  Réclamer +{b.xpReward} XP
                                                </button>
                                              )
                                            ) : (
                                              <span className="text-[8px] font-bold text-slate-400 flex items-center gap-1">
                                                🔒 Verrouillé
                                              </span>
                                            )}
                                          </div>
                                        );
                                      })}
                                    </div>
                                  </div>
                                ))}
                              </div>
                            </div>

                            {/* Level History / XP gains feed */}
                            <div className="p-3 bg-slate-50 dark:bg-slate-950 rounded-xl border border-slate-100 dark:border-slate-800 space-y-2">
                              <h4 className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Historique de Progression d'XP</h4>
                              <div className="space-y-1.5 max-h-[85px] overflow-y-auto pr-1 no-scrollbar">
                                {xpLogs.map(log => (
                                  <div key={log.id} className="flex justify-between items-center text-[9px] text-slate-600 dark:text-slate-400 bg-white dark:bg-slate-900 p-1.5 rounded-lg border border-slate-100 dark:border-slate-800/50">
                                    <div className="flex items-center gap-1.5 min-w-0">
                                      <span className="text-blue-500 font-bold">+{log.xp} XP</span>
                                      <span className="truncate">{log.action}</span>
                                    </div>
                                    <span className="text-[8px] text-slate-400 shrink-0 font-mono">{log.date}</span>
                                  </div>
                                ))}
                              </div>
                            </div>
                          </div>
                        )}

                        {/* SUBTAB 2: DETAILED CHARTS DASHBOARD */}
                        {profileActiveSubTab === 'stats' && (() => {
                          const wellnessHistory = getWellnessHistory();
                          const focusHistory = getFocusHistory();
                          const categoryTotals = getTransactionCategoryTotals();
                          
                          const categoriesToRender = [
                            { name: 'Alimentation', amt: categoryTotals['Alimentation'], color: 'bg-emerald-500' },
                            { name: 'Loisirs', amt: categoryTotals['Loisirs'], color: 'bg-indigo-500' },
                            { name: 'Maison', amt: categoryTotals['Maison'], color: 'bg-amber-500' },
                            { name: 'Abonnement', amt: categoryTotals['Abonnement'], color: 'bg-purple-500' },
                            { name: 'Bonus', amt: categoryTotals['Bonus'], color: 'bg-pink-500' }
                          ];
                          
                          const totalCalculatedExpense = Object.values(categoryTotals).reduce((a, b) => a + b, 0);

                          // Mapping wellnessHistory values to SVG heights relative to base height 110
                          const hPoints = wellnessHistory.map(score => Math.max(10, Math.min(100, 110 - score)));

                          return (
                            <div className="space-y-3.5">
                              {/* SVG Chart 1: Nexii State Evolution over time */}
                              <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 space-y-2">
                                <div className="flex justify-between items-center">
                                  <h4 className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Évolution Bien-être (Nexii State)</h4>
                                  <span className="text-[9px] text-blue-600 font-bold">{getWellnessScore()}% Actuel</span>
                                </div>
                                
                                <div className="h-28 flex items-end justify-between relative pt-3 pb-1">
                                  {/* Smooth Area Line using SVG */}
                                  <svg className="absolute inset-0 w-full h-full" preserveAspectRatio="none">
                                    <defs>
                                      <linearGradient id="areaGradient" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="0%" stopColor="#3b82f6" stopOpacity="0.3" />
                                        <stop offset="100%" stopColor="#3b82f6" stopOpacity="0" />
                                      </linearGradient>
                                    </defs>
                                    {/* Draw background grid lines */}
                                    <line x1="0" y1="20%" x2="100%" y2="20%" stroke="#e2e8f0" strokeDasharray="3" className="dark:stroke-slate-800" />
                                    <line x1="0" y1="50%" x2="100%" y2="50%" stroke="#e2e8f0" strokeDasharray="3" className="dark:stroke-slate-800" />
                                    <line x1="0" y1="80%" x2="100%" y2="80%" stroke="#e2e8f0" strokeDasharray="3" className="dark:stroke-slate-800" />
                                    
                                    {/* Dynamic Path calculated from real state */}
                                    <path 
                                      d={`M 0,110 L 0,${hPoints[0]} L 30,${hPoints[1]} L 60,${hPoints[2]} L 90,${hPoints[3]} L 120,${hPoints[4]} L 150,${hPoints[5]} L 180,${hPoints[6]} L 180,110 Z`} 
                                      fill="url(#areaGradient)" 
                                    />
                                    <path 
                                      d={`M 0,${hPoints[0]} L 30,${hPoints[1]} L 60,${hPoints[2]} L 90,${hPoints[3]} L 120,${hPoints[4]} L 150,${hPoints[5]} L 180,${hPoints[6]}`} 
                                      fill="none" 
                                      stroke="#3b82f6" 
                                      strokeWidth="2.5" 
                                      strokeLinecap="round" 
                                    />
                                  </svg>
                                  
                                  <div className="absolute bottom-0 inset-x-0 flex justify-between px-1 text-[7px] font-mono text-slate-400">
                                    <span>Lun</span>
                                    <span>Mar</span>
                                    <span>Mer</span>
                                    <span>Jeu</span>
                                    <span>Ven</span>
                                    <span>Sam</span>
                                    <span>Dim</span>
                                  </div>
                                </div>
                              </div>

                              {/* SVG Chart 2: Focus Minutes (dynamic vertical bar chart) */}
                              <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 space-y-2">
                                <div className="flex justify-between items-center">
                                  <h4 className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Heures Concentration (Pomodoro)</h4>
                                  <span className="text-[9px] text-purple-600 font-bold">{focusMinutes} mins</span>
                                </div>

                                <div className="h-24 flex items-end justify-between px-2 pt-2 pb-1 relative">
                                  {focusHistory.map((min, idx) => {
                                    // Max baseline 90 min for height calculations
                                    const pct = Math.min(100, (min / 90) * 100);
                                    return (
                                      <div key={idx} className="flex flex-col items-center flex-1 h-full justify-end group relative">
                                        <div 
                                          style={{ height: `${pct}%` }} 
                                          className={`w-4 rounded-t-md transition-all duration-700 ${idx === 6 ? 'bg-purple-600 dark:bg-purple-500' : 'bg-purple-300 dark:bg-purple-950/60'}`}
                                        ></div>
                                        <span className="text-[7px] text-slate-400 font-mono mt-1 shrink-0">
                                          {['L', 'M', 'M', 'J', 'V', 'S', 'D'][idx]}
                                        </span>
                                        
                                        {/* Hover tooltip */}
                                        <div className="absolute bottom-full mb-1 opacity-0 group-hover:opacity-100 bg-slate-950 text-white text-[7px] px-1.5 py-0.5 rounded transition-opacity font-mono z-30">
                                          {min}m
                                        </div>
                                      </div>
                                    );
                                  })}
                                </div>
                              </div>

                              {/* Budget Category Breakdown Horizontal progress bars */}
                              <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 space-y-2">
                                <h4 className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Répartition des Dépenses</h4>
                                {totalCalculatedExpense === 0 ? (
                                  <div className="py-4 text-center text-[10px] text-slate-400 border border-dashed border-slate-100 dark:border-slate-800 rounded-xl">
                                    Aucune dépense enregistrée. Ajoutez des transactions dans l'onglet Budget !
                                  </div>
                                ) : (
                                  <div className="space-y-2">
                                    {categoriesToRender.map((cat, i) => {
                                      const pct = Math.min(100, (cat.amt / totalCalculatedExpense) * 100);
                                      if (cat.amt === 0) return null; // Only show active categories for accurate stats
                                      return (
                                        <div key={i} className="text-[9px] space-y-0.5">
                                          <div className="flex justify-between items-center text-slate-600 dark:text-slate-400">
                                            <span className="font-semibold">{cat.name}</span>
                                            <span className="font-mono font-bold">{cat.amt.toFixed(2)} {getCurrencySymbol(currency)} ({pct.toFixed(0)}%)</span>
                                          </div>
                                          <div className="h-1.5 w-full bg-slate-100 dark:bg-slate-950 rounded-full overflow-hidden">
                                            <div 
                                              style={{ width: `${pct}%` }} 
                                              className={`h-full ${cat.color} rounded-full transition-all duration-700`}
                                            ></div>
                                          </div>
                                        </div>
                                      );
                                    })}
                                  </div>
                                )}
                              </div>

                              {/* Nexii AI Personal Insights (Fonction 7) */}
                              <div className="p-3.5 bg-gradient-to-br from-blue-600/10 to-purple-600/10 dark:from-blue-950/25 dark:to-purple-950/25 rounded-2xl border border-blue-500/15 space-y-2 text-xs">
                                <div className="flex items-center gap-1.5 font-bold text-blue-600 dark:text-blue-400">
                                  <Sparkles className="w-4 h-4 animate-pulse shrink-0" />
                                  <span className="text-[10px] uppercase font-black tracking-wider">Nexii AI Reports & Tendances</span>
                                </div>
                                <p className="text-[10px] text-slate-700 dark:text-slate-300 leading-relaxed">
                                  {getWellnessScore() < 50 
                                    ? "🚨 Votre niveau d'énergie est particulièrement bas aujourd'hui. L'IA vous conseille de réduire la difficulté de vos tâches actives, de prioriser le sommeil, et de déléguer ou reporter les tâches non-essentielles."
                                    : "✨ Vos indicateurs de bien-être et de motivation sont excellents ! C'est le moment idéal pour aborder vos tâches Pro complexes à haute valeur ajoutée."
                                  }
                                </p>
                                <div className="pt-1.5 text-[9px] text-slate-400 dark:text-slate-500 flex justify-between items-center border-t border-slate-100 dark:border-slate-800/60">
                                  <span>Score Aura : <strong className="text-purple-600 dark:text-purple-400">{aura.percentage}%</strong></span>
                                  <span>Focus Hebdo : <strong className="text-blue-600 dark:text-blue-400">{focusMinutes} mins</strong></span>
                                </div>
                              </div>
                            </div>
                          );
                        })()}

                        {/* SUBTAB 3: PREFERENCES */}
                        {profileActiveSubTab === 'prefs' && (
                          <div className="space-y-3.5">
                            {/* General Statistics Block */}
                            <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 space-y-2 text-xs">
                              <h4 className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">{t.stats_title}</h4>
                              <div className="grid grid-cols-2 gap-2 text-center">
                                <div className="p-2 bg-slate-50 dark:bg-slate-950 rounded-lg">
                                  <span className="text-slate-400 text-[9px] block">{t.focus_hours}</span>
                                  <span className="font-bold text-slate-700 dark:text-slate-200">
                                    {Math.floor(focusMinutes / 60)}h {(focusMinutes % 60).toString().padStart(2, '0')}m
                                  </span>
                                </div>
                                <div className="p-2 bg-slate-50 dark:bg-slate-950 rounded-lg">
                                  <span className="text-slate-400 text-[9px] block">{t.challenges_completed}</span>
                                  <span className="font-bold text-slate-700 dark:text-slate-200">
                                    {missions.filter(m => m.completed).length} / {missions.length || 4}
                                  </span>
                                </div>
                                <div className="p-2 bg-slate-50 dark:bg-slate-950 rounded-lg">
                                  <span className="text-slate-400 text-[9px] block">{t.success_rate}</span>
                                  <span className="font-bold text-slate-700 dark:text-slate-200">
                                    {tasks.length > 0 ? `${Math.round((tasks.filter(t => t.completed).length / tasks.length) * 100)}%` : '0%'}
                                  </span>
                                </div>
                                <div className="p-2 bg-slate-50 dark:bg-slate-950 rounded-lg">
                                  <span className="text-slate-400 text-[9px] block">{t.cardiac_coherence_short}</span>
                                  <span className="font-bold text-slate-700 dark:text-slate-200">
                                    {getWellnessScore()}%
                                  </span>
                                </div>
                              </div>
                            </div>

                            {/* Live switches inside preferences */}
                            <div className="space-y-2.5">
                              <h4 className="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider font-sans">{t.device_options}</h4>

                              {/* Theme Selector */}
                              <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 flex items-center justify-between text-xs transition-all shadow-xs">
                                <div className="flex items-center gap-2.5">
                                  <div className="p-1.5 bg-indigo-50 dark:bg-indigo-950/40 text-indigo-600 dark:text-indigo-400 rounded-lg">
                                    {isDarkMode ? <Moon className="w-4 h-4" /> : <Sun className="w-4 h-4 text-amber-500" />}
                                  </div>
                                  <span className="font-semibold text-slate-700 dark:text-slate-200">{t.settings_theme}</span>
                                </div>
                                <button 
                                  type="button"
                                  onClick={() => setIsDarkMode(!isDarkMode)}
                                  className={`w-9 h-5 rounded-full transition-colors flex items-center p-0.5 ${isDarkMode ? 'bg-blue-600' : 'bg-slate-300 dark:bg-slate-700'}`}>
                                  <span className={`w-4 h-4 bg-white rounded-full shadow-sm transition-all transform ${isDarkMode ? 'translate-x-4' : 'translate-x-0'}`}></span>
                                </button>
                              </div>

                              {/* System Notifications Selector */}
                              <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 space-y-2 text-xs transition-all shadow-xs">
                                <div className="flex items-center justify-between">
                                  <div className="flex items-center gap-2.5">
                                    <div className="p-1.5 bg-rose-50 dark:bg-rose-950/40 text-rose-600 dark:text-rose-400 rounded-lg">
                                      <Bell className="w-4 h-4 animate-swing" />
                                    </div>
                                    <span className="font-semibold text-slate-700 dark:text-slate-200">{t.system_notifications_title}</span>
                                  </div>
                                  <button
                                    type="button"
                                    onClick={requestNotificationPermission}
                                    disabled={systemNotificationsEnabled}
                                    className={`text-[10px] font-bold px-2.5 py-1 rounded-lg transition-all ${systemNotificationsEnabled ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 cursor-default' : 'bg-rose-600 hover:bg-rose-700 text-white cursor-pointer'}`}
                                  >
                                    {systemNotificationsEnabled ? t.system_notifications_btn_enabled : t.system_notifications_btn_enable}
                                  </button>
                                </div>
                                <p className="text-[10px] text-slate-400 dark:text-slate-500 leading-normal pl-9">
                                  {t.system_notifications_desc}
                                </p>
                              </div>

                              {/* Language Selector */}
                              <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 flex items-center justify-between text-xs transition-all shadow-xs">
                                <div className="flex items-center gap-2.5">
                                  <div className="p-1.5 bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 rounded-lg">
                                    <Globe className="w-4 h-4" />
                                  </div>
                                  <span className="font-semibold text-slate-700 dark:text-slate-200">{t.settings_lang}</span>
                                </div>
                                <select 
                                  value={lang}
                                  onChange={(e) => setLang(e.target.value as any)}
                                  className="bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-200 text-[10px] px-2 py-1 rounded border-none outline-none font-sans font-bold cursor-pointer"
                                >
                                  <option value="fr">Français</option>
                                  <option value="en">English</option>
                                  <option value="es">Español</option>
                                </select>
                              </div>

                              {/* Currency Selector */}
                              <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 flex items-center justify-between text-xs transition-all shadow-xs">
                                <div className="flex items-center gap-2.5">
                                  <div className="p-1.5 bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 rounded-lg">
                                    <Coins className="w-4 h-4" />
                                  </div>
                                  <span className="font-semibold text-slate-700 dark:text-slate-200">
                                    {lang === 'fr' ? 'Devise de l\'application' : lang === 'es' ? 'Moneda de la aplicación' : 'App Currency'}
                                  </span>
                                </div>
                                <div className="flex gap-1 bg-slate-100 dark:bg-slate-800 p-0.5 rounded-lg border border-slate-200 dark:border-slate-700 text-[9px] font-black">
                                  {(['EUR', 'USD', 'XAF'] as const).map((cur) => (
                                    <button
                                      key={cur}
                                      type="button"
                                      onClick={() => handleCurrencyChange(cur)}
                                      className={`px-1.5 py-0.5 rounded transition-all ${currency === cur ? 'bg-blue-600 text-white shadow-xs' : 'text-slate-500 hover:text-slate-700 dark:hover:text-slate-350'}`}
                                    >
                                      {cur === 'XAF' ? 'FCFA' : cur === 'EUR' ? '€' : '$'}
                                    </button>
                                  ))}
                                </div>
                              </div>

                              {/* Birthday Card */}
                              {userBirthdate && (
                                <div className="p-3 bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 flex items-center justify-between text-xs transition-all shadow-xs">
                                  <div className="flex items-center gap-2.5">
                                    <div className="p-1.5 bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400 rounded-lg">
                                      <Calendar className="w-4 h-4" />
                                    </div>
                                    <span className="font-semibold text-slate-700 dark:text-slate-200">{lang === 'fr' ? 'Date de naissance' : lang === 'es' ? 'Fecha de nacimiento' : 'Date of birth'}</span>
                                  </div>
                                  <span className="font-bold text-slate-500 dark:text-slate-400">
                                    {new Date(userBirthdate).toLocaleDateString(lang === 'fr' ? 'fr-FR' : lang === 'es' ? 'es-ES' : 'en-US', { day: 'numeric', month: 'long', year: 'numeric' })}
                                  </span>
                                </div>
                              )}

                              {/* Edit Profile Form or Display Button */}
                              {isEditingProfile ? (
                                <form onSubmit={handleSaveProfile} className="p-3 bg-slate-50 dark:bg-slate-950 rounded-xl border border-blue-500/30 space-y-3">
                                  <div className="flex justify-between items-center">
                                    <h4 className="text-[10px] font-black text-slate-500 uppercase tracking-wider">{t.edit_profile_title}</h4>
                                    <span className="text-[8px] bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-350 px-1.5 py-0.5 rounded font-black uppercase">Editeur</span>
                                  </div>

                                  {profileError && (
                                    <div className="p-2 rounded-xl bg-red-500/10 border border-red-500/20 text-red-500 text-[10px] flex items-center gap-2">
                                      <AlertCircle className="w-3.5 h-3.5 shrink-0" />
                                      <span className="font-semibold leading-normal">{profileError}</span>
                                    </div>
                                  )}

                                  <div className="space-y-2">
                                    <div className="space-y-1">
                                      <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">
                                        {t.onboarding_name_label}
                                      </label>
                                      <input
                                        type="text"
                                        required
                                        value={editName}
                                        onChange={(e) => setEditName(e.target.value)}
                                        className="w-full text-xs px-3 py-2 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 focus:border-blue-600 outline-none transition-all text-slate-700 dark:text-slate-200"
                                      />
                                    </div>

                                    <div className="space-y-1">
                                      <label className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">
                                        {t.onboarding_birthdate_label}
                                      </label>
                                      <input
                                        type="text"
                                        inputMode="numeric"
                                        required
                                        placeholder={lang === 'fr' ? 'JJ/MM/AAAA' : lang === 'es' ? 'DD/MM/AAAA' : 'DD/MM/YYYY'}
                                        value={editBirthdateText}
                                        onChange={(e) => handleTypedDateChange(e.target.value, setEditBirthdateText, setEditBirthdate)}
                                        className="w-full text-xs px-3 py-2 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 focus:border-blue-600 outline-none transition-all text-slate-700 dark:text-slate-200"
                                      />
                                    </div>
                                  </div>

                                  <div className="grid grid-cols-2 gap-2 pt-1">
                                    <button
                                      type="button"
                                      onClick={() => setIsEditingProfile(false)}
                                      className="py-2 rounded-xl text-[10px] font-bold border border-slate-200 dark:border-slate-800 text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200 transition-all"
                                    >
                                      {t.cancel_btn}
                                    </button>
                                    <button
                                      type="submit"
                                      disabled={isSyncing}
                                      className="py-2 rounded-xl text-[10px] font-bold bg-blue-600 hover:bg-blue-700 text-white transition-all flex items-center justify-center gap-1"
                                    >
                                      {isSyncing ? <RefreshCw className="w-3 animate-spin" /> : t.save_profile_btn}
                                    </button>
                                  </div>
                                </form>
                              ) : (
                                <button
                                  type="button"
                                  onClick={startEditingProfile}
                                  className="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition-all shadow-md shadow-blue-600/15 flex items-center justify-center gap-2"
                                >
                                  <User className="w-4 h-4" />
                                  {t.edit_profile_btn}
                                </button>
                              )}

                              {/* Formulaire de retour utilisateur (Feedback) */}
                              <div className="p-4 bg-white dark:bg-slate-900 rounded-xl border border-slate-150 dark:border-slate-800/80 space-y-3 shadow-xs">
                                <div className="space-y-1">
                                  <h4 className="text-xs font-bold text-slate-800 dark:text-slate-200">
                                    {lang === 'fr' ? 'Votre avis compte énormément !' : lang === 'es' ? '¡Tu opinión es muy importante!' : 'Your feedback is highly valued!'}
                                  </h4>
                                  <p className="text-[10px] text-slate-400 dark:text-slate-500 leading-normal">
                                    {lang === 'fr' ? 'Aidez-nous à améliorer Nexii en partageant votre expérience ou en signalant un bug.' : lang === 'es' ? 'Ayúdanos a mejorar Nexii compartiendo tu experiencia o reportando un problema.' : 'Help us improve Nexii by sharing your experience or reporting an issue.'}
                                  </p>
                                </div>

                                <form onSubmit={handleSubmitFeedback} className="space-y-3">
                                  {/* Star Rating Row */}
                                  <div className="flex justify-center gap-1.5 py-1">
                                    {[1, 2, 3, 4, 5].map((starValue) => {
                                      const isFilled = starValue <= feedbackRating;
                                      return (
                                        <button
                                          key={starValue}
                                          type="button"
                                          onClick={() => setFeedbackRating(starValue)}
                                          className="focus:outline-none transition-transform hover:scale-125"
                                        >
                                          <Star
                                            className={`w-6 h-6 ${isFilled ? 'fill-amber-400 text-amber-400' : 'text-slate-300 dark:text-slate-700'}`}
                                          />
                                        </button>
                                      );
                                    })}
                                  </div>

                                  {/* Comment area */}
                                  <div className="space-y-1">
                                    <textarea
                                      rows={3}
                                      value={feedbackComment}
                                      onChange={(e) => setFeedbackComment(e.target.value)}
                                      placeholder={lang === 'fr' ? 'Écrivez votre message ici...' : lang === 'es' ? 'Escribe tu mensaje aquí...' : 'Write your message here...'}
                                      className="w-full text-xs px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 focus:border-purple-600 outline-none transition-all text-slate-700 dark:text-slate-200 font-sans resize-none"
                                    />
                                  </div>

                                  {/* Submit button */}
                                  <button
                                    type="submit"
                                    disabled={isSubmittingFeedback}
                                    className="w-full py-2 bg-purple-600 hover:bg-purple-700 disabled:bg-purple-400 text-white rounded-xl text-xs font-bold transition-all shadow-md shadow-purple-600/15 flex items-center justify-center gap-2"
                                  >
                                    {isSubmittingFeedback ? (
                                      <>
                                        <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                                        <span>{lang === 'fr' ? 'Envoi en cours...' : lang === 'es' ? 'Enviando...' : 'Sending...'}</span>
                                      </>
                                    ) : (
                                      <>
                                        <Send className="w-3.5 h-3.5" />
                                        <span>{lang === 'fr' ? 'Envoyer mon avis' : lang === 'es' ? 'Enviar mi opinión' : 'Submit feedback'}</span>
                                      </>
                                    )}
                                  </button>
                                </form>
                              </div>

                              <button
                                onClick={handleSignOut}
                                className="w-full mt-4 py-2.5 bg-red-600 hover:bg-red-700 text-white rounded-xl text-xs font-bold transition-all shadow-md shadow-red-600/15 flex items-center justify-center gap-2"
                              >
                                <LogOut className="w-4 h-4" />
                                Se déconnecter (Logout)
                              </button>
                            </div>
                          </div>
                        )}
                      </div>
                    )}
                  </motion.div>
                )}
                </AnimatePresence>
              </div>

              {/* M3 Material 3 Dynamic Bottom Navigation Bar with 7 tabs */}
              {user && (
                <div className={`h-16 border-t ${isDarkMode ? 'bg-slate-900 border-slate-800 text-slate-400' : 'bg-white border-slate-100 text-slate-500'} flex items-center justify-between px-3 relative z-20`}>
                  {[
                    { icon: Home, label: t.tab_home },
                    { icon: Award, label: t.tab_missions },
                    { icon: CheckSquare, label: t.tab_tasks },
                    { icon: Timer, label: t.tab_focus },
                    { icon: Brain, label: t.tab_coach },
                    { icon: Wallet, label: t.tab_budget },
                    { icon: User, label: t.tab_profile }
                  ].map((tab, idx) => {
                    const IconComponent = tab.icon;
                    const isActive = activeTab === idx;
                    return (
                      <button
                        key={idx}
                        onClick={() => setActiveTab(idx)}
                        className="flex flex-col items-center justify-center flex-1 py-1 group relative outline-none"
                      >
                        {/* Pill indicator back style like Material 3 */}
                        <div className={`px-3 py-1 rounded-full transition-all ${isActive ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300' : 'group-hover:bg-slate-100 dark:group-hover:bg-slate-800/40'}`}>
                          <IconComponent className="w-[17px] h-[17px]" />
                        </div>
                        <span className="text-[8px] font-bold mt-1 tracking-tight font-sans text-center max-w-[42px] truncate">
                          {tab.label}
                        </span>
                      </button>
                    );
                  })}
                </div>
              )}

              {/* Mindful Breathing Recovery Overlay */}
              {recoveryOverlay && (
                <div className="absolute inset-0 bg-slate-950/95 backdrop-blur-md z-50 flex flex-col items-center justify-between p-6 text-white animate-fadeIn rounded-3xl">
                  <div className="text-center mt-4">
                    <span className="text-[9px] bg-blue-500/20 text-blue-400 border border-blue-500/30 px-3 py-1 rounded-full font-bold uppercase tracking-widest">
                      Séance de Récupération active
                    </span>
                    <h3 className="text-base font-black tracking-tight mt-2.5 font-sans">
                      Cohérence Cardiaque Nexii
                    </h3>
                    <p className="text-[10px] text-slate-400 max-w-xs mx-auto mt-1 font-sans leading-relaxed">
                      Suggéré par le Coach IA pour réduire la fatigue et réorganiser vos énergies.
                    </p>
                  </div>

                  {/* Pulsing Breathing circle */}
                  <div className="flex flex-col items-center justify-center space-y-6">
                    <div 
                      className={`w-32 h-32 rounded-full bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center relative shadow-2xl shadow-blue-500/20 transition-all duration-1000 transform ${
                        (recoverySeconds % 12) < 4 ? 'scale-110' : (recoverySeconds % 12) < 8 ? 'scale-125 ring-8 ring-blue-500/20' : 'scale-90 opacity-80'
                      }`}
                    >
                      <span className="text-xs font-black select-none tracking-tight">
                        {(recoverySeconds % 12) < 4 ? 'INSPIRER' : (recoverySeconds % 12) < 8 ? 'RETENIR' : 'EXPIRER'}
                      </span>
                    </div>

                    <div className="text-center space-y-1">
                      <span className="text-4xl font-mono font-black tracking-widest text-blue-400">
                        {Math.floor(recoverySeconds / 60)}:{(recoverySeconds % 60).toString().padStart(2, '0')}
                      </span>
                      <p className="text-[10px] text-slate-400 font-mono italic">
                        {(recoverySeconds % 12) < 4 ? 'Inspirez lentement par le nez (4s)...' : (recoverySeconds % 12) < 8 ? 'Retenez l’air doucement (4s)...' : 'Expirez lentement par la bouche (4s)...'}
                      </p>
                    </div>
                  </div>

                  <button
                    onClick={() => {
                      setRecoveryOverlay(false);
                      setRecoveryRunning(false);
                    }}
                    className="w-full max-w-xs mb-4 py-2.5 bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white rounded-xl text-xs font-bold transition-all border border-slate-700/50"
                  >
                    Arrêter la récupération
                  </button>
                </div>
              )}

              {/* High-Fidelity Notifications Panel Overlay */}
              <AnimatePresence>
                {showNotifications && (
                  <motion.div
                    initial={{ opacity: 0, x: '100%' }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: '100%' }}
                    transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                    className="absolute inset-0 bg-white dark:bg-slate-950 z-40 flex flex-col rounded-[38px] overflow-hidden"
                  >
                    {/* Panel Header */}
                    <div className="px-5 pt-12 pb-4 border-b border-slate-100 dark:border-slate-900 flex justify-between items-center bg-slate-50/50 dark:bg-slate-900/50">
                      <div className="flex items-center gap-2">
                        <Bell className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                        <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                          Notifications {notifications.filter(n => !n.read).length > 0 && (
                            <span className="bg-red-500 text-white text-[9px] px-1.5 py-0.5 rounded-full ml-1 font-bold animate-pulse">
                              {notifications.filter(n => !n.read).length}
                            </span>
                          )}
                        </h3>
                      </div>
                      <button
                        onClick={() => {
                          const marked = notifications.map(n => ({ ...n, read: true }));
                          setNotifications(marked);
                          triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, marked);
                          setShowNotifications(false);
                        }}
                        className="text-xs text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 font-bold bg-slate-100 dark:bg-slate-800 px-3 py-1.5 rounded-xl transition-all cursor-pointer"
                      >
                        {lang === 'fr' ? 'Fermer' : lang === 'es' ? 'Cerrar' : 'Close'}
                      </button>
                    </div>

                    {/* Actions Toolbar */}
                    {notifications.length > 0 && (
                      <div className="px-5 py-2 bg-slate-50 dark:bg-slate-900/30 border-b border-slate-100 dark:border-slate-900/50 flex justify-between items-center text-[10px]">
                        <button
                          onClick={() => {
                            const marked = notifications.map(n => ({ ...n, read: true }));
                            setNotifications(marked);
                            triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, marked);
                          }}
                          className="text-blue-600 dark:text-blue-400 font-bold hover:underline"
                        >
                          {lang === 'fr' ? 'Tout marquer comme lu' : lang === 'es' ? 'Marcar leído' : 'Mark all read'}
                        </button>
                        <button
                          onClick={() => {
                            setNotifications([]);
                            triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, []);
                          }}
                          className="text-red-500 font-bold hover:underline flex items-center gap-1"
                        >
                          <Trash2 className="w-3 h-3" />
                          {lang === 'fr' ? 'Tout effacer' : lang === 'es' ? 'Borrar todo' : 'Clear all'}
                        </button>
                      </div>
                    )}

                    {/* Scrollable List */}
                    <div className="flex-1 overflow-y-auto px-5 py-3 space-y-2.5 no-scrollbar">
                      {notifications.length === 0 ? (
                        <div className="h-full flex flex-col items-center justify-center text-center space-y-2 py-12">
                          <span className="text-3xl">📭</span>
                          <p className="text-xs font-semibold text-slate-400">
                            {lang === 'fr' ? 'Aucune notification pour le moment.' : lang === 'es' ? 'Sin notificaciones por ahora.' : 'No notifications yet.'}
                          </p>
                          <p className="text-[10px] text-slate-500 max-w-[200px] leading-relaxed">
                            {lang === 'fr' ? 'Vos réussites, rappels et gains d\'XP s\'afficheront ici.' : 'Your achievements, reminders, and XP gains will show up here.'}
                          </p>
                        </div>
                      ) : (
                        notifications.map((notif) => {
                          let icon = '🔔';
                          let bgClass = 'bg-blue-50 dark:bg-blue-950/30 text-blue-600 dark:text-blue-400';
                          if (notif.type === 'success') {
                            icon = '🎉';
                            bgClass = 'bg-emerald-50 dark:bg-emerald-950/30 text-emerald-600 dark:text-emerald-400';
                          } else if (notif.type === 'xp') {
                            icon = '✨';
                            bgClass = 'bg-amber-50 dark:bg-amber-950/30 text-amber-600 dark:text-amber-400';
                          } else if (notif.type === 'warning') {
                            icon = '⚠️';
                            bgClass = 'bg-red-50 dark:bg-red-950/30 text-red-600 dark:text-red-400';
                          }

                          return (
                            <div
                              key={notif.id}
                              className={`p-3 rounded-2xl border transition-all flex gap-3 relative ${
                                notif.read
                                  ? 'bg-slate-50/50 dark:bg-slate-900/20 border-slate-100 dark:border-slate-900'
                                  : 'bg-white dark:bg-slate-900 border-blue-100 dark:border-blue-900/40 shadow-xs'
                              }`}
                            >
                              {!notif.read && (
                                <span className="absolute top-3.5 right-3.5 w-1.5 h-1.5 bg-blue-600 rounded-full"></span>
                              )}

                              <div className={`w-8 h-8 rounded-xl flex items-center justify-center shrink-0 ${bgClass}`}>
                                <span className="text-sm">{icon}</span>
                              </div>

                              <div className="flex-1 min-w-0 space-y-0.5 text-left">
                                <h4 className={`text-xs font-bold leading-tight truncate ${notif.read ? 'text-slate-600 dark:text-slate-400' : 'text-slate-900 dark:text-white'}`}>
                                  {notif.title}
                                </h4>
                                <p className="text-[10px] text-slate-500 dark:text-slate-400 leading-normal font-sans">
                                  {notif.content}
                                </p>
                                <span className="text-[8px] text-slate-400 block font-mono">
                                  {new Date(notif.date).toLocaleTimeString(lang === 'fr' ? 'fr-FR' : 'en-US', { hour: '2-digit', minute: '2-digit' })}
                                </span>
                              </div>

                              <button
                                onClick={() => {
                                  const next = notifications.filter(n => n.id !== notif.id);
                                  setNotifications(next);
                                  triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, next);
                                }}
                                className="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 self-center p-1 text-xs"
                              >
                                &times;
                              </button>
                            </div>
                          );
                        })
                      )}
                    </div>

                    {/* Dynamic Simulation Sandbox Controls */}
                    <div className="p-4 bg-slate-50 dark:bg-slate-900 border-t border-slate-100 dark:border-slate-800 flex flex-col gap-2 rounded-b-[38px]">
                      <span className="text-[9px] font-bold text-slate-400 uppercase tracking-wider text-center block">
                        {lang === 'fr' ? 'Zone de Simulation / Test' : 'Simulation & Test Zone'}
                      </span>
                      <div className="grid grid-cols-2 gap-2">
                        <button
                          onClick={() => {
                            const title = lang === 'fr' ? 'Rappel Bien-être 🧘' : 'Wellness Reminder 🧘';
                            const body = lang === 'fr' ? 'Il est l\'heure de boire un grand verre d\'eau et de vous étirer !' : 'Time to drink a big glass of water and stretch!';
                            const testNotifs = [
                              {
                                id: Date.now(),
                                title,
                                content: body,
                                date: new Date().toISOString(),
                                read: false,
                                type: 'info' as const
                              },
                              ...notifications
                            ];
                            setNotifications(testNotifs);
                            triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, testNotifs);
                            sendSystemNotification(title, body);
                          }}
                          className="py-1.5 bg-blue-600/10 hover:bg-blue-600/25 text-blue-600 dark:text-blue-400 text-[10px] font-bold rounded-xl transition-all cursor-pointer text-center"
                        >
                          ℹ️ {lang === 'fr' ? 'Rappel Infos' : 'Info Reminder'}
                        </button>
                        <button
                          onClick={() => {
                            const title = lang === 'fr' ? 'Défi Hebdo Relevé ! 🏆' : 'Weekly Challenge Cleared! 🏆';
                            const body = lang === 'fr' ? 'Vous avez complété l\'ensemble de vos objectifs hebdomadaires.' : 'You have completed all of your weekly goals.';
                            const testNotifs = [
                              {
                                id: Date.now(),
                                title,
                                content: body,
                                date: new Date().toISOString(),
                                read: false,
                                type: 'success' as const
                              },
                              ...notifications
                            ];
                            setNotifications(testNotifs);
                            triggerSync(tasks, missions, transactions, totalBudget, spentAmount, userXp, userLevel, selectedMood, lang, isDarkMode, userStreak, focusMinutes, lastCheckInDate, agendaEvents, lastMissionsResetDate, currency, savingsGoals, testNotifs);
                            sendSystemNotification(title, body);
                          }}
                          className="py-1.5 bg-emerald-600/10 hover:bg-emerald-600/25 text-emerald-600 dark:text-emerald-400 text-[10px] font-bold rounded-xl transition-all cursor-pointer text-center"
                        >
                          🎉 {lang === 'fr' ? 'Défi Réussi' : 'Challenge Won'}
                        </button>
                      </div>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>

            </div>
          </div>
        </section>

        {/* RIGHT COLUMN: Interactive Flutter Code Architect Explorer (lg:span-7) */}
        <section className="lg:col-span-7 space-y-6">
          
          {/* Summary Box detailing Flutter architectural foundations setup */}
          <div className="p-6 bg-white dark:bg-slate-900 rounded-3xl border border-slate-200 dark:border-slate-800 shadow-xl shadow-slate-200/10 space-y-4">
            <div className="flex items-center gap-2.5">
              <Layers className="w-5 h-5 text-blue-600" />
              <h2 className="text-lg font-extrabold tracking-tight">Nexii Flutter Workspace</h2>
            </div>
            
            <p className="text-sm text-slate-600 dark:text-slate-400 leading-relaxed font-sans">
              Félicitations ! Les fondations de l'application mobile **Nexii** ont été structurées selon une 
              **architecture modulaire Flutter hautement scalable**, en parfaite adéquation avec la source de vérité Material 3. 
              Toutes les connexions de routage, d'états dynamiques, et de multi-langues sont prêtes.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3.5 pt-1">
              <div className="p-3 bg-slate-50 dark:bg-slate-950 rounded-xl border border-slate-100 dark:border-slate-800 flex items-start gap-3">
                <BookOpen className="w-5 h-5 text-blue-600 mt-0.5" />
                <div>
                  <h4 className="text-xs font-bold">Standardisation Material 3</h4>
                  <p className="text-[11px] text-slate-500 mt-0.5">Palette couleur Nexii complète, thèmes global clair/sombre, typographies Inter/Poppins.</p>
                </div>
              </div>

              <div className="p-3 bg-slate-50 dark:bg-slate-950 rounded-xl border border-slate-100 dark:border-slate-800 flex items-start gap-3">
                <Globe className="w-5 h-5 text-purple-600 mt-0.5" />
                <div>
                  <h4 className="text-xs font-bold">Internationalisation (i18n)</h4>
                  <p className="text-[11px] text-slate-500 mt-0.5">Structure de traduction flexible intégrée (FR, EN, ES) prête pour les assets JSON.</p>
                </div>
              </div>
            </div>
          </div>

          {/* Interactive Source Explorer */}
          <div className="bg-slate-900 text-slate-200 rounded-3xl overflow-hidden shadow-2xl border border-slate-800">
            
            {/* Explorer Head */}
            <div className="px-6 py-4 bg-slate-950/80 border-b border-slate-800/80 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
              <div className="flex items-center gap-2">
                <Folder className="w-5 h-5 text-blue-400" />
                <span className="text-sm font-bold tracking-tight">Explorateur de code Flutter</span>
              </div>
              
              <div className="flex items-center gap-2">
                <span className="text-[10px] uppercase font-bold text-slate-500 tracking-wider">Fichier Actif:</span>
                <span className="text-xs font-mono bg-slate-900 text-blue-400 px-2.5 py-1 rounded-md border border-slate-800">
                  {selectedFile.path}
                </span>
              </div>
            </div>

            {/* Layout with file list sidebar and code view */}
            <div className="grid grid-cols-1 md:grid-cols-12 min-h-[460px]">
              
              {/* Sidebar: Tree view of files */}
              <div className="md:col-span-4 bg-slate-950/40 border-r border-slate-800/60 p-4 space-y-4">
                <span className="text-[10px] font-bold tracking-wider text-slate-500 uppercase block px-1">
                  Arborescence
                </span>
                
                <div className="space-y-3.5 text-xs max-h-[380px] overflow-y-auto pr-1">
                  {/* Category Groupings */}
                  {['Config', 'Entrée', 'Core', 'Navigation', 'Providers', 'Screens'].map((cat) => {
                    const filesInCat = FLUTTER_FILES.filter(f => f.category === cat);
                    if (filesInCat.length === 0) return null;
                    return (
                      <div key={cat} className="space-y-1">
                        <span className="text-[9px] font-black text-slate-500 uppercase block pl-1 tracking-widest">
                          {cat}
                        </span>
                        <div className="space-y-0.5 pl-2">
                          {filesInCat.map((file) => {
                            const isSelected = selectedFile.path === file.path;
                            return (
                              <button
                                key={file.path}
                                onClick={() => setSelectedFile(file)}
                                className={`w-full text-left py-1.5 px-2.5 rounded-lg flex items-center justify-between transition-all ${
                                  isSelected 
                                    ? 'bg-blue-600 text-white font-semibold' 
                                    : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/40'
                                }`}
                              >
                                <span className="truncate pr-2">{file.name}</span>
                                <ChevronRight className={`w-3.5 h-3.5 opacity-50 ${isSelected ? 'translate-x-0.5' : ''} transition-transform`} />
                              </button>
                            );
                          })}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Code viewer with dark color scheme & copy option */}
              <div className="md:col-span-8 flex flex-col bg-slate-950/25">
                
                {/* Code action header */}
                <div className="px-5 py-3 border-b border-slate-800 flex justify-between items-center bg-slate-950/10">
                  <span className="text-[10px] uppercase tracking-wider font-bold text-slate-500 flex items-center gap-1.5">
                    <FileCode className="w-3.5 h-3.5 text-blue-400" />
                    Flutter &bull; Dart
                  </span>

                  <button
                    onClick={() => handleCopyCode(selectedFile.code, selectedFile.path)}
                    className="flex items-center gap-2 text-xs font-semibold bg-slate-800 hover:bg-slate-700 text-slate-200 px-3 py-1.5 rounded-lg transition-all border border-slate-700"
                  >
                    {copiedPath === selectedFile.path ? (
                      <>
                        <Check className="w-3.5 h-3.5 text-emerald-400" />
                        Copié !
                      </>
                    ) : (
                      <>
                        <Copy className="w-3.5 h-3.5" />
                        Copier le code
                      </>
                    )}
                  </button>
                </div>

                {/* Preformatted code panel */}
                <div className="flex-1 p-5 overflow-auto max-h-[360px] text-xs font-mono leading-relaxed bg-slate-950/60 scrollbar-thin">
                  <pre className="text-slate-300">
                    <code>{selectedFile.code}</code>
                  </pre>
                </div>

                {/* Descriptive file role info footer */}
                <div className="p-4 bg-slate-950 border-t border-slate-800 flex items-start gap-3">
                  <FileText className="w-5 h-5 text-blue-400 shrink-0 mt-0.5" />
                  <div>
                    <h4 className="text-[11px] font-bold text-white tracking-wide">
                      Rôle architectural de <span className="font-mono text-blue-400">{selectedFile.name}</span>
                    </h4>
                    <p className="text-[10px] text-slate-400 leading-normal mt-0.5">
                      {selectedFile.category === 'Config' && "Définit les dépendances et packages fondamentaux requis par Nexii pour la localisation, la gestion d'état globale et le design system."}
                      {selectedFile.category === 'Entrée' && "Initialise le point d'ancrage principal et monte la structure applicative avec les providers d'états globaux."}
                      {selectedFile.category === 'Core' && "Fournit les valeurs d'usine fondamentales indispensables de Material 3 et les utilitaires de style global."}
                      {selectedFile.category === 'Navigation' && "Gère la barre de routage M3 inférieure, servant de composant d'interface découpé et réutilisable."}
                      {selectedFile.category === 'Providers' && "Gère le dispatch des changements de langues à la volée ainsi que le changement d'ambiance d'affichage global."}
                      {selectedFile.category === 'Screens' && "Gère le gabarit visuel Material 3 dédié à l'un des 7 piliers principaux, optimisé pour les animations et le calme de l'esprit."}
                    </p>
                  </div>
                </div>

              </div>

            </div>

          </div>

        </section>

      </main>

      {/* Daily Check-In/Bilan Modal */}
      <AnimatePresence>
        {showCheckInModal && (
          <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-sm z-[9999] flex items-center justify-center p-4">
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-white dark:bg-slate-900 rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-100 dark:border-slate-800 space-y-5 text-slate-800 dark:text-slate-100"
            >
              <div className="text-center">
                <span className="text-3xl">🌸</span>
                <h3 className="text-lg font-bold font-sans text-slate-900 dark:text-white mt-2">
                  {lang === 'fr' ? 'Bilan Quotidien Nexii' : 'Nexii Daily Check-In'}
                </h3>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
                  {lang === 'fr' 
                    ? 'Prenez un court instant pour évaluer votre état. Le Coach adaptera ses conseils et votre Aura.' 
                    : 'Take a brief moment to evaluate your state. The Coach will adapt advice and your Aura.'}
                </p>
              </div>

              <div className="space-y-4">
                {/* Mood slider */}
                <div className="space-y-1.5">
                  <div className="flex justify-between text-xs font-semibold text-slate-700 dark:text-slate-300">
                    <span>🙂 {lang === 'fr' ? 'Humeur globale' : 'Overall Mood'}</span>
                    <span className="font-bold text-blue-600 dark:text-blue-400">{checkInMood}/5</span>
                  </div>
                  <input
                    type="range" min="1" max="5" value={checkInMood}
                    onChange={(e) => setCheckInMood(parseInt(e.target.value))}
                    className="w-full accent-blue-600"
                  />
                </div>

                {/* Energy slider */}
                <div className="space-y-1.5">
                  <div className="flex justify-between text-xs font-semibold text-slate-700 dark:text-slate-300">
                    <span>⚡ {lang === 'fr' ? 'Niveau d\'énergie' : 'Energy Level'}</span>
                    <span className="font-bold text-amber-500">{checkInEnergy}/5</span>
                  </div>
                  <input
                    type="range" min="1" max="5" value={checkInEnergy}
                    onChange={(e) => setCheckInEnergy(parseInt(e.target.value))}
                    className="w-full accent-amber-500"
                  />
                </div>

                {/* Motivation slider */}
                <div className="space-y-1.5">
                  <div className="flex justify-between text-xs font-semibold text-slate-700 dark:text-slate-300">
                    <span>🎯 {lang === 'fr' ? 'Motivation' : 'Motivation'}</span>
                    <span className="font-bold text-emerald-500">{checkInMotivation}/5</span>
                  </div>
                  <input
                    type="range" min="1" max="5" value={checkInMotivation}
                    onChange={(e) => setCheckInMotivation(parseInt(e.target.value))}
                    className="w-full accent-emerald-500"
                  />
                </div>

                {/* Stress slider */}
                <div className="space-y-1.5">
                  <div className="flex justify-between text-xs font-semibold text-slate-700 dark:text-slate-300">
                    <span>🧘 {lang === 'fr' ? 'Niveau de Stress' : 'Stress Level'}</span>
                    <span className="font-bold text-rose-500">{checkInStress}/5</span>
                  </div>
                  <input
                    type="range" min="1" max="5" value={checkInStress}
                    onChange={(e) => setCheckInStress(parseInt(e.target.value))}
                    className="w-full accent-rose-500"
                  />
                </div>

                {/* Sleep slider */}
                <div className="space-y-1.5">
                  <div className="flex justify-between text-xs font-semibold text-slate-700 dark:text-slate-300">
                    <span>😴 {lang === 'fr' ? 'Qualité du sommeil' : 'Sleep Quality'}</span>
                    <span className="font-bold text-purple-500">{checkInSleep}/5</span>
                  </div>
                  <input
                    type="range" min="1" max="5" value={checkInSleep}
                    onChange={(e) => setCheckInSleep(parseInt(e.target.value))}
                    className="w-full accent-purple-500"
                  />
                </div>
              </div>

              <div className="flex gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setShowCheckInModal(false)}
                  className="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300 text-xs font-bold rounded-2xl transition-all cursor-pointer"
                >
                  {lang === 'fr' ? 'Annuler' : 'Cancel'}
                </button>
                 <button
                  type="button"
                  onClick={() => {
                    const todayStr = new Date().toISOString().split('T')[0];
                    setLastManualCheckInDate(todayStr);
                    setHasDoneCheckIn(true);
                    awardXp(30, lang === 'fr' ? "Bilan quotidien complété" : "Daily Check-In completed");
                    setShowCheckInModal(false);
                    triggerSync(
                      tasks,
                      missions,
                      transactions,
                      totalBudget,
                      spentAmount,
                      userXp + 30, // Account for immediate XP award
                      userLevel,
                      selectedMood,
                      lang,
                      isDarkMode,
                      userStreak,
                      focusMinutes,
                      lastCheckInDate,
                      agendaEvents,
                      lastMissionsResetDate,
                      currency,
                      savingsGoals,
                      notifications,
                      userAge,
                      userBirthdate,
                      workouts,
                      user?.displayName || onboardingName || '',
                      todayStr,
                      checkInMood,
                      checkInEnergy,
                      checkInMotivation,
                      checkInStress,
                      checkInSleep
                    );
                  }}
                  className="flex-1 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-2xl transition-all shadow-md shadow-blue-600/20 cursor-pointer"
                >
                  {lang === 'fr' ? 'Valider le Bilan (+30 XP)' : 'Validate Bilan (+30 XP)'}
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Premium Upgrade Modal */}
      <AnimatePresence>
        {showEconomicModal && (
          <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-sm z-[9999] flex items-center justify-center p-4">
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-white dark:bg-slate-900 rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-100 dark:border-slate-800 space-y-5 text-slate-800 dark:text-slate-100"
            >
              <div className="text-center">
                <span className="text-3xl">💎</span>
                <h3 className="text-lg font-bold font-sans text-slate-900 dark:text-white mt-2">
                  {lang === 'fr' ? 'Passez à Nexii Premium' : 'Upgrade to Nexii Premium'}
                </h3>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
                  {lang === 'fr' 
                    ? 'Débloquez la pleine puissance de l\'IA et atteignez une productivité sereine sans limites.' 
                    : 'Unlock the full power of AI and achieve limitless serene productivity.'}
                </p>
              </div>

              {/* Economic model tiers */}
              <div className="space-y-3">
                <div className="p-3.5 rounded-2xl border border-slate-100 dark:border-slate-800 bg-slate-50 dark:bg-slate-950 flex justify-between items-center">
                  <div>
                    <h4 className="text-xs font-extrabold text-slate-800 dark:text-slate-100">Nexii Free</h4>
                    <p className="text-[10px] text-slate-500 dark:text-slate-400">Coach IA basique, 3 tâches/jour, Focus standard</p>
                  </div>
                  <span className="text-xs font-extrabold text-slate-400">0 €</span>
                </div>

                <div className="p-3.5 rounded-2xl border border-purple-500 bg-purple-500/5 flex justify-between items-center relative overflow-hidden">
                  <div className="absolute top-0 right-0 bg-purple-600 text-white text-[8px] font-black uppercase tracking-wider px-2.5 py-0.5 rounded-bl-xl">Popular</div>
                  <div>
                    <h4 className="text-xs font-extrabold text-purple-600 dark:text-purple-400 flex items-center gap-1">
                      Nexii Premium
                    </h4>
                    <p className="text-[10px] text-slate-500 dark:text-slate-400">Coach Vocal, Aura complète, Auto-Planification, Analyses</p>
                  </div>
                  <span className="text-xs font-black text-purple-600 dark:text-purple-400">4.99 €<span className="text-[9px] font-normal text-slate-400">/m</span></span>
                </div>

                <div className="p-3.5 rounded-2xl border border-slate-100 dark:border-slate-800 bg-slate-50 dark:bg-slate-950 flex justify-between items-center">
                  <div>
                    <h4 className="text-xs font-extrabold text-slate-800 dark:text-slate-100">Nexii Enterprise</h4>
                    <p className="text-[10px] text-slate-500 dark:text-slate-400">Intégration d'équipe, SSO, API sur-mesure, Rapports</p>
                  </div>
                  <span className="text-xs font-extrabold text-slate-800 dark:text-slate-100">Sur devis</span>
                </div>
              </div>

              <div className="flex gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setShowEconomicModal(false)}
                  className="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300 text-xs font-bold rounded-2xl transition-all cursor-pointer"
                >
                  {lang === 'fr' ? 'Plus tard' : 'Later'}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setIsPremium(true);
                    awardXp(100, "Abonnement Nexii Premium");
                    setShowEconomicModal(false);
                    alert("Félicitations ! Vous êtes maintenant membre Nexii Premium ! 💎✨");
                  }}
                  className="flex-1 py-2.5 bg-purple-600 hover:bg-purple-700 text-white text-xs font-bold rounded-2xl transition-all shadow-md shadow-purple-600/20 cursor-pointer"
                >
                  {lang === 'fr' ? 'S\'abonner (4.99€)' : 'Subscribe (4.99€)'}
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

    </div>
  );
}
