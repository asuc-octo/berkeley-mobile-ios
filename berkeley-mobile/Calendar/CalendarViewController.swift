//
//  CalendarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kViewMargin: CGFloat = 16

/// The main view controller displayed for the Calendar tab.
class CalendarViewController: UIViewController {

    private var eventsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutMargins = UIEdgeInsets(top: 31, left: 16, bottom: 16, right: 16)
        self.view.backgroundColor = Color.modalBackground
        
        setupHeader()
        setupSegmentedControls()
    }

    // Events Label and Blobs
    private func setupHeader() {
        eventsLabel = UILabel()
        eventsLabel.font = Font.bold(30)
        eventsLabel.text = "Events"
        view.addSubview(eventsLabel)
        eventsLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        eventsLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        
        // Blob
        guard let blob = UIImage(named: UIDevice.current.hasNotch ? "BlobTopRight2" : "BlobTopRight1") else { return }
        let aspectRatio = blob.size.width / blob.size.height
        let blobView = UIImageView(image: blob)
        blobView.contentMode = .scaleAspectFit

        view.addSubview(blobView)
        blobView.translatesAutoresizingMaskIntoConstraints = false
        blobView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1 / 1.3).isActive = true
        blobView.heightAnchor.constraint(equalTo: blobView.widthAnchor, multiplier: 1 / aspectRatio).isActive = true
        blobView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blobView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    // SegmentedControl and Page views
    private func setupSegmentedControls() {
        // Add some right-padding to the segmented control so it doesn't overlap with the blob.
        // Don't add this padding for now.
        let segmentedControl = SegmentedControlViewController(pages: [
            Page(viewController: AcademicCalendarViewController(), label: "Academic"),
            Page(viewController: CampusCalendarViewController(), label: "Campus-Wide")
        ], controlInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), centerControl: false)
        self.add(child: segmentedControl)
        segmentedControl.view.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.view.topAnchor.constraint(equalTo: eventsLabel.bottomAnchor, constant: kViewMargin).isActive = true
        segmentedControl.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        segmentedControl.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        segmentedControl.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - Analytics

extension CalendarViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_events_screen", parameters: nil)
    }
}

