import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NSOperationAPICallerTests.allTests),
    ]
}
#endif
