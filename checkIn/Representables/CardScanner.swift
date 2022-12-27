//
//  CardScanner.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-10-09.
//

import AVKit
import Foundation
import SwiftUI

struct CardScanner: UIViewControllerRepresentable {
    var patient: Patient
    func makeUIViewController(context: Context) -> CardScannerViewController {
        CardScannerViewController(patient: patient)
    }

    func updateUIViewController(_ uiViewController: CardScannerViewController, context: Context) {
    }
}



