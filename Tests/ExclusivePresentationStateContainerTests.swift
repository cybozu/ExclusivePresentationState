import XCTest
@testable import ExclusivePresentationState

@MainActor
final class ExclusivePresentationStateContainerTests: XCTestCase {
    let sut = ExclusivePresentationStateContainer.self

    override func tearDown() async throws {
        await sut.dismissAll(where: { _ in true })
    }

    func test_setDefaultValueAllFromRecent_assign_default_values_in_order_from_back_of_the_given_arguments() async {
        var array: [String] = []

        let target = [DataStoreMock(group: "a", completionHandlerOnSetDefaultValue: { array.append($0) }),
                      DataStoreMock(group: "b", completionHandlerOnSetDefaultValue: { array.append($0) }),
                      DataStoreMock(group: "c", completionHandlerOnSetDefaultValue: { array.append($0) }),
                      DataStoreMock(group: "d", completionHandlerOnSetDefaultValue: { array.append($0) })]

        await sut.setDefaultValueAllFromRecent(target)

        XCTAssertEqual(array, target.map(\.group).reversed())
    }

    func test_filterWhere_filter_only_DataStores_matching_the_condition() {
        let sut: [DataStoreProtocol] = [DataStoreMock(group: "a", priority: .low),
                                        DataStoreMock(group: "b", priority: .medium),
                                        DataStoreMock(group: "c", priority: .high)]

        XCTAssertEqual(sut.filter(where: { $0 == .medium }).map(\.group), ["b"])
    }

    func test_maxPriority_return_nil_when_the_given_argument_is_the_same_value_as_the_group_name_stored_in_storage() {
        sut.storage = ["a" : [{ DataStoreMock(group: "a") }]]
        XCTAssertNil(sut.maxPriority(exceptFor: "a"))
    }

    func test_maxPriority_return_nil_when_the_given_argument_is_a_different_value_from_the_group_name_stored_in_storage_and_the_DataStore_stored_in_storage_is_nil() {
        sut.storage = ["a" : [{ nil }]]
        XCTAssertNil(sut.maxPriority(exceptFor: "b"))
    }

    func test_maxPriority_return_nil_when_the_given_argument_is_a_different_value_from_the_group_name_stored_in_storage_and_the_DataStore_stored_in_storage_has_default_value() {
        sut.storage = ["a" : [{ DataStoreMock(group: "a", isNotDefaultValue: false) }]]
        XCTAssertNil(sut.maxPriority(exceptFor: "b"))
    }

    func test_maxPriority_return_nil_when_the_given_argument_is_a_different_value_from_the_group_name_stored_in_storage_and_the_DataStore_stored_in_storage_has_non_default_value() {
        sut.storage = ["a" : [{ DataStoreMock(group: "a", priority: .low)}],
                       "b" : [{ DataStoreMock(group: "b", priority: .medium)}],
                       "c" : [{ DataStoreMock(group: "c", priority: .high)}]]
        XCTAssertEqual(sut.maxPriority(exceptFor: "c"), .medium)
    }

    func test_excepted_return_array_of_DataStore_that_does_not_match_the_given_group_name() {
        let sut: DataStoreStorage = ["a" : [{ DataStoreMock(group: "a") }],
                                     "b" : [{ DataStoreMock(group: "b") }],
                                     "c" : [{ DataStoreMock(group: "c") }],
                                     "d" : [{ DataStoreMock(group: "d") }]]
        XCTAssertEqual(sut.excepted(for: "a").keys,
                       ["b" : [{ DataStoreMock(group: "b") }],
                        "c" : [{ DataStoreMock(group: "c") }],
                        "d" : [{ DataStoreMock(group: "d") }]].keys)

    }

    func test_defaultValueAssignables_return_array_of_DataStore_that_exclude_DataStores_containing_nil_or_default_value() {
        let sut: DataStoreWeakReferences = [{ DataStoreMock(group: "a", isNotDefaultValue: false) },
                                            { DataStoreMock(group: "b") },
                                            { DataStoreMock(group: "c") },
                                            { DataStoreMock(group: "d") },
                                            { nil }]

        XCTAssertEqual(sut.defaultValueAssignables.map(\.group),
                       ["b", "c", "d"])

    }
}

private struct DataStoreMock: DataStoreProtocol {
    let group: GroupKey
    let priority: Priority
    let isNotDefaultValue: Bool
    private let completionHandlerOnSetDefaultValue: (GroupKey) -> Void

    init(group: GroupKey, priority: Priority = .low, isNotDefaultValue: Bool = true, completionHandlerOnSetDefaultValue: @escaping (GroupKey) -> Void = { _ in }) {
        self.group = group
        self.priority = priority
        self.isNotDefaultValue = isNotDefaultValue
        self.completionHandlerOnSetDefaultValue = completionHandlerOnSetDefaultValue
    }

    func setDefaultValue() { completionHandlerOnSetDefaultValue(group) }
}
