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
    private var blobImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.view.backgroundColor = Color.modalBackground
            
        setupHeader()
        let vc = CampusResourceViewController()
        self.add(child: vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: resourcesLabel.bottomAnchor, constant: kViewMargin).isActive = true
        vc.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
}

// MARK: - Analytics
extension ResourcesViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_resource_screen", parameters: nil)
    }
}
