// import Foundation
// import NSpry
// import XCTest
//
// final class SpryableSpec: QuickSpec {
//    override func spec() {
//        describe("Spryable") {
//            var subject: SpryableTestClass!
//
//            beforeEach {
//                subject = SpryableTestClass()
//            }
//
//            afterEach {
//                SpryableTestClass.resetCallsAndStubs()
//            }
//
//            describe("recording calls - instance; with arguments") {
//                var actual: String!
//
//                beforeEach {
//                    subject.stub(.getAStringWithArguments).andReturn("out")
//                    actual = subject.getAString(string: "in")
//                }
//
//                it("should have recorded the call using Spyable") {
//                    let result = subject.didCall(.getAStringWithArguments)
//                    expect(result.success).to(beTrue())
//                    expect(actual) == "out"
//                }
//            }
//
//            describe("recording calls - instance") {
//                var actual: String!
//
//                beforeEach {
//                    subject.stub(.getAString).andReturn("out")
//                    actual = subject.getAString()
//                }
//
//                it("should have recorded the call using Spyable") {
//                    let result = subject.didCall(.getAString)
//                    expect(result.success).to(beTrue())
//                    expect(actual) == "out"
//                }
//            }
//
//            describe("recording calls - class") {
//                var actual: String!
//
//                beforeEach {
//                    SpryableTestClass.stub(.getAStaticString).andReturn("out")
//                    actual = SpryableTestClass.getAStaticString()
//                }
//
//                it("should have recorded the call using Spyable") {
//                    let result = SpryableTestClass.didCall(.getAStaticString)
//                    expect(result.success).to(beTrue())
//                    expect(actual) == "out"
//                }
//            }
//
//            describe("stubbing functions - instance") {
//                let expectedString = "stubbed string"
//
//                beforeEach {
//                    subject.stub(.getAString).andReturn(expectedString)
//                }
//
//                it("should return the stubbed value using Stubbable") {
//                    expect(subject.getAString()).to(equal(expectedString))
//                }
//            }
//
//            describe("stubbing functions - class") {
//                let expectedString = "stubbed string"
//
//                beforeEach {
//                    SpryableTestClass.stub(.getAStaticString).andReturn(expectedString)
//                }
//
//                it("should return the stubbed value using Stubbable") {
//                    expect(SpryableTestClass.getAStaticString()).to(equal(expectedString))
//                }
//            }
//
//            describe("reseting calls and stubs - instance") {
//                beforeEach {
//                    subject.stub(.getAString).andReturn("")
//                    _ = subject.getAString()
//
//                    subject.resetCallsAndStubs()
//                }
//
//                it("should reset the calls and the stubs") {
//                    expect(subject.didCall(.getAString).success).to(beFalse())
//                    expect({ _ = subject.getAString() }()).to(throwAssertion())
//                }
//            }
//
//            describe("reseting calls and stubs - class") {
//                beforeEach {
//                    SpryableTestClass.stub(.getAStaticString).andReturn("")
//                    _ = SpryableTestClass.getAStaticString()
//
//                    SpryableTestClass.resetCallsAndStubs()
//                }
//
//                it("should reset the calls and the stubs") {
//                    expect(SpryableTestClass.didCall(.getAStaticString).success).to(beFalse())
//                    expect({ _ = SpryableTestClass.getAStaticString() }()).to(throwAssertion())
//                }
//            }
//        }
//    }
// }
