Nexii

«Your life. Your focus. Your progress.»

Nexii is an intelligent personal productivity and well-being application designed to help users understand their current state, organize their activities, focus on what matters, and make meaningful progress over time.

Rather than treating productivity as a simple checklist, Nexii combines tasks, goals, agenda, focus sessions, financial awareness, personal well-being, and AI-assisted coaching into one coherent system.

🚀 Nexii V1

Nexii V1 is currently entering its real-device beta testing phase.

The current version focuses on establishing a reliable foundation for:

- Personal productivity
- Goal management
- Task management
- Agenda management
- Focus sessions
- Progress analysis
- AI coaching
- Intelligent action execution
- Personal profile and onboarding
- Firebase authentication and persistence

---

🧠 Core Intelligence

Nexii includes an intelligence pipeline designed to transform raw user activity into useful, contextual guidance.

The current server-side intelligence architecture includes:

Observe
   ↓
Understand
   ↓
Pulse
   ↓
Anticipate
   ↓
Recommend
   ↓
Measure
   ↓
Aura
   ↓
Living Goals

These components are orchestrated before the AI Coach receives the context.

Intelligence Orchestrator

The orchestrator:

- Collects the user's current context
- Processes productivity signals
- Evaluates recent activity
- Detects potential friction
- Generates recommendations
- Produces a compact intelligence summary
- Passes the result to the AI Coach
- Gracefully handles individual node failures

If one intelligence component fails, the remaining pipeline can continue instead of crashing the Coach.

---

🤖 Nexii Coach

The Coach is Nexii's conversational intelligence layer.

It receives:

- User message
- Nexii State
- Recent productivity data
- Task completion statistics
- Focus activity
- Active days
- Goals
- Goal/task relationships
- Intelligence orchestrator results
- Current focus context

The server then constructs a contextual prompt for the AI model.

The Coach can also return structured intents, allowing Nexii to turn natural-language requests into actions.

Example:

User:
"Create a task to revise chemistry tomorrow."

        ↓

Nexii Coach

        ↓

Intent:
create_task

        ↓

ActionEngine

        ↓

Firebase persistence

        ↓

TaskProvider refresh

        ↓

Updated UI

---

⚡ Action Engine

Nexii does not only generate suggestions.

The Action Engine allows accepted AI intents to become actual application actions.

Currently supported actions include:

- "create_task"
- "update_task"
- "delete_task"
- "reschedule_task"
- "create_goal"
- "update_goal"
- "create_event"

The execution flow is:

AI Intent
   ↓
User Acceptance
   ↓
ActionEngineService
   ↓
ActionEngine
   ↓
Persistence
   ↓
Provider Refresh
   ↓
Updated UI

This keeps AI-generated actions under explicit user control.

---

📊 Progress Engine

The Progress Engine computes a compact view of recent activity.

The current 7-day summary includes:

- Total tasks
- Completed tasks
- Completion rate
- Focus sessions
- Focus minutes
- Active days
- Goals
- Tasks linked to goals
- Generated insights

This data is transformed into "progressContext" and provided to the Coach intelligence pipeline.

---

🌱 Onboarding

Nexii uses a context-first onboarding experience.

The initial flow is:

Nexii Splash
      ↓
Activity
      ↓
Productivity Problem
      ↓
How are you?
      ↓
Authentication
      ↓
Nexii

The onboarding information is temporarily stored locally and associated with the user's profile after authentication.

This allows Nexii to understand the user before asking them to create an account.

---

🔐 Authentication & Data

Nexii currently uses Firebase services through a dedicated service layer.

The architecture includes:

- Firebase Authentication
- Firestore persistence
- Session restoration
- Local session storage
- Profile persistence
- Provider-based state management

The Gemini API key remains server-side and is not embedded in the Flutter client.

---

🏗️ Architecture

Nexii currently combines Flutter/Dart on the client with a TypeScript/Node.js server.

                    ┌──────────────────────┐
                    │      Nexii App       │
                    │      Flutter/Dart    │
                    └──────────┬───────────┘
                               │
                               │ HTTP
                               ▼
                    ┌──────────────────────┐
                    │     Node Server      │
                    │   TypeScript/Express │
                    └──────────┬───────────┘
                               │
                 ┌─────────────┴─────────────┐
                 │                           │
                 ▼                           ▼
       ┌──────────────────┐        ┌──────────────────┐
       │ Intelligence     │        │ Gemini Service   │
       │ Orchestrator     │───────▶│ Server-side AI   │
       └──────────────────┘        └──────────────────┘
                 │
                 ▼
       ┌──────────────────────┐
       │ Observe / Understand │
       │ Pulse / Anticipate   │
       │ Recommend / Measure  │
       │ Aura / Living Goals  │
       └──────────────────────┘

                    Firebase
                       ▲
                       │
              Persistence layer

Client

- Flutter
- Dart
- Provider
- Firebase REST services
- SharedPreferences
- ActionEngine
- ProgressEngine

Server

- Node.js
- TypeScript
- Express
- Gemini API
- Intelligence Orchestrator

Web / Frontend

The repository also contains the project's web infrastructure using:

- React
- TypeScript
- Vite

---

🧪 Testing

Nexii V1 has automated tests covering important application flows.

Current validation includes:

dart analyze --fatal-warnings
flutter test
npm run lint

The test suite covers areas including:

- Authentication
- Providers
- Tasks
- Goals
- Budget
- Progress Engine
- Coach context
- Coach intents
- Action Engine
- Rescheduling
- API client behavior

The intelligence orchestrator has also been runtime-tested against:

- Normal data
- Empty data
- Partial data
- Simulated intelligence-node failures

---

📁 Project Structure

nexii/
├── android/
├── ios/
├── linux/
├── macos/
├── windows/
├── web/
│
├── assets/
│
├── lib/
│   ├── core/
│   │   ├── intelligence/
│   │   ├── services/
│   │   ├── theme/
│   │   └── utils/
│   │
│   ├── models/
│   ├── navigation/
│   ├── providers/
│   ├── screens/
│   ├── app.dart
│   └── main.dart
│
├── server/
│   ├── intelligence/
│   ├── routes/
│   ├── services/
│   ├── fallbacks/
│   └── types/
│
├── test/
│
├── package.json
├── pubspec.yaml
├── tsconfig.json
└── README.md

---

🛡️ Design Principles

Nexii is built around several principles:

Context before action

The system should understand the user's situation before recommending what they should do.

AI with user control

AI-generated actions are not silently executed. The user can review and accept an intent before persistence.

Graceful degradation

An intelligence component failing should not bring down the entire Coach pipeline.

Structured intelligence

Nexii separates intelligence processing from conversational generation.

Productivity without overload

The objective is not to maximize the number of completed tasks, but to help users make sustainable progress.

---

🗺️ Roadmap

V1 — Foundation

- [x] Authentication
- [x] Onboarding
- [x] Profile
- [x] Tasks
- [x] Goals
- [x] Agenda
- [x] Focus
- [x] Progress Engine
- [x] Intelligence nodes
- [x] Intelligence Orchestrator
- [x] AI Coach
- [x] Action Engine
- [x] Intent persistence
- [x] Rescheduling
- [x] Automated tests
- [ ] Real-device beta testing

Future

Potential future work includes:

- More advanced personalization
- Expanded intelligence signals
- Improved AI context compression
- Deeper financial intelligence
- More powerful goal intelligence
- Advanced analytics
- Expanded platform support
- Public release

---

📱 Beta Status

Current status: REAL-DEVICE BETA

Nexii V1 has passed the current static analysis and automated test validation.

The next major validation step is testing the application on a real Android device through the production build pipeline.

---

🔒 Security

Secrets must not be committed to the repository.

Environment variables should be configured through the appropriate deployment environment.

Example configuration:

GEMINI_API_KEY=your_server_side_key

Never commit a real API key.

---

📄 License

This project is currently under private development.

License information will be added when Nexii is ready for public distribution.

---

Nexii

Build the system. Understand the user. Turn intelligence into action.