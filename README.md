# Satu Ayat Sehari

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ecf8e)
![Platform](https://img.shields.io/badge/Platform-Android-lightgrey)

Satu Ayat Sehari is a Flutter-based Android application that delivers one Bible verse and one reflection per day, structured by date.  
The system is designed to be simple, consistent, and spiritually focused: one day, one verse, one reflection.

The mobile app acts as a read-only client, while Supabase handles data storage and scheduled push automation.

---

## Overview

Each devotion is uniquely identified by date:

- 1 verse per day
- 1 reflection (renungan) per day
- Optional theme categorization
- Stored and managed from backend
- Delivered automatically every morning

This structure keeps the application lightweight, meaningful, and scalable.

---

## Tech Stack

- Flutter (Android)
- Supabase (PostgreSQL Database)
- Supabase Edge Functions (Deno runtime)
- Firebase Cloud Messaging (Push Notifications)

---

## Architecture

The system follows a simple client–backend architecture.

Flow of daily devotion:

1. User opens the app
2. Flutter requests devotion data by current date
3. Supabase returns verse and reflection
4. At 06:00, a scheduled Edge Function runs
5. Edge Function sends push notification via FCM
6. Device receives daily reminder

### System Flow

```
Flutter App
    ↓
Supabase Database (daily_devotions)
    ↓
Edge Function (Cron 06:00)
    ↓
Firebase Cloud Messaging
    ↓
User Device
```

### Project Structure

```
lib/
 ├── models/
 ├── services/
 ├── screens/
 └── main.dart

supabase/
 └── functions/
     └── send_daily_push/
```

---

## Features

- Daily devotion based on date
- Clean and reflective UI
- Local favorite verse storage (SQLite)
- Scheduled push notification (06:00)
- Backend-managed devotion content
- Theme-ready data structure

---

## Getting Started

### 1. Clone Repository

```bash
git clone https://github.com/thomasandrianto/satu-ayat-sehari-android.git
cd satu-ayat-sehari-android
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Environment Variables

Create `.env` file in root directory:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4. Run Application

```bash
flutter run
```

---

## Environment Variables

| Variable          | Description                   |
| ----------------- | ----------------------------- |
| SUPABASE_URL      | Supabase project URL          |
| SUPABASE_ANON_KEY | Public anon key from Supabase |

---

## Roadmap

- [x] Daily devotion by date
- [x] Scheduled push notification
- [x] Local favorite verse
- [ ] Devotion theme filtering
- [ ] Archive calendar view
- [ ] Admin content management interface
- [ ] iOS deployment
- [ ] Custom domain backend migration

---

## Design Principles

- One day, one message
- Minimal distraction
- Structured spiritual rhythm
- Lightweight client, controlled backend

---

## License

Developed as a personal structured devotional application project.
