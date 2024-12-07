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
        VStack(alignment: .leading) {
            Color.orange
                .frame(height: 10)
            undergraduateProgramsView
        }
        .background(Color(uiColor: BMColor.cardBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 300)
        .compositingGroup()
        .shadow(color: .gray.opacity(0.25), radius: 10, x: 0, y: 0)
        
        VStack(alignment: .leading) {
            Color.orange
                .frame(height: 10)
            graduateProgramsView
        }
        .background(Color(uiColor: BMColor.cardBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 300)
        .compositingGroup()
        .shadow(color: .gray.opacity(0.25), radius: 10, x: 0, y: 0)
    }
    
    private var undergraduateProgramsView: some View {
        VStack(alignment: .leading) {
            Text("Undergraduate Programs")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                .bold()
                .underline()
            Text("• Chemistry, B.S.")
            Text("• Chemical Engineering, B.S.")
            Text("• Chemical Biology, B.S.")
            Text("• Chemistry, B.A.")
        }
        .font(Font(BMFont.regular(14)))
        .padding()
    }
    
    private var graduateProgramsView: some View {
        VStack(alignment: .leading) {
            Text("Graduate Programs")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                .bold()
                .underline()
            Text("• Chemistry, Ph.D")
            Text("• Chemical Engineering, Ph.D")
            Text("• Chemical Biology Graduate Program")
            Text("• Master of Product Development")
            Text("• Master of Bioprocess Engineering")
            Text("• Master of Molecular Science & Software Engineering")
        }
        .font(Font(BMFont.regular(14)))
        .padding()
    }
}

#Preview {
    ResourcesSubTopicView()
}
