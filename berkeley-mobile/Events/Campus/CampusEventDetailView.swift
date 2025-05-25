import SwiftUI

struct CampusEventDetailView: View {
    private enum AlertType {
        case learnMore
        case register
    }
    
    @EnvironmentObject var eventsViewModel: EventsViewModel
    
    let event: EventCalendarEntry
    
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
        .onChange(of: alertType) { type in
            presentAlert(type: type)
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
            
            BMActionButton(title: "Add To Calendar") {
                eventsViewModel.showAddEventToCalendarAlert(event)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func presentAlert(type: AlertType?) {
        guard let type else {
            return
        }
        
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
    let event: EventCalendarEntry
    
    var body: some View {
        ZStack {
            BMCachedAsyncImageView(imageURL: event.imageURL, placeholderImage: BMConstants.doeGladeImage, aspectRatio: .fill, widthAndHeight: 330, cornerRadius: 10)
            
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                BMCachedAsyncImageView(imageURL: event.imageURL, placeholderImage: BMConstants.doeGladeImage, aspectRatio: .fill, widthAndHeight: 130, cornerRadius: 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .shadow(color: .gray, radius: 10)
                eventNameView
                timeView
                locationView
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
    
    private var timeView: some View {
        HStack {
            Image(systemName: "clock")
                .font(.system(size: 16))
            
            Text(event.dateString)
                .font(Font(BMFont.regular(12)))
        }
    }
    
    @ViewBuilder
    private var locationView: some View {
        if let location = event.location {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 16))
                
                Text(location)
                    .font(Font(BMFont.regular(12)))
            }
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
     
#Preview {
    let sampleEvent = EventCalendarEntry(
        name: "Exhibit | A Storied Campus: Cal in Fiction",
        date: Date(),
        end: Date().addingTimeInterval(7200),
        descriptionText: "Mention of the name University of California, Berkeley, evokes a range of images: a celebrated institution, a seat of innovation, protests and activism, iconic architecture, colorful traditions, and … literary muse? The campus has long sparked the creativity of fiction writers, inspiring them to use it as a backdrop, a key player, or a barely disguised character within their tales. This exhibition highlights examples of these portrayals through book covers, excerpts, illustrations, photographs, and other materials largely selected from the University Archives and general collections of The Bancroft Library.",
        location: "The Rowell Exhibition Cases, Doe Library, 2nd floo...",
        registerLink: "https://berkeley.edu/register",
        imageURL: "https://events.berkeley.edu/live/image/gid/139/width/200/height/200/crop/1/src_region/0,0,3200,2420/4595_cubanc00006587_ae_a.rev.1698182194.jpg",
        sourceLink: "https://berkeley.edu/event",
        type: "Default"
    )
    CampusEventDetailView(event: sampleEvent)
        .environmentObject(EventsViewModel())
}
