# SecureHanger
An asynchronous HTTPS Client for Swift


## Getting Started
### Ubuntu

```sh
# Install build tools and libssl-dev
sudo apt-get upgrade
sudo apt-get install build-essential libtool libssl-dev
sudo apt-get install automake clang

# build and install libuv
git clone https://github.com/libuv/libuv.git && cd libuv
sh autogen.sh
./configure
make
make install
```

### Mac OS X

#### brew

```sh
brew install libuv
brew link libuv --force
```

And then, add
```swift
.Package(url: "https://github.com/slimane-swift/SecureHanger.git", majorVersion: 0, minor: 1)
```
to your Package.swift


## Usage
```swift
import SecureHanger

let request = Request(method: .get, uri: URI(path: "/"))

try! _ = SecureHanger(connection: SecureClientConnection(host: "miketokyo.com"), request: request) {
    let response = try! $0()
    print(response)
    // Need to call connection.close
    // If you didn't specify `Connection: Close` header
    try! connection.close()
}

// Once need to run uv_loop
// But if you use Hanger in a Slimane/Skelton Project doesn't need here.
Loop.defaultLoop.run()
```

## Reusable Connection
You can reuse connection for the host.

Note: You need to manage the connection life time on your own.
The `SecureClientConnection` should be released/closed with `close` method.

Here is an example.


```swift
import Hanger

let connection = try! SecureClientConnection(host: "miketokyo.com")

// Make a request with Connection: Keep-Alive header
let fooRequest = Request(method: .get, uri: URI(path: "/foo"))

try! _ = SecureHanger(connection: connection, request: fooRequest) {
    let response = try! $0()
    print(response)

    let barRequest = Request(method: .get, uri: URI(path: "/bar"))

    // connection is still retained
    try! _ = SecureHanger(connection: connection, request: barRequest) {
        let response = try! $0()
        print(response)
    }

    try! connection.close() // connection will be released
}

Loop.defaultLoop.run()
```

## Streaming
Getting ready

## Package.swift
```swift
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .Package(url: "https://github.com/slimane-swift/SecureHanger.git", majorVersion: 0, minor: 1)
    ]
)
```

## Licence

Hanger is released under the MIT license. See LICENSE for details.
