//
//  Response.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/2/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

/// An enum describing responses from network requests.
enum Response<T> {

    /// A HTTP status code of 200, and any returned data.
    case success(data: T?)

    /// A HTTP status code other than 200.
    case failure(error: Error)
}
