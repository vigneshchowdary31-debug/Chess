//
//  SettingsView.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("showCoordinates") var showCoordinates = true
    @AppStorage("highlightMoves") var highlightMoves = true
    @AppStorage("showLegalMoves") var showLegalMoves = true
    @AppStorage("enableSound") var enableSound = true
    @AppStorage("enableHaptics") var enableHaptics = true
    @AppStorage("autoFlipBoard") var autoFlipBoard = false
    
    @AppStorage("boardTheme") var boardTheme = BoardTheme.classic
    @AppStorage("pieceSet") var pieceSet = PieceSet.standard
    @AppStorage("isDarkMode") var isDarkMode = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Appearance
                        SettingsSection(title: "Appearance") {
                            ToggleRow(title: "Dark Mode", isOn: $isDarkMode)
                            Divider()
                            PickerRow(title: "Board Theme", selection: $boardTheme)
                            Divider()
                            PickerRow(title: "Piece Set", selection: $pieceSet)
                        }
                        
                        // Visuals
                        SettingsSection(title: "Visuals") {
                            ToggleRow(title: "Show Coordinates", isOn: $showCoordinates)
                            Divider()
                            ToggleRow(title: "Highlight Last Move", isOn: $highlightMoves)
                            Divider()
                            ToggleRow(title: "Show Legal Moves", isOn: $showLegalMoves)
                            Divider()
                            ToggleRow(title: "Auto-flip Board", isOn: $autoFlipBoard)
                        }
                        
                        // Audio
                        SettingsSection(title: "Audio & Haptics") {
                            ToggleRow(title: "Sound Effects", isOn: $enableSound)
                            Divider()
                            ToggleRow(title: "Haptic Feedback", isOn: $enableHaptics)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Helpers
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .padding()
            .background(Theme.panelBackground)
            .cornerRadius(12)
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(title, isOn: $isOn)
            .padding(.vertical, 4)
    }
}

struct PickerRow<T: Hashable & CaseIterable & Identifiable & RawRepresentable>: View where T.RawValue == String, T.AllCases == [T] {
    let title: String
    @Binding var selection: T
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker(title, selection: $selection) {
                ForEach(T.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}
