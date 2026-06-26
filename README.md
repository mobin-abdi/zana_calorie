# 🥗 Zana - Smart Nutrition \& Calorie Tracking Platform



**Zana** (meaning *Wise*) is a modern, smart platform designed to help users track their daily meals, calories, and macronutrients. The ecosystem consists of a powerful **Django** backend and a cross-platform mobile application built with **Flutter**. Zana's core feature is an AI-powered smart food scanner that recognizes meals from photos and instantly estimates their calories and macros.

## 🛠️ Tech Stack


**Backend:** Python / Django / Django REST Framework (DRF)

**Frontend:** Dart / Flutter / BLoC Pattern (State Management)

**Database:** SQLite (Development) / PostgreSQL (Production)

## 🚀 Getting Started
Follow these steps to set up and run both the backend and frontend on your local machine.

### 1. Backend Setup (Django)
First, navigate to the `backend` directory:

```bash
cd backend
```

Create a virtual environment and activate it:

```bash
\# Create virtual environment

python -m venv venv

\# Activate on Windows

venv\\Scripts\\activate

\# Activate on macOS/Linux

source venv/bin/activate
```

Install the required dependencies:

پ
```bash
pip install -r requirements.txt
```

Apply database migrations and start the development server:

```bash
python manage.py migrate
python manage.py runserver
```

The backend server will now be running at `http://127.0.0.1:8000`.

### 2. Frontend Setup (Flutter)

Navigate to your Flutter project directory:

```bash
cd zana\_calorie
```

Fetch the required Dart packages:

```bash
flutter pub get
```

Connect an emulator or a physical device and run the application:

```bash
flutter run
```

> 💡 **Connection Note:**

> If you are running the app on an Android Emulator, use `10.0.2.2:8000` to connect to your local backend. If you are testing on a physical device, make sure to replace `localhost` with your machine's local IP address in your `http\_client.dart` configuration.

## 📄 API Documentation
The backend includes interactive API documentation (Swagger) to easily test endpoints and understand the data structures.
Once your local backend server is running, you can access the full documentation here:

🔗 \*\*\[http://localhost:8000/api/docs](http://localhost:8000/api/docs)\*\*

## ✨ Key Features



**Dynamic Dashboard:** Real-time visual tracking of daily calorie intake and macronutrients (carbs, proteins, fats) using dynamic state updating.

**Robust Architecture:** Clean implementation of the BLoC pattern in Flutter to maintain predictable UI state changes (`Loading`, `Loaded`, `Error`).

**AI Smart Food Scanner:** Dedicated interface to capture or upload meal photos for AI-based nutrient estimation.

**Seamless Sync:** Pull-to-refresh integration ensuring local application state matches backend records instantly.
