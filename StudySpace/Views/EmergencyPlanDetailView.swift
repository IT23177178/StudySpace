//
//  EmergencyPlanDetailView.swift
//  StudySpace
//
//  Created by Risini Senara on 2026-10-11.
//

import SwiftUI
import SwiftData

struct EmergencyPlanDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @Bindable var plan: EmergencyPlanModel

    private var completedCount: Int {
        plan.subtasks.filter { $0.isCompleted }.count
    }

    private var progress: Double {
        guard !plan.subtasks.isEmpty else { return 0 }

        return Double(completedCount) / Double(plan.subtasks.count)
    }

    var body: some View {
        List {
            Section("Assignment") {
                Text(plan.title)
                    .font(.headline)

                Label {
                    Text(
                        plan.dueDate.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                } icon: {
                    Image(systemName: "calendar")
                }

                LabeledContent(
                    "Estimated workload",
                    value: "\(plan.estimatedTotalMinutes / 60) hr \(plan.estimatedTotalMinutes % 60) min"
                )

                LabeledContent(
                    "Available time",
                    value: "\(plan.availableMinutes / 60) hr \(plan.availableMinutes % 60) min"
                )
            }

            Section("Your Progress") {
                ProgressView(value: progress)

                Text(
                    "\(completedCount) of \(plan.subtasks.count) subtasks completed"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if plan.estimatedTotalMinutes > plan.availableMinutes {
                    Label(
                        "Your workload exceeds your available time. Focus on the most important work first.",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                }
            }

            Section("Your Subtasks") {
                ForEach(
                    plan.subtasks.sorted { $0.order < $1.order }
                ) { subtask in
                    Button {
                        subtask.isCompleted.toggle()
                        try? modelContext.save()
                    } label: {
                        HStack(spacing: 12) {
                            Image(
                                systemName: subtask.isCompleted
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .font(.title3)
                            .foregroundStyle(
                                subtask.isCompleted ? AppTheme.lilac : Color.secondary
                            )
                            VStack(alignment: .leading, spacing: 6) {
                                Text(subtask.title)
                                    .font(.body)
                                    .foregroundStyle(
                                        subtask.isCompleted
                                            ? .secondary
                                            : .primary
                                    )
                                    .strikethrough(subtask.isCompleted)

                                HStack {
                                    Text("\(subtask.estimatedMinutes) min")
                                    Text("•")
                                    Text(subtask.priority + " priority")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

        }
        .navigationTitle("Emergency Plan")
        .navigationBarTitleDisplayMode(.inline)
    }
}
