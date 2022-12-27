//
//  AdressAutoComplete.swift
//  AdressAutoComplete
//
//  Created by Alex Yeh on 2022-11-12.
//

import SwiftUI
import Combine
import MapKit
import CoreLocation

class AddressAutoComplete : NSObject, ObservableObject {
    
    @Published var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchTerm: String
    @Published var deviceLocation: CLLocationCoordinate2D
    
    let toronto = CLLocation(latitude: 43.65, longitude: -79.38)
    private var cancellables : Set<AnyCancellable> = []
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var currentPromise : ((Result<[MKLocalSearchCompletion], Error>) -> Void)?
    
    init(address: String, location: CLLocationCoordinate2D) {
        searchTerm = address
        deviceLocation = location
        super.init()
        searchCompleter.region = MKCoordinateRegion(center: deviceLocation, latitudinalMeters: 100000, longitudinalMeters: 100000)
        searchCompleter.delegate = self
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])

        $searchTerm
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap({ (currentSearchTerm) in
                self.searchTermToResults(searchTerm: currentSearchTerm)
            })
            .sink(receiveCompletion: { (completion) in
                //handle error
            }, receiveValue: { (results) in
                print(results.count)
                self.locationResults = results// This parses the subtitle to show only results that have United States as the country. You could change this text to be Germany or Brazil and only show results from those countries.
            })
            .store(in: &cancellables)
        
    }

//    override init() {
//        super.init()
//        searchCompleter.delegate = self
//        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])
//
//        $searchTerm
//            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .flatMap({ (currentSearchTerm) in
//                self.searchTermToResults(searchTerm: currentSearchTerm)
//            })
//            .sink(receiveCompletion: { (completion) in
//                //handle error
//            }, receiveValue: { (results) in
//                self.locationResults = results.filter { $0.subtitle.contains("Canada") } // This parses the subtitle to show only results that have United States as the country. You could change this text to be Germany or Brazil and only show results from those countries.
//            })
//            .store(in: &cancellables)
//    }
    
    func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        Future { promise in
            self.searchCompleter.queryFragment = searchTerm
            self.currentPromise = promise
        }
    }
    
}

extension AddressAutoComplete : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            currentPromise?(.success(completer.results))
        }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //could deal with the error here, but beware that it will finish the Combine publisher stream
        //currentPromise?(.failure(error))
    }
}

struct ReversedGeoLocation {
    let streetNumber: String    // eg. 1
    let streetName: String      // eg. Infinite Loop
    let city: String            // eg. Cupertino
    let state: String           // eg. CA
    let zipCode: String         // eg. 95014
    let country: String         // eg. United States
    let isoCountryCode: String  // eg. US

    var formattedAddress: String {
        return """
        \(streetNumber) \(streetName),
        \(city), \(state) \(zipCode)
        \(country)
        """
    }

    // Handle optionals as needed
    init(with placemark: CLPlacemark) {
        self.streetName     = placemark.thoroughfare ?? ""
        self.streetNumber   = placemark.subThoroughfare ?? ""
        self.city           = placemark.locality ?? ""
        self.state          = placemark.administrativeArea ?? ""
        self.zipCode        = placemark.postalCode ?? ""
        self.country        = placemark.country ?? ""
        self.isoCountryCode = placemark.isoCountryCode ?? ""
    }
}
