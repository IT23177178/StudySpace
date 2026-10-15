# StudySpace

### A SwiftUI Task Planner Designed to Make Workloads More Manageable

**Student Name:** WPR Senara  
**Student ID:** IT23177178  
**Module:** SE4041 – Mobile Application Design and Development  
**Lecturer:** Mr. Nushkan Nismi  
**Submission Date:** 13 October 2026

---

## 1. Project Overview

StudySpace is a native iOS task-planning application developed using SwiftUI. It is designed to help users manage responsibilities, reduce feelings of overwhelm, and approach their workload one step at a time.

The application allows users to create tasks, track deadlines, estimate task durations, receive machine-learning-based category suggestions, and view recommendations about what to work on next. An additional Emergency Task Mode helps users break larger, urgent responsibilities into smaller activities.

StudySpace combines a minimal interface with persistent local storage and simple, explainable planning logic to provide a calm and supportive task-management experience.

## 2. Key Features

- **Task Management:** Create tasks with titles, categories, optional due dates, and estimated durations.
- **Task Completion:** Mark tasks as completed and receive visual feedback.
- **Task Categories:** Organize tasks into Assignment, Revision, and Project categories.
- **Machine-Learning Suggestions:** Predict a suitable task category from its title using a trained Core ML classifier.
- **Task Recommendations:** Recommend tasks using completion status, deadlines, and estimated duration.
- **Emergency Task Mode:** Break urgent, larger responsibilities into smaller activities and estimate their workload.
- **Workload Warnings:** Highlight situations where estimated workload exceeds the available time.
- **Persistent Storage:** Save tasks and emergency plans locally using SwiftData.
- **Minimal User Interface:** Use a calm lavender accent, neutral backgrounds, rounded cards, and subtle completion animations.

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Swift | Main programming language |
| SwiftUI | User interface and navigation |
| SwiftData | Local data persistence |
| Core ML | Running the trained classification model |
| Create ML | Training the task-category classifier |
| MVVM | Organizing application responsibilities |
| Xcode | Development, building, and debugging |
| Git and GitHub | Version control and repository hosting |

## 4. Application Architecture

StudySpace follows the Model–View–ViewModel (MVVM) architectural pattern, separating data models, interface components, application logic, and machine-learning services.

### Models
- `StudyTaskModel.swift` — Represents individual tasks, including titles, deadlines, completion states, categories, and estimated durations.
- `EmergencyPlanModel.swift` — Stores emergency-plan information, deadlines, workload estimates, and progress.
- `EmergencySubtaskModel.swift` — Represents activities generated within an emergency plan.

### Views
- `ContentView.swift` — Home screen, task creation, recommendations, and main task interactions.
- `AllTasksView.swift` — Displays tasks and supports category filtering.
- `EmergencyTaskView.swift` — Collects information for an emergency plan.
- `EmergencyPlanDetailView.swift` — Displays an emergency plan and tracks subtask completion.
- `AppTheme.swift` — Defines shared colours and visual styling.
- `MyApp.swift` — Application entry point and data-container configuration.

### ViewModels
- `StudyTaskViewModel.swift` — Handles task creation, category prediction, recommendations, and recommendation explanations.
- `EmergencyPlanViewModel.swift` — Handles emergency-plan creation, activity generation, time allocation, and workload warnings.

### Services
- `TaskCategoryPredictor.swift` — Connects the application to the trained Core ML classification model.

*Note: The file names above describe the intended project organization. Refer to the actual repository for the current source files.*

## 5. Machine-Learning Implementation

StudySpace uses a text-classification model trained with Create ML to suggest a category based on a task title.

The classifier supports three categories:

- Assignment
- Revision
- Project

### Prediction workflow

1. The user enters a task title.
2. The application sends the title to the prediction service.
3. The Core ML model processes the text.
4. The model returns a predicted category.
5. The application displays the category suggestion.
6. A fallback category of `Assignment` is used when prediction cannot be completed.

During development, the phrase `Revise Swift lecture notes` produced a recorded prediction of 91% Revision, 5% Assignment, and 4% Project.

This is an example prediction, not a measurement of overall model accuracy. The classifier should be evaluated using held-out test data to determine its overall accuracy and per-category performance.

Training and evaluation resources include:

- `TrainingData.csv`
- `ValidationData.csv`
- `TestingData.csv`

## 6. Task Recommendation Logic

The recommendation system uses rule-based logic to help users decide what to work on next.

The general selection process is:

1. Exclude completed tasks.
2. Prioritize tasks with deadlines.
3. Prefer earlier deadlines.
4. When deadlines are comparable, prioritize longer projects with estimated durations of at least 60 minutes.
5. Otherwise, prefer shorter tasks that may be easier to complete.

Recommendations can include explanations relating to overdue work, approaching deadlines, starting larger projects early, or completing a manageable task.

The current algorithm does not fully account for assessment weighting, personal importance, task dependencies, or calendar availability.

## 7. Emergency Task Mode

Emergency Task Mode helps users approach larger, urgent responsibilities by dividing them into smaller activities.

The workflow collects information such as the task title, optional description, deadline, estimated workload, and available time.

The application uses keyword-based rules to identify broad stages, such as:

- Preparation
- Implementation
- Testing
- Documentation
- Submission

It then estimates activity durations, assigns priorities, and warns the user when the estimated workload exceeds the available time.

Generated activities are intended as a starting point for planning. Because the system relies on keyword rules rather than a full understanding of the task instructions, users should review the generated activities and their estimates.

## 8. User Interface Design

StudySpace uses a minimal design inspired by the visual style of built-in iOS applications.

- **Primary accent:** Lavender (`#E6D7FF`)
- **Completion animation accent:** Lavender (`#D2AFFF`)
- **Interface style:** Neutral backgrounds, rounded cards, and restrained visual emphasis.

The design focuses on reducing visual clutter, making progress visible, providing familiar navigation, and presenting recommendations as helpful guidance rather than strict instructions.

## 9. Getting Started

### Prerequisites

- A compatible version of macOS
- Xcode
- An iOS simulator or compatible iOS device

### Installation

1. Clone or download this repository:

   ```bash
   git clone https://github.com/IT23177178/StudySpace.git
   ```

2. Open the project directory.

3. Open `StudySpace copy.xcodeproj` in Xcode.

4. Confirm that the required Core ML model resources are included in the project target.

5. Select a compatible simulator or connected iOS device.

6. Build and run the application.

The deployment target and device requirements can be checked in the Xcode project settings.

## 10. Testing

Testing should cover the main application workflows, including:

- Building and launching the application.
- Creating tasks and validating required fields.
- Setting deadlines and estimated durations.
- Completing tasks and checking visual feedback.
- Opening task details and filtering the task list.
- Checking category predictions and fallback behaviour.
- Verifying task recommendations.
- Creating emergency plans and generating subtasks.
- Checking workload warnings and time allocation.
- Confirming that saved data remains available after relaunching the application.

The classifier should be evaluated separately using the held-out testing dataset. Final test results should be documented only after the corresponding tests have been performed.

## 11. Limitations

The current implementation has several limitations:

- The classifier supports only Assignment, Revision, and Project categories.
- Category predictions depend on the training examples and may be incorrect for unfamiliar task titles.
- Task recommendations do not currently incorporate assessment weighting or every user's personal priorities.
- Emergency-plan generation relies on keyword-based rules and may not accurately interpret complex instructions.
- Further systematic testing is needed to confirm end-to-end behaviour and measure classifier performance.

## 12. Future Improvements

Potential improvements include:

1. Adding assessment weighting and personal importance to task recommendations.
2. Evaluating and improving the classifier using held-out test data.
3. Allowing users to edit generated emergency activities, priorities, and durations.
4. Expanding support for user-defined task categories.
5. Improving accessibility and verifying layouts across different device sizes.
6. Adding more comprehensive tests for persistence, deadlines, and recommendation logic.

## 13. Repository

GitHub repository:  
https://github.com/IT23177178/StudySpace

## 14. References

- [Apple Developer — SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Apple Developer — SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Apple Developer — Core ML Documentation](https://developer.apple.com/documentation/coreml)
- [Apple Developer — Create ML Documentation](https://developer.apple.com/documentation/createml)

---

**StudySpace** — Helping users make progress, one task at a time.
