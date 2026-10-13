//
//  TaskCategoryPredictor.swift
//  StudySpace
//
//  Created by Risini Senara on 2026-10-10.
//


import Foundation
import CoreML

struct TaskCategoryPredictor {
    private let model: StudySpaceTaskClassifier_1

    init() throws {
        model = try StudySpaceTaskClassifier_1(
            configuration: MLModelConfiguration()
        )
    }

    func predictCategory(for taskTitle: String) throws -> String {
        let prediction = try model.prediction(text: taskTitle)
        return prediction.label
    }
}

