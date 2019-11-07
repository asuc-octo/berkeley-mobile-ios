//
//  SearchResultsView.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

// MARK: - Table State
enum TableState {
    case populated([CLPlacemark])
    case empty
    
    var placemarks: [CLPlacemark] {
        switch self {
        case .populated(let placemarks):
            return placemarks
        default:
            return []
        }
    }
}

// MARK: - SearchResultsView
class SearchResultsView: UIView {
    
    private var tableView: UITableView!
    private var containerView: UIView!
    private var noResultsLabel: UILabel!
    
    private var cellIdentifier = "searchResultCell"
    
    public var rowHeight: CGFloat = 60.0
    
    private var state = TableState.empty
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initResultsView()
    }
    
    private func initResultsView() {
        self.setCornerBorder()
        initTableView()
        
        noResultsLabel = UILabel()
        noResultsLabel.text = "Nothing found!"
        noResultsLabel.font = Font.regular(17)
        
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.rowHeight))
        containerView.addSubview(noResultsLabel)
    }
    
    private func initTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.isUserInteractionEnabled = true
        tableView.canCancelContentTouches = false
        
        self.addSubview(tableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    func updateTable(newPlacemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print(error)
            return
        }
        guard let newPlacemarks = newPlacemarks, !newPlacemarks.isEmpty else {
            state = .empty
            return
        }
        state = .populated(newPlacemarks)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SearchResultsView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(state.placemarks.count, 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchResultCell else {
            return UITableViewCell()
        }
        cell.cellConfigure(state.placemarks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
}
