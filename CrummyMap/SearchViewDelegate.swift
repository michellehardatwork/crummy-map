//
//  SearchDelegate.swift
//  CrummyMap
//
//  Created by Cervenka, Michelle on 9/9/17.
//  Copyright © 2017 Cervenka, Michelle. All rights reserved.
//

import Foundation

protocol SearchViewDelegate: class {

    func searchViewDidBeginSearching(_ searchViewController: SearchViewController) // called when searching begins

    func searchViewDidEndSearching(_ searchViewController: SearchViewController) // called when searching ends

    func searchView(_ searchViewController: SearchViewController, didSelectLocation location: Location) // called when a location is selected
}
