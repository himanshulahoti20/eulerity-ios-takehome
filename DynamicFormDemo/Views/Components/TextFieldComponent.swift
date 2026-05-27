//
//  TextFieldComponent.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import SwiftUI

struct TextFieldComponent: View {
    let model: FormField.TextFieldModel
    let theme: Theme
    @Binding var value: String
    let error: String?
    
    @FocusState private var isFocused: Bool
    
    private var hasError: Bool {
        error != nil
    }
    
    private var currentCount: Int {
        value.count
    }
    
    private var shouldShowCounter: Bool {
        model.maxLength != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text(model.label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: theme.textColor))
            
            // Input field based on subtype
            Group {
                switch model.subtype {
                case .plain:
                    textField
                case .multiline:
                    multilineTextField
                case .number:
                    numberTextField
                case .uri:
                    uriTextField
                case .secure:
                    secureTextField
                }
            }
            .padding(12)
            .background(Color(hex: theme.backgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .focused($isFocused)
            
            // Character counter
            if shouldShowCounter, let maxLength = model.maxLength {
                HStack {
                    Spacer()
                    Text("\(currentCount) / \(maxLength)")
                        .font(.caption)
                        .foregroundColor(currentCount > maxLength ? Color(hex: theme.errorColor) : Color(hex: theme.textColor).opacity(0.6))
                }
            }
            
            // Error message
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                }
                .foregroundColor(Color(hex: theme.errorColor))
            }
        }
    }
    
    // MARK: - Input Field Variants
    
    private var textField: some View {
        TextField(model.placeholder ?? "", text: $value)
            .foregroundColor(Color(hex: theme.textColor))
            .autocorrectionDisabled()
            .onChange(of: value) { _, newValue in
                enforceMaxLength(newValue)
            }
    }
    
    private var multilineTextField: some View {
        TextField(model.placeholder ?? "", text: $value, axis: .vertical)
            .lineLimit(3...6)
            .foregroundColor(Color(hex: theme.textColor))
            .onChange(of: value) { _, newValue in
                enforceMaxLength(newValue)
            }
    }
    
    private var numberTextField: some View {
        TextField(model.placeholder ?? "", text: $value)
            .keyboardType(.decimalPad)
            .foregroundColor(Color(hex: theme.textColor))
            .onChange(of: value) { _, newValue in
                enforceMaxLength(newValue)
            }
    }
    
    private var uriTextField: some View {
        TextField(model.placeholder ?? "", text: $value)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .foregroundColor(Color(hex: theme.textColor))
            .onChange(of: value) { _, newValue in
                enforceMaxLength(newValue)
            }
    }
    
    private var secureTextField: some View {
        SecureField(model.placeholder ?? "", text: $value)
            .foregroundColor(Color(hex: theme.textColor))
            .onChange(of: value) { _, newValue in
                enforceMaxLength(newValue)
            }
    }
    
    // MARK: - Helpers
    
    private var borderColor: Color {
        hasError ? Color(hex: theme.errorColor) : Color(hex: theme.borderColor)
    }
    
    private func enforceMaxLength(_ newValue: String) {
        if let maxLength = model.maxLength, newValue.count > maxLength {
            value = String(newValue.prefix(maxLength))
        }
    }
}
