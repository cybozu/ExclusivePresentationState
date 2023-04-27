import XCTest
@testable import ExclusivePresentationState

@MainActor
final class DataStoreTests: XCTestCase {
    override func setUpWithError() throws {
        ExclusivePresentationStateContainer.storage = [:]
    }

    func test_isDefaultValue_return_true_when_type_is_Bool_and_argument_is_false() {
        let sut = DataStore<Bool>(value: true, group: "", priority: .low)
        XCTAssertTrue(sut.isDefaultValue(false))
    }

    func test_isDefaultValue_return_false_when_type_is_Bool_and_argument_is_true() {
        let sut = DataStore<Bool>(value: false, group: "", priority: .low)
        XCTAssertFalse(sut.isDefaultValue(true))
    }

    func test_isDefaultValue_return_true_when_type_is_Optional_and_argument_is_nil() {
        let sut = DataStore<String?>(value: "hoge", group: "", priority: .low)
        XCTAssertTrue(sut.isDefaultValue(nil))
    }

    func test_isDefaultValue_return_false_when_type_is_Optional_and_argument_is_not_nil() {
        let sut = DataStore<String?>(value: nil, group: "", priority: .low)
        XCTAssertFalse(sut.isDefaultValue("hoge"))
    }

    func test_isNotDefaultValue_return_false_when_type_is_Bool_and_value_is_false() {
        let sut = DataStore<Bool>(value: false, group: "", priority: .low)
        XCTAssertFalse(sut.isNotDefaultValue)
    }

    func test_isNotDefaultValue_return_true_when_type_is_Bool_and_value_is_true() {
        let sut = DataStore<Bool>(value: true, group: "", priority: .low)
        XCTAssertTrue(sut.isNotDefaultValue)
    }

    func test_isNotDefaultValue_return_false_when_type_is_Optional_and_value_is_nil() {
        let sut = DataStore<String?>(value: nil, group: "", priority: .low)
        XCTAssertFalse(sut.isNotDefaultValue)
    }

    func test_isDefaultValue_return_true_when_type_is_Optional_and_value_is_not_nil() {
        let sut = DataStore<String?>(value: "hoge", group: "", priority: .low)
        XCTAssertTrue(sut.isNotDefaultValue)
    }

    func test_setDefaultValue_assign_false_to_value_when_type_is_Bool() {
        let sut = DataStore<Bool>(value: true, group: "", priority: .low)
        sut.setDefaultValue()
        XCTAssertFalse(sut.value)
    }

    func test_setDefaultValue_assign_nil_to_value_when_type_is_Optional() {
        let sut = DataStore<String?>(value: "hoge", group: "", priority: .low)
        sut.setDefaultValue()
        XCTAssertNil(sut.value)
    }

    func test_set_assign_default_value_when_new_value_assigned_is_default_value() async {
        let sut = DataStore<Bool>(value: true, group: "", priority: .low)
        await sut.set(false)
        XCTAssertFalse(sut.value)
    }

    func test_set_assign_new_value_when_exclusive_control_is_not_required_and_non_default_value_is_assigned() async {
        let sut = DataStore<Bool>(value: false, group: "", priority: .low)
        await sut.set(true)
        XCTAssertTrue(sut.value)
    }

    func test_set_assign_default_value_when_exclusive_control_is_required_and_priority_is_inferior_and_non_default_value_is_assigned() async {
        ExclusivePresentationStateContainer.storage = ["other group" : [{ DataStore<Bool>(value: true, group: "other group", priority: .medium) }]]
        let sut = DataStore<Bool>(value: false, group: "", priority: .low)
        await sut.set(true)
        XCTAssertFalse(sut.value)
    }

    func test_set_assign_new_value_when_exclusive_control_is_required_and_priority_is_superior_and_non_default_value_is_assigned() async {
        ExclusivePresentationStateContainer.storage = ["other group" : [{ DataStore<Bool>(value: true, group: "other group", priority: .low) }]]
        let sut = DataStore<Bool>(value: false, group: "", priority: .medium)
        await sut.set(true)
        XCTAssertTrue(sut.value)
    }
}

private struct DataStoreMock: DataStoreProtocol {
    let group: GroupKey
    let priority: Priority = .low
    let isNotDefaultValue: Bool

    init(group: GroupKey, isNotDefaultValue: Bool = true) {
        self.group = group
        self.isNotDefaultValue = isNotDefaultValue
    }

    func setDefaultValue() {}
}
