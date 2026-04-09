Here's the full implementation prompt you can drop into Claude Code or any AI coding assistant:

---

## MailFlow — Gmail-Like Flutter App: Full Implementation Prompt

---

### CONTEXT

I have an existing Flutter email client called **MailFlow**. I want to upgrade it to closely mirror Gmail's interaction design, navigation structure, and feature set — while keeping the existing color palette.

The app already has:
- Login screen with mock auth
- Basic inbox screen
- Email detail screen
- Compose screen with recipient chips, formatting toolbar, attachments
- Riverpod state management
- Clean architecture (Data → Domain → Presentation)

---

### WHAT TO BUILD / UPGRADE

---

#### 1. PROJECT STRUCTURE

Reorganize into this clean architecture layout:

```
lib/
├── core/
│   ├── theme/            # AppColors, AppTheme
│   ├── constants/        # routes, strings, enums
│   └── utils/            # date formatter, avatar color picker
├── data/
│   ├── models/           # EmailModel, UserModel, LabelModel
│   ├── sources/          # MockEmailDataSource (async with delay)
│   └── repositories/     # EmailRepositoryImpl
├── domain/
│   ├── entities/         # Email, User, Label
│   ├── repositories/     # abstract EmailRepository
│   └── usecases/         # GetEmails, GetEmailById, MarkAsRead,
│                         # ToggleStar, DeleteEmail, SendEmail
├── presentation/
│   ├── splash/           # SplashScreen
│   ├── auth/             # LoginScreen, AuthNotifier
│   ├── inbox/            # InboxScreen, InboxNotifier
│   ├── detail/           # EmailDetailScreen, DetailNotifier
│   ├── compose/          # ComposeScreen, ComposeNotifier
│   ├── search/           # SearchScreen, SearchNotifier
│   ├── settings/         # SettingsScreen
│   └── widgets/          # shared widgets
└── main.dart
```

---

#### 2. SPLASH SCREEN

- Show centered app logo (envelope icon) on `#2C2C2A` background
- Animate logo with a scale + fade-in over 800ms
- After 2 seconds, check SharedPreferences for saved auth state
- Navigate to Inbox if logged in, otherwise Login screen
- Use `Navigator.pushReplacement` so back button doesn't return to splash

---

#### 3. LOGIN SCREEN

Keep existing layout but add:
- Labeled fields with uppercase `0.5px` border inputs (`EMAIL`, `PASSWORD`)
- Inline validation — red border + error text below field on bad input
- Loading state on button press (replace text with `CircularProgressIndicator`)
- On success → navigate to InboxScreen, save auth to SharedPreferences
- Mock credentials: `user@mail.com` / `password123`
- "Sign in with Google" button (UI only, shows snackbar: "Google auth coming soon")
- Keyboard dismisses on tap outside

---

#### 4. INBOX SCREEN — GMAIL PATTERN

**App Bar:**
- Hamburger menu → opens drawer
- Tappable search bar in the app bar (navigates to SearchScreen)
- User avatar circle (initials) on the right → shows account info dialog

**Category Tabs:**
- `Primary`, `Social`, `Promotions` — horizontally scrollable
- primary color underline on active tab
- Each tab has its own email list (filter mock data by category)
- Unread count badge on Social and Promotions tabs

**Email List Items:**
- Sender initials avatar (colored by sender, cycling through avatar palette)
- Bold sender name + subject when unread, normal weight when read
- One-line body preview truncated with ellipsis
- Timestamp (show time if today, date if older)
- Star icon on the right — tappable, toggles filled/outlined primary color star
- Unread blue dot replaced with **primary color dot** (`#D4537E`)
- **Swipe right** → archive (green background with archive icon + "Undo" snackbar)
- **Swipe left** → delete (red background with trash icon + "Undo" snackbar)
- **Long press** → enters multi-select mode:
  - Checkbox appears on avatar
  - App bar changes to show count + bulk action icons (archive, delete, mark read)
  - Tap any email to toggle its selection

**FAB:**
- Extended FAB with pencil icon + "Compose" label
- Shrinks to icon-only FAB on scroll down
- Re-expands on scroll up or when list reaches top
- primary color background, white icon

**Pull to Refresh:**
- `RefreshIndicator` with primary color color
- Re-fetches mock data with 800ms simulated delay

---

#### 5. SIDE DRAWER — GMAIL PATTERN

Structure:
```
[MailFlow logo + "user@mail.com"]
──────────────────────────────
Inbox                    [24]
Starred
Important
Sent
All Mail
──────────────────────────────
Trash
```

- Active folder highlighted with primary color background pill
- Unread counts shown as primary color badges
- Folder icon on the left of each item
- Tapping a folder closes drawer and updates inbox to show that folder's emails
- Sent, Drafts, Spam, Trash show empty state if no mock data for them

---

#### 6. EMAIL DETAIL SCREEN — GMAIL PATTERN

**App Bar:**
- Back arrow
- Archive icon
- Delete icon (with confirmation dialog)
- Three-dot menu → Mark unread, Star, Move to, Label as

**Header:**
- Subject as large title
- primary color label chips below subject (e.g. "Work", "Important")
- Sender avatar + name + "to me" row
- Tap "to me" → expands to show full From/To/Date/Subject header block
- Star button top right
- Timestamp

**Body:**
- Scrollable full body text
- "Show quoted text" toggle if body contains quoted reply (chevron button)
- Attachment chips at bottom with file icon, filename, size, and download tap (shows snackbar)

**Bottom Actions:**
- `Reply`, `Reply All`, `Forward` buttons in a row
- Each navigates to ComposeScreen pre-filled with appropriate data

---

#### 7. COMPOSE SCREEN — GMAIL PATTERN

Keep existing implementation and add:

- **"From" field** showing `user@mail.com` (static, non-editable)
- **Auto-complete** on the To field — filter mock contacts as user types, show dropdown suggestions
- **Signature** auto-appended at bottom of body: `--\nSent from MailFlow`
- **"Undo Send"** — on pressing Send:
  1. Show a 5-second countdown snackbar: `"Sending... Undo"`
  2. If Undo tapped → cancel send, return to compose
  3. If countdown completes → confirm send, show `"Email sent"` snackbar, pop screen
- **Auto-save draft** every 10 seconds while composing (save to mock drafts list)
- **Discard dialog** if user closes with unsaved changes:
  - Options: `"Save draft"`, `"Discard"`, `"Keep editing"`

---

#### 8. SEARCH SCREEN — GMAIL PATTERN

- Full-screen search with back arrow
- Search input auto-focused on open
- Recent searches list shown when input is empty (stored in memory)
- As user types → filter mock emails by sender name, subject, body preview
- Results shown in same email list tile format as inbox
- "No results" empty state with illustration
- Tapping a result opens EmailDetailScreen

---

#### 9. SETTINGS SCREEN

Static UI only (no functionality needed):

```
Account
  ├── Profile photo + name + email
  ├── Manage account (shows snackbar)

General
  ├── Default email action  →  Archive / Delete
  ├── Conversation view     →  On / Off toggle
  ├── Swipe actions         →  Configure (snackbar)

Notifications
  ├── Inbox notifications   →  toggle
  ├── Email notifications   →  toggle

Signature
  ├── Mobile signature      →  text field, pre-filled

About
  ├── App version           →  1.0.0
  ├── Privacy policy        →  snackbar
```

---

#### 10. EMPTY STATE SCREENS

Create a reusable `EmptyStateWidget` used across all folder screens:

```dart
EmptyStateWidget(
  icon: Icons.inbox_outlined,
  title: "Your inbox is empty",
  subtitle: "Emails will appear here",
)
```

- Centered icon (64px, muted color)
- Title in `textPrimary`, 18px, weight 500
- Subtitle in `muted`, 14px
- Used in: Starred, Sent, Trash, Search no-results

---

#### 11. OFFLINE / ERROR STATE

- Wrap inbox in error state: if mock fetch throws, show:
  - Red banner at top: `"No internet connection"`
  - Retry button
- Simulate occasional failure (10% chance) in mock data source to demonstrate error handling

---

#### 12. MOCK DATA

Create `MockEmailDataSource` with 20 realistic emails:

```dart
class MockEmailDataSource {
  static final List<EmailModel> _emails = [ ... ];  // 20 items

  Future<List<EmailModel>> fetchEmails({String folder = 'inbox'}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (Random().nextInt(10) == 0) throw Exception('Network error');
    return _emails.where((e) => e.folder == folder).toList();
  }

  Future<EmailModel> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _emails.firstWhere((e) => e.id == id);
  }
}
```

Email model fields:
```dart
class EmailModel {
  final String id;
  final String senderName;
  final String senderEmail;
  final String recipientEmail;
  final String subject;
  final String preview;
  final String fullBody;
  final DateTime timestamp;
  bool isRead;
  bool isStarred;
  bool isArchived;
  final String folder;       // inbox, sent, drafts, spam, trash
  final String category;     // primary, social, promotions
  final List<String> labels; // Work, Important, Personal
  final List<String> attachments;
}
```

Include mock emails from: GitHub, Notion, Vercel, Slack, teammates, newsletters — vary read/unread, starred, categories.

---

#### 13. RIVERPOD STATE — ALL PROVIDERS

```dart
// Auth
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>

// Emails — per folder
final emailsProvider = StateNotifierProvider.family<InboxNotifier, AsyncValue<List<Email>>, String>

// Selected email
final selectedEmailProvider = StateNotifierProvider<DetailNotifier, Email?>

// Search
final searchQueryProvider = StateProvider<String>
final searchResultsProvider = Provider<List<Email>>  // derived from emailsProvider

// Compose
final composeProvider = StateNotifierProvider<ComposeNotifier, ComposeState>

// Multi-select
final selectedEmailIdsProvider = StateNotifierProvider<SelectedIdsNotifier, Set<String>>

// Active folder
final activeFolderProvider = StateProvider<String>  // 'inbox', 'sent', etc.

// Unread counts
final unreadCountProvider = Provider<Map<String, int>>  // derived
```

---

#### 14. NAVIGATION

Use `Navigator`  as already implemented in the app:

Auth guard: redirect to `/login` if not authenticated.

---

#### 15. ANIMATIONS & POLISH

- **FAB** scale animation on shrink/expand (scroll listener)
- **Multi-select** avatar → checkbox with scale + rotate transition
- **Swipe actions** with colored background reveal (Dismissible with custom background)
- **Unread → read** transition: bold text fades to normal weight on tap
- **Compose** slides up from bottom (custom page route)
- **Search screen** fades in
- **Drawer** standard Material slide
- **Loading skeletons** on inbox initial load (shimmer-style alternating opacity)
- **Snackbars** always use `SnackBarBehavior.floating` with primary color action text

---

#### 16. PUBSPEC DEPENDENCIES

Add the following dependencies to your pubspec.yaml file for animations and swipe actions:

```yaml
dependencies:
  flutter_slidable: ^3.1.0    # swipe actions
  shimmer: ^3.0.0              # skeleton loading
```

---

