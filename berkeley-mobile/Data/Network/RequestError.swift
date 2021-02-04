//
//  RequestError.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/2/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

/// An error that occurs while attempting a HTTP request through `NetworkManager`.
enum RequestError: Error {

    /// The target URL or parameters are malformed.
    case badURL

    /// A 200 status code was not recieved.
    case badResponse(code: Int)
    
    /// Unable to properly parse the response.
    case decodeFailure(data: Data)
}
