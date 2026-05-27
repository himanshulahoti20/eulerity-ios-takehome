//
//  DropdownComponent.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import SwiftUI

struct DropdownComponent: View {
    let model: FormField.DropdownFieldModel
    let theme: Theme
    @Binding var singleValue: String
    @Binding var multipleValues: [String]
    let error: String?
    
    private var hasError: Bool {
        error != nil
    }
    
    private var isEmpty: Bool {
        model.options.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text(model.label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: theme.textColor))
            
            if isEmpty {
                // Empty state
                Text("No options available")
                    .font(.body)
                    .foregroundColor(Color(hex: theme.textColor).opacity(0.5))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: theme.backgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: theme.borderColor), lineWidth: 1.5)
                    )
            } else {
                // Dropdown menu
                if model.allowMultiple {
                    multiSelectMenu
                } else {
                    singleSelectMenu
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
    
    // MARK: - Single Select
    
    private var singleSelectMenu: some View {
        Menu {
            ForEach(model.options) { option in
                Button {
                    singleValue = option.id
                } label: {
                    HStack {
                        Text(option.label)
                        if singleValue == option.id {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedLabel)
                    .foregroundColor(singleValue.isEmpty ? Color(hex: theme.textColor).opacity(0.5) : Color(hex: theme.textColor))
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(hex: theme.textColor).opacity(0.5))
            }
            .padding(12)
            .background(Color(hex: theme.backgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
    }
    
    private var selectedLabel: String {
        if singleValue.isEmpty {
            return "Select an option"
        }
        return model.options.first(where: { $0.id == singleValue })?.label ?? "Select an option"
    }
    
    // MARK: - Multi Select
    
    private var multiSelectMenu: some View {
        Menu {
            ForEach(model.options) { option in
                Button {
                    toggleMultipleSelection(option.id)
                } label: {
                    HStack {
                        Text(option.label)
                        if multipleValues.contains(option.id) {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(multipleSelectedLabel)
                    .foregroundColor(multipleValues.isEmpty ? Color(hex: theme.textColor).opacity(0.5) : Color(hex: theme.textColor))
                    .lineLimit(2)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(hex: theme.textColor).opacity(0.5))
            }
            .padding(12)
            .background(Color(hex: theme.backgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
    }
    
    private var multipleSelectedLabel: String {
        if multipleValues.isEmpty {
            return "Select options"
        }
        
        let labels = multipleValues.compactMap { selectedId in
            model.options.first(where: { $0.id == selectedId })?.label
        }
        
        return labels.joined(separator: ", ")
    }
    
    private func toggleMultipleSelection(_ optionId: String) {
        if multipleValues.contains(optionId) {
            multipleValues.removeAll { $0 == optionId }
        } else {
            multipleValues.append(optionId)
        }
    }
    
    // MARK: - Helpers
    
    private var borderColor: Color {
        hasError ? Color(hex: theme.errorColor) : Color(hex: theme.borderColor)
    }
}
