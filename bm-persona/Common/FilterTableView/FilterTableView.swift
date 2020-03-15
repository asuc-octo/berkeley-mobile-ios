//
//  LocationTableView.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/14/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class FilterTableView<T>: UIView {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    var filter: FilterView = FilterView(frame: .zero)
    var data: [T] = []
    var filteredData: [T] = []
    var filters: [Filter<T>] = []
    var sortFunc: ((T, T) -> Bool) = {lib1, lib2 in true}
    
    override func layoutSubviews() {
        self.addSubview(filter)
        
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        filter.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        filter.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        filter.heightAnchor.constraint(equalToConstant: FilterViewCell.kCellSize.height).isActive = true

        filter.labels = filters.map { $0.label }
        filter.filterDelegate = self
        
        self.addSubview(tableView)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: filter.bottomAnchor, constant: 24).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.rowHeight = 131
        tableView.layer.masksToBounds = true
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        tableView.setContentOffset(CGPoint(x: 0, y: -5), animated: false)
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    init(frame: CGRect, filters: [Filter<T>]) {
        super.init(frame: frame)
        self.filters = filters
    }
    
    func setData(data: [T]) {
        self.data = data
        self.filteredData = data
        self.filteredData.sort(by: sortFunc)
    }
    
    func sort() {
        self.filteredData.sort(by: sortFunc)
    }
    
    func setSortFunc(newSortFunc: @escaping ((T, T) -> Bool)) {
        sortFunc = newSortFunc
        sort()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var workItem: DispatchWorkItem?
    func update() {
        workItem?.cancel()
        let data = self.data
        workItem = Filter.apply(filters: filters, on: data, indices: filter.indexPathsForSelectedItems?.map { $0.row }, completion: {
          filtered in
            self.filteredData = filtered
            self.sort()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
}

extension FilterTableView: FilterViewDelegate {
    
    func filterView(_ filterView: FilterView, didSelect index: Int) {
        update()
    }
    
    func filterView(_ filterView: FilterView, didDeselect index: Int) {
        update()
    }

}
