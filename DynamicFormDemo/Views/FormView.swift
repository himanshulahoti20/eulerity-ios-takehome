//
//  FormView.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import SwiftUI

struct FormView: View {
    @State private var viewModel = FormViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.loadError {
                errorView(error)
            } else if viewModel.formPayload != nil {
                formContent
            } else {
                emptyStateView
            }
        }
        .onAppear {
            viewModel.loadForm()
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.successMessage)
        }
    }
    
    // MARK: - Form Content
    
    private var formContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Form Title
                Text(viewModel.formTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(themeTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                
                // Form Fields
                ForEach(Array(viewModel.sortedFields.enumerated()), id: \.element.id) { index, field in
                    fieldView(for: field)
                }
                
                // Save Button
                Button {
                    viewModel.validateForm()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 16)
            }
            .padding()
        }
        .background(themeBackgroundColor)
        .ignoresSafeArea(.keyboard,edges: .bottom)
    }
    
    @ViewBuilder
    private func fieldView(for field: FormField) -> some View {
        switch field {
        case .text(let model):
            TextFieldComponent(
                model: model,
                theme: viewModel.theme!,
                value: Binding(
                    get: { viewModel.getValue(for: model.id, as: String.self) ?? "" },
                    set: { viewModel.setValue($0, for: model.id) }
                ),
                error: viewModel.getError(for: model.id)
            )
            
        case .dropdown(let model):
            if model.allowMultiple {
                DropdownComponent(
                    model: model,
                    theme: viewModel.theme!,
                    singleValue: .constant(""),
                    multipleValues: Binding(
                        get: { viewModel.getValue(for: model.id, as: [String].self) ?? [] },
                        set: { viewModel.setValue($0, for: model.id) }
                    ),
                    error: viewModel.getError(for: model.id)
                )
            } else {
                DropdownComponent(
                    model: model,
                    theme: viewModel.theme!,
                    singleValue: Binding(
                        get: { viewModel.getValue(for: model.id, as: String.self) ?? "" },
                        set: { viewModel.setValue($0, for: model.id) }
                    ),
                    multipleValues: .constant([]),
                    error: viewModel.getError(for: model.id)
                )
            }
            
        case .toggle(let model):
            ToggleComponent(
                model: model,
                theme: viewModel.theme!,
                value: Binding(
                    get: { viewModel.getValue(for: model.id, as: Bool.self) ?? false },
                    set: { viewModel.setValue($0, for: model.id) }
                ),
                error: viewModel.getError(for: model.id)
            )
            
        case .checkbox(let model):
            CheckboxComponent(
                model: model,
                theme: viewModel.theme!,
                value: Binding(
                    get: { viewModel.getValue(for: model.id, as: Bool.self) ?? false },
                    set: { viewModel.setValue($0, for: model.id) }
                ),
                error: viewModel.getError(for: model.id)
            )
            
        case .unknown:
            EmptyView()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading form...")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Error View
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            Text("Error Loading Form")
                .font(.headline)
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry") {
                viewModel.loadForm()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No form available")
                .font(.headline)
            Text("Please check that form.json exists in your app bundle.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    // MARK: - Theme Colors
    
    private var themeBackgroundColor: Color {
        if let theme = viewModel.theme {
            return Color(hex: theme.backgroundColor)
        }
        return Color(.systemBackground)
    }
    
    private var themeTextColor: Color {
        if let theme = viewModel.theme {
            return Color(hex: theme.textColor)
        }
        return Color.primary
    }
}

#Preview {
    FormView()
}
