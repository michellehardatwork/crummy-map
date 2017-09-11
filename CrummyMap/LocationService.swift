//
//  LocationService.swift
//  CrummyMap
//
//  Created by Michelle Cervenka 9/9/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import Foundation
import MapKit

typealias JSONDictionary = [String: Any]
typealias LocationResult = (Result<[Location]>) -> Void

enum Result<T> {
    case success(T)
    case failure(Error)
}

public enum LocationServiceError: Error {
    case malformedURL
    case unexpectedHttpResponse
}

extension LocationServiceError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString("Oops!  Something crummy happened!", comment: "general error message")
    }
}

class LocationService {

    let defaultSession = URLSession(configuration: .default)

    var dataTask: URLSessionDataTask?

    private lazy var openCageAPIKey: String? = {
        return APIKey.openCage.valueForAPIKey()
    }()

    // Cancel any previous searches
    func cancel() {
        dataTask?.cancel()
    }

    func search(searchTerm: String, completion: @escaping LocationResult) {

        if let openCageAPIKey = openCageAPIKey,
            var urlComponents = URLComponents(string: "http://api.opencagedata.com/geocode/v1/json") {

            let searchTermQuery = URLQueryItem(name: "q", value: searchTerm)
            let apiKeyQuery = URLQueryItem(name: "key", value: openCageAPIKey)
            urlComponents.queryItems = [searchTermQuery, apiKeyQuery]

            guard let url = urlComponents.url else {
                completion(Result.failure(LocationServiceError.malformedURL))
                return
            }

            //Make new request to get search results
            dataTask = defaultSession.dataTask(with: url) { data, response, error in

                //Checking for error
                if let error = error {
                    print("Location Service: Error while search locations: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(Result.failure(error))
                    }
                    return
                }

                //Checking HTTP response
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                        print("Location Service: HTTP error")
                        DispatchQueue.main.async {
                            completion(Result.failure(LocationServiceError.unexpectedHttpResponse))
                        }
                        return
                }

                //Checking response content
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data) as? JSONDictionary,
                    let jsonResults = json?["results"] as? [Any] else {
                        print("Location Service: No data received or misformed")
                        DispatchQueue.main.async {
                            completion(Result.success([]))
                        }
                        return
                }

                //Transform JSON to locations
                let locations: [Location?] = jsonResults.map({ (item: Any) -> Location?  in
                    if let locationDictionary = item as? JSONDictionary,
                        let location = Location(json: locationDictionary) {
                        return location
                    }
                    return nil
                })

                DispatchQueue.main.async {
                    completion(Result.success(locations.flatMap { $0 }))
                }
            }

            dataTask?.resume()
        }
    }
}
