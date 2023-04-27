# ExclusivePresentationState

A Swift Package for exclusive control of state for presentation using Property Wrappers.

## Installation

### Swift Package Manager
To integrate using Apple's Swift Package Manager, add the following as a dependency to your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/cybozu/ExclusivePresentationState.git", from: "1.0.0")
]
```

## Usage

### @ExclusivePresentationState

#### Exclusive control of sheets and alerts

```swift
import SwiftUI
import ExclusivePresentationState

struct ContentView: View {
    @ExclusivePresentationState(priority: .low) private var showingSheet = false
    @ExclusivePresentationState(priority: .high) private var showingAlert = false

    var body: some View {
        VStack {
            Button("Show sheet") {
                showingSheet = true
            }

            Button("Show alert with delay") {
                Task {
                    try? await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC)
                    showingAlert = true
                }
            }
        }
        .sheet(isPresented: $showingSheet) {
            Text("Sheet")
        }
        .alert("Alert", isPresented: $showingAlert) {}
    }
}
```

#### Grouping and exclusive control
```swift
import SwiftUI
import ExclusivePresentationState

struct ContentView: View {
    @ExclusivePresentationState(group: "A", priority: .low) private var showingSheetA = false
    @ExclusivePresentationState(group: "B", priority: .medium) private var showingSheetB = false
    
    var body: some View {
        VStack {
            Button("Show parent sheet of A") {
                showingSheetA = true
            }
            
            Button("Show sheet of B with delay") {
                Task {
                    try? await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC)
                    showingSheetB = true
                }
            }
        }
        .sheet(isPresented: $showingSheetA) {
            ChildView()
        }
        .sheet(isPresented: $showingSheetB) {
            Text("Sheet B")
        }
    }
}

struct ChildView: View {
    @ExclusivePresentationState(group: "A", priority: .low) private var showingSheet = false

    var body: some View {
        Button("Show child sheet of A") {
            showingSheet = true
        }
        .sheet(isPresented: $showingSheet) {
            Text("Sheet A")
        }
    }
}
```

### ExclusivePresentationStateContainer

```swift
import SwiftUI
import ExclusivePresentationState

struct ContentView: View {
    @ExclusivePresentationState(priority: .low) private var showingSheet = false

    var body: some View {
        VStack {
            Button("Show sheet") {
                showingSheet = true
            }

            Button("Dismiss all low priority sheets") {
                ExclusivePresentationStateContainer.dismissAll(where: { $0 == .low })
            }
        }
        .sheet(isPresented: $showingSheet) {
            Text("Sheet")
        }
    }
}
```
