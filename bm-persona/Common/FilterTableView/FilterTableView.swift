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

    var filter: FilterView = FilterView(frame: .zero)
    var data: [T] = []
    var filteredData: [T] = []
    var tableFunctions: [TableFunction] = []
    var sortIndex: Int?
    var defaultSort: ((T, T) -> Bool)
    
    override func layoutSubviews() {
        self.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.addSubview(filter)
        
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        filter.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        filter.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        filter.heightAnchor.constraint(equalToConstant: FilterViewCell.kCellSize.height).isActive = true

        filter.labels = tableFunctions.map { $0.label }
        filter.filterDelegate = self
        
        self.addSubview(tableView)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: filter.bottomAnchor, constant: kViewMargin).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.rowHeight = 131
        tableView.layer.masksToBounds = true
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        tableView.setContentOffset(CGPoint(x: 0, y: -5), animated: false)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
    }
    
    init(frame: CGRect, tableFunctions: [TableFunction], defaultSort: @escaping ((T, T) -> Bool)) {
        self.defaultSort = defaultSort
        super.init(frame: frame)
        missingView = MissingDataView(parentView: tableView)
        self.tableFunctions = tableFunctions
        self.update()
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
    
    func setSortFunc(index: Int) {
        if index < tableFunctions.count,
           tableFunctions[index] as? Sort<T> != nil {
            sortIndex = index
            sort()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var workItem: DispatchWorkItem?
    @objc func update() {
        workItem?.cancel()
        let data = self.data
        guard let paths = filter.indexPathsForSelectedItems else { return }
        let rows = paths.map { $0.row }
        var filters: [Filter<T>] = []
        sortIndex = nil
        for row in rows {
            guard row < tableFunctions.count else { continue }
            if let filter = tableFunctions[row] as? Filter<T> {
                filters.append(filter)
            } else if tableFunctions[row] as? Sort<T> != nil {
                setSortFunc(index: row)
            }
        }
        workItem = Filter.apply(filters: filters, on: data, completion: {
          filtered in
            self.filteredData = filtered
            self.sort()
            
            DispatchQueue.main.async {
                if (self.filteredData.count == 0) {
                    self.missingView.isHidden = false
                } else {
                    self.missingView.isHidden = true
                }
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
