
---

## 🧠 Prompt: Flutter Email Client App (Snaarp Assessment)

---

### OVERVIEW

Build a **Flutter email client mobile application** that mimics the core functionality of Gmail/Outlook. The app should demonstrate clean architecture, state management, API integration (mocked), and polished UI/UX. This is a technical assessment submission, so code quality, structure, and design all matter.

---

### TECH STACK

- **Framework:** Flutter (latest stable version)
- **Language:** Dart
- **State Management:** Riverpod (preferred) or Bloc
- **Architecture:** Clean Architecture (Data → Domain → Presentation layers)
- **Navigation:** GoRouter
- **Local Storage:** SharedPreferences (for auth state persistence)
- **Mock API:** Local JSON / Dart service classes simulating async API calls with delays
- **UI:** Material 3 design system

---

### PROJECT STRUCTURE

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── sources/          # mock data sources
├── domain/
│   ├── entities/
│   ├── repositories/     # abstract interfaces
│   └── usecases/
├── presentation/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── auth_provider.dart
│   ├── inbox/
│   │   ├── inbox_screen.dart
│   │   └── inbox_provider.dart
│   ├── detail/
│   │   ├── email_detail_screen.dart
│   │   └── detail_provider.dart
│   ├── compose/
│   │   ├── compose_screen.dart
│   │   └── compose_provider.dart
│   └── widgets/          # shared widgets
└── main.dart
```

---

### FEATURE SPECIFICATIONS

#### 1. 🔐 Authentication Screen
- Fields: **Email** and **Password**
- Hardcoded mock credentials: `user@mail.com` / `password123`
- Validate inputs (empty check, email format)
- Show loading spinner on "Login" press (simulate 1.5s async delay)
- On success: navigate to Inbox, persist auth state via SharedPreferences
- On failure: show inline error snackbar — *"Invalid credentials"*
- On app relaunch: check auth state, skip login if already authenticated
- Add a **"Logout"** option in the app drawer/settings

#### 2. 📥 Inbox Screen
- Display a **scrollable list** of 15–20 mock emails
- Each list tile shows:
  - Sender avatar (initials-based colored circle)
  - Sender name + email
  - Subject line (bold if unread)
  - Body preview (1 line, truncated)
  - Timestamp (e.g., *"10:32 AM"* or *"Mar 28"*)
  - Unread indicator (colored dot or bold styling)
- Simulate loading with a **skeleton loader** (not just a spinner)
- **Pull-to-refresh** support (re-fetches mock data with delay)
- **Search bar** at the top to filter emails by sender or subject
- FAB (Floating Action Button) with pencil icon → opens Compose screen
- App bar with: app title, search icon, avatar/profile icon

#### 3. 📧 Email Detail Screen
- Opened by tapping an inbox item
- Shows:
  - Subject as screen title
  - Sender full name + email
  - Recipient
  - Date/time (full format)
  - Full email body (scrollable)
- **Mark as Read/Unread** toggle button in the app bar
- Marking as read updates the inbox list state (unread dot disappears)
- Back navigation returns to inbox with updated state
- Reply button (UI only, no functionality needed — can show a snackbar: *"Reply coming soon"*)

#### 4. ✏️ Compose Screen
- Opened as a **modal bottom sheet** or full screen
- Fields:
  - **To** (recipient email — validate format)
  - **Subject**
  - **Body** (multiline, expands)
- App bar with: **Close (X)** icon and **Send** button
- On Send:
  - Validate all fields are filled and email is valid
  - Show loading indicator for 1.5s (mock send)
  - Show success snackbar: *"Email sent successfully"*
  - Dismiss the compose screen
  - Optionally add the sent email to a "Sent" mock list
- Discard confirmation dialog if user closes with unsaved content

#### 5. 🧭 Navigation
- Use **GoRouter** for declarative routing
- Routes: `/login`, `/inbox`, `/email/:id`, `/compose`
- Auth guard: redirect unauthenticated users to `/login`
- Smooth transitions (slide or fade animations between screens)
- Bottom navigation bar or drawer with: Inbox, Sent, Drafts (Sent/Drafts can show empty state UI)

---

### MOCK DATA SPECIFICATION

Generate a Dart file `mock_emails.dart` with a list of 20 `EmailEntity` objects:

```dart
class EmailEntity {
  final String id;
  final String senderName;
  final String senderEmail;
  final String recipientEmail;
  final String subject;
  final String bodyPreview;
  final String fullBody;
  final DateTime timestamp;
  bool isRead;
  final bool isStarred;
}
```

Vary the data: include emails from different senders, some read, some unread, different timestamps (today, yesterday, last week).

---

### UI / UX REQUIREMENTS

- Follow **Material 3** design guidelines
- Support **light and dark mode** (auto from system)
- Use a consistent color scheme (suggest: deep blue primary `#1A73E8` à la Gmail, or any professional palette)
- Smooth animations: list item transitions, screen transitions, FAB animation
- Empty state UI: show an illustration + message when no emails
- Error state UI: show retry button when mock fetch fails (simulate occasional failure)
- Responsive layout: works well on both small (360dp) and large (412dp+) screens
- No overflowing text — use `TextOverflow.ellipsis` where needed

---

### ERROR HANDLING & LOADING STATES

- All async operations must have 3 states: **loading**, **success**, **error**
- Use Riverpod `AsyncValue` or Bloc states to manage these
- Show shimmer/skeleton on initial inbox load
- Show `CircularProgressIndicator` on login and send actions
- Show error messages via `SnackBar` or inline error widgets
- Handle edge cases: empty fields, invalid email format, network timeout simulation

---

### README.md MUST INCLUDE

```markdown
# MailFlow — Flutter Email Client

## How to Run
1. Clone the repo: `git clone <url>`
2. Run `flutter pub get`
3. Run `flutter run`

## Mock Credentials
- Email: user@mail.com
- Password: password123

## Architecture
Clean Architecture with Riverpod state management...

## Challenges Faced
- [Describe real challenges encountered]

## Screen Recordings / Demo
- [Link or GIF]
```

---



### BONUS (Optional but impressive)

- Star/favourite an email
- Swipe-to-delete or swipe-to-archive on inbox items
- Categorized tabs: Primary, Social, Promotions (like Gmail)
- Animated splash screen
