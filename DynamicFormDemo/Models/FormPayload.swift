//
//  FormPayload.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import Foundation

struct FormPayload: Codable {
    let theme: Theme
    let formTitle: String
    let fields: [FormField]
    
    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }
    
    // Custom decoding to filter out unknown fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        theme = try container.decode(Theme.self, forKey: .theme)
        formTitle = try container.decode(String.self, forKey: .formTitle)
        
        // Decode all fields, filtering out .unknown cases
        let allFields = try container.decode([FormField].self, forKey: .fields)
        fields = allFields.filter { field in
            if case .unknown = field {
                return false
            }
            return true
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(theme, forKey: .theme)
        try container.encode(formTitle, forKey: .formTitle)
        try container.encode(fields, forKey: .fields)
    }
}
