# Loop Mobile Challenge

UIKit iOS app for browsing movies, viewing details, and managing favorites.

## Project at a glance

- Feature-based structure (Home, Search, Detail, SignUp, Splash)
- Programmatic UIKit UI with Auto Layout
- Shared data/services layer for catalog and favorites
- Home and Search both use the same catalog and favorite state

## MovieCatalog approach

MovieCatalog is the single in-memory source for movie data during app runtime.

- Loads two endpoints concurrently:
  - all movies
  - staff picks
- Tracks explicit loading state: idle, loading, loaded, failed
- Stores IDs and movie payloads in memory for fast lookup
- Exposes movie lookup by ID so view models can assemble screen-specific lists

Flow:
1. HomeViewModel calls loadCatalog() on first load or retry.
2. MovieCatalog fetches and decodes both JSON payloads.
3. HomeViewModel maps catalog data into:
   - staff picks for the table
   - favorites for the top horizontal section

## Search approach

Search is implemented as a dedicated screen with its own SearchViewModel, but it reuses the same shared MovieCatalog and FavoritesManager instance coming from Home.

- Query updates are handled in the view model (updateQuery)
- Filtering is local/in-memory (no extra network calls)
- Search matches against:
  - movie title
  - movie overview
  - release year
- Empty query returns all movies
- Favorite toggles in Search update shared favorite state immediately

Because Home and Search share dependencies, favorite changes stay consistent across screens after refresh/render updates.
