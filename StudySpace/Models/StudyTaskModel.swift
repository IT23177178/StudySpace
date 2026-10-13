//
//  StudyTaskModel.swift
//  StudySpace
//
//  Created by Risini Senara on 2026-10-09.
//

import Foundation
import SwiftData

@Model
final class StudyTaskModel {
    var title: String
    var dueDate: Date?
    var isCompleted: Bool
    var category: String = "Assignment"
    var estimatedMinutes: Int = 30
    var createdAt: Date = Date.now

    init(
        title: String,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        category: String = "Assignment",
        estimatedMinutes: Int = 30,
        createdAt: Date = .now
    ) {
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.category = category
        self.estimatedMinutes = estimatedMinutes
        self.createdAt = createdAt
    }
}

