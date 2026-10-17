
import Testing
@testable import StudySpace

struct StudySpaceTests {

    // Test 1: A new task should not be completed
    @Test
    func testTaskStartsIncomplete() {
        let task = StudyTaskModel(
            title: "Complete iOS assignment"
        )

        #expect(task.isCompleted == false)
    }

    // Test 2: A task should store its title correctly
    @Test
    func testTaskStoresTitle() {
        let task = StudyTaskModel(
            title: "Revise Swift notes"
        )

        #expect(task.title == "Revise Swift notes")
    }

    // Test 3: A task should store its estimated duration
    @Test
    func testTaskStoresEstimatedMinutes() {
        let task = StudyTaskModel(
            title: "Complete project",
            estimatedMinutes: 60
        )

        #expect(task.estimatedMinutes == 60)
    }

    // Test 4: A task can be marked as completed
    @Test
    func testTaskCanBeCompleted() {
        let task = StudyTaskModel(
            title: "Submit assignment"
        )

        task.isCompleted = true

        #expect(task.isCompleted == true)
    }

    // Test 5: A task should store its category
    @Test
    func testTaskStoresCategory() {
        let task = StudyTaskModel(
            title: "Revise lecture notes",
            category: "Revision"
        )

        #expect(task.category == "Revision")
    }
}

