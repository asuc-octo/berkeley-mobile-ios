//
//  Course.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/2/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

struct CoursesDocument: Decodable {
    let courses: [Course]
}

struct Course: Decodable {
    let number: String
    let abbreviation: String

    enum CodingKeys: String, CodingKey {
        case number = "course_number", abbreviation
    }
}
