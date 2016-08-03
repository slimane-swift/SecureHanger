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

public struct SecureHanger {
    
    public init(connection: ClientConnection, request: Request, completion: ((Void) throws -> Response) -> Void) throws {
        if case .Closed = connection.state {
            completion {
                throw StreamError.closedStream(data: [])
            }
            return
        }
        
        var request = request
        request.uri.scheme = "https"
        request.uri.host = connection.host
        request.uri.port = connection.port
        
        let future = QWFuture<Response> { (result: (() throws -> Response) -> ()) in
            result {
                if case .Disconnected = connection.state {
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

private func sendRequest(connection: ClientConnection, request: Request) throws -> Response {
    var request = request
    request.userAgent = "Hanger"
    
    let serializer = RequestSerializer()
    try serializer.serialize(request, to: connection)
    
    let parser = ResponseParser()
    
    while true {
        let data = try connection.receive()
        if let response = try parser.parse(data) {
            if !request.isKeepAlive {
                try connection.close()
            }
            return response
        }
    }
}