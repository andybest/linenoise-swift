import XCTest
@testable import linenoiseTests

XCTMain([
    testCase(AnsiCodesTests.allTests),
    testCase(EditStateTests.allTests),
    testCase(HistoryTests.allTests),
])
