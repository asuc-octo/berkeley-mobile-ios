//
//  BerkeleyMobile+Injection.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/7/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FactoryKit
import Foundation

extension Container {
    var calendarViewModel: Factory<CalendarViewModel> {
        self { CalendarViewModel() }.shared
    }

    #if DEBUG
    var debugViewModel: Factory<DebugViewModel> {
        self { DebugViewModel(feedbackFormPresenter: self.feedbackFormPresenter()) }
    }
    #endif

    var diningHallsViewModel: Factory<DiningHallsViewModel> {
        self { DiningHallsViewModel() }.singleton
    }

    var eventsViewModel: Factory<EventsViewModel> {
        self { @MainActor in
            EventsViewModel()
        }.shared
    }

    var feedbackFormPresenter: Factory<FeedbackFormPresenter> {
        self { FeedbackFormPresenter(feedbackFormViewModel: self.feedbackFormViewModel()) }
    }

    var feedbackFormViewModel: Factory<FeedbackFormViewModel> {
        self { FeedbackFormViewModel() }
    }

    var guidesViewModel: Factory<GuidesViewModel> {
        self { GuidesViewModel() }.singleton
    }

    var homeDrawerPinViewModel: Factory<HomeDrawerPinViewModel> {
        self { HomeDrawerPinViewModel() }.shared
    }

    var homeViewModel: Factory<HomeViewModel> {
        self { @MainActor in
            HomeViewModel()
        }.singleton
    }

    var mapMarkersDropdownViewModel: Factory<MapMarkersDropdownViewModel> {
        self { MapMarkersDropdownViewModel() }.shared
    }

    var mapUserLocationButtonViewModel: Factory<MapUserLocationButtonViewModel> {
        self { MapUserLocationButtonViewModel() }.shared
    }

    var menuItemIconCacheManager: Factory<MenuItemIconCacheManager> {
        self { MenuItemIconCacheManager() }.shared
    }

    var newsDataViewModel: Factory<NewsDataViewModel> {
        self { @MainActor in
            NewsDataViewModel()
        }.shared
    }

    var resourcesViewModel: Factory<ResourcesViewModel> {
        self { ResourcesViewModel() }.shared
    }

    var rsfOccupancyViewModel: Factory<GymOccupancyViewModel> {
        self { GymOccupancyViewModel(location: .rsf) }.singleton
    }

    var safetyViewModel: Factory<SafetyViewModel> {
        self { SafetyViewModel() }.shared
    }

    var searchViewModel: Factory<SearchViewModel> {
        self { SearchViewModel { _ in } choosePlacemark: { _ in } }.shared
    }

    var stadiumOccupancyViewModel: Factory<GymOccupancyViewModel> {
        self { GymOccupancyViewModel(location: .stadium) }.singleton
    }

    var weatherDataViewModel: Factory<WeatherDataViewModel> {
        self { @MainActor in
            WeatherDataViewModel()
        }.shared
    }
}
