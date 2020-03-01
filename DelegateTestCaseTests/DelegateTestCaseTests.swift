//
//  DelegateTestCaseTests.swift
//  DelegateTestCaseTests
//
//  Created by 村田真矢 on 2020/03/01.
//  Copyright © 2020 村田真矢. All rights reserved.
//

import XCTest
@testable import DelegateTestCase

var calculatorTestExpectation: XCTestExpectation!

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
        calculator.delegatedSum(x: 1, y: 2)
        
        class TestCalculatorDelegate: TestBaseCalculatorDelegate {
            override func summed(result: Int) {
                calculatorTestExpectation.fulfill()
                XCTAssertEqual(result, 3)
            }
        }
        
        self.wait(for: [calculatorTestExpectation], timeout: 2)
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
    func summed(result: Int) { XCTFail("called \(#function)") }
    func multiplied(result: Int) { XCTFail("called \(#function)") }
}
