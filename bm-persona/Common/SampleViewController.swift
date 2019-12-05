//
//  SampleViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/20/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

enum DummyBadge: String {
    case Holiday
    case Academic
    
    var color: UIColor {
        switch self {
        case .Holiday:
            return .orange
        default:
            return .blue
        }
    }
}

struct DummyData {
    var event: String
    var date: String
    var type: DummyBadge
}

class SampleViewController: UIViewController {

    private var dummyData: [DummyData]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
// MARK: - CardView
        
        let card = CardView()
        card.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
// MARK: - CardCollectionView
        
        dummyData = [
            DummyData(event: "Early Drop Deadline", date: "Nov 21, 2019", type: .Academic),
            DummyData(event: "Veteran's Day", date: "Nov 11, 2019", type: .Holiday),
            DummyData(event: "Event", date: "Date", type: .Academic)
        ]
        
        let collectionView = CardCollectionView(frame: .zero)
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: card.layoutMargins.left, bottom: 0, right: card.layoutMargins.right)
        card.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: CardCollectionViewCell.kCardSize.height + 16).isActive = true
        collectionView.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
    }

}

extension SampleViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dummyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionView.kCellIdentifier, for: indexPath)
        if let card = cell as? CardCollectionViewCell {
            let data = dummyData[indexPath.row]
            card.title.text = data.event
            card.subtitle.text = data.date
            card.badge.text = data.type.rawValue
            card.badge.backgroundColor = data.type.color
        }
        return cell
    }
    
}
