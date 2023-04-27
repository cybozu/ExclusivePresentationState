import Foundation

struct DurationOf {
    static let readyForPresentSheet = 1000 * 12 / 60 * NSEC_PER_MSEC

    struct Animation {
        static let dismissSheet = 1000 * 36 / 60 * NSEC_PER_MSEC
        static let dismissNestedSheet = 1000 * 12 / 60 * NSEC_PER_MSEC
    }
}
