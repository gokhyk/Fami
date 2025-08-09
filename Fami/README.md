
# Family Task Coordinator — SwiftUI + Firebase Starter

A minimal SwiftUI starter using a Repository Pattern with a Firestore-backed implementation.

## Included Files
- `FamilyTaskApp.swift` — App entry point, configures Firebase, injects repo+VM
- `Models.swift` — Data models (`ToDoItem`, `Family`)
- `Repository.swift` — `TaskRepository` protocol + `FirestoreTaskRepository`
- `TaskViewModel.swift` — `@MainActor` view model
- `TaskRowView.swift`, `NewTaskView.swift`, `TaskListView.swift` — UI

## Setup (Xcode)
1. Create a Firebase project at console.firebase.google.com
2. Register your iOS app bundle ID
3. Add `GoogleService-Info.plist` to your Xcode project
4. Add Swift Package: `https://github.com/firebase/firebase-ios-sdk`
5. Link products: **FirebaseFirestore**, **FirebaseFirestoreSwift**

## Run
- Open `FamilyTaskApp.swift` and set `activeFamilyId` if needed.
- Build & run; add tasks with the + button.

## Notes
- Firestore rules are not included.
- Tasks are filtered by `familyId` and ordered by `createdAt`.
