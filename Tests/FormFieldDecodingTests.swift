//
//  FormFieldDecodingTests.swift
//  DynamicFormDemoTests
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import Testing
import Foundation
@testable import DynamicFormDemo

@Suite("Form Field Polymorphic Decoding Tests")
struct FormFieldDecodingTests {
    
    // MARK: - TEXT Field Tests
    
    @Test("Decode TEXT field with PLAIN subtype")
    func decodeTextFieldPlain() throws {
        let json = """
        {
            "id": "test_field",
            "order": 1,
            "type": "TEXT",
            "subtype": "PLAIN",
            "label": "Test Label",
            "required": true,
            "placeholder": "Enter text",
            "max_length": 50
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let field = try decoder.decode(FormField.self, from: data)
        
        if case .text(let model) = field {
            #expect(model.id == "test_field")
            #expect(model.order == 1)
            #expect(model.label == "Test Label")
            #expect(model.required == true)
            #expect(model.subtype == .plain)
            #expect(model.placeholder == "Enter text")
            #expect(model.maxLength == 50)
        } else {
            Issue.record("Expected .text case, got \(field)")
        }
    }
    
    @Test("Decode TEXT field with SECURE subtype")
    func decodeTextFieldSecure() throws {
        let json = """
        {
            "id": "password",
            "order": 1,
            "type": "TEXT",
            "subtype": "SECURE",
            "label": "Password",
            "required": true
        }
        """
        
        let data = json.data(using: .utf8)!
        let field = try JSONDecoder().decode(FormField.self, from: data)
        
        if case .text(let model) = field {
            #expect(model.subtype == .secure)
            #expect(model.id == "password")
        } else {
            Issue.record("Expected .text case with SECURE subtype")
        }
    }
    
    // MARK: - DROPDOWN Field Tests
    
    @Test("Decode single-select DROPDOWN")
    func decodeSingleSelectDropdown() throws {
        let json = """
        {
            "id": "country",
            "order": 2,
            "type": "DROPDOWN",
            "label": "Country",
            "required": true,
            "allow_multiple": false,
            "options": [
                {"id": "us", "label": "United States"},
                {"id": "ca", "label": "Canada"}
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let field = try JSONDecoder().decode(FormField.self, from: data)
        
        if case .dropdown(let model) = field {
            #expect(model.id == "country")
            #expect(model.allowMultiple == false)
            #expect(model.options.count == 2)
            #expect(model.options[0].id == "us")
            #expect(model.options[0].label == "United States")
        } else {
            Issue.record("Expected .dropdown case")
        }
    }
    
    @Test("Decode multi-select DROPDOWN with defaults")
    func decodeMultiSelectDropdown() throws {
        let json = """
        {
            "id": "networks",
            "order": 2,
            "type": "DROPDOWN",
            "label": "Networks",
            "required": true,
            "allow_multiple": true,
            "default_values": ["net1", "net2"],
            "options": [
                {"id": "net1", "label": "Network 1"},
                {"id": "net2", "label": "Network 2"}
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let field = try JSONDecoder().decode(FormField.self, from: data)
        
        if case .dropdown(let model) = field {
            #expect(model.allowMultiple == true)
            #expect(model.defaultValues?.count == 2)
            #expect(model.defaultValues?.contains("net1") == true)
        } else {
            Issue.record("Expected .dropdown case")
        }
    }
    
    // MARK: - TOGGLE Field Tests
    
    @Test("Decode TOGGLE field with default value")
    func decodeToggle() throws {
        let json = """
        {
            "id": "enable_feature",
            "order": 3,
            "type": "TOGGLE",
            "label": "Enable Feature",
            "required": false,
            "default_value": true
        }
        """
        
        let data = json.data(using: .utf8)!
        let field = try JSONDecoder().decode(FormField.self, from: data)
        
        if case .toggle(let model) = field {
            #expect(model.id == "enable_feature")
            #expect(model.defaultValue == true)
            #expect(model.required == false)
        } else {
            Issue.record("Expected .toggle case")
        }
    }
    
    // MARK: - CHECKBOX Field Tests
    
    @Test("Decode CHECKBOX with metadata links")
    func decodeCheckboxWithMetadata() throws {
        let json = """
        {
            "id": "accept_terms",
            "order": 4,
            "type": "CHECKBOX",
            "label": "I agree to the Terms and Privacy Policy.",
            "required": true,
            "error_message": "You must accept the terms.",
            "metadata": {
                "Terms": "https://example.com/terms",
                "Privacy Policy": "https://example.com/privacy"
            },
            "clickable_text_color": "#0000FF"
        }
        """
        
        let data = json.data(using: .utf8)!
        let field = try JSONDecoder().decode(FormField.self, from: data)
        
        if case .checkbox(let model) = field {
            #expect(model.id == "accept_terms")
            #expect(model.required == true)
            #expect(model.metadata?.count == 2)
            #expect(model.metadata?["Terms"] == "https://example.com/terms")
            #expect(model.clickableTextColor == "#0000FF")
        } else {
            Issue.record("Expected .checkbox case")
        }
    }
    
    // MARK: - Unknown Type Tests
    
    @Test("Unknown field type is silently ignored")
    func decodeUnknownFieldType() throws {
        let json = """
        {
            "id": "color_picker",
            "order": 5,
            "type": "COLOR_PICKER",
            "label": "Pick a Color",
            "required": true
        }
        """
        
        let data = json.data(using: .utf8)!
        let field = try JSONDecoder().decode(FormField.self, from: data)
        
        if case .unknown = field {
            // Success - unknown type handled gracefully
            #expect(true)
        } else {
            Issue.record("Expected .unknown case for COLOR_PICKER type")
        }
    }
    
    @Test("Malformed field with missing required property becomes unknown")
    func decodeMalformedField() throws {
        let json = """
        {
            "id": "broken_field",
            "type": "TEXT"
        }
        """
        
        let data = json.data(using: .utf8)!
        let field = try JSONDecoder().decode(FormField.self, from: data)
        
        if case .unknown = field {
            // Success - malformed field handled gracefully
            #expect(true)
        } else {
            Issue.record("Expected .unknown case for malformed field")
        }
    }
    
    // MARK: - FormPayload Tests
    
    @Test("Decode complete FormPayload and filter unknown fields")
    func decodeFormPayload() throws {
        let json = """
        {
            "theme": {
                "background_color": "#FFFFFF",
                "text_color": "#000000",
                "border_color": "#CCCCCC",
                "error_color": "#FF0000"
            },
            "form_title": "Test Form",
            "fields": [
                {
                    "id": "name",
                    "order": 1,
                    "type": "TEXT",
                    "subtype": "PLAIN",
                    "label": "Name",
                    "required": true
                },
                {
                    "id": "unknown_field",
                    "order": 2,
                    "type": "UNKNOWN_TYPE",
                    "label": "Unknown"
                },
                {
                    "id": "agree",
                    "order": 3,
                    "type": "CHECKBOX",
                    "label": "I Agree",
                    "required": true
                }
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let payload = try JSONDecoder().decode(FormPayload.self, from: data)
        
        #expect(payload.formTitle == "Test Form")
        #expect(payload.theme.backgroundColor == "#FFFFFF")
        // Unknown field should be filtered out, leaving only 2 fields
        #expect(payload.fields.count == 2)
        
        // First field should be TEXT
        if case .text = payload.fields[0] {
            #expect(true)
        } else {
            Issue.record("First field should be .text")
        }
        
        // Second field should be CHECKBOX (unknown was filtered)
        if case .checkbox = payload.fields[1] {
            #expect(true)
        } else {
            Issue.record("Second field should be .checkbox")
        }
    }
    
    // MARK: - Theme Tests
    
    @Test("Decode Theme with hex colors")
    func decodeTheme() throws {
        let json = """
        {
            "background_color": "#121212",
            "text_color": "#E0E0E0",
            "border_color": "#333333",
            "error_color": "#CF6679"
        }
        """
        
        let data = json.data(using: .utf8)!
        let theme = try JSONDecoder().decode(Theme.self, from: data)
        
        #expect(theme.backgroundColor == "#121212")
        #expect(theme.textColor == "#E0E0E0")
        #expect(theme.borderColor == "#333333")
        #expect(theme.errorColor == "#CF6679")
    }
    
    // MARK: - Edge Case Tests
    
    @Test("TEXT field with regex validation")
    func decodeTextFieldWithRegex() throws {
        let json = """
        {
            "id": "email",
            "order": 1,
            "type": "TEXT",
            "subtype": "PLAIN",
            "label": "Email",
            "required": true,
            "regex": "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\\\.[A-Z]{2,}$"
        }
        """
        
        let data = json.data(using: .utf8)!
        let field = try JSONDecoder().decode(FormField.self, from: data)
        
        if case .text(let model) = field {
            #expect(model.regex != nil)
            #expect(model.regex?.contains("@") == true)
        } else {
            Issue.record("Expected .text case with regex")
        }
    }
    
    @Test("DROPDOWN with empty options array")
    func decodeDropdownWithEmptyOptions() throws {
        let json = """
        {
            "id": "empty_dropdown",
            "order": 1,
            "type": "DROPDOWN",
            "label": "Empty",
            "required": true,
            "allow_multiple": false,
            "options": []
        }
        """
        
        let data = json.data(using: .utf8)!
        let field = try JSONDecoder().decode(FormField.self, from: data)
        
        if case .dropdown(let model) = field {
            #expect(model.options.isEmpty == true)
        } else {
            Issue.record("Expected .dropdown case")
        }
    }
    
    @Test("Field ordering via order property")
    func testFieldOrdering() throws {
        let json = """
        {
            "theme": {
                "background_color": "#FFFFFF",
                "text_color": "#000000",
                "border_color": "#CCCCCC",
                "error_color": "#FF0000"
            },
            "form_title": "Ordered Form",
            "fields": [
                {
                    "id": "field3",
                    "order": 3,
                    "type": "TEXT",
                    "subtype": "PLAIN",
                    "label": "Third",
                    "required": false
                },
                {
                    "id": "field1",
                    "order": 1,
                    "type": "TEXT",
                    "subtype": "PLAIN",
                    "label": "First",
                    "required": false
                },
                {
                    "id": "field2",
                    "order": 2,
                    "type": "TEXT",
                    "subtype": "PLAIN",
                    "label": "Second",
                    "required": false
                }
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let payload = try JSONDecoder().decode(FormPayload.self, from: data)
        let sorted = payload.fields.sorted { $0.order < $1.order }
        
        #expect(sorted[0].id == "field1")
        #expect(sorted[1].id == "field2")
        #expect(sorted[2].id == "field3")
    }
}
