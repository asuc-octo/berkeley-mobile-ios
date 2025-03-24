//
//  MapMarkersDropdownView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/7/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI


class MapMarkersDropdownViewModel: ObservableObject {
    @Published var selectedFilterIndex = 0
    @Published var mapMarkerTypes = MapMarkerType.allCases
    
    var selectedMapMarkerUIImage: UIImage {
        mapMarkerTypes[selectedFilterIndex].icon()
    }
    
    func sortMapMarkerTypes(basedOn filters: [Filter<[MapMarker]>]) {
        let filterLabels = filters.map { $0.label }
        mapMarkerTypes = filterLabels.compactMap { MapMarkerType(rawValue: $0) }
    }
}

struct MapMarkersDropdownButton: View {
    @EnvironmentObject var viewModel: MapMarkersDropdownViewModel
    @State private var isPresentingMapMarkersDropdownView = false

    var selectedMapMakerTypeCompletionHandler: () -> Void
    
    private let widthAndHeight: CGFloat = 50
    
    var body: some View {
        Button(action: {
            isPresentingMapMarkersDropdownView.toggle()
        }) {
            Image(uiImage: viewModel.selectedMapMarkerUIImage)
        }
        .buttonStyle(BMControlButtonStyle())
        .fullScreenCover(isPresented: $isPresentingMapMarkersDropdownView) {
            MapMarkersDropdownView(selectedMapMakerTypeCompletionHandler: selectedMapMakerTypeCompletionHandler)
                .background(BMBackgroundBlurView().ignoresSafeArea(.all))
        }
    }
}


// MARK: - MapMarkersDropdownView

struct MapMarkersDropdownView: View {
    @EnvironmentObject var viewModel: MapMarkersDropdownViewModel
    @Environment(\.dismiss) private var dismiss
  
    var selectedMapMakerTypeCompletionHandler: () -> Void
    
    var body: some View {
        ZStack {
            List(Array(viewModel.mapMarkerTypes.enumerated()), id: \.offset) { index, type in
                Button(action: {
                    viewModel.selectedFilterIndex = index
                    selectedMapMakerTypeCompletionHandler()
                    dismiss()
                }) {
                    HStack(spacing: 15) {
                        Image(uiImage: type.icon())
                        Text(type.rawValue)
                            .font(Font(BMFont.medium(20)))
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .frame(height: 40)
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


// MARK: - BMBackgroundBlurView

struct BMBackgroundBlurView: UIViewRepresentable {
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
    MapMarkersDropdownView(selectedMapMakerTypeCompletionHandler: { })
        .environmentObject(MapMarkersDropdownViewModel())
}

#Preview("MapMarkersDropdownButton") {
    MapMarkersDropdownButton(selectedMapMakerTypeCompletionHandler: { })
        .environmentObject(MapMarkersDropdownViewModel())
}
