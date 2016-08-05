//
//  SecureHanger.swift
//  SecureHanger
//
//  Created by Yuki Takei on 8/3/16.
//
//

@_exported import HTTP
@_exported import HTTPParser
import HTTPSerializer
import QWFuture

extension Request {
    var shouldClose: Bool {
        return connection?.lowercased() == "close"
    }
}

public struct SecureHanger {

    public init(connection: SecureClientConnection, request: Request, completion: ((Void) throws -> Response) -> Void) throws {
        if connection.closed {
            completion {
                throw StreamError.closedStream(data: [])
            }
            return
        }

        var request = request
        request.uri.scheme = "https"
        request.uri.host = connection.host
        if connection.port != 443 {
            request.uri.port = connection.port
        }

        let future = QWFuture<Response> { (result: (() throws -> Response) -> ()) in
            result {
                if !connection.opend {
                    try connection.open()
                }
                return try sendRequest(connection: connection, request: request)
            }
        }

        future.onSuccess { response in
            completion {
                response
            }
        }

        future.onFailure { error in
            completion {
                throw error
            }
        }
    }
}

private func sendRequest(connection: SecureClientConnection, request: Request) throws -> Response {
    var request = request

    if request.userAgent == nil {
        request.userAgent = "SecureHanger HTTP Client"
    }

    if request.host == nil {
        request.host = connection.host
    }

    let serializer = RequestSerializer()
    try serializer.serialize(request, to: connection)

    let parser = ResponseParser()

    while true {
        let data = try connection.receive()
        if let response = try parser.parse(data) {
            if request.shouldClose {
                try connection.close()
            }
            return response
        }
    }
}
