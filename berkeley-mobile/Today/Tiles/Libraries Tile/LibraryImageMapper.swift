//
//  LibraryImageMapper.swift
//  berkeley-mobile
//
//  Created by Lewis Yang on 4/27/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import Foundation

/// Maps library names to their corresponding image URLs from https://www.lib.berkeley.edu/hours
struct LibraryImageMapper {
    
    /// Returns the image URL for a given library name from the Berkeley Library website
    /// If no mapping exists, returns the library's stored imageURL or nil
    static func imageURL(for library: BMLibrary) -> URL? {
        // First, try to get from the static mapping
        if let mappedURL = imageURLFromName(library.name) {
            return mappedURL
        }
        
        // Fall back to the library's stored imageURL from Firebase
        return library.imageURL
    }
    
    /// Whether the library is listed on https://www.lib.berkeley.edu/hours. Firestore still has
    /// entries for libraries that have since closed or merged (e.g. Career Counseling Library).
    static func isListedOnHoursPage(_ library: BMLibrary) -> Bool {
        imageMapping[hoursPageName(for: library.name)] != nil
    }
    
    /// Firestore names for libraries that the hours page lists under a different name
    private static let firestoreNameAliases: [String: String] = [
        "bampfa film library & study center": "berkeley art museum and pacific film archive",
        "bancroft library/university archives": "bancroft library",
        "chemistry and chemical engineering library": "chemistry, astronomy & physics library",
        "engineering library": "engineering & mathematical sciences library",
        "south/southeast asia library": "south/southeast asia library (study only)",
    ]
    
    // Map library names to their image URLs from https://www.lib.berkeley.edu/hours
    // These URLs should be updated to match the actual image URLs from the Berkeley Library website
    private static let imageMapping: [String: String] = [
        // Main Libraries
        "doe library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-Doe-05041.jpg.webp?itok=3yp7XnLo",
        "moffitt library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-moffitt-.jpg.webp?itok=rDFDP0mS",
        "bancroft library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/BANC-06515.jpg.webp?itok=koeFZNaE",
        
        // Branch Libraries
        "berkeley art museum and pacific film archive": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-BAMPFA-.jpg.webp?itok=k83jWUHa",
        "berkeley law library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-law-.jpg.webp?itok=HoKRxYSv",
        "bioscience, natural resources & public health library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-02/Bioscience.jpg.webp?itok=UWkVN47d",
        "business library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-BUSINESS-02.jpg.webp?itok=9F1P2hpI",
        "chemistry, astronomy & physics library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-CHEM-.jpg.webp?itok=hjlcMvpH",
        "earth sciences & map library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-EARTH-03.jpg.webp?itok=GOOESJRa",
        "east asian library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-EAL-4692.jpg.webp?itok=7pfe3ClH",
        "engineering & mathematical sciences library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2025-05/web-engineering-exterior-01296.jpg.webp?itok=p_fZjaf9",
        "environmental design library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-ENVI-.jpg.webp?itok=tsZHxCT4",
        "ethnic studies library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-ETHNIC-.jpg.webp?itok=sl-E6K0x",
        "graduate theological union library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-theo-.jpg.webp?itok=52DGj7YG",
        "institute of governmental studies library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2023-03/IGS-06213.jpg.webp?itok=wIVssQ2x",
        "institute of transportation studies library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-transportation-.jpg.webp?itok=pALCIvTx",
        "interlibrary loan": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-10/hours-Doe-ILL.jpg.webp?itok=GLfV13t7",
        "main (gardner) stacks": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-Doe-05041_2.jpg.webp?itok=A4wveHVs",
        "morrison library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-Doe-05041_1.jpg.webp?itok=sOEDY9fE",
        "music library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-music-02.jpg.webp?itok=lwEAYBtm",
        "newspapers & microforms library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-Doe-05041_6.jpg.webp?itok=ntXbvIKb",
        "privileges desk": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-10/hours-Doe-Privdesk.jpg.webp?itok=pUX4ZT6L",
        "social research library": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-social-.jpg.webp?itok=xQuUv-rj",
        "south/southeast asia library (study only)": "https://www.lib.berkeley.edu/sites/default/files/styles/library_hours_image/public/2022-03/hours-Doe-05041_3.jpg.webp?itok=0vFkdCJd",
    ]
    
    /// Normalizes a Firestore library name (lowercased, trimmed) to its name on the hours page
    private static func hoursPageName(for name: String) -> String {
        let normalizedName = name.lowercased().trimmingCharacters(in: .whitespaces)
        return firestoreNameAliases[normalizedName] ?? normalizedName
    }
    
    private static func imageURLFromName(_ name: String) -> URL? {
        let normalizedName = hoursPageName(for: name)

        // Try exact match first
        if let urlString = imageMapping[normalizedName],
           let url = URL(string: urlString) {
            return url
        }
        
        // Try partial match (if library name contains any key)
        for (key, urlString) in imageMapping {
            if normalizedName.contains(key) || key.contains(normalizedName) {
                if let url = URL(string: urlString) {
                    return url
                }
            }
        }
        
        return nil
    }
}
