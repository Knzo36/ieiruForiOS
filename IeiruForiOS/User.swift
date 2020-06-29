//
//  User.swift
//  IeiruForiOS
//
//  Created by 高木 健三朗 on 2020/06/26.
//  Copyright © 2020 KenzaburoTakagi. All rights reserved.
//

import Foundation

struct User : Codable {
    let id: Int
    let name: String
    let latitude: Float
    let longitude: Float
    let isHome: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case isHome = "is_home"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
