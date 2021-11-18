//
//  Strings.swift
//  berkeley-mobile
//
//  Created by Shawn on 11/10/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

struct Strings {
    static let agree = "Yes"
    static let cancel = "Cancel"
    
    static let defaultName = "Unnamed"
    static let unknown = "Unknown"
    static let notAvailable = "N/A"
    static let defaultLocationBerkeley = "Berkeley, CA"
    static let invalidCharacter = "�"
    
    static let openSafariTitle = "Are you sure you want to open Safari?"
    static let openZoomTitle = "Are you sure you want to open Zoom?"
    
    struct Occupancy {
        static let high = "High"
        static let medium = "Medium"
        static let low = "Low"
    }
    
    struct Filter {
        static let nearby = "Nearby"
        static let open = "Open"
    }
    
    struct Calendar {
        static let addTitle = "Add to Calendar"
        static let addMessage = "Would you like to add this event to your calendar?"
        static let addSuccessTitle = "Successfully added to calendar"
        static let addFailureTitle = "Failed to add to calendar"
        static let addFailureMessage = "Make sure Berkeley Mobile has access to your calendar and try again."
        
        static let todayPrefix = "Today / "
        static let dateFormat = "MM/dd/yyyy"
        static let timeFormat = "h:mm a"
    }
    
    struct Library {
        static let libraryTableHeader = "Find your study spot"
        static let openBookingMessage = "Berkeley Mobile wants to open Libcal to book a study room"
        static let bookButtonTitle = "Book a Study Room"
    }
    
    struct StudyPact {
        static let studyGroupsHeader = "Your Study Groups"
        static let studyGroupsExpand = "See All >"
        static let goToProfileButtonTitle = "Sign In to Get Started With Study Pact!"
        
        static let formNextPageButtonTitle = "Next"
        static let formCloseButtonTitle = "X"
        static let groupSizeSelectHeader = "How many people do you want to study with?"
        static let classSelectHeader = "What class do you want to study for?"
        static let classSelectTextFieldPlaceholder = "Search for a class"
        static let environmentSelectHeader = "What kind of study environment are you looking for?"
        static let environmentQuietButtonTitle = "Quiet"
        static let environmentQuietDescription = "study alone, but keep each other accountable"
        static let environmentCollaborativeButtonTitle = "Collaborative"
        static let environmentCollaborativeDescription = "work together to finish tasks"
        static let reviewHeader = "Let's Review!"
        static let reviewInfoPrefix = "You are looking for a:"
        static func reviewInfo(className: String, size: Int, isQuiet: Bool) -> String {
            return "\(className) study group\nwith \(size) other \(size == 1 ? "person" : "people")\nin a \(isQuiet ? "quiet" : "collaborative") setting"
        }
        static let reviewInfoError = "There was an error with your selection."
        static let formSubmitButtonTitle = "Save Preference"
        static let failedToSubmitTitle = "Unable to Save"
        static let failedToSubmitMessage = "An issue occurred when attempting to save your group preference. Please try again later."
        
        static let 
    }
    
    struct Resources {
        static let resourcesTabHeader = "What do you need?"
        
        static func covidLastUpdated(_ lastUpdated: String) -> String {
            return "Last Updated: \(lastUpdated)"
        }
        static let covidDateFormat = "hh:mm a 'on' MM-dd-yyyy"
        static let covidStatsHeader = "Statistics"
        static let covidStatsTotalCasesLabel = "Total"
        static let covidStatsNewCasesLabel = "New"
        static let bookAppointmentHeader = "Need an appointment?"
        static let bookAppointmentSubheader = "Book an appointment through University Health Services:"
        static let bookAppointmentButtonTitle = "Book Now"
        static let openBookAppointmentMessage = "Berkeley Mobile wants to navigate to the UHS Booking Website"
        static let healthSurveyHeader = "Will you be on campus today?"
        static let healthSurveySubheader = "Complete the health survey before entering campus."
        static let healthSurveyButtonTitle = "Start Health Survey"
        static let openHealthSurveyMessage = "Berkeley Mobile wants to navigate to the Health Survey"
        
        static let covidPageTitle = "Dashboard"
        static let sproulClubPageTitle = "Clubs"
        static let healthPageTitle = "Health"
        static let adminPageTitle = "Admin"
        static let basicNeedsPageTitle = "Basic Needs"
        static let otherPageTitle = "Other"
    }
    
    struct Fitness {
        static func gymClassDescriptionLink(_ link: String) -> String {
            return "Link: \(link)"
        }
        static func gymClassDescriptionTrainer(_ trainer: String) -> String {
            return "Trainer: \(trainer)"
        }
        static let gymClassDescriptionDateFormat = "MMM d"
        static let gymClassDescriptionTimeFormat = "h:mm a"
        
        static let gymWebsiteButtonTitle = "Learn More"
        static let openGymWebsiteMessage = "Berkeley Mobile wants to open this fitness location's website"
        
        static let gymClassesHeader = "Classes"
        static let gymClassesExpand = "See Full Schedule >"
        static let gymClassesMissingData = "No classes found"
        static let openGymClassZoomMesssage = "Berkeley Mobile wants to open an online fitness class in Zoom"
        
        static let fitnessLocationsHeader = "Fitness Locations"
    }
}
