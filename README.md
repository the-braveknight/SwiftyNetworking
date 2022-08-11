### SwiftyNetworking

SwiftyNetworking library is a generic networking library written in Swift that provides a protocol-oriented approach to load requests. It provides a protocol `Endpoint` to parse networking requests in a generic and type-safe way.

#### Endpoint Protocol
Conformance to `Endpoint` protocol is easy and straighforward. This is how the protocol looks like:
```swift
public protocol Endpoint {
    associatedtype Response
    
    var scheme: Scheme { get }
    var host: String { get }
    var port: Int? { get }
    var path: String { get }
    var method: Method { get }
    var queryItems: [URLQueryItem] { get }
    func prepare(request: inout URLRequest)
    func parse(_ data: Data) throws -> Response
}
```
The library includes default implementations for some of the required variables and functions for convenience.
```swift
public extension Endpoint {
    var scheme: Scheme { .https }
    var method : Method { .get }
    var queryItems: [URLQueryItem] { [] }
    func prepare(request: inout URLRequest) {}
    var port: Int? { nil }
}
```
You can easily override any of these default implementations by manually specifying the value for each variable inside the object conforming to `Endpoint`.

### Preparing the URLRequest
Any object conforming to `Endpoint` will automatically get `url` and `request` properites which are not overridable because they are not included in the protocol requirements.
```swift
public extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = path
        components.port = port
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            fatalError("Invalid URL components: \(components)")
        }
        
        return url
    }
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        
        switch method {
        case .post(let data), .put(let data):
            request.httpMethod = method.value
            request.httpBody = data
        default:
            request.httpMethod = method.value
        }
        
        prepare(request: &request)
        
        return request
    }
}
```
These properties are not meant to be overrided and are not specified in the original protocol body. You can use the **prepare(_:)** function to prepare the request or add any headers before it is loaded. The **prepare(_:)** function is defaultly implemented to do nothing by default because most of the time, you will not need to modify the request. In certain cases, for example when the `Response` conforms to `Decodable` and we expect to decode JSON, it would be reasonable to provide some custom implementations for both **prepare(:_)** and **parse(:_)** functions to handle that.
```swift
public extension Endpoint where Response : Decodable {
    func prepare(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    }
    
    func parse(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}
```
You can still provide your own implementation of these functions override this default implementation.

### An Example Endpoint
This is an example endpoint with `GET` method to parse requests from [Agify.io](https://agify.io/ "Agify.io") API.

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
    
    let host: String = "api.agify.io"
    let path: String = "/"
    let queryItems: [URLQueryItem]
    
    init(@ArrayBuilder queryItems: () -> [URLQueryItem]) {
        self.queryItems = queryItems()
    }
}
```
As you can see from the above example, we did not need to implement **parse(_:) ** by ourselves because we declared that our response will be of type `Person` which conforms to `Decodable` protocol. And since our endpoint performs a `GET`  request, we also did not need to manually specify a value for `method` variable and relied on the default implementation. The initializer also uses **@ArrayBuilder**, which is a result builder included in the library that is used to create arrays in a declarative way.

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

