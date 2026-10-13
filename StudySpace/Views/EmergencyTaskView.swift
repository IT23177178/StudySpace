//
//  EmergencyTaskView.swift
//  StudySpace
//
//  Created by Risini Senara on 2026-10-11.
//

import SwiftUI
import SwiftData

struct EmergencyTaskView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = EmergencyPlanViewModel()

    @State private var assignmentTitle = ""
    @State private var assignmentDescription = ""
    @State private var dueDate = Calendar.current.date(
        byAdding: .day,
        value: 1,
        to: .now
    ) ?? .now

    @State private var estimatedHours = 3
    @State private var estimatedMinutes = 0
    @State private var availableHours = 2
    @State private var availableMinutes = 0

    @State private var errorMessage: String?

    private var totalEstimatedMinutes: Int {
        estimatedHours * 60 + estimatedMinutes
    }

    private var totalAvailableMinutes: Int {
        availableHours * 60 + availableMinutes
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Assignment Details") {
                    TextField(
                        "Assignment name",
                        text: $assignmentTitle
                    )
                    
                    TextField(
                        "Describe the work (optional)",
                        text: $assignmentDescription,
                        axis: .vertical
                    )
                    .lineLimit(3...6)

                    DatePicker(
                        "Deadline",
                        selection: $dueDate,
                        in: Date.now...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Estimated Workload") {
                    Picker("Hours", selection: $estimatedHours) {
                        ForEach(0..<25, id: \.self) { hour in
                            Text("\(hour) hr")
                                .tag(hour)
                        }
                    }

                    Picker("Minutes", selection: $estimatedMinutes) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text("\(minute) min")
                                .tag(minute)
                        }
                    }
                }

                Section("Time Available") {
                    Picker("Hours", selection: $availableHours) {
                        ForEach(0..<25, id: \.self) { hour in
                            Text("\(hour) hr")
                                .tag(hour)
                        }
                    }

                    Picker("Minutes", selection: $availableMinutes) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text("\(minute) min")
                                .tag(minute)
                        }
                    }
                }

                if let warning = viewModel.workloadWarning(
                    estimatedMinutes: totalEstimatedMinutes,
                    availableMinutes: totalAvailableMinutes
                ) {
                    Section {
                        Label(
                            warning,
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(.orange)
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        saveEmergencyPlan()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Generate Emergency Plan")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(
                        assignmentTitle
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                        || totalEstimatedMinutes == 0
                        || totalAvailableMinutes == 0
                    )
                }
            }
            .navigationTitle("Emergency Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveEmergencyPlan() {
        do {
            try viewModel.createEmergencyPlan(
                title: assignmentTitle,
                dueDate: dueDate,
                estimatedTotalMinutes: totalEstimatedMinutes,
                availableMinutes: totalAvailableMinutes,
                taskDescription: assignmentDescription
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
                    ? nil
                    : assignmentDescription.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                modelContext: modelContext
            )

            dismiss()
        } catch {
            errorMessage = "Couldn't save the plan. Please try again."
        }
    }
}

