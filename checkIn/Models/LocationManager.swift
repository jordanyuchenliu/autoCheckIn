//
//  LocationManager.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-12-03.
//

import CoreLocation
import Foundation



class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        print(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
    }
}
