//
//  Response.swift
//  IeiruForiOS
//
//  Created by 高木 健三朗 on 2020/06/26.
//  Copyright © 2020 KenzaburoTakagi. All rights reserved.
//

import Foundation

struct Response : Codable {
    let status: String
    let data: [User]
}
