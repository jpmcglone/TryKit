import XCTest
@testable import TryKit

final class TryKitTests: XCTestCase {

  enum MockError: Error, Equatable, CustomStringConvertible {
    case test
    case other(String)

    var description: String {
      switch self {
      case .test:
        return "MockError.test"
      case .other(let message):
        return "MockError.other(\(message))"
      }
    }
  }

  // MARK: - Synchronous Tests

  func testSuccessCase() {
    let result = tryCatch { 42 }

    XCTAssertTrue(result.isSuccess)
    XCTAssertFalse(result.isFailure)
    XCTAssertEqual(try? result.get(), 42)
  }

  func testFailureCase() {
    let result: Result<Int, Error> = tryCatch {
      throw MockError.test
    }

    XCTAssertTrue(result.isFailure)
    XCTAssertFalse(result.isSuccess)
    XCTAssertThrowsError(try result.get()) { error in
      XCTAssertEqual(error as? MockError, MockError.test)
    }
  }

  func testOnSuccessAndOnFailure() {
    var capturedValue: Int?
    var capturedError: Error?

    _ = tryCatch { 7 }
      .onSuccess { capturedValue = $0 }
      .onFailure { capturedError = $0 }

    XCTAssertEqual(capturedValue, 7)
    XCTAssertNil(capturedError)
  }

  func testOnFailureOnly() {
    var capturedError: Error?
    _ = tryCatch { throw MockError.other("oops") }
      .onFailure { capturedError = $0 }

    XCTAssertNotNil(capturedError)
    XCTAssertEqual((capturedError as? MockError)?.description, MockError.other("oops").description)
  }

  func testMapTransformsValue() {
    let result = tryCatch { 10 }.map { $0 * 3 }
    XCTAssertEqual(try? result.get(), 30)
  }

  func testMapDoesNotRunOnFailure() {
    let result = tryCatch { throw MockError.test }.map { _ in "nope" }
    XCTAssertTrue(result.isFailure)
    XCTAssertThrowsError(try result.get())
  }

  func testFlatMapChainsSuccess() {
    let result = tryCatch { "user" }
      .flatMap { name in tryCatch { "\(name)-settings" } }

    XCTAssertEqual(try? result.get(), "user-settings")
  }

  func testFlatMapStopsOnFailure() {
    let result: Result<String, Error> = tryCatch { "fail" }
      .flatMap { _ in
        throw MockError.other("inner fail")
      }

    XCTAssertTrue(result.isFailure)
    XCTAssertThrowsError(try result.get()) { error in
      XCTAssertEqual(error as? MockError, MockError.other("inner fail"))
    }
  }

  func testRecoverProvidesFallback() {
    let result: Result<String, Error> = tryCatch { throw MockError.test }
    let recovered: String = result.recover { _ in "fallback" }

    XCTAssertEqual(recovered, "fallback")
  }

  func testRecoverDoesNotRunOnSuccess() {
    let result = tryCatch { "actual" }
    let recovered = result.recover { _ in "should not happen" }

    XCTAssertEqual(recovered, "actual")
  }

  func testRecoverWithReplacesFailure() {
    let result: Result<String, Error> = tryCatch { throw MockError.test }
    let recovered = result.recoverWith { _ in .success("recovered") }

    XCTAssertEqual(try? recovered.get(), "recovered")
  }

  func testRecoverWithDoesNotChangeSuccess() {
    let result = tryCatch { "yay" }
    let recovered = result.recoverWith { _ in .success("nope") }

    XCTAssertEqual(try? recovered.get(), "yay")
  }

  func testGetThrowsOnFailure() {
    let result = tryCatch { throw MockError.test }
    XCTAssertThrowsError(try result.get()) { error in
      XCTAssertEqual(error as? MockError, MockError.test)
    }
  }

  // MARK: - Asynchronous Tests

  func testAsyncSuccess() async {
    let result = await tryCatch {
      try await simulatedSuccess(123)
    }

    XCTAssertTrue(result.isSuccess)
    XCTAssertEqual(try? result.get(), 123)
  }

  func testAsyncFailure() async {
    let result: Result<Int, Error> = await tryCatch {
      try await simulatedFailure()
    }

    XCTAssertTrue(result.isFailure)
    XCTAssertThrowsError(try result.get()) { error in
      XCTAssertEqual(error as? MockError, MockError.test)
    }
  }

  func testAsyncRecoverOnFailure() async {
    let result: Result<Int, Error> = await tryCatch {
      try await simulatedFailure()
    }

    let value = result.recover { _ in 77 }
    XCTAssertEqual(value, 77)
  }

  func testAsyncFlatMapChain() async {
    let result = await tryCatch {
      try await simulatedSuccess("user")
    }.flatMap { name in
      tryCatch { "\(name)-settings" }
    }

    XCTAssertEqual(try? result.get(), "user-settings")
  }

  func testAsyncMapTransformsValue() async {
    let result = await tryCatch {
      try await simulatedSuccess("hello")
    }.map { $0.uppercased() }

    XCTAssertEqual(try? result.get(), "HELLO")
  }

  // MARK: - Helper Functions

  private func simulatedSuccess<T>(_ value: T) async throws -> T {
    try await Task.sleep(nanoseconds: 10_000)
    return value
  }

  private func simulatedFailure<T>() async throws -> T {
    try await Task.sleep(nanoseconds: 10_000)
    throw MockError.test
  }
}
