//
//  ToggleComponent.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import SwiftUI

struct ToggleComponent: View {
    let model: FormField.ToggleFieldModel
    let theme: Theme
    @Binding var value: Bool
    let error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $value) {
                Text(model.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: theme.textColor))
            }
            .tint(Color(hex: theme.borderColor))
            
            // Error message (if any)
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
        .padding(.vertical, 4)
    }
}
