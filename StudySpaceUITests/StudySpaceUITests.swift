
import XCTest

final class StudySpaceUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.wait(for: .runningForeground, timeout: 10),
            "StudySpace should launch and appear in the foreground."
        )
    }
    
    
    @MainActor
    func testHomeScreenAccessibility() throws {
        let app = XCUIApplication()
        app.launch()

        print("===== STUDYSPACE UI ELEMENTS =====")
        print(app.debugDescription)
    }
    @MainActor
        func testAddTaskButtonOpensForm() throws {
            let app = XCUIApplication()
            app.launch()

            let addTaskButton = app.buttons["Add a task"]

            XCTAssertTrue(
                addTaskButton.waitForExistence(timeout: 5),
                "The Add a task button should appear on the home screen."
            )

            addTaskButton.tap()

            // Confirm that the task creation form opens.
            XCTAssertTrue(
                app.navigationBars.firstMatch.waitForExistence(timeout: 5)
                    || app.staticTexts["Add Task"].waitForExistence(timeout: 5),
                "The task creation screen should open."
            )
        }
    
    @MainActor
    func testAddTaskAndSave() throws {
        let app = XCUIApplication()
        app.launch()

        // Open the task creation form.
        let addTaskButton = app.buttons["Add a task"]

        XCTAssertTrue(
            addTaskButton.waitForExistence(timeout: 5),
            "The Add a task button should appear."
        )

        addTaskButton.tap()

        // Find the task title field.
        let titleField = app.textFields["What do you need to do?"]

        XCTAssertTrue(
            titleField.waitForExistence(timeout: 5),
            "The task title field should appear."
        )

        // Enter a unique task title.
        let taskTitle = "UI Test - Complete Swift assignment"
        titleField.tap()
        titleField.typeText(taskTitle)

        // Save the task.
        let saveButton = app.buttons["Add"]

        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 5),
            "The Add button should appear."
        )

        saveButton.tap()

        // Verify that the saved task appears on the home screen.
        XCTAssertTrue(
            app.staticTexts[taskTitle].waitForExistence(timeout: 5),
            "The newly saved task should appear on the home screen."
        )
    }

    
    @MainActor
    func testCompleteTask() throws {
        let app = XCUIApplication()
        app.launch()

        let taskTitle = "Completion Test \(UUID().uuidString.prefix(6))"

        // Open the Add Task form
        let addTaskButton = app.buttons["Add a task"]
        XCTAssertTrue(addTaskButton.waitForExistence(timeout: 5))
        addTaskButton.tap()

        // Enter a unique task title
        let titleField = app.textFields["What do you need to do?"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText(taskTitle)

        // Save the task
        let saveButton = app.buttons["Add"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        // Confirm the task appears before completing it
        let taskText = app.staticTexts[taskTitle]
        XCTAssertTrue(
            taskText.waitForExistence(timeout: 5),
            "The new task should appear before completion."
        )

        // Find and tap its completion button
        let completeButton =
            app.buttons["completeTaskButton_\(taskTitle)"]

        XCTAssertTrue(
            completeButton.waitForExistence(timeout: 5),
            "The completion button should exist."
        )

        completeButton.tap()

        // The home screen lists incomplete tasks only.
        // Completing this task should remove it from that list.
        let taskDisappeared = NSPredicate(format: "exists == false")

        expectation(
            for: taskDisappeared,
            evaluatedWith: taskText
        )

        waitForExpectations(timeout: 5)
    }


}
