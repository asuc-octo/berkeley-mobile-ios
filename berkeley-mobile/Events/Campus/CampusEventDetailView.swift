import SwiftUI
import EventKit

struct CampusEventDetailView: View {
    @State private var learnMoreAlert = false
    @State private var registerAlert = false
    @State private var calendarSuccess = false
    @State private var calendarError = false
    let eventManager: EventManager
    let event: EventCalendarEntry
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Event overview card
                EventOverviewView(event: event)
                    .modifier(Cardify())
                
                // Description card
                if let description = event.descriptionText {
                    DescriptionView(description: description)
                        .modifier(Cardify())
                }
                
                // Buttons
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
                        EventManager.shared.addEventToCalendar(calendarEvent: event) { success in
                            if success {
                                calendarSuccess = true
                            } else {
                                calendarError = true
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
            .padding(.horizontal)
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

// MARK: - EventOverviewView
struct EventOverviewView: View {
    let event: EventCalendarEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(event.name)
                    .font(Font(BMFont.bold(24)))
                    .foregroundColor(Color(BMColor.blackText))
                    .fixedSize(horizontal: false, vertical: true)
            
                Spacer()
            }
            
            HStack {
                Image(systemName: "clock")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(BMColor.blackText))
                    .frame(width: 16, height: 16)
                
                Text(event.date, style: .date)
                    .font(Font(BMFont.light(12)))
                    .foregroundColor(Color(BMColor.blackText))
            }
            
            if let location = event.location {
                HStack {
                    Image(systemName: "mappin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color(.black))
                    
                    Text(location)
                        .font(Font(BMFont.light(12)))
                        .foregroundColor(Color(BMColor.blackText))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DescriptionView: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            Text(description)
                .font(.caption)
                .fontWeight(.light)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BoxViewModifier: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .foregroundStyle(.white)
            .font(.subheadline)
            .fontWeight(.semibold)
            .background(Color(.darkGray))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
        
#Preview {
    let sampleEvent = EventCalendarEntry(
        name: "Sample Event",
        date: Date(),
        end: Date().addingTimeInterval(7200),
        descriptionText: "I wrote a script, which would ideally take about 480 hours to runs (It has to do a same thing 60 times.) But the problem is I have to use a VPN Client to get to the network before connecting to the machine. The Client automatically closes after 10 hours, closing my console and thus my script. So my question is:",
        location: "Sproul Plaza",
        registerLink: "https://berkeley.edu/register",
        imageURL: nil,
        sourceLink: "https://berkeley.edu/event",
        type: "Default"
    )
    CampusEventDetailView(eventManager: EventManager(), event: sampleEvent)
}
