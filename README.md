# TryKit

**Clean, expressive error handling for Swift.**  
TryKit makes it painless to work with Swift’s `Result` type by providing chainable helpers like `.onSuccess`, `.recover`, `.flatMap`, and more — including `tryCatch` wrappers for both sync and async functions.

---

## ✨ Why use TryKit?

Writing Swift code that deals with errors doesn't need to look like this:

```swift
do {
  let data = try fetchData()
  let value = try transform(data)
  print("Success:", value)
} catch {
  print("Error:", error)
}
```

With **TryKit**, you can streamline your logic:

```swift
tryCatch { try fetchData() }
  .flatMap { data in tryCatch { try transform(data) } }
  .onSuccess { print("Success:", $0) }
  .onFailure { print("Oops:", $0.localizedDescription) }
```

---

## 📦 Installation

### Swift Package Manager (SPM)

Add this to your `Package.swift`:

```swift
.package(url: "https://github.com/jpmcglone/TryKit.git", from: "1.0.0")
```

And add `"TryKit"` to your target dependencies.

Or in Xcode:

- Go to `File → Add Packages…`
- Enter `https://github.com/yourusername/TryKit`
- Choose your version and add it to your target

---

## 🚀 Quick Start

### Wrap a throwing function:

```swift
import TryKit

let result = tryCatch {
  try fetchUserProfile()
}
```

### Handle success and failure:

```swift
result
  .onSuccess { user in
    print("Welcome, \(user.name)")
  }
  .onFailure { error in
    print("Error loading profile:", error)
  }
```

---

## 🔁 Chaining operations

Each transformation only runs if the previous step succeeded:

```swift
tryCatch { try loadUserID() }
  .flatMap { id in tryCatch { try fetchUser(id: id) } }
  .map { $0.name }
  .recover { _ in "Guest" }
  .onSuccess { print("Hello, \($0)") }
```

---

## 🔧 Features

- ✅ `tryCatch { ... }` for sync and async
- ✅ `.onSuccess { ... }` and `.onFailure { ... }`
- ✅ `.map { ... }` and `.flatMap { ... }`
- ✅ `.recover { ... }` and `.recoverWith { ... }`
- ✅ `.isSuccess` and `.isFailure` helpers
- ✅ Fully tested and lightweight

---

## Basic Async Example

```swift
await tryCatch {
  try await loadUsername()
}
.onSuccess { name in
  print("Welcome, \(name)")
}
.onFailure { error in
  print("Failed to load user:", error)
}
```

---

## 🌍 Async Example

```swift
let result = await tryCatch {
  try await fetchRemoteSettings()
}

let settings = result
  .map { $0.theme }
  .recover { _ in "light" }

print("Theme:", settings)
```

---

## Recover Example

```swift
let result = tryCatch {
  try loadUsername()
}
.recover { _ in "Guest" }

print("Hello, \(result)")
```

---

## Chaining Example

```swift
tryCatch { try fetchToken() }
  .flatMap { token in 
    tryCatch { try fetchUser(token: token) }
  }
  .map { $0.name }
  .onSuccess { print("Welcome, \($0)") }
  .onFailure { print("Login failed") }
```

---

## 📘 API Reference

Every method is fully documented with Swift-style doc comments.  
You can also use `Option + Click` in Xcode for inline docs.

---

## 🧪 Testing

To run tests:

```swift
swift test
```

Covers:

- Sync and async flows
- Mapping and flatMapping
- Recovering from errors
- Chaining and branching behavior

---

## 👏 Credits

Built with care by JP McGlone  
Inspired by Swift’s powerful `Result` type and functional patterns.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

