

/**
 * `ResourceDataSource` implements a static function that fetches 
 * list of `ResourceTypes` and returns the results to the completion handler.
 */
protocol ResourceDataSource
{
    typealias completionHandler = (_ resources: [Resource]?) -> Void

    static func fetchResources(_ completion: @escaping completionHandler)
}
