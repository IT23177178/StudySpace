
import SwiftUI
import SwiftData

// MARK: - Task date label

extension StudyTaskModel {
    var dueDateLabel: String {
        guard let dueDate = dueDate else {
            return "No due date"
        }

        if Calendar.current.isDateInToday(dueDate) {
            return "Due today"
        }

        if Calendar.current.isDateInTomorrow(dueDate) {
            return "Due tomorrow"
        }

        return "Due \(dueDate.formatted(date: .abbreviated, time: .omitted))"
    }

    var estimatedDurationLabel: String {
        if estimatedMinutes >= 60 && estimatedMinutes.isMultiple(of: 60) {
            return "\(estimatedMinutes / 60) hour\(estimatedMinutes == 60 ? "" : "s")"
        }

        return "\(estimatedMinutes) minutes"
    }
}

// MARK: - Home screen

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = StudyTaskViewModel()

    @Query(sort: \StudyTaskModel.title)
    private var tasks: [StudyTaskModel]
    

    @Query(
        sort: \EmergencyPlanModel.createdAt,
        order: .reverse
    )
    private var emergencyPlans: [EmergencyPlanModel]
    
    private var activeEmergencyPlans: [EmergencyPlanModel] {
        emergencyPlans.filter { plan in
            !plan.subtasks.isEmpty &&
            !plan.subtasks.allSatisfy { $0.isCompleted }
        }
    }

    @State private var showEmergencyTask = false
    

    @State private var showAddTask = false
    @State private var newTaskTitle = ""
    @State private var suggestedCategory = "Assignment"
    @State private var newTaskHasDueDate = false
    @State private var newTaskDueDate = Date.now
    @State private var newTaskDuration = 30

    private var incompleteTasks: [StudyTaskModel] {
        tasks.filter { !$0.isCompleted }
    }
    
    private var completedTaskCount: Int {
        tasks.filter { $0.isCompleted }.count % 20
    }

    private var recommendedTask: StudyTaskModel? {
        viewModel.recommendedTask(from: tasks)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {

                        // Welcome heading
                        VStack(alignment: .leading, spacing: 8) {
                            Text("STUDY SPACE")
                                .font(.caption.bold())
                                .tracking(1.5)
                                .foregroundStyle(AppTheme.secondaryText)

                            Text("Hello, Risini!")
                                .font(.largeTitle.bold())
                                .foregroundStyle(AppTheme.text)

                            Text("Small steps, big progress.")
                                .foregroundStyle(AppTheme.secondaryText)
                        }

                        // Task overview
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Your overview")
                                .font(.title3.bold())
                                .foregroundStyle(AppTheme.text)

                            HStack(spacing: 12) {
                                summaryCard(
                                    title: "To do",
                                    number: "\(incompleteTasks.count)"
                                )

                                summaryCard(
                                    title: "Completed",
                                    number: "\(completedTaskCount)"
                                )
                            }
                        }

                        // Recommended task
                        recommendationCard

                        // Task list
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Your tasks")
                                .font(.title2.bold())
                                .foregroundStyle(AppTheme.text)

                            if incompleteTasks.isEmpty {
                                Text("You're all caught up! Add another task whenever you're ready.")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                    .padding(16)
                                    .background(AppTheme.lightGrey)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 16)
                                    )
                            }

                            ForEach(incompleteTasks) { task in
                                AnimatedTaskRow(task: task)
                            }
                        }

                        // Saved emergency plans
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Emergency Plans")
                                .font(.title2.bold())
                                .foregroundStyle(AppTheme.text)

                            if activeEmergencyPlans.isEmpty {
                                Text("No emergency plans yet. Create one when you need a focused study plan.")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(16)
                                    .background(AppTheme.lightGrey)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                ForEach(activeEmergencyPlans) { plan in
                                    NavigationLink {
                                        EmergencyPlanDetailView(plan: plan)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(plan.title)
                                                .font(.headline)
                                                .foregroundStyle(AppTheme.text)

                                            Text(
                                                "\(plan.subtasks.filter { $0.isCompleted }.count) of \(plan.subtasks.count) subtasks completed"
                                            )
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.secondaryText)

                                            ProgressView(
                                                value: plan.subtasks.isEmpty
                                                    ? 0
                                                    : Double(
                                                        plan.subtasks.filter { $0.isCompleted }.count
                                                    ) / Double(plan.subtasks.count)
                                            )
                                            .tint(AppTheme.lilac)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                        .background(AppTheme.lightGrey)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        
                        // All tasks navigation
                        NavigationLink {
                            AllTasksView()
                        } label: {
                            Label(
                                "View all tasks",
                                systemImage: "list.bullet"
                            )
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.text)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.lightGrey)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                        }
                        
                        // Emergency Task Mode button
                        Button {
                            showEmergencyTask = true
                        } label: {
                            Label(
                                "Emergency Task Mode",
                                systemImage: "exclamationmark.triangle.fill"
                            )
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.text)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.lilac.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .sheet(isPresented: $showEmergencyTask) {
                            EmergencyTaskView()
                        }


                        // Add task button
                        Button {
                            addTask()
                        } label: {
                            Label("Add a task", systemImage: "plus")
                                .fontWeight(.semibold)
                                .foregroundStyle(AppTheme.text)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.lilac)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                        }
                    }
                    .padding(24)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddTask) {
                addTaskSheet
            }
        }
    }

    // MARK: - Recommendation card

    private var recommendationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppTheme.text)

                Text("RECOMMENDED FOR YOU")
                    .font(.caption.bold())
                    .tracking(1)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            if let task = recommendedTask {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.text)

                    Text(viewModel.recommendationReason(for: task))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Image(systemName: "clock")

                        Text(task.estimatedDurationLabel)

                        Text("•")

                        Text(task.dueDateLabel)
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.top, 2)
                }
                

                NavigationLink {
                    TaskDetailView(task: task)
                } label: {
                    HStack {
                        Text("View recommended task")

                        Spacer()

                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.text)
                    .padding(12)
                    .background(AppTheme.lilac.opacity(0.65))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }
                .buttonStyle(.plain)

            } else {
                Text("You're all caught up!")
                    .font(.headline)
                    .foregroundStyle(AppTheme.text)

                Text("Take a break or add a new task whenever you're ready.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.lightGrey)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.lilac, lineWidth: 1.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Overview card

    private func summaryCard(
        title: String,
        number: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(number)
                .font(.system(size: 30, weight: .bold))

            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .foregroundStyle(AppTheme.text)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.lightGrey)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Add task

    private func addTask() {
        newTaskTitle = ""
        suggestedCategory = "Assignment"
        newTaskHasDueDate = false
        newTaskDueDate = .now
        newTaskDuration = 30
        showAddTask = true
    }

    private var addTaskSheet: some View {
        NavigationStack {
            Form {
                Section("Task details") {
                    TextField(
                        "What do you need to do?",
                        text: $newTaskTitle
                    )
                    .onChange(of: newTaskTitle) { _, newValue in
                        suggestedCategory = viewModel.predictCategory(
                            for: newValue
                        )
                    }

                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Suggested category: \(suggestedCategory)")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)

                        Text("Choose a category")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.text)

                        Picker("Category", selection: $suggestedCategory) {
                            Text("Assignment").tag("Assignment")
                            Text("Revision").tag("Revision")
                            Text("Project").tag("Project")
                        }
                        .pickerStyle(.segmented)
                        .tint(AppTheme.lilac)
                    }


                    Picker(
                        "Estimated study time",
                        selection: $newTaskDuration
                    ) {
                        Text("15 minutes").tag(15)
                        Text("30 minutes").tag(30)
                        Text("1 hour").tag(60)
                        Text("2 hours").tag(120)
                    }
                    .tint(AppTheme.text)

                    Toggle(
                        "Set a due date",
                        isOn: $newTaskHasDueDate
                    )
                    .tint(.green)

                    if newTaskHasDueDate {
                        DatePicker(
                            "Due date",
                            selection: $newTaskDueDate,
                            in: Date.now...,
                            displayedComponents: .date
                        )
                        .tint(.blue)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("New task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddTask = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let title = newTaskTitle.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                        guard !title.isEmpty else {
                            return
                        }

                        do {
                            try viewModel.addTask(
                                title: title,
                                dueDate: newTaskHasDueDate
                                    ? newTaskDueDate
                                    : nil,
                                category: suggestedCategory,
                                estimatedMinutes: newTaskDuration,
                                modelContext: modelContext
                            )

                            showAddTask = false
                        } catch {
                            print("SAVE ERROR: \(error)")
                        }
                    }
                    .disabled(
                        newTaskTitle.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
            .tint(AppTheme.text)
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Animated task row

struct AnimatedTaskRow: View {
    @Bindable var task: StudyTaskModel

    @State private var showConfetti = false

    var body: some View {
        HStack(spacing: 14) {
            Button(action: completeTask) {
                ZStack {
                    Image(
                        systemName: task.isCompleted
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(.title2)
                    .foregroundStyle(
                        task.isCompleted
                            ? AppTheme.text
                            : AppTheme.secondaryText
                    )

                    ForEach(0..<8, id: \.self) { index in
                        let angle = Double(index) * .pi / 4

                        Circle()
                            .fill(Color(hex: "D2AFFF"))
                            .frame(width: 6, height: 6)
                            .offset(
                                x: showConfetti
                                    ? CGFloat(cos(angle)) * 24
                                    : 0,
                                y: showConfetti
                                    ? CGFloat(sin(angle)) * 24
                                    : 0
                            )
                            .opacity(showConfetti ? 1 : 0)
                            .scaleEffect(showConfetti ? 1 : 0.2)
                    }
                }
                .frame(width: 42, height: 42)
                .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                task.isCompleted
                    ? "Mark \(task.title) incomplete"
                    : "Complete \(task.title)"
            )

            NavigationLink {
                TaskDetailView(task: task)
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(
                            task.isCompleted
                                ? AppTheme.secondaryText
                                : AppTheme.text
                        )

                    Text("\(task.category) • \(task.estimatedDurationLabel)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)

                    Text(task.dueDateLabel)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.lightGrey.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(task.isCompleted ? 0.7 : 1)
        .animation(.easeInOut(duration: 0.25), value: task.isCompleted)
    }

    private func completeTask() {
        if task.isCompleted {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                task.isCompleted = false
            }
            return
        }

        withAnimation(.easeOut(duration: 0.18)) {
            showConfetti = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                task.isCompleted = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showConfetti = false
                }
            }
        }
    }
}

// MARK: - Task details

struct TaskDetailView: View {
    @Bindable var task: StudyTaskModel

    @Environment(\.dismiss) private var dismiss

    private var dueDateBinding: Binding<Date> {
        Binding(
            get: { task.dueDate ?? .now },
            set: { task.dueDate = $0 }
        )
    }

    private var hasDueDate: Binding<Bool> {
        Binding(
            get: { task.dueDate != nil },
            set: { enabled in
                if enabled {
                    task.dueDate = task.dueDate ?? .now
                } else {
                    task.dueDate = nil
                }
            }
        )
    }

    var body: some View {
        Form {
            Section("Task details") {
                TextField("Task name", text: $task.title)

                Picker(
                    "Estimated study time",
                    selection: $task.estimatedMinutes
                ) {
                    Text("15 minutes").tag(15)
                    Text("30 minutes").tag(30)
                    Text("1 hour").tag(60)
                    Text("2 hours").tag(120)
                }

                Toggle("Set a due date", isOn: hasDueDate)
                    .tint(.green)

                if task.dueDate != nil {
                    DatePicker(
                        "Due date",
                        selection: dueDateBinding,
                        in: Date.now...,
                        displayedComponents: .date
                    )
                    .tint(.blue)
                }

                Toggle("Completed", isOn: $task.isCompleted)
            }

            Section {
                Text("Take it one step at a time. You're doing your best.")
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle("Task details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
                .tint(AppTheme.text)
            }
        }
    }
}
