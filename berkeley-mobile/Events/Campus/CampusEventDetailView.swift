import SwiftUI
import EventKit

struct CampusEventDetailView: View {
    let event: EventCalendarEntry
    @State private var learnMoreAlert = false
    @State private var registerAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Event overview card
                EventOverviewCard(event: event)
                    .modifier(BoxViewModifier())
                
                // Description card
                if let description = event.descriptionText {
                    DescriptionView(description: description)
                        .modifier(BoxViewModifier())
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
                        addToDeviceCalendar()
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
    
    private func addToDeviceCalendar() {
        let eventStore = EKEventStore()
        
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                handleCalendarAccess(granted: granted, eventStore: eventStore)
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                handleCalendarAccess(granted: granted, eventStore: eventStore)
            }
        }
    }
    
    private func handleCalendarAccess(granted: Bool, eventStore: EKEventStore) {
        if granted {
            let ekEvent = EKEvent(eventStore: eventStore)
            ekEvent.title = event.name
            ekEvent.startDate = event.date
            ekEvent.endDate = event.end ?? event.date.addingTimeInterval(3600) // Default 1 hour if no end time
            ekEvent.notes = event.descriptionText
            
            if let location = event.location {
                ekEvent.location = location
            }
            
            ekEvent.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
                try eventStore.save(ekEvent, span: .thisEvent)
            } catch {
                print("Error saving event to calendar: \(error)")
            }
        }
    }
}

struct EventOverviewCard: View {
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
                Image("Clock")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(BMColor.blackText))
                    .frame(width: 16, height: 16)
                
                Text(event.dateString)
                    .font(Font(BMFont.light(12)))
                    .foregroundColor(Color(BMColor.blackText))
            }
            
            if let location = event.location {
                HStack {
                    Image("Placemark")
                        .resizable()
                        .frame(width: 16, height: 16)
                    
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

// Preview provider
struct CampusEventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample event for preview
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
        
        return CampusEventDetailView(event: sampleEvent)
    }
}
