//
//  LocationTableView.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/14/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16

class FilterTableView<T>: UIView {
    let tableView = UITableView(frame: .zero, style: .plain)
    var missingView: MissingDataView!

    var data: [T] = []
    var filteredData: [T] = []
    var tableFunctions: [TableFunction] = []
    var sortIndex: Int?
    var defaultSort: ((T, T) -> Bool)
    
    init(frame: CGRect, tableFunctions: [TableFunction], defaultSort: @escaping ((T, T) -> Bool), initialSelectedIndices: [Int] = [], filterView: FilterView? = nil) {
        self.defaultSort = defaultSort
        super.init(frame: frame)
        self.setupSubviews()

        missingView = MissingDataView(parentView: tableView, text: "No items found")
        self.tableFunctions = tableFunctions

        self.update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        self.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.addSubview(tableView)
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 103
        tableView.layer.masksToBounds = true
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        tableView.setContentOffset(CGPoint(x: 0, y: -5), animated: false)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func setData(data: [T]) {
        self.data = data
        self.filteredData = data
        sort()
    }
    
    func sort() {
        if let sortIndex = self.sortIndex,
           sortIndex < tableFunctions.count,
           let sort = tableFunctions[sortIndex] as? Sort<T> {
            self.filteredData.sort(by: sort.sort)
        } else {
            self.filteredData.sort(by: defaultSort)
        }
    }
    
    @objc
    func update() {
        filteredData = data
        filteredData.sort(by: defaultSort)
        
        DispatchQueue.main.async {
            if (self.filteredData.isEmpty) {
                self.missingView.isHidden = false
            } else {
                self.missingView.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
}
