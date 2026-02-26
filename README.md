# Satu Ayat Sehari

Satu Ayat Sehari is a Flutter-based daily devotion application that delivers one verse and one reflection per day based on date. The application uses Supabase as backend and Firebase Cloud Messaging for scheduled daily push notifications.

---

## Overview

This project is built around a simple spiritual rhythm concept:

- One day
- One verse
- One reflection

Each devotion is stored and retrieved based on date, creating a consistent and meaningful daily experience.

The mobile application acts as a read-only client, while Supabase manages data storage and scheduled push notification automation.

---

## Tech Stack

- Flutter (Android)
- Supabase (PostgreSQL & Edge Functions)
- Firebase Cloud Messaging (Push Notifications)
- Deno (Edge Function runtime)

---

## Architecture

The project follows a simple layered structure:

- `models/` – Data models
- `services/` – Business logic and API communication
- `screens/` – User interface layer
- `supabase/` – Backend configuration and Edge Functions

Devotion data is organized by date, ensuring only one verse and one reflection per day. Push notifications are triggered via a scheduled Supabase Edge Function.

---

## Features

- Daily verse based on current date
- Daily reflection (renungan)
- Archive page
- Favorite verse (stored locally on device)
- Scheduled push notification (06:00)
- Supabase Edge Function for automated push delivery

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/thomasandrianto/satu-ayat-sehari-android.git
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Setup environment variables

Create a `.env` file in the project root:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4. Run the application

```bash
flutter run
```

---

## Environment Variables

| Variable          | Description              |
| ----------------- | ------------------------ |
| SUPABASE_URL      | Supabase project URL     |
| SUPABASE_ANON_KEY | Supabase public anon key |

---

## Future Improvements

- Devotion theme filtering
- Enhanced UI theming
- Improved offline capability
- iOS production deployment

---

## License

This project is developed as a personal project focused on delivering a structured and meaningful daily devotion experience.
