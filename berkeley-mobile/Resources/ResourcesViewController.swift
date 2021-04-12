//
//  ResourcesViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kViewMargin: CGFloat = 16

class ResourcesViewController: UIViewController {
    private var resourcesLabel: UILabel!
    
    private var resourcesCard: CardView!
    private var resourcesTable: FilterTableView = FilterTableView<Resource>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortAlph(item1:item2:))
    private var blobImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.view.backgroundColor = Color.modalBackground
            
        setupHeader()
        setupSegmentedControls()
    }
}

extension ResourcesViewController {
    // Header Label and Blobs
    func setupHeader() {
        resourcesLabel = UILabel()
        resourcesLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        resourcesLabel.numberOfLines = 0
        resourcesLabel.font = Font.bold(30)
        resourcesLabel.text = "What do you need?"
        view.addSubview(resourcesLabel)
        resourcesLabel.translatesAutoresizingMaskIntoConstraints = false
        resourcesLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
        resourcesLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true

        // Blob
        let blob = UIImage(named: "BlobRight")!
        let blobView = UIImageView(image: blob)
        blobView.contentMode = .scaleAspectFit
        blobView.setContentCompressionResistancePriority(.required, for: .horizontal)
        blobView.setContentHuggingPriority(.required, for: .horizontal)

        view.addSubview(blobView)
        blobView.translatesAutoresizingMaskIntoConstraints = false
        blobView.topAnchor.constraint(equalTo: view.topAnchor, constant: -blobView.frame.height / 3).isActive = true
        blobView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: blobView.frame.width / 2).isActive = true
        // Hacky workaround. Assumes that it is safe to overlap the text with half (and some) of the blob.
        blobView.centerXAnchor.constraint(equalTo: resourcesLabel.rightAnchor, constant: -20).isActive = true
        blobImageView = blobView
    }
    
    // SegmentedControl and Page views
    private func setupSegmentedControls() {
        // Add some right-padding to the segmented control so it doesn't overlap with the blob.
        // Don't add this padding for now.
        let segmentedControl = SegmentedControlViewController(pages: [
            Page(viewController: CovidResourceViewController(), label: "Dashboard"),
            Page(viewController: SproulClubViewController(), label: "Clubs"),
            Page(viewController: CampusResourceViewController(type: .health), label: "Health"),
            Page(viewController: CampusResourceViewController(type: .admin), label: "Admin"),
            Page(viewController: CampusResourceViewController(type: .basicNeeds), label: "Basic Needs"),
            Page(viewController: CampusResourceViewController(
                type: nil,
                notIn: Set<ResourceType>([.health, .admin, .basicNeeds])
            ), label: "Other")
        ], controlInsets: UIEdgeInsets(top: 0, left: view.layoutMargins.left,
                                       bottom: 0, right: blobImageView.frame.width / 4),
           centerControl: false, scrollable: true)
        segmentedControl.control.sizeEqually = false
        self.add(child: segmentedControl)
        segmentedControl.view.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.view.topAnchor.constraint(equalTo: resourcesLabel.bottomAnchor, constant: kViewMargin).isActive = true
        segmentedControl.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        segmentedControl.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        segmentedControl.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - Analytics
extension ResourcesViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_resource_screen", parameters: nil)
    }
}
