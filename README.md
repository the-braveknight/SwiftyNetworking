### SwiftyNetworking

SwiftyNetworking library is a generic networking library written in Swift that provides a protocol-oriented approach to load requests. It provides a protocol `Endpoint` to parse networking requests in a generic and type-safe way.

#### Endpoint Protocol
Conformance to `Endpoint` protocol is easy and straighforward. This is how the protocol body looks like:
```swift
public protocol Endpoint {
    associatedtype Response
    
    var scheme: Scheme { get }
    var host: String { get }
    var port: Int? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [HTTPHeader] { get }
    func prepare(request: inout URLRequest)
    func parse(data: Data, urlResponse: URLResponse) throws -> Response
}

```
The library includes default implementations for some of the required variables and functions for convenience.
```swift
public extension Endpoint {
    var scheme: Scheme { .https }
    var port: Int? { nil }
    var method : HTTPMethod { .get }
    var queryItems: [URLQueryItem] { [] }
    var headers: [HTTPHeader] { [] }
    func prepare(request: inout URLRequest) {}
}
```
You can easily override any of these default implementations by manually specifying the value for each variable inside the object conforming to `Endpoint`.

### Preparing the URLRequest
Any object conforming to `Endpoint` will automatically get `url` and `request` properites which are not overridable since they are not included in the protocol requirements.
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
        
        request.httpMethod = method.value
        
        switch method {
        case .post(let data), .put(let data), .patch(let data):
            request.httpBody = data
        default:
            break
        }
        
        headers.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        prepare(request: &request)
        
        return request
    }
}
```
These properties are not meant to be overridden and are not specified in the original protocol body. You can implement the **prepare(request:)** method if you need to modify the request before it is loaded.

In certain cases, for example when the `Response` conforms to `Decodable` and we expect to decode JSON, it would be reasonable to provide custom implementation for **parse(data:urlResponse:)** method to handle that.
```swift
public extension Endpoint where Response : Decodable {
    func parse(data: Data, urlResponse: URLResponse) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}
```
You can still provide your own implementation of this method to override this default implementation.

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
}
```
Finally, here is how our endpoint will look like:
```swift
struct AgifyAPIEndpoint : Endpoint {
    typealias Response = Person
    
    let host: String = "api.agify.io"
    let path: String = "/"
    let queryItems: [URLQueryItem]
    
    init(@QueriesBuilder queryItems: () -> [URLQueryItem]) {
        self.queryItems = queryItems()
    }
}
```
As you can see from the above example, we did not need to implement **parse(data:urlResponse:)** by ourselves because we declared that our response will be of type `Person` which conforms to `Decodable` protocol. And since our endpoint performs a `GET`  request, we also did not need to manually implement `method` variable and relied on the default implementation. The initializer also uses **@ArrayBuilder\<Element\>**, which is a generic result builder included in the library that is used to create arrays in a declarative way. **@QueriesBuilder** and **@HeadersBuilder** are convenient typealiases for **@ArrayBuilder\<URLQueryItem\>** and **@ArrayBuilder\<HTTPHeader\>** respectively.

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

