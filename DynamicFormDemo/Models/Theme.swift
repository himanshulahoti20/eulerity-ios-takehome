//
//  Theme.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import Foundation

struct Theme: Codable {
    let backgroundColor: String
    let textColor: String
    let borderColor: String
    let errorColor: String
    
    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
    }
}
