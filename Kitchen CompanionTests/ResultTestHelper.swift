//
//  ResultTestHelper.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//

import XCTest

// Saves repeating the same switch statement in every use case test.
extension Result {
    func assertSuccess(file: StaticString = #filePath, line: UInt = #line) -> Success? {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            XCTFail("Expected success but got failure: \(error)", file: file, line: line)
            return nil
        }
    }

    func assertFailure(file: StaticString = #filePath, line: UInt = #line) -> Failure? {
        switch self {
        case .success:
            XCTFail("Expected failure but got success", file: file, line: line)
            return nil
        case .failure(let error):
            return error
        }
    }
}
