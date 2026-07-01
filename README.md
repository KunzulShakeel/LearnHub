# EduNova Portal 📚

A modern multi-screen Flutter application developed for Mobile Application Development coursework.

## 👨‍🎓 Student Information

- **Name:** Kunzul Shakeel
- **Project:** EduNova Portal
- **Technology:** Flutter & Dart

---

## 🚀 Features

### 🔐 Authentication System
- User Registration
- Login Screen
- Remember Me Checkbox
- Show/Hide Password
- Form Validation
- Logout Functionality

### 📋 Registration Validation
- First Name Validation
- Last Name Validation
- Email Validation
- Password Security Rules
- Confirm Password Validation
- Gender Dropdown Selection

### 📚 Dashboard
- User Welcome Section
- Subject List
- Subject Navigation
- Dynamic Subject Cards

### 📖 Subject Detail Screen
- Subject Description
- Schedule Information
- Subject Banner UI

---

## 🧠 Subjects Included

- Mobile App Development
- Software Re-engineering
- Management Information Systems (MIS)

---

## 🛠 Technologies Used

- Flutter
- Dart
- Material Design
- Stateful Widgets
- Navigation
- Form Validation

---

## 📂 Project Structure

```text
lib
├── controllers
│   └── auth_controller.dart
├── enums
│   └── app_enums.dart          # includes ApiStatus (loading/success/error)
├── models
│   ├── course_model.dart       # NEW: Course model (API)
│   ├── subject_model.dart
│   └── user_model.dart
├── services
│   └── course_service.dart     # NEW: API service layer (GET/POST/PUT/DELETE)
├── screens
│   ├── course_form_screen.dart # NEW: Add/Edit course form
│   ├── courses_screen.dart     # NEW: Course list + CRUD UI
│   ├── dashboard_screen.dart
│   ├── detail_screen.dart
│   ├── login_screen.dart
│   └── register_screen.dart
├── validators
│   └── app_validator.dart
└── main.dart
```

---

## 📱 Screenshots

### Login Screen
![Login](screenshot/login.png)

### Registration Screen
![Register](screenshot/register.png)

### Dashboard Screen
![Dashboard](screenshot/Dashboard.png)

### Subject Detail Screen
![Detail](screenshot/subjectdetail.png)

### Courses (Live API) — Add screenshots below after running the app
![Courses List](screenshot/courses_list.png)
![Add Course](screenshot/add_course.png)
![Edit Course](screenshot/edit_course.png)
![Delete Confirmation](screenshot/delete_course.png)

> ⚠️ The four Course screenshots above are placeholders. Run the app
> (`flutter run`), navigate to **Dashboard → Courses (Live API)**, capture the
> list, add, edit, and delete-confirmation screens, and save them into the
> `screenshot/` folder using the filenames above (or update the paths here).

---

## 💡 Assignment Requirements Covered

✅ Registration Screen  
✅ Login Screen  
✅ Dashboard Screen  
✅ Detail Screen  
✅ Form Validation  
✅ Custom Validator Class  
✅ Enum Implementation  
✅ Controller Layer  
✅ Navigation & Data Passing  
✅ Multi-Screen Flutter UI  

---

## 🌐 REST API Integration (CRUD)

### API Used
**JSONPlaceholder** — a free fake REST API for testing/prototyping.
- Base URL: `https://jsonplaceholder.typicode.com`
- Resource used: `/posts` (mapped to "Course" records — `title` → course
  title, `body` → course description, `id` → course id)

### Documentation Followed
https://jsonplaceholder.typicode.com/guide

### Branch
All API/CRUD work for this assignment was completed on:
```
feature/course-api-integration
```

### What Was Implemented

| Operation | HTTP Method | Endpoint             | Where it's called from                     |
|-----------|-------------|-----------------------|---------------------------------------------|
| Read      | GET         | `/posts?_limit=10`    | `CourseService.fetchCourses()`               |
| Create    | POST        | `/posts`              | `CourseService.addCourse()`                  |
| Update    | PUT         | `/posts/:id`          | `CourseService.updateCourse()`               |
| Delete    | DELETE      | `/posts/:id`          | `CourseService.deleteCourse()`               |

### Architecture

- **Service layer (`lib/services/course_service.dart`)** — owns all
  `http` calls and JSON encoding/decoding. The UI never calls `http`
  directly.
- **Model (`lib/models/course_model.dart`)** — `CourseModel.fromJson` /
  `toJson` map between the API's `title`/`body` fields and the app's
  course concept.
- **UI (`lib/screens/courses_screen.dart` and
  `lib/screens/course_form_screen.dart`)** — `CoursesScreen` handles the
  list, loading/error states, refresh, and delete confirmation dialogs.
  `CourseFormScreen` is a single reusable form used for both Add and Edit
  (pre-filled with existing data when editing).

### State Handling

`CoursesScreen` tracks an `ApiStatus` (`loading` / `success` / `error`):
- **Loading** → centered `CircularProgressIndicator` while the initial GET
  request is in flight.
- **Success** → scrollable, pull-to-refresh list of courses.
- **Error** → error message with a **Retry** button.
- Per-row mutations (edit/delete) show an inline spinner on just that row
  and a success/error `SnackBar` when the request completes.

### How to Try It

1. `flutter pub get`
2. `flutter run`
3. Log in (any non-empty email/password) → **Dashboard** →
   **Courses (Live API)** card.
4. Use the **+** button to add a course, tap **✎** to edit, tap **🗑** to
   delete (with confirmation).

> Note: JSONPlaceholder is a mock API — it does not persist data on its
> server. POST/PUT/DELETE requests are real network calls and return
> realistic responses, but a fresh GET will still return the original
> seed data. The app therefore updates its local in-memory list optimistically
> after each successful response so CRUD is fully visible in the UI.

---

## 👨‍💻 Developer

Kunzul Shakeel