//
//  NetworkManager.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/2/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

typealias JSONObject = [String: Any]
typealias Params<T: Encodable> = T
typealias Nonce = URLSessionDataTask

// MARK: - NetworkManager

/// Class for managing HTTP POST and GET requests and decoding JSON responses.
class NetworkManager {

    /// Singleton instance.
    static let shared = NetworkManager()

    /// The `URLSession` used by this class to execute requests.
    private var session: URLSession = URLSession.shared

    /// The `JSONEncoder` used to encode `Encodable` parameters.
    private var jsonEncoder: JSONEncoder = JSONEncoder()

    // MARK: - GET Requests

    @discardableResult
    private func _get<D: Encodable, T>(url: URL, params: Params<D>,
                                       decode: @escaping (Data) throws -> T,
                                       completion: @escaping (Response<T>) -> Void) -> Nonce? {
        guard let url = parameterize(url, with: params) else {
            completion(.failure(error: RequestError.badURL))
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.responseHandler(data: data, response: response, error: error,
                                     decode: decode, completion: completion)
            }
        }
        task.resume()
        return task
    }

    /**
     Performs an HTTP GET request and interprets the result as the given type.

     - Parameter url: The URL of the request.
     - Parameter params: The parameters to send in the request. These must be encodable into (key, value) string pairs.
     - Parameter asType: The decodable type with which to interpret the response as.
     - Parameter completion: A completion block that is called with a `Response` enum containing either
        the decoded response data or an error.

     - Returns: A reference to the `URLSessionDataTask` for this request, or `nil` if no request was made.
     */
    @discardableResult
    open func get<D: Encodable, T: Decodable>(url: URL, params: Params<D>, asType: T.Type,
                                              completion: @escaping (Response<T>) -> Void) -> Nonce? {
        return _get(url: url, params: params, decode: { data in
            return try JSONDecoder().decode(T.self, from: data)
        }, completion: completion)
    }

    /**
     Performs an HTTP GET request and interprets the result as a JSON object, returned as `[String: Any]`.

     - Parameter url: The URL of the request.
     - Parameter params: The parameters to send in the request. These must be encodable into (key, value) string pairs.
     - Parameter completion: A completion block that is called with a `Response` enum containing either
        the decoded response data or an error.

     - Returns: A reference to the `URLSessionDataTask` for this request, or `nil` if no request was made.
     */
    @discardableResult
    open func get<D: Encodable>(url: URL, params: Params<D>,
                                completion: @escaping (Response<JSONObject>) -> Void) -> Nonce? {
        return _get(url: url, params: params, decode: { data in
            guard let dict = try JSONSerialization.jsonObject(with: data) as? JSONObject else {
                throw RequestError.decodeFailure(data: data)
            }
            return dict
        }, completion: completion)
    }

    // MARK: - POST Requests

    private func _post<T>(url: URL, body: JSONObject,
                          decode: @escaping (Data) throws -> T,
                          completion: @escaping (Response<T>) -> Void) -> Nonce? {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.responseHandler(data: data, response: response, error: error,
                                     decode: decode, completion: completion)
            }
        }
        task.resume()
        return task
    }

    /**
     Performs an HTTP POST request and interprets the result as the given type.

     - Parameter url: The URL of the request.
     - Parameter body: The JSON object to send in the request body.
     - Parameter asType: The decodable type with which to interpret the response as.
     - Parameter completion: A completion block that is called with a `Response` enum containing either
        the decoded response data or an error.

     - Returns: A reference to the `URLSessionDataTask` for this request, or `nil` if no request was made.
     */
    @discardableResult
    open func post<T: Decodable>(url: URL, body: JSONObject, asType: T.Type,
                                 completion: @escaping (Response<T>) -> Void) -> Nonce? {
        return _post(url: url, body: body, decode: { data in
            return try JSONDecoder().decode(T.self, from: data)
        }, completion: completion)
    }

    /**
     Performs an HTTP POST request and interprets the result as a JSON object, returned as `[String: Any]`.

     - Parameter url: The URL of the request.
     - Parameter body: The JSON object to send in the request body.
     - Parameter completion: A completion block that is called with a `Response` enum containing either
        the decoded response data or an error.

     - Returns: A reference to the `URLSessionDataTask` for this request, or `nil` if no request was made.
     */
    @discardableResult
    open func post(url: URL, body: JSONObject,
                   completion: @escaping (Response<JSONObject>) -> Void) -> Nonce? {
        return _post(url: url, body: body, decode: { data in
            guard let dict = try JSONSerialization.jsonObject(with: data) as? JSONObject else {
                throw RequestError.decodeFailure(data: data)
            }
            return dict
        }, completion: completion)
    }

    // MARK: - Response Handler

    @inline(__always) private func responseHandler<T>(data: Data?, response: URLResponse?, error: Error?,
                                                      decode: (Data) throws -> T,
                                                      completion: @escaping (Response<T>) -> Void) {
        if let error = error {
            completion(.failure(error: error))
        } else if let response = response as? HTTPURLResponse,
                  response.statusCode != 200 {
            if let data = data {
                do {
                    let decoded = try decode(data)
                    print("Received: \(response) with data: \(decoded)")
                } catch {
                    do {
                        // Try to decode as `AnyJSON`
                        let decoded = try JSONDecoder().decode(AnyJSON.self, from: data)
                        print("Received: \(response) with data: \(decoded)")
                    } catch {
                        print("Received: \(response) with data: \(data)")
                    }
                }
            }
            completion(.failure(error: RequestError.badResponse(code: response.statusCode)))
        } else {
            guard let data = data else {
                completion(.success(data: nil))
                return
            }
            do {
                let decoded = try decode(data)
                completion(.success(data: decoded))
            } catch {
                completion(.failure(error: RequestError.decodeFailure(data: data)))
            }
        }
    }

    // MARK: - Helpers

    private func parameterize<T: Encodable>(_ url: URL, with params: Params<T>) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let json = try? JSONSerialization.jsonObject(with: jsonEncoder.encode(params))
                as? JSONObject else { return nil }
        components.queryItems = json.compactMap { k, v in
            if JSONSerialization.isValidJSONObject(v) {
                guard let data = try? JSONSerialization.data(withJSONObject: v, options: []),
                      let str = String(data: data, encoding: .ascii) else { return nil }
                return URLQueryItem(name: k, value: str)
            }
            return URLQueryItem(name: k, value: "\(v)")
        }
        return components.url
    }
}
