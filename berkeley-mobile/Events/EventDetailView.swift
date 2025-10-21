import SwiftUI

struct EventDetailView: View {
    private enum AlertType {
        case learnMore
        case register
    }
    
    @EnvironmentObject var eventsViewModel: EventsViewModel
    
    let event: BMEventCalendarEntry
    
    @State private var alertType: AlertType?
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    BMDetailHeaderView(event: event)
                        .shadowfy()
                        .padding(.top, 20)
                    descriptionSection
                    buttonsSection
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .background(Color(BMColor.modalBackground))
        .toolbar {
            let doesEventExists = eventsViewModel.doesEventExists(for: event)
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    if doesEventExists {
                        eventsViewModel.showDeleteEventFromCalendarAlert(event)
                    } else {
                        eventsViewModel.showAddEventToCalendarAlert(event)
                    }
                }) {
                    Image(systemName: doesEventExists ? "calendar.badge.checkmark" : "calendar.badge.plus")
                }
            }
        }
        .onChange(of: alertType) { type in
            presentLinkAlert(type: type)
        }
    }
    
    @ViewBuilder
    private var descriptionSection: some View {
        if let description = event.descriptionText, !description.isEmpty {
            BMDetailDescriptionView(description: description)
                .shadowfy()
        }
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 16) {
            if event.sourceLink != nil {
                BMActionButton(title: "Learn More") {
                    alertType = .learnMore
                }
            }
            
            if event.registerLink != nil {
                BMActionButton(title: "Register") {
                    alertType = .register
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func presentLinkAlert(type: AlertType?) {
        guard let type else { return }
        
        var message = ""
        var url: URL!
        
        switch type {
        case .learnMore:
            message = "Berkeley Mobile wants to open a web page with more info for this event."
            url = event.sourceLink
        case .register:
            message = "Berkeley Mobile wants to open the web page to register for this event."
            url = event.registerLink
        }
        
        withoutAnimation {
            eventsViewModel.alert = BMAlert(title: "Open in Safari?", message: message, type: .action) {
                UIApplication.shared.open(url)
            }
            alertType = nil
        }
    }
}

// MARK: - BMDetailHeaderView

struct BMDetailHeaderView: View {
    let event: BMEventCalendarEntry
    
    var body: some View {
        ZStack {
            BMCachedAsyncImageView(
                imageURL: event.imageURL,
                placeholderImage: BMConstants.doeGladeImage,
                aspectRatio: .fill,
                widthAndHeight: 330,
                cornerRadius: 10
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                BMCachedAsyncImageView(
                    imageURL: event.imageURL,
                    placeholderImage: BMConstants.doeGladeImage,
                    aspectRatio: .fill,
                    widthAndHeight: 130,
                    cornerRadius: 10
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .shadow(color: .gray, radius: 10)
                
                eventNameView
                VStack(alignment: .leading, spacing: 4) {
                    dateView
                    timeView
                    locationView
                }
                
                Spacer()
            }
            .padding()
            .font(Font(BMFont.light(12)))
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var eventNameView: some View {
        HStack {
            Text(event.name)
                .font(Font(BMFont.bold(20)))
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
    
    private var dateView: some View {
        let datePart = event.dateString.components(separatedBy: " / ").first ?? ""
        return EventDetailRow(systemImageName: "calendar", text: datePart)
    }
    
    private var timeView: some View {
        let timePart = event.dateString.components(separatedBy: " / ").last ?? ""
        return EventDetailRow(systemImageName: "clock", text: timePart)
    }
    
    @ViewBuilder
    private var locationView: some View {
        if let location = event.location, !location.isEmpty {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 16))
                
                Text(location)
                    .font(Font(BMFont.regular(12)))
            }
        }
    }
}

struct EventDetailRow: View {
    let systemImageName: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .font(.system(size: 16))
            Text(text)
                .font(Font(BMFont.regular(12)))
        }
    }
}

// MARK: - BMDetailDescriptionView

struct BMDetailDescriptionView: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(Font(BMFont.bold(16)))
                .padding(.bottom, 8)
            
            Text(description)
                .font(Font(BMFont.light(12)))
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    EventDetailView(event: BMEventCalendarEntry.sampleEntry)
        .environmentObject(EventsViewModel())
}


