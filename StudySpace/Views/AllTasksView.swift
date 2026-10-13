
import SwiftUI
import SwiftData
import Foundation

struct AllTasksView: View {
    @Query(sort: \StudyTaskModel.title)
    private var tasks: [StudyTaskModel]

    @State private var selectedFilter = "All"

    private let filters = [
        "All",
        "Assignment",
        "Revision",
        "Project"
    ]

    // MARK: - Filter tasks

    private var filteredTasks: [StudyTaskModel] {
        if selectedFilter == "All" {
            return tasks
        }

        return tasks.filter {
            $0.category == selectedFilter
        }
    }

    // MARK: - Main view

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    // Heading
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ALL TASKS")
                            .font(.caption.bold())
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.secondaryText)

                        Text("Your study planner")
                            .font(.largeTitle.bold())
                            .foregroundStyle(AppTheme.text)

                        Text("\(tasks.count) tasks in total")
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    // Category filters
                    ScrollView(
                        .horizontal,
                        showsIndicators: false
                    ) {
                        HStack(spacing: 10) {
                            ForEach(filters, id: \.self) { filter in
                                Button {
                                    withAnimation(
                                        .easeInOut(duration: 0.2)
                                    ) {
                                        selectedFilter = filter
                                    }
                                } label: {
                                    Text(filter)
                                        .font(
                                            .subheadline.weight(.semibold)
                                        )
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .foregroundStyle(
                                            selectedFilter == filter
                                                ? AppTheme.text
                                                : AppTheme.secondaryText
                                        )
                                        .background(
                                            selectedFilter == filter
                                                ? AppTheme.lilac
                                                : AppTheme.lightGrey
                                        )
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Task list
                    VStack(alignment: .leading, spacing: 12) {
                        Text(
                            selectedFilter == "All"
                                ? "Every task"
                                : selectedFilter + " tasks"
                        )
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.text)

                        if filteredTasks.isEmpty {
                            Text(
                                "No tasks here yet. Add a task to get started!"
                            )
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .padding(18)
                            .background(AppTheme.lightGrey)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                        } else {
                            ForEach(filteredTasks) { task in
                                AllTasksTaskRow(task: task)
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("All Tasks")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Individual task row

private struct AllTasksTaskRow: View {
    @Bindable var task: StudyTaskModel

    @State private var showConfetti = false

    private let particleCount = 12

    var body: some View {
        HStack(spacing: 12) {

            // Completion button with lilac confetti
            Button {
                completeTask()
            } label: {
                ZStack {
                    ForEach(0..<particleCount, id: \.self) { index in
                        let angle =
                            Double(index) * 2 * Double.pi
                            / Double(particleCount)

                        Circle()
                            .fill(
                                Color(
                                    red: 0.82,
                                    green: 0.69,
                                    blue: 1.0
                                )
                            )
                            .frame(width: 6, height: 6)
                            .offset(
                                x: showConfetti
                                    ? 30 * cos(angle) : 0,
                                y: showConfetti
                                    ? 30 * sin(angle) : 0
                            )
                            .opacity(showConfetti ? 1 : 0)
                            .scaleEffect(showConfetti ? 0.3 : 1)
                    }

                    Image(
                        systemName: task.isCompleted
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(.title3)
                    .foregroundStyle(
                        task.isCompleted
                            ? AppTheme.secondaryText
                            : AppTheme.text
                    )
                    .scaleEffect(task.isCompleted ? 1.15 : 1.0)
                    .contentTransition(.symbolEffect(.replace))
                }
                .frame(width: 42, height: 42)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Task details
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

                    Text(task.category)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.secondaryText)

                    Text(task.dueDateLabel)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(AppTheme.lightGrey.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Complete task

    private func completeTask() {
        if task.isCompleted {
            withAnimation(
                .spring(response: 0.3, dampingFraction: 0.6)
            ) {
                task.isCompleted = false
            }
            return
        }

        showConfetti = true

        withAnimation(
            .spring(response: 0.3, dampingFraction: 0.6)
        ) {
            task.isCompleted = true
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.5
        ) {
            showConfetti = false
        }
    }
}
