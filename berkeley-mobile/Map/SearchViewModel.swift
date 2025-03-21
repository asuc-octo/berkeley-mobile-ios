//
//  SearchViewModel.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import MapKit

// MARK: - SearchResultsViewDelegate protocol

protocol SearchResultsViewDelegate {
    func choosePlacemark(_ placemark: MapPlacemark)
    func chooseMapMarker(_ placemark: MapMarker)
}


// MARK: - SearchResultsState

enum SearchResultsState {
    case idle // When SearchBar text field is empty (includes inital state)
    case loading
    case populated([MapPlacemark])
    case empty
    case error(Error)
    
    var placemarks: [MapPlacemark] {
        switch self {
        case .populated(let placemarks):
            return placemarks
        default:
            return []
        }
    }
}


// MARK: - SearchViewModel

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var isSearchBarFocused = false
    @Published var state = SearchResultsState.idle
    var chooseMapMarker: (MapMarker) -> Void
    var choosePlacemark: (MapPlacemark) -> Void
    
    init(chooseMapMarker: @escaping (MapMarker) -> Void, choosePlacemark: @escaping (MapPlacemark) -> Void) {
        self.chooseMapMarker = chooseMapMarker
        self.choosePlacemark = choosePlacemark
    }
    
    // MARK: - SearchBarView's funcs:
    func clearSearchText() {
        searchText = ""
    }
    
    func searchLocations(_ keyword: String, completion: (([MapPlacemark], Error?) -> Void)? = nil) {
        state = .loading
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else {
                return
            }
            
            let data = DataManager.shared.searchable
            let filtered = data.filter { ($0.searchName.lowercased().contains(keyword.lowercased()) && $0.location.0 != 0 && $0.location.1 != 0) }
            var placemarks = [MapPlacemark]()
            
            for item in filtered {
                let cl = CLLocation(latitude: CLLocationDegrees(item.location.0), longitude: CLLocationDegrees(item.location.1))
                let place = MapPlacemark(loc: cl, name: item.searchName, locName: item.locationName, item: item)
                placemarks.append(place)
            }
            DispatchQueue.main.async {
                self.updatePlacemarksList(newPlacemarks: placemarks, error: nil)
                completion?(placemarks, nil)
            }
        }
    }
    
    // MARK: - SearchResultsView's funcs:
    func updatePlacemarksList(newPlacemarks: [MapPlacemark]?, error: Error?) {
        if let error {
            state = .error(error)
            return
        }
        
        guard let newPlacemarks, !newPlacemarks.isEmpty else {
            if searchText.isEmpty {
                state = .idle
            } else {
                state = .empty
            }
            return
        }
        
        state = .populated(newPlacemarks)
    }
    
    func selectListRow(_ placemark: MapPlacemark) {
        searchText = ""
        isSearchBarFocused = false
        
        if let mapMarker = placemark.item as? MapMarker {
            chooseMapMarker(mapMarker)
        }
        else {
            choosePlacemark(placemark)
        }
    }
}
