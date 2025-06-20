//
//  View+Extension.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

// MARK: - Global Functions

func withoutAnimation(action: @escaping () -> Void) {
    var transaction = Transaction()
    transaction.disablesAnimations = true
    withTransaction(transaction) {
        action()
    }
}


// MARK: - Button Styles

struct BMControlButtonStyle: ButtonStyle {
    static let widthAndHeight: CGFloat = 45
    
    var widthAndHeight: CGFloat = BMControlButtonStyle.widthAndHeight
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .addBadgeStyle(widthAndHeight: widthAndHeight)
    }
}

struct BMBadgeStyleViewModifer: ViewModifier {
    let widthAndHeight: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: widthAndHeight, height: widthAndHeight)
            .background(
                Circle()
                    .fill(.thickMaterial)
            )
            .overlay(
                Circle()
                    .strokeBorder(.gray, lineWidth: 0.5)
            )
    }
}

struct SearchResultsListRowButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? .gray.opacity(0.3) : .white.opacity(0.001))
            .clipShape(.rect(cornerRadius: 12))
    }
}


// MARK: - View Positioning

struct PositionAtTopModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea(.all)
        
            VStack {
                content
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                Spacer()
            }
        }
    }
}

struct Shadowfy: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(BMColor.cardBackground)) 
            )
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 0)
    }
}


// MARK: - Other View Componments

struct EventsContextMenuModifier: ViewModifier {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    
    let event: BMEventCalendarEntry
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                contextMenu
            }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        if eventsViewModel.doesEventExists(for: event) {
            Button(action: {
                eventsViewModel.deleteEvent(for: event)
            }) {
                Label("Delete Event From Calendar", systemImage: "calendar.badge.minus")
            }
        } else {
            Button(action: {
                eventsViewModel.addAcademicEventToCalendar(event)
            }) {
                Label("Add Event To Calendar", systemImage: "calendar.badge.plus")
            }
        }
    }
}

struct BMAlertsOverlayViewModifier: ViewModifier {
    @Binding var alert: BMAlert?
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $alert) { alert in
            BMAlertView(alert: alert)
                .presentationBackground(Color.clear)
        }
    }
}


// MARK: - View Extension

extension View {
    func positionedAtTop() -> some View {
        modifier(PositionAtTopModifier())
    }
  
    func shadowfy() -> some View {
        modifier(Shadowfy())
    }
    
    func addEventsContextMenu(event: BMEventCalendarEntry) -> some View {
        modifier(EventsContextMenuModifier(event: event))
    }
    
    func addBadgeStyle(widthAndHeight: CGFloat) -> some View {
        modifier(BMBadgeStyleViewModifer(widthAndHeight: widthAndHeight))
    }
    
    func alertsOverlayView(alert: Binding<BMAlert?>) -> some View {
        modifier(BMAlertsOverlayViewModifier(alert: alert))
    }
}
