//
//  SafariWebView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/5/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

