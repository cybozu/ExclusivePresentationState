import Foundation

public typealias GroupKey = String
typealias DataStoreStorage = [GroupKey : DataStoreWeakReferences]
typealias DataStoreWeakReferences = [() -> DataStoreProtocol?]

@MainActor
protocol DataStoreProtocol {
    nonisolated var group: GroupKey { get }
    nonisolated var priority: Priority { get }
    var isNotDefaultValue: Bool { get }

    func setDefaultValue()
}

@MainActor
public struct ExclusivePresentationStateContainer {
    static var storage: DataStoreStorage = [:]

    public static func dismissAll(where shouldBeDismissed: (Priority) -> Bool) async {
        for dataStores in storage.values {
            let targetDataStores = dataStores.defaultValueAssignables.filter(where: shouldBeDismissed)
            await setDefaultValueAllFromRecent(targetDataStores)
        }
    }

    static func setDefaultValueAllFromRecent(_ targetDataStores: [DataStoreProtocol]) async {
        for (index, dataStore) in targetDataStores.enumerated().reversed() {
            dataStore.setDefaultValue()

            if index != targetDataStores.startIndex {
                try? await Task.sleep(nanoseconds: DurationOf.Animation.dismissNestedSheet)
            }
        }
    }

    static func maxPriority(exceptFor group: GroupKey) -> Priority? {
        storage
            .filter { key, _ in key != group }
            .values
            .flatMap { $0 }
            .compactMap { $0() }
            .filter(\.isNotDefaultValue)
            .map(\.priority)
            .max()
    }
}

extension DataStoreStorage {
    func excepted(for group: GroupKey) -> [GroupKey : [() -> DataStoreProtocol?]] {
        self.filter { key, _ in key != group }
    }
}

extension DataStoreWeakReferences {
    var defaultValueAssignables: [DataStoreProtocol] {
        self.compactMap { $0() }.filter(\.isNotDefaultValue)
    }
}

extension [DataStoreProtocol] {
    func filter(where shouldBeDismissed: (Priority) -> Bool) -> Self {
        self.filter { shouldBeDismissed($0.priority) }
    }
}
