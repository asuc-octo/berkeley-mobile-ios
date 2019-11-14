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
    case loading
    case populated([CLPlacemark])
    case empty
    case error(Error)
    
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
    private var loadingView: UIView!
    private var emptyView: UIView!
    private var errorView: UIView!
    
    private var noResultsLabel: UILabel!
    private var errorLabel: UILabel!
    
    private var cellIdentifier = "searchResultCell"
    
    public var rowHeight: CGFloat = 60.0
    public var isScrolling = false
    
    var state = TableState.loading {
        didSet {
            self.updateView()
            let sections = NSIndexSet(indexesIn: NSMakeRange(0, self.tableView.numberOfSections))
            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initResultsView()
    }
    
    private func initResultsView() {
        self.setCornerBorder(cornerRadius: 0.0)
        initTableView()
        
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.rowHeight))
        
        noResultsLabel = UILabel()
        noResultsLabel.text = "Nothing found!"
        noResultsLabel.font = Font.regular(17)
        noResultsLabel.textAlignment = .center
        noResultsLabel.numberOfLines = 3
        
        errorLabel = UILabel()
        errorLabel.text = "Error. Please try again later."
        errorLabel.font = Font.regular(17)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 3
        
        // TODO: - Insert spinner
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.rowHeight))
        
        errorView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.rowHeight))
        errorView.addSubViews([errorLabel])
        
        emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.rowHeight))
        emptyView.addSubViews([noResultsLabel])
    }
    
    private func initTableView() {
        tableView = UITableView()
        tableView.backgroundColor = Color.searchBarBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.isUserInteractionEnabled = true
        tableView.canCancelContentTouches = false
        
        self.addSubViews([tableView])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        errorLabel.leftAnchor.constraint(equalTo: errorView.leftAnchor).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: errorView.rightAnchor).isActive = true
        errorView.centerSubView(errorLabel)
        
        noResultsLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor).isActive = true
        noResultsLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor).isActive = true
        emptyView.centerSubView(noResultsLabel)
        
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    func updateView() {
        switch state {
        case .error(let error):
            errorLabel.text = error.localizedDescription
            tableView.tableFooterView = errorView
        case .loading:
            tableView.tableFooterView = loadingView
        case .empty:
            tableView.tableFooterView = emptyView
        case .populated:
            tableView.tableFooterView = nil
        }
    }
    
    func updateTable(newPlacemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            state = .error(error)
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

// MARK: - TableView Delegeate and DS
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }
    
}
