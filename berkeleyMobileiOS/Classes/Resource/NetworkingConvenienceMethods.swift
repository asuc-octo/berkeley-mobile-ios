//
//  NetworkingConvenienceMethods.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh on 1/26/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Alamofire
func encode_url_no_cache(_ address: String) -> URLRequest {
    
    let route: URL = URL(string: address)!
    var originalRequest = try! URLRequest(url: route, method: .get)

    originalRequest.cachePolicy = .reloadIgnoringCacheData

    let encodedURLRequest = try! URLEncoding.default.encode(originalRequest, with: nil)
    
    return encodedURLRequest
}
