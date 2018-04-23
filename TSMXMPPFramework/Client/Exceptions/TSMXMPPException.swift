//
//  TSMXMPPException.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani on 23/04/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation

public struct TSMXMPPError {
    
    public var errorCode: TSMXMPPErrorCode
    public var errorDescription: String
    
    public init(errorCode: TSMXMPPErrorCode = .customer, error: String? = nil) {
        self.errorCode = errorCode
        if let error = error {
            errorDescription = error
        } else {
            errorDescription = errorCode.description + "❌❌❌"
        }
    }
}

public enum TSMXMPPErrorCode: Int, CustomStringConvertible {
    
    case authenticationFailed
    case userAlreadyLogin
    
    case serverNotReachable
    case serverTimeout
    case serverUnknownError
    
    case customer
    
    public var description: String {
        var string = ""
        switch self {
        case .authenticationFailed:
            string = "Error de autenticación ❌❌❌"
        case .userAlreadyLogin:
            string = "El usuario de inicio de sesión"
        case .serverNotReachable:
            string = "No conecta con el servidor"
        case .serverTimeout:
            string = "Error la conexión con el servidor tiempo de fuera a cabo 😡😡😡"
        case .serverUnknownError:
            string = "Conectar con el servidor de error desconocido"
        default:
            string = ""
        }
        return string
    }
    
}
