//
//  APIKeys.swift
//  CrummyMap
//
//  Created by Cervenka, Michelle on 9/10/17.
//  Copyright © 2017 Cervenka, Michelle. All rights reserved.
//

import Foundation

enum APIKey: String {
    case openCage = "OPEN_CAGE_API_TOKEN"

    func valueForAPIKey() -> String? {
        // Get the file path for keys.plist
        let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist")

        // Put the keys in a dictionary
        let plist = NSDictionary(contentsOfFile: filePath!)

        // Pull the value for the key
        return plist?.object(forKey: self.rawValue) as? String
    }
}
