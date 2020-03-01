//
//  DelegateTestCaseTests.swift
//  DelegateTestCaseTests
//
//  Created by 村田真矢 on 2020/03/01.
//  Copyright © 2020 村田真矢. All rights reserved.
//

import XCTest
@testable import DelegateTestCase

private var calculatorTestExpectation: XCTestExpectation!
private var testingFile: StaticString!
private var testingLine: UInt!

class DelegateTestCaseTests: XCTestCase {
    override func setUp() {
        calculatorTestExpectation = XCTestExpectation(description: "Wait for finish")
    }
    
    override func tearDown() {
        calculatorTestExpectation = nil
    }
    
    func testReturnedSum() {
        let calculator = Calculator()
        XCTAssertEqual(calculator.returnedSum(x: 1, y: 2), 3)
    }
    
    func testClosuredSum() {
        let calculator = Calculator()
        calculator.closuredSum(x: 1, y: 2) { result in
            calculatorTestExpectation.fulfill()
            XCTAssertEqual(result, 3)
        }
        
        self.wait(for: [calculatorTestExpectation], timeout: 2)
    }
    
    func testDelegatedSum() {
        let calculator = Calculator()
        let testDelegate = TestCalculatorDelegate()
        calculator.delegate = testDelegate
        calculatorTestExpectation.expectedFulfillmentCount = 2
        self.updateFileAndLine(test: { calculator.delegatedSum(x: 1, y: 2) } )
        self.updateFileAndLine(test: { calculator.delegatedSum(x: 1, y: 2) } )
        
        class TestCalculatorDelegate: TestBaseCalculatorDelegate {
            override func summed(result: Int) {
                calculatorTestExpectation.fulfill()
                XCTAssertEqual(result, 3, file: testingFile, line: testingLine)
            }
        }
        
        self.wait(for: [calculatorTestExpectation], timeout: 2)
    }
    
    private func updateFileAndLine(test: () -> Void, file: StaticString = #file, line: UInt = #line) {
        testingFile = file
        testingLine = line
        test()
    }
}

class Calculator {
    weak var delegate: CalculatorDelegate?
    
    func returnedSum(x: Int, y: Int) -> Int {
        return x + y
    }
    
    func closuredSum(x: Int, y: Int, completion: @escaping ((Int) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(x + y)
        }
    }
    
    func delegatedSum(x: Int, y: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate?.summed(result: x + y)
        }
    }
}

protocol CalculatorDelegate: AnyObject {
    func summed(result: Int)
    func multiplied(result: Int)
}

class TestBaseCalculatorDelegate: CalculatorDelegate {
    func summed(result: Int) { XCTFail("called \(#function)", file: testingFile, line: testingLine) }
    func multiplied(result: Int) { XCTFail("called \(#function)", file: testingFile, line: testingLine) }
}
