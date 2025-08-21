//
//  SettingsView.swift
//  TrainMoreAccess Watch App
//
//  Created by Stanislaw Pusep on 2025-08-21.
//

import SwiftUI

struct SettingsView: View {
    @Binding var publicFacilityGroup: String
    @Binding var authToken: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Public Facility Group") {
                    TextField("Enter facility group", text: $publicFacilityGroup)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.none)
                }

                Section("Auth Token") {
                    TextField("Enter auth token", text: $authToken)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.password)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}