import Foundation

final class DataStore<T>: DataStoreProtocol, ObservableObject {
    @Published var value: T
    @Published var group: GroupKey
    @Published var priority: Priority

    var isNotDefaultValue: Bool {
        // NOTE: T does not conform to Equatable because it only needs to check if the value is a default value or not.
        !isDefaultValue(value)
    }

    let isDefaultValue: (T) -> Bool
    private let defaultValue: T

    init(value: T, group: GroupKey, priority: Priority) where T == Bool {
        self.value = value
        self.group = group
        self.priority = priority
        self.isDefaultValue = { $0 == false }
        self.defaultValue = false
        ExclusivePresentationStateContainer.storage[group, default: []].append({ [weak self] in self })
    }

    init<V>(value: T, group: GroupKey, priority: Priority) where T == Optional<V> {
        self.value = value
        self.group = group
        self.priority = priority
        self.isDefaultValue = { $0 == nil }
        self.defaultValue = nil
        ExclusivePresentationStateContainer.storage[group, default: []].append({ [weak self] in self })
    }

    func setDefaultValue() {
        value = defaultValue
    }

    func set(_ newValue: T) async {
        guard !isDefaultValue(newValue) else {
            setDefaultValue()
            return
        }

        guard let currentPresentingMaxPriority = ExclusivePresentationStateContainer.maxPriority(exceptFor: group) else {
            try? await Task.sleep(nanoseconds: DurationOf.readyForPresentSheet)
            value = newValue
            return
        }

        if currentPresentingMaxPriority > priority {
            setDefaultValue()
        } else {
            for dataStores in ExclusivePresentationStateContainer.storage.excepted(for: group).values {
                await ExclusivePresentationStateContainer.setDefaultValueAllFromRecent(dataStores.defaultValueAssignables)
            }

            try? await Task.sleep(nanoseconds: DurationOf.Animation.dismissSheet)
            value = newValue
        }
    }
}
