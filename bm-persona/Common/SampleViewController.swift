//
//  SampleViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {

    var filter: FilterView!
    var filters: [Filter<Int>] = [
        Filter(label: "Does nothing", filter: nil),
        Filter(label: "Odd", filter: { num in num % 2 == 1 }),
        Filter(label: "Even", filter: { num in num % 2 == 0 }),
        Filter(label: "Less than 5", filter: { num in num < 5})
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        filter = FilterView(frame: .zero)
        view.addSubview(filter)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        filter.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        filter.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30).isActive = true
        filter.heightAnchor.constraint(equalToConstant: FilterViewCell.kCellSize.height).isActive = true
        
        filter.labels = filters.map { $0.label }
        filter.filterDelegate = self
    }
    
    var workItem: DispatchWorkItem?
    func update() {
        workItem?.cancel()
        let data = Array(1...100)
        workItem = Filter.apply(filters: filters, on: data, indices: filter.indexPathsForSelectedItems?.map { $0.row }, completion: {
          filtered in
          print(filtered)
        })
    }

}

extension SampleViewController: FilterViewDelegate {
    
    func filterView(_ filterView: FilterView, didSelect index: Int) {
        update()
    }
    
    func filterView(_ filterView: FilterView, didDeselect index: Int) {
        update()
    }

}
