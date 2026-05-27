//
//  CheckboxComponent.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import SwiftUI

struct CheckboxComponent: View {
    let model: FormField.CheckboxFieldModel
    let theme: Theme
    @Binding var value: Bool
    let error: String?
    
    @Environment(\.openURL) private var openURL
    
    private var hasError: Bool {
        error != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Checkbox row
            Button {
                value.toggle()
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: value ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundColor(value ? Color(hex: theme.borderColor) : Color(hex: theme.textColor).opacity(0.5))
                    
                    // Label with clickable links
                    labelView
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)
            
            // Error message
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                }
                .foregroundColor(Color(hex: theme.errorColor))
                .padding(.leading, 32)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Label View with Clickable Links
    
    @ViewBuilder
    private var labelView: some View {
        if let metadata = model.metadata, !metadata.isEmpty {
            // Create AttributedString with clickable links
            Text(attributedLabel)
                .font(.subheadline)
                .tint(Color(hex: model.clickableTextColor ?? "#2563EB"))
                .environment(\.openURL, OpenURLAction { url in
                    openURL(url)
                    return .handled
                })
        } else {
            // Plain text label
            Text(model.label)
                .font(.subheadline)
                .foregroundColor(Color(hex: theme.textColor))
        }
    }
    
    private var attributedLabel: AttributedString {
        var attributedString = AttributedString(model.label)
        
        // Apply base color
        attributedString.foregroundColor = Color(hex: theme.textColor)
        
        // Find and style clickable substrings
        if let metadata = model.metadata {
            for (text, urlString) in metadata {
                if let range = attributedString.range(of: text),
                   let url = URL(string: urlString) {
                    attributedString[range].link = url
                    attributedString[range].foregroundColor = Color(hex: model.clickableTextColor ?? "#2563EB")
                    attributedString[range].underlineStyle = .single
                }
            }
        }
        
        return attributedString
    }
}
