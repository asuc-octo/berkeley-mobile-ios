import SwiftUI
import EventKit

struct CampusEventDetailView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var learnMoreAlert = false
    @State private var registerAlert = false
    
    let event: EventCalendarEntry
    
    var body: some View {
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
            .padding(EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 0))
            
            ScrollView {
                VStack(spacing: 16) {
                    BMDetailHeaderView(event: event)
                        .shadowfy()
                        .padding(.top, 20)
                    
                    if let description = event.descriptionText, !description.isEmpty {
                        BMDetailDescriptionView(description: description)
                            .shadowfy()
                    }
                    
                    VStack(spacing: 16) {
                        if event.sourceLink != nil {
                            BMActionButton(title: "Learn More") {
                                learnMoreAlert = true
                            }
                        }
                        
                        if event.registerLink != nil {
                            BMActionButton(title: "Register") {
                                registerAlert = true
                            }
                        }
                        
                        BMActionButton(title: "Add To Calendar") {
                            eventsViewModel.showAddEventToCalendarAlert(event)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .background(Color(BMColor.modalBackground))
        .alert("Open Safari?", isPresented: $learnMoreAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Open") {
                if let url = event.sourceLink {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Berkeley Mobile wants to open a web page with more info for this event.")
        }
        .alert("Open Safari?", isPresented: $registerAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Open") {
                if let url = event.registerLink {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Berkeley Mobile wants to open the web page to register for this event.")
        }
    }
}


// MARK: - BMDetailHeaderView

struct BMDetailHeaderView: View {
    let event: EventCalendarEntry
    
    var body: some View {
        ZStack {
            BMCachedAsyncImageView(imageURL: event.imageURL, placeholderImage: BMConstants.doeGladeImage, aspectRatio: .fit, widthAndHeight: 250, cornerRadius: 10)
            
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                BMCachedAsyncImageView(imageURL: event.imageURL, placeholderImage: BMConstants.doeGladeImage, aspectRatio: .fit, widthAndHeight: 200, cornerRadius: 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .shadow(color: .gray, radius: 10)
                    .rotation3DEffect(.degrees(20), axis: (x: 0, y: 1, z: 0))
                
                HStack {
                    Text(event.name)
                        .font(Font(BMFont.bold(20)))
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "clock")
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Text(event.dateString)
                        .font(Font(BMFont.light(12)))
                        .foregroundColor(Color(BMColor.blackText))
                }
                
                if let location = event.location {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        
                        Text(location)
                            .font(Font(BMFont.light(12)))
                    }
                }
            }
            .padding()
            .font(Font(BMFont.light(12)))
            .foregroundColor(Color(BMColor.blackText))
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: 275)
    }
}

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
