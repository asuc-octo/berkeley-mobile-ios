//
//  DetailView.swift
//  bm-persona
//
//  Created by Kevin Hu on 8/15/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

/// Delegate for a `DetailView`.
protocol DetailViewDelegate: NSObject {
    /// Called when a `DetailView` updates its contents.
    func detailsUpdated(for view: UIView)
}

/// A view presenting information for a single protocol.
protocol DetailView: UIView {
    /// The protocol this detail view presents information for.
    associatedtype Item

    /// The `DetailViewDelegate` for this detail view.
    ///
    /// This property should be `weak` to prevent retain cycles.
    var delegate: DetailViewDelegate? { get set }

    /// Indicates when crucial data is missing and the view should not be shown.
    var missingData: Bool { get }

    /// Configures the view with relevant info from `item`.
    func configure(for item: Item)
}
