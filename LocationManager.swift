//
//  LocationManager.swift
//  Widgets
//
//  Created by Anna Liu on 8/5/23.
//
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var lastKnownLocation: CLLocation?

    func startUpdating() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        lastKnownLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorized {
            manager.startUpdatingLocation()
        }
    }
}
