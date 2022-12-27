//
//  Provider.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-20.
//

import Foundation


class Provider: ObservableObject, Identifiable, Codable, Equatable {
    static func == (lhs: Provider, rhs: Provider) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    init(id: String) {
        self.id = id
    }
    var uuid = UUID()
    var id: String
    var onShift = false
}
