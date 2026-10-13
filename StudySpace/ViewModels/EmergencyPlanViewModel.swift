//
//  EmergencyPlanViewModel.swift
//  StudySpace
//
//  Created by Risini Senara on 2026-10-11.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class EmergencyPlanViewModel {

    func createEmergencyPlan(
        title: String,
        dueDate: Date,
        estimatedTotalMinutes: Int,
        availableMinutes: Int,
        taskDescription: String?,
        modelContext: ModelContext
    ) throws {

        let cleanedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedTitle.isEmpty else { return }

        let cleanedDescription = taskDescription?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let plan = EmergencyPlanModel(
            title: cleanedTitle,
            dueDate: dueDate,
            estimatedTotalMinutes: estimatedTotalMinutes,
            availableMinutes: availableMinutes,
            taskDescription: cleanedDescription
        )

        let subtasks = generateSubtasks(
            for: cleanedTitle,
            description: cleanedDescription,
            estimatedMinutes: estimatedTotalMinutes
        )

        plan.subtasks = subtasks

        modelContext.insert(plan)
        try modelContext.save()
    }

    func workloadWarning(
        estimatedMinutes: Int,
        availableMinutes: Int
    ) -> String? {

        if estimatedMinutes > availableMinutes {
            return "Your workload exceeds your available time. Prioritise the most important tasks."
        }

        return nil
    }

    // Generate activities from the user's description
    func generateSubtasks(
        for title: String,
        description: String?,
        estimatedMinutes: Int
    ) -> [EmergencySubtaskModel] {

        let text = (description ?? "").trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // Split activities at common separators
        let preparedText = text.replacingOccurrences(
            of: " and ",
            with: ",",
            options: .caseInsensitive
        )

        let activities = preparedText
            .components(
                separatedBy: CharacterSet(
                    charactersIn: ",;.\n"
                )
            )
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter { !$0.isEmpty }

        let tasks = activities.isEmpty ? [title] : activities

        // Order prerequisite activities before later work
        let orderedTasks = tasks.enumerated().sorted {
            let firstPriority = orderPriority($0.element)
            let secondPriority = orderPriority($1.element)

            if firstPriority == secondPriority {
                return $0.offset < $1.offset
            }

            return firstPriority < secondPriority
        }.map { $0.element }

        // Estimate the relative effort of each activity
        let weights = orderedTasks.map {
            durationWeight(for: $0)
        }

        let totalWeight = weights.reduce(0, +)

        // Distribute the total workload proportionally
        var taskMinutes = weights.map { weight in
            max(
                0,
                Int(
                    (
                        Double(max(0, estimatedMinutes))
                        * Double(weight)
                        / Double(totalWeight)
                    ).rounded(.down)
                )
            )
        }

        // Ensure task estimates add up to the total workload
        let remainingMinutes = max(0, estimatedMinutes)
            - taskMinutes.reduce(0, +)

        if remainingMinutes > 0 {
            for index in 0..<remainingMinutes {
                taskMinutes[index] += 1
            }
        }

        return orderedTasks.enumerated().map { index, activity in
            EmergencySubtaskModel(
                title: activity,
                estimatedMinutes: taskMinutes[index],
                priority: index < 3 ? "High" : "Medium",
                order: index
            )
        }
    }

    // Preparation comes before implementation and submission
    private func orderPriority(_ activity: String) -> Int {

        let text = activity.lowercased()

        if containsAny(
            text,
            ["collect", "gather", "download", "obtain", "find images",
             "find data", "research", "requirements", "prepare data"]
        ) {
            return 0
        }

        if containsAny(
            text,
            ["plan", "design", "setup", "set up", "install",
             "organise", "organize", "prepare environment"]
        ) {
            return 1
        }

        if containsAny(
            text,
            ["create", "build", "develop", "implement", "code",
             "process", "processing", "train", "analyse", "analyze"]
        ) {
            return 2
        }

        if containsAny(
            text,
            ["test", "debug", "review", "check", "evaluate"]
        ) {
            return 3
        }

        if containsAny(
            text,
            ["report", "document", "write-up", "write up",
             "presentation", "slides"]
        ) {
            return 4
        }

        if containsAny(
            text,
            ["upload", "submit", "submission", "finalise",
             "finalize"]
        ) {
            return 5
        }

        return 2
    }

    // Relative effort weights, not fixed task durations
    private func durationWeight(for activity: String) -> Int {

        let text = activity.lowercased()

        if containsAny(
            text,
            ["collect", "gather", "download", "obtain", "find images"]
        ) {
            return 1
        }

        if containsAny(
            text,
            ["upload", "submit", "submission"]
        ) {
            return 1
        }

        if containsAny(
            text,
            ["research", "plan", "review", "check", "test", "debug"]
        ) {
            return 2
        }

        if containsAny(
            text,
            ["report", "document", "presentation", "slides"]
        ) {
            return 3
        }

        if containsAny(
            text,
            ["create", "build", "develop", "implement", "process",
             "processing", "code", "train"]
        ) {
            return 4
        }

        return 2
    }

    private func containsAny(
        _ text: String,
        _ keywords: [String]
    ) -> Bool {

        keywords.contains { text.contains($0) }
    }
}

