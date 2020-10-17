//
//  ImageLoader.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/10/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

/// Loads images and keeps tracks of all previously loaded images by url, all current tasks by uuid
class ImageLoader {
    /// Shared ImageLoader instance to be used across the app
    public static var shared = ImageLoader()
    /// All images are cached here, all objects fetch cached images from here by url
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    /// Load the image with specified url, run the completion once loaded, return the uuid for the task to load the image
    @discardableResult
    func getImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        let uuid = UUID()
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    self.runningRequests.removeValue(forKey: uuid)
                }
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.loadedImages[url] = image
                }
                completion(.success(image))
                return
            }
            guard let error = error else { return }
            // If task wasn't cancelled and we got another error, report that the load failed
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
        }
        task.resume()
        runningRequests[uuid] = task
        return uuid
    }
    
    /// Return the image for a url if it has already been loaded, don't load the image otherwise. This makes it so image loads must be specifically called using ImageLoader.getImage
    func getImageIfLoaded(url: URL) -> UIImage? {
        if let image = loadedImages[url] {
            return image
        }
        return nil
    }
    
    /// Cancel a running load by uuid
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
    
}
