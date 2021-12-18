### SwiftyNetworking

SwiftyNetworking library is a generic networking library written in Swift that provides a protocol-oriented approach to load requests. It provides a protocol `Endpoint` to parse networking requests in a generic and type-safe way.

#### Endpoint Protocol
Conformance to `Endpoint` protocol is easy and straighforward. This is how the protocol looks like:
```swift
public protocol Endpoint {
    associatedtype Response
    
    var host: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var scheme: Scheme { get }
    func makeRequest() -> URLRequest?
    func parse(_ data: Data) throws -> Response
}
```
The library also includes default implementations for some of the required variables and functions for convenience. For example, there is a default implementation for **func parse(_ data: Data) throws -> Response ** whenever `Response` conforms to `Decodable` protocol as follows:
```swift
extension Endpoint where Response : Decodable {
    func parse(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}
```
You can alternatively provide your own implementation of the function and override this default implementation.

### An Example Endpoint
This is an example endpoint to parse requests from [Agify.io](https://agify.io/ "Agify.io") API.

The response body from an API call (https://api.agify.io/?name=bella) looks like this:
```json
{
    "name" : "bella",
    "age" : 34,
    "count" : 40138
}
```
A custom Swift struct that can contain this data would look like this:
```swift
struct Person : Decodable {
    let name: String
    let age: Int
    let count: Int
}
```
Finally, here is how our endpoint will look like:
```swift
struct AgifyAPIEndpoint : Endpoint {
    typealias Response = Person
    let scheme: Scheme = .https
    
    let host: String = "api.agify.io"
    let path: String = "/"
    let queryItems: [URLQueryItem]
    
    init(@ArrayBuilder queryItems: () -> [URLQueryItem]) {
        self.queryItems = queryItems()
    }
}
```
As you can see from our above example, we did not need to implement **parse(_:) ** by ourselves since we declared that our response will be of type `Person` which conforms to `Decodable` protocol. The initializer also uses **@ArrayBuilder**, which is a result builder included in the library that is used to create arrays in a declarative way.

We could use the Swift dot syntax to create a convenient way to call our endpoint.
```swift
extension Endpoint where Self == AgifyAPIEndpoint {
    static func estimatedAge(forName personName: String) -> Self {
        AgifyAPIEndpoint {
            URLQueryItem(name: "name", value: "\(personName)")
        }
    }
}
```
Finally, this is how we would call our endpoint. The result is of type `Result<Person, Error>`.
```swift
URLSession.shared.load(.estimatedAge(forName: "Zaid")) { result in
    do {
        let person = try result.get()
        print("\(person.name) is probably \(person.age) years old.")
    } catch {
        // Handle errors
    }
}
```
### Combine
SwiftyNetworking supports loading endpoints using `Combine` framework.
```swift
let subscription: AnyCancellable = URLSession.shared.load(.estimatedAge(forName: "Zaid"))
    .sink { completion in
        // Handle errors
    } receiveValue: { person in
        print("\(person.name) is probably \(person.age) years old.")
    }
```
### Swift Concurrency
SwiftyNetworking also supports loading an endpoint using Swift Concurrency and `async/await`.
```swift
Task {
    do {
        let person = try await URLSession.shared.load(.estimatedAge(forName: "Zaid"))
        print("\(person.name) is probably \(person.age) years old.")
    } catch {
        // Handle errors
    }
}
```

### Credits
- John Sundell from [SwiftBySundell](https://www.swiftbysundell.com "SwiftBySundell") for the inspiration.
