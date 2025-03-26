import Foundation

public extension Result where Failure: Error {

  /// A Boolean value indicating whether the result is a success.
  ///
  /// Use this property to check whether a result instance represents a successful outcome.
  ///
  ///     let result = tryCatch { "hello" }
  ///     if result.isSuccess {
  ///         print("It worked!")
  ///     }
  @inlinable
  var isSuccess: Bool {
    if case .success = self { return true }
    return false
  }

  /// A Boolean value indicating whether the result is a failure.
  ///
  /// This is the inverse of `isSuccess`. It returns `true` when the result is a failure.
  ///
  ///     if result.isFailure {
  ///         print("Something went wrong.")
  ///     }
  @inlinable
  var isFailure: Bool { !isSuccess }

  /// Returns the success value, or throws the failure as an error.
  ///
  /// - Returns: The value associated with a successful result.
  /// - Throws: The error associated with a failed result.
  ///
  /// Use this when you want to exit early if the result failed:
  ///
  ///     let value = try result.get()
  @inlinable
  func get() throws -> Success {
    switch self {
    case .success(let value): return value
    case .failure(let error): throw error
    }
  }

  /// Performs the given closure if the result is a success.
  ///
  /// - Parameter block: A closure that receives the success value.
  /// - Returns: The original result, allowing for method chaining.
  ///
  ///     result
  ///       .onSuccess { print("Value is \($0)") }
  ///       .onFailure { print("Error is \($0)") }
  @inlinable
  @discardableResult
  func onSuccess(_ block: (Success) -> Void) -> Self {
    if case let .success(value) = self {
      block(value)
    }
    return self
  }

  /// Performs the given closure if the result is a failure.
  ///
  /// - Parameter block: A closure that receives the failure error.
  /// - Returns: The original result, allowing for method chaining.
  ///
  ///     result
  ///       .onFailure { print("Caught: \($0)") }
  @inlinable
  @discardableResult
  func onFailure(_ block: (Failure) -> Void) -> Self {
    if case let .failure(error) = self {
      block(error)
    }
    return self
  }

  /// Transforms the success value of the result using the given closure.
  ///
  /// - Parameter transform: A closure that takes the success value and returns a new value.
  /// - Returns: A new result containing the transformed value or the original failure.
  ///
  ///     result.map { $0.uppercased() }
  @inlinable
  func map<U>(_ transform: (Success) -> U) -> Result<U, Failure> {
    flatMap { .success(transform($0)) }
  }

  /// Transforms the success value using a closure that may throw or return a new result.
  ///
  /// - Parameter transform: A throwing closure that returns a new result.
  /// - Returns: A result containing the transformed value, or a failure.
  ///
  /// This allows for chaining operations that also return a `Result`.
  func flatMap<U>(_ transform: (Success) throws -> Result<U, Failure>) -> Result<U, Failure> {
    switch self {
    case .success(let value):
      do {
        return try transform(value)
      } catch let error as Failure {
        return .failure(error)
      } catch {
        fatalError("Unhandled error: \(error)")
      }
    case .failure(let error):
      return .failure(error)
    }
  }

  /// Returns the success value, or a fallback value provided by the closure.
  ///
  /// - Parameter handler: A closure that provides a fallback value when the result is a failure.
  /// - Returns: The original success value or the fallback value.
  ///
  ///     let value = result.recover { _ in "default" }
  @inlinable
  func recover(_ handler: (Failure) -> Success) -> Success {
    switch self {
    case .success(let value):
      return value
    case .failure(let error):
      return handler(error)
    }
  }

  /// Returns the original result or a fallback result provided by the closure.
  ///
  /// - Parameter handler: A closure that provides a new result when the original is a failure.
  /// - Returns: The original success result or the fallback result.
  ///
  ///     let recovered = result.recoverWith { _ in .success("default") }
  @inlinable
  func recoverWith(_ handler: (Failure) -> Result<Success, Failure>) -> Result<Success, Failure> {
    switch self {
    case .success:
      return self
    case .failure(let error):
      return handler(error)
    }
  }
}

/// Executes a throwing closure and returns a `Result` with the outcome.
///
/// - Parameter block: A closure that may throw an error.
/// - Returns: A result containing the value from the closure, or the error thrown.
///
///     let result = tryCatch { try loadUser() }
@inlinable
public func tryCatch<T>(_ block: () throws -> T) -> Result<T, Error> {
  do {
    return .success(try block())
  } catch {
    return .failure(error)
  }
}

/// Executes an asynchronous throwing closure and returns a `Result` with the outcome.
///
/// - Parameter block: An async closure that may throw an error.
/// - Returns: A result containing the value from the closure, or the error thrown.
///
///     let result = await tryCatch { try await fetchData() }
@inlinable
public func tryCatch<T>(_ block: () async throws -> T) async -> Result<T, Error> {
  do {
    return .success(try await block())
  } catch {
    return .failure(error)
  }
}
