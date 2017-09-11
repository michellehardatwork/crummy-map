//
//  MapViewController.swfit
//  CrummyMap
//
//  Created by Michelle Cervenka 9/9/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import UIKit
import MapKit

private enum SearchViewState {
    case close
    case open
}

// MARK: - View Controller

class MapViewController: UIViewController {

    @IBOutlet weak var searchResultsView: UIView!
    @IBOutlet weak var mapView: MKMapView!

    fileprivate var searchResultsHeightConstraint: NSLayoutConstraint?

    fileprivate var searchViewCurrentState = SearchViewState.close {
        didSet {
            switch searchViewCurrentState {
            case .close:
                searchResultsHeightConstraint?.isActive = false
                UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)

                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
                break
            case .open:
                searchResultsHeightConstraint?.isActive = true

                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Adding constraint to control view animation when switching between
        //searching and viewing map
        searchResultsHeightConstraint = searchResultsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.85, constant: 0)
        searchResultsHeightConstraint?.isActive = false

        mapView.delegate = self
        setupMap()
    }

    private func setupMap() {

        //Add tap gesture to close map
        let mapTapGesture = UITapGestureRecognizer()
        mapTapGesture.addTarget(self, action: #selector(mapTouched(recognizer:)))
        mapView.addGestureRecognizer(mapTapGesture)

        //Add OpenStreetMap tile overlays
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.add(overlay, level: MKOverlayLevel.aboveRoads)

        //Default to Austin
        mapView.centerTo(CLLocationCoordinate2DMake(30.284458, -97.7342105))
    }

    @objc private func mapTouched(recognizer: UIPanGestureRecognizer) {
        searchViewCurrentState = .close
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchViewController = segue.destination as? SearchViewController {
            searchViewController.searchViewDelegate = self
        }
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: overlay)
        }

        return MKOverlayRenderer()
    }
}

// MARK: SearchViewDelegate

extension MapViewController: SearchViewDelegate {

    func searchViewDidBeginSearching(_ searchViewController: SearchViewController) {
        searchViewCurrentState = .open
    }

    func searchViewDidEndSearching(_ searchViewController: SearchViewController) {
        searchViewCurrentState = .close
    }

    func searchView(_ searchViewController: SearchViewController, didSelectLocation location: Location) {
        mapView.add(location)
    }
}

extension MKMapView {

    func add(_ location: Location) {
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = location.degrees

        removeAnnotations(annotations)
        addAnnotation(annotation)
        centerTo(annotation.coordinate)
    }

    func centerTo(_ coordinates: CLLocationCoordinate2D) {
        let spanX = 0.007
        let spanY = 0.007

        let newRegion = MKCoordinateRegion(center:coordinates, span: MKCoordinateSpanMake(spanX, spanY))
        setRegion(newRegion, animated: true)
    }
}
