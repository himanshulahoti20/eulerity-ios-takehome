//
//  FormViewModel.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import Foundation
import SwiftUI

@Observable
class FormViewModel {
    // MARK: - Published State
    var formPayload: FormPayload?
    var fieldValues: [String: Any] = [:]
    var fieldErrors: [String: String] = [:]
    var isLoading = false
    var loadError: String?
    var showSuccessAlert = false
    var successMessage = ""
    
    // MARK: - Computed Properties
    
    var sortedFields: [FormField] {
        guard let payload = formPayload else { return [] }
        return payload.fields.sorted { $0.order < $1.order }
    }
    
    var theme: Theme? {
        formPayload?.theme
    }
    
    var formTitle: String {
        formPayload?.formTitle ?? ""
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Data Loading
    
    func loadForm(filename: String = "form") {
        isLoading = true
        loadError = nil
        
        do {
            let payload = try JSONLoader.load(filename, as: FormPayload.self)
            self.formPayload = payload
            populateDefaultValues()
            isLoading = false
        } catch {
            loadError = error.localizedDescription
            isLoading = false
        }
    }
    
    private func populateDefaultValues() {
        guard let fields = formPayload?.fields else { return }
        
        for field in fields {
            switch field {
            case .text(let model):
                if let defaultValue = model.defaultValue {
                    // Truncate to max_length if needed
                    if let maxLength = model.maxLength, defaultValue.count > maxLength {
                        fieldValues[model.id] = String(defaultValue.prefix(maxLength))
                    } else {
                        fieldValues[model.id] = defaultValue
                    }
                } else {
                    fieldValues[model.id] = ""
                }
                
            case .dropdown(let model):
                if let defaultValues = model.defaultValues, !defaultValues.isEmpty {
                    if model.allowMultiple {
                        fieldValues[model.id] = defaultValues
                    } else {
                        fieldValues[model.id] = defaultValues.first ?? ""
                    }
                } else {
                    fieldValues[model.id] = model.allowMultiple ? [String]() : ""
                }
                
            case .toggle(let model):
                fieldValues[model.id] = model.defaultValue ?? false
                
            case .checkbox(let model):
                fieldValues[model.id] = false
                
            case .unknown:
                break
            }
        }
    }
    
    // MARK: - State Management
    
    func getValue<T>(for fieldId: String, as type: T.Type) -> T? {
        return fieldValues[fieldId] as? T
    }
    
    func setValue(_ value: Any, for fieldId: String) {
        fieldValues[fieldId] = value
        // Clear error when value changes
        fieldErrors[fieldId] = nil
    }
    
    func getError(for fieldId: String) -> String? {
        return fieldErrors[fieldId]
    }
    
    // MARK: - Validation
    
    @discardableResult
    func validateForm() -> Bool {
        fieldErrors.removeAll()
        var isValid = true
        
        guard let fields = formPayload?.fields else {
            return false
        }
        
        for field in fields {
            switch field {
            case .text(let model):
                if !validateTextField(model) {
                    isValid = false
                }
                
            case .dropdown(let model):
                if !validateDropdownField(model) {
                    isValid = false
                }
                
            case .toggle(let model):
                if !validateToggleField(model) {
                    isValid = false
                }
                
            case .checkbox(let model):
                if !validateCheckboxField(model) {
                    isValid = false
                }
                
            case .unknown:
                break
            }
        }
        
        if isValid {
            handleSuccessfulValidation()
        }
        
        return isValid
    }
    
    private func validateTextField(_ model: FormField.TextFieldModel) -> Bool {
        let value = (fieldValues[model.id] as? String) ?? ""
        
        // Required validation
        if model.required && value.isEmpty {
            fieldErrors[model.id] = model.errorMessage ?? "This field is required."
            return false
        }
        
        // Skip further validation if not required and empty
        if !model.required && value.isEmpty {
            return true
        }
        
        // Max length validation
        if let maxLength = model.maxLength, value.count > maxLength {
            fieldErrors[model.id] = model.errorMessage ?? "Maximum \(maxLength) characters allowed."
            return false
        }
        
        // Regex validation
        if let regexPattern = model.regex, !value.isEmpty {
            do {
                let regex = try NSRegularExpression(pattern: regexPattern)
                let range = NSRange(value.startIndex..., in: value)
                if regex.firstMatch(in: value, range: range) == nil {
                    fieldErrors[model.id] = model.errorMessage ?? "Invalid format."
                    return false
                }
            } catch {
                print("Invalid regex pattern: \(regexPattern)")
            }
        }
        
        return true
    }
    
    private func validateDropdownField(_ model: FormField.DropdownFieldModel) -> Bool {
        if model.allowMultiple {
            let selected = (fieldValues[model.id] as? [String]) ?? []
            if model.required && selected.isEmpty {
                fieldErrors[model.id] = model.errorMessage ?? "Please select at least one option."
                return false
            }
        } else {
            let selected = (fieldValues[model.id] as? String) ?? ""
            if model.required && selected.isEmpty {
                fieldErrors[model.id] = model.errorMessage ?? "Please select an option."
                return false
            }
        }
        
        return true
    }
    
    private func validateToggleField(_ model: FormField.ToggleFieldModel) -> Bool {
        // Toggles are typically optional, but if required and false, fail
        if model.required {
            let value = (fieldValues[model.id] as? Bool) ?? false
            if !value {
                fieldErrors[model.id] = "This option must be enabled."
                return false
            }
        }
        return true
    }
    
    private func validateCheckboxField(_ model: FormField.CheckboxFieldModel) -> Bool {
        let isChecked = (fieldValues[model.id] as? Bool) ?? false
        
        if model.required && !isChecked {
            fieldErrors[model.id] = model.errorMessage ?? "You must check this box."
            return false
        }
        
        return true
    }
    
    private func handleSuccessfulValidation() {
        // Build output dictionary
        var output: [String: Any] = [:]
        
        for (key, value) in fieldValues {
            output[key] = value
        }
        
        // Convert to JSON string for console output
        if let jsonData = try? JSONSerialization.data(withJSONObject: output, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("✅ Form Validation Successful!")
            print("📋 Form Output:")
            print(jsonString)
        }
        
        // Show success alert
        successMessage = "Form submitted successfully!"
        showSuccessAlert = true
    }
}
