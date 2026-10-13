//
//  EmergencyPlanModel.swift
//  StudySpace
//
//  Created by Risini Senara on 2026-10-11.
//

import Foundation
import SwiftData

@Model
final class EmergencyPlanModel {
    var title: String
    var dueDate: Date
    var estimatedTotalMinutes: Int
    var availableMinutes: Int
    var completedMinutes: Int
    var createdAt: Date
    var taskDescription: String?

    @Relationship(deleteRule: .cascade)
    var subtasks: [EmergencySubtaskModel] = []

    init(
        title: String,
        dueDate: Date,
        estimatedTotalMinutes: Int,
        availableMinutes: Int,
        completedMinutes: Int = 0,
        createdAt: Date = .now,
        taskDescription: String? = nil
    ) {
        self.title = title
        self.dueDate = dueDate
        self.estimatedTotalMinutes = estimatedTotalMinutes
        self.availableMinutes = availableMinutes
        self.completedMinutes = completedMinutes
        self.createdAt = createdAt
        self.taskDescription = taskDescription
    }
}

@Model
final class EmergencySubtaskModel {
    var title: String
    var estimatedMinutes: Int
    var priority: String
    var isCompleted: Bool
    var order: Int

    var plan: EmergencyPlanModel?

    init(
        title: String,
        estimatedMinutes: Int,
        priority: String = "High",
        isCompleted: Bool = false,
        order: Int = 0
    ) {
        self.title = title
        self.estimatedMinutes = estimatedMinutes
        self.priority = priority
        self.isCompleted = isCompleted
        self.order = order
    }
}

