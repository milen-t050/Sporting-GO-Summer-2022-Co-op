//
//  LocationManager.swift
//  Sporting GO
//
//  Created by AppleSHSM on 2022-07-22.
//

import SwiftUI
import CoreLocation
import MapKit

// Mark: Combine  Framework to watch Textfield Change
import Combine

class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate {
    //MARK: Properties
    @Published var mapView: MKMapView = .init()
    @Published var manager: CLLocationManager = .init()
    
    // Mark: Search Bar Text
    @Published var searchText: String = ""
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    //Mark: User Location
    @Published var userLocation:  CLLocation?
    
    // Mark: Final Location
    @Published var pickedLocation: CLLocation?
    @Published var pickedPlaceMarker: CLPlacemark?
    
    override init() {
        super.init()
        //MARK: Setting Delegates
        manager.delegate = self
        mapView.delegate = self
        
        //Mark: Requesting Location Access
        manager.requestWhenInUseAuthorization()
        
        //Mark: Search Textfield Watching
        cancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if value != "" {
                    self.fetchPlaces(value: value)
                }else {
                    self.fetchedPlaces = nil
                }
            })
    }
    
    func fetchPlaces(value: String) {
        //Mark: Fetching places using MKLocalSearch
        Task{
            do{
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()
                
                let response = try await MKLocalSearch(request: request).start()
                //Use Mainactor to publish changes in Main Thread
                await MainActor.run(body: {
                    self.fetchedPlaces = response.mapItems.compactMap({ item -> CLPlacemark? in
                        return item.placemark
                    })
                })
            }
            catch{
                //Handle Errors
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //Handle error
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }
        self.userLocation = currentLocation
    }
    
    //MARK: Location Authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedAlways: manager.requestLocation()
        case .authorizedWhenInUse: manager.requestLocation()
        case .denied: handleLocationError()
        case .notDetermined: manager.requestWhenInUseAuthorization()
        default: ()
        }
    }
    
    func handleLocationError() {
        //Handle Error
    }
    
    //Mark: Add Draggable Pin to Mapview
    func addDraggablePin(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "You are here!"
        
        mapView.addAnnotation(annotation)
    }
    
    //Mark: Enabling Dragging
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "DELIVERYPIN")
        marker.isDraggable = true
        marker.canShowCallout = false
        
        return marker
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        print("Updated")
        guard let newLocation = view.annotation?.coordinate else {
            return
        }
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        updatePlacemark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude))
    }
    
    func updatePlacemark(location: CLLocation) {
        Task{
            do{
                guard let place = try await reverseLocationCoordinates(location: location) else {
                    return
                }
                await MainActor.run(body: {
                    self.pickedPlaceMarker = place
                })
            }
            catch{
                //Handle Errors
            }
        }
    }
    
    //Display new Location
    func reverseLocationCoordinates(location: CLLocation) async throws -> CLPlacemark? {
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        return place
    }
}
