//
//  ResourcesSubTopicView.swift
//  berkeley-mobile
//
//  Created by Sahana Bharadwaj on 11/18/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct ResourcesSubTopicView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Undergraduate Programs")
                    .font(Font.custom("BMFont", size:20))
                Text("Chemistry, B.S.",
                     "Chemical Engineering, B.S."
                     "Chemical Biology, B.S."
                     "Chemistry, B.A.")
                    .font(Font.custom("BMFont", size:20))
            }
        }
    }
}

struct ResourcesSubTopicView_Preview: PreviewProvider {
    static var previews: some View {
        ResourcesSubTopicView()
    }
}
