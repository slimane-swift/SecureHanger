//
//  TCPSSLConnection.swift
//  SecureHanger
//
//  Created by Yuki Takei on 8/3/16.
//
//

import SocksCore
import SecretSocks
import TLS
import C7

public class TCPSSLConnection: Connection {
    var secureSocket: TLS.Socket
    let socket: TCPInternetSocket
    let retainedSecureSocket: Unmanaged<TLS.Socket>
    
    public var closed: Bool {
        return socket.closed
    }
    
    public init(host: String, port: Int) throws {
        let address = InternetAddress(hostname: host, port: Port(port))
        socket = try TCPInternetSocket(address: address)
        secureSocket = try socket.makeSecret()
        retainedSecureSocket = Unmanaged.passRetained(secureSocket)
    }
    
    public func open(timingOut deadline: Double = .never) throws {
        try socket.connect()
        try secureSocket.connect()
    }
    
    public func send(_ data: Data, timingOut deadline: Double = .never) throws {
        try secureSocket.send(data.bytes)
    }
    
    public func receive(upTo byteCount: Int = 1024, timingOut deadline: Double = .never) throws -> Data {
        return Data(try secureSocket.receive(max: byteCount))
    }
    
    public func flush(timingOut deadline: Double = .never) throws {}
    
    public func close() throws {
        retainedSecureSocket.release()
        do {
            try socket.close()
        } catch {
            if let error = error as? SocksError {
                switch error.type {
                case .closeSocketFailed:
                    return
                default:
                    throw error
                }
            }
            throw error
        }
    }
}
