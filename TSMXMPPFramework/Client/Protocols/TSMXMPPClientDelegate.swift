//
//  TSMXMPPClientDelegate.swift
//  TSMXMPPFramework
//
//  Created by Smith Huamani Hilario on 4/13/18.
//  Copyright © 2018 demos. All rights reserved.
//

import Foundation

protocol TSMXMPPClientDelegate {
    
    /**
     * Esta funcion requiere de 1 parametro de tipo String para connectarse y
     * logearse al servidor, el framework le generara una contraseña por defecto.
     **/
    func login(username: String)

    /**
     * Esta función requiere de 2 parametros de tipo String para connectarse y
     * logearse al servidor
     **/
    func login(username: String, password: String)

    /**
     * Esta función desconectara al usuario del servidor, si el usuario quiere
     * volver a loguearse
     **/
    func disconnect()

    /**
     * Esta función espera un booleano el cual indicara al framework si habilita
     * la reconeccion automatica por default false;
     **/
    func autoReconnect(isAutoreconnecting: Bool)

    /**
     *Esta función es utilizado para el envio de mennsajes.
     **/
    func sendMessage(sendTo: String, message: String)

    /**
     * Esta función espera un message, sendTo, filename y un pathFile de tipo String
     * para el envió de mensaje y archivos cuyo proceso es síncrono.
     **/
    func sendMessageAndFile(sendTo: String, message: String, listURL: [URL])

    /**
     * Esta función espera un message, sendTo, filename y un pathFile de tipo String,
     * y un callback que implementara dos funciones de success y error. El proceso se
     * hace en un hilo asíncrono.
     **/
    func sendMessageAndFileAsync(sendTo: String, message: String, listURL: [URL])
}

