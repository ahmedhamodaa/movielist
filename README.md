# Movielist

A modern **Flutter** app for discovering and tracking **Movies & TV Shows** powered by **TMDB**.  
Browse trending titles, search across movies and TV, manage favorites, and create custom lists — all in a clean **dark UI**.

![Movielist App Screenshot](https://i.ibb.co/C3F4FPtM/Movielist-App.png)

## Features

- **Browse**: Popular Movies, Top Rated Movies, Upcoming Movies
- **Browse**: Popular TV Shows, Top Rated TV Shows, Airing Today
- **Search**: Multi-search across movies and TV shows
- **Auth**: TMDB login + session management
- **Favorites**: Add/Remove movies and TV shows to favorites
- **Lists**: Create/Update/Delete lists and add/remove items
- **Details pages**: Rich details screens for movies and TV shows
- **UI**: Modern dark theme + smooth navigation

## Tech Stack

- **Flutter**, **Dart**
- **REST API** + **TMDB API**
- **HTTP** for networking
- **Shared Preferences** for local session storage
- **Material Design**

## Getting Started

### Prerequisites

- Flutter SDK (stable)
- A TMDB account

### Setup

```bash
flutter pub get
flutter run
```

## TMDB API Configuration (Important)

This project calls TMDB endpoints (authentication, search, lists, favorites, etc.).  
To run it in production or share publicly, **do not hardcode secrets** in the repo.

- Create TMDB API credentials from TMDB developer settings.
- Update the API key / bearer token used by the app (currently used inside `lib/services/tmdb_service.dart`).

> Tip: Prefer injecting keys via build-time variables (e.g. `--dart-define`) or a non-committed config file.

## Project Structure (High Level)

- `lib/services/` — API services (TMDB integration)
- `lib/presentation/` — UI screens + widgets
- `lib/core/` — constants, styling, shared widgets

## License

This project is for learning/portfolio purposes. Add your preferred license if you plan to distribute it.
