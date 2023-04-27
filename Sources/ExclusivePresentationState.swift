import SwiftUI

@propertyWrapper
public struct ExclusivePresentationState<T>: DynamicProperty {
    @StateObject private var dataStore: DataStore<T>

    public init(wrappedValue: T, group: GroupKey = UUID().uuidString, priority: Priority) where T == Bool {
        self._dataStore = .init(wrappedValue: .init(value: wrappedValue, group: group, priority: priority))
    }

    public init<V>(wrappedValue: T, group: GroupKey = UUID().uuidString, priority: Priority) where T == Optional<V> {
        self._dataStore = .init(wrappedValue: .init(value: wrappedValue, group: group, priority: priority))
    }

    public var wrappedValue: T {
        get {
            dataStore.value
        }
        nonmutating set {
            Task {
                await dataStore.set(newValue)
            }
        }
    }

    public var projectedValue: Binding<T> {
        Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
    }
}
