//
//  MapMarkersDropdownView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/7/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct MapMarkersDropdownButton: View {
    @State private var isPresentingMapMarkersDropdownView = false
    var selectedMapMakerTypeCompletionHandler: (MapMarkerType) -> Void
    
    var body: some View {
        Button(action: {
            isPresentingMapMarkersDropdownView.toggle()
        }) {
            Image(systemName: "chevron.down.circle")
                .background(Color(uiColor: BMColor.modalBackground))
                .foregroundColor(Color(uiColor: BMColor.blackText))
                .font(.system(size: 42))
                .clipShape(Circle())
        }
        .fullScreenCover(isPresented: $isPresentingMapMarkersDropdownView) {
            MapMarkersDropdownView(selectedMapMakerTypeCompletionHandler: selectedMapMakerTypeCompletionHandler)
                .background(BMBackgroundBlurView().ignoresSafeArea(.all))
        }
        .shadow(color: Color(uiColor: UIColor.black).opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

//MARK: - MapMarkersDropdownView
struct MapMarkersDropdownView: View {
    @Environment(\.dismiss) private var dismiss
    private let mapMarkerTypes = MapMarkerType.allCases.sorted(by: { $0.rawValue < $1.rawValue })
    var selectedMapMakerTypeCompletionHandler: (MapMarkerType) -> Void
    
    var body: some View {
        ZStack {
            List(mapMarkerTypes, id: \.self) { type in
                if type != MapMarkerType.none {
                    HStack(spacing: 15){
                        Image(uiImage: type.icon())
                        Text(type.rawValue)
                            .fontWeight(.semibold)
                            .font(.title3)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .frame(height: 40)
                    .onTapGesture {
                        selectedMapMakerTypeCompletionHandler(type)
                        dismiss()
                    }
                }
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            
            dismissButton
        }
    }
    
    private var dismissButton: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray.opacity(0.7))
                        .font(.system(size: 35))
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 0))
            .background(.ultraThinMaterial)
            Spacer()
        }
    }
}

//MARK: - BMBackgroundBlurView
fileprivate struct BMBackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}


#Preview("MapMarkersDropdownView") {
    MapMarkersDropdownView(selectedMapMakerTypeCompletionHandler: {_ in})
}

#Preview("MapMarkersDropdownButton") {
    MapMarkersDropdownButton(selectedMapMakerTypeCompletionHandler: {_ in})
}
