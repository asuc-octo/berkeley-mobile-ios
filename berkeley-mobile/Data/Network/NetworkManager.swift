//
//  NetworkManager.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/2/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

typealias Nonce = URLSessionDataTask

// MARK: - NetworkManager

class NetworkManager {

    /// Singleton instance.
    static let shared = NetworkManager()

    /// The `URLSession` used by this class to executre requests.
    private var session: URLSession = URLSession.shared

    // MARK: - GET Requests

    @discardableResult
    private func _get<T>(url: URL, params: [String: String],
                         decode: @escaping (Data) throws -> T,
                         completion: @escaping (Response<T>) -> Void) -> Nonce? {
        guard let url = parameterize(url, with: params) else {
            completion(.failure(error: RequestError.badURL))
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { data, response, error in
            self.responseHandler(data: data, response: response, error: error,
                                 decode: decode, completion: completion)
        }
        task.resume()
        return task
    }

    @discardableResult
    open func get<T: Decodable>(url: URL, params: [String: String], asType: T.Type,
                                completion: @escaping (Response<T>) -> Void) -> Nonce? {
        return _get(url: url, params: params, decode: { data in
            return try JSONDecoder().decode(T.self, from: data)
        }, completion: completion)
    }

    @discardableResult
    open func get(url: URL, params: [String: String],
                  completion: @escaping (Response<[String: Any]>) -> Void) -> Nonce? {
        return _get(url: url, params: params, decode: { data in
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw RequestError.decodeFailure(data: data)
            }
            return dict
        }, completion: completion)
    }

    // MARK: - POST Requests

    private func _post<T>(url: URL, body: [String: String],
                          decode: @escaping (Data) throws -> T,
                          completion: @escaping (Response<T>) -> Void) -> Nonce? {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        let task = session.dataTask(with: request) { data, response, error in
            self.responseHandler(data: data, response: response, error: error,
                                 decode: decode, completion: completion)
        }
        task.resume()
        return task
    }

    @discardableResult
    open func post<T: Decodable>(url: URL, body: [String: String], asType: T.Type,
                                 completion: @escaping (Response<T>) -> Void) -> Nonce? {
        return _post(url: url, body: body, decode: { data in
            return try JSONDecoder().decode(T.self, from: data)
        }, completion: completion)
    }

    @discardableResult
    open func post(url: URL, body: [String: String],
                   completion: @escaping (Response<[String: Any]>) -> Void) -> Nonce? {
        return _post(url: url, body: body, decode: { data in
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
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

    private func parameterize(_ url: URL, with params: [String: String]) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        components.queryItems = params.map { k, v in URLQueryItem(name: k, value: v) }
        return components.url
    }
}
