//
//  FormField.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import Foundation

// MARK: - FormField (Polymorphic Enum)

enum FormField: Codable {
    case text(TextFieldModel)
    case dropdown(DropdownFieldModel)
    case toggle(ToggleFieldModel)
    case checkbox(CheckboxFieldModel)
    case unknown
    
    // MARK: - Nested Models
    
    struct TextFieldModel: Codable {
        let id: String
        let order: Int
        let label: String
        let required: Bool
        let subtype: TextSubtype
        let placeholder: String?
        let maxLength: Int?
        let defaultValue: String?
        let errorMessage: String?
        let regex: String?
        
        enum TextSubtype: String, Codable {
            case plain = "PLAIN"
            case multiline = "MULTILINE"
            case number = "NUMBER"
            case uri = "URI"
            case secure = "SECURE"
        }
        
        enum CodingKeys: String, CodingKey {
            case id, order, label, required, subtype, placeholder, regex
            case maxLength = "max_length"
            case defaultValue = "default_value"
            case errorMessage = "error_message"
        }
    }
    
    struct DropdownFieldModel: Codable {
        let id: String
        let order: Int
        let label: String
        let required: Bool
        let options: [DropdownOption]
        let allowMultiple: Bool
        let defaultValues: [String]?
        let errorMessage: String?
        
        struct DropdownOption: Codable, Identifiable {
            let id: String
            let label: String
        }
        
        enum CodingKeys: String, CodingKey {
            case id, order, label, required, options
            case allowMultiple = "allow_multiple"
            case defaultValues = "default_values"
            case errorMessage = "error_message"
        }
    }
    
    struct ToggleFieldModel: Codable {
        let id: String
        let order: Int
        let label: String
        let required: Bool
        let defaultValue: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id, order, label, required
            case defaultValue = "default_value"
        }
    }
    
    struct CheckboxFieldModel: Codable {
        let id: String
        let order: Int
        let label: String
        let required: Bool
        let errorMessage: String?
        let metadata: [String: String]?
        let clickableTextColor: String?
        
        enum CodingKeys: String, CodingKey {
            case id, order, label, required, metadata
            case errorMessage = "error_message"
            case clickableTextColor = "clickable_text_color"
        }
    }
    
    // MARK: - Codable Implementation
    
    private enum FieldType: String, Codable {
        case text = "TEXT"
        case dropdown = "DROPDOWN"
        case toggle = "TOGGLE"
        case checkbox = "CHECKBOX"
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode the type field
        guard let typeString = try? container.decode(String.self, forKey: .type),
              let fieldType = FieldType(rawValue: typeString) else {
            // Unknown type - silently ignore
            self = .unknown
            return
        }
        
        // Decode into the appropriate case based on type
        switch fieldType {
        case .text:
            do {
                let model = try TextFieldModel(from: decoder)
                self = .text(model)
            } catch {
                // If decoding fails, treat as unknown
                self = .unknown
            }
            
        case .dropdown:
            do {
                let model = try DropdownFieldModel(from: decoder)
                self = .dropdown(model)
            } catch {
                self = .unknown
            }
            
        case .toggle:
            do {
                let model = try ToggleFieldModel(from: decoder)
                self = .toggle(model)
            } catch {
                self = .unknown
            }
            
        case .checkbox:
            do {
                let model = try CheckboxFieldModel(from: decoder)
                self = .checkbox(model)
            } catch {
                self = .unknown
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let model):
            try model.encode(to: encoder)
        case .dropdown(let model):
            try model.encode(to: encoder)
        case .toggle(let model):
            try model.encode(to: encoder)
        case .checkbox(let model):
            try model.encode(to: encoder)
        case .unknown:
            // Don't encode unknown fields
            break
        }
    }
    
    // MARK: - Convenience Properties
    
    var order: Int {
        switch self {
        case .text(let model):
            return model.order
        case .dropdown(let model):
            return model.order
        case .toggle(let model):
            return model.order
        case .checkbox(let model):
            return model.order
        case .unknown:
            return Int.max // Push unknown fields to the end
        }
    }
    
    var id: String {
        switch self {
        case .text(let model):
            return model.id
        case .dropdown(let model):
            return model.id
        case .toggle(let model):
            return model.id
        case .checkbox(let model):
            return model.id
        case .unknown:
            return "unknown"
        }
    }
}
