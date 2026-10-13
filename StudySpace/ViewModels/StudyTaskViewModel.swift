//
//  StudyTaskViewModel.swift
//  StudySpace
//
//  Created by Risini Senara on 2026-10-11.
//



import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class StudyTaskViewModel {

    // MARK: - Predict task category

    func predictCategory(for title: String) -> String {
        let cleanedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedTitle.isEmpty else {
            return "Assignment"
        }

        do {
            let predictor = try TaskCategoryPredictor()
            return try predictor.predictCategory(for: cleanedTitle)
        } catch {
            return "Assignment"
        }
    }

    // MARK: - Add task

    func addTask(
        title: String,
        dueDate: Date?,
        category: String,
        estimatedMinutes: Int,
        modelContext: ModelContext
    ) throws {
        let cleanedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedTitle.isEmpty else {
            return
        }

        let task = StudyTaskModel(
            title: cleanedTitle,
            dueDate: dueDate,
            category: category,
            estimatedMinutes: estimatedMinutes
        )

        modelContext.insert(task)
        try modelContext.save()
    }

    // MARK: - Recommend a task

    func recommendedTask(
        from tasks: [StudyTaskModel]
    ) -> StudyTaskModel? {

        let incompleteTasks = tasks.filter {
            !$0.isCompleted
        }

        return incompleteTasks.sorted { first, second in

            // Tasks with deadlines come first.
            if let firstDate = first.dueDate,
               let secondDate = second.dueDate {

                if !Calendar.current.isDate(
                    firstDate,
                    inSameDayAs: secondDate
                ) {
                    return firstDate < secondDate
                }

            } else if first.dueDate != nil {
                return true
            } else if second.dueDate != nil {
                return false
            }

            // For similar deadlines, encourage starting
            // longer projects early.
            let firstIsLongProject =
                first.category == "Project" &&
                first.estimatedMinutes >= 60

            let secondIsLongProject =
                second.category == "Project" &&
                second.estimatedMinutes >= 60

            if firstIsLongProject != secondIsLongProject {
                return firstIsLongProject
            }

            // Otherwise, prefer a manageable task.
            return first.estimatedMinutes < second.estimatedMinutes
        }.first
    }

    // MARK: - Recommendation explanation

    func recommendationReason(
        for task: StudyTaskModel
    ) -> String {

        if let dueDate = task.dueDate {
            let today = Calendar.current.startOfDay(for: .now)
            let deadline = Calendar.current.startOfDay(
                for: dueDate
            )

            let daysUntilDue = Calendar.current.dateComponents(
                [.day],
                from: today,
                to: deadline
            ).day ?? 0

            if daysUntilDue < 0 {
                return "This task is overdue, so it may need attention."
            }

            if daysUntilDue <= 1 {
                return "This task is due soon, so consider focusing on it first."
            }
        }

        if task.category == "Project" &&
            task.estimatedMinutes >= 60 {
            return "Starting this longer project early can make it easier to manage."
        }

        if task.estimatedMinutes <= 30 {
            return "A manageable task can help you get started."
        }

        return "This looks like a useful next step based on its deadline and study time."
    }
}
