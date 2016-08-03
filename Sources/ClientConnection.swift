//
//  HTTPSClient.swift
//  SecureHanger
//
//  Created by Yuki Takei on 8/3/16.
//
//

import Suv

public enum ClientError: ErrorProtocol {
    case httpsSchemeRequired
    case hostRequired
    case brokenConnection
}

public final class ClientConnection: Connection {
    
    public enum ConnectionState {
        case Disconnected
        case Connected
        case Closed
    }
    
    public private(set) var state: ConnectionState = .Disconnected
    
    public let host: String
    public let port: Int
    
    public var connection: C7.Connection
    
    public var closed: Bool {
        return connection.closed
    }
    
    private var retainedSelf: Unmanaged<ClientConnection>? = nil
    
    public init(host: String, port: Int = 443) throws {
        self.host = host
        self.port = port
        self.connection = try TCPSSLConnection(host: host, port: port)
        self.retainedSelf = Unmanaged.passRetained(self)
    }
    
    public func open(timingOut deadline: Double = .never) throws {
        try connection.open(timingOut: deadline)
        self.state = .Connected
    }
    
    public func send(_ data: Data, timingOut deadline: Double = .never) throws {
        try connection.send(data, timingOut: deadline)
    }
    
    public func receive(upTo byteCount: Int = 1024, timingOut deadline: Double = .never) throws -> Data {
        return try connection.receive(upTo: byteCount, timingOut: deadline)
    }
    
    public func flush(timingOut deadline: Double = .never) throws {
        try connection.flush(timingOut: deadline)
    }
    
    public func close() throws {
        try connection.close()
        self.state = .Closed
        retainedSelf?.release()
    }
}
