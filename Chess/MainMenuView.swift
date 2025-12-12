//
//  MainMenuView.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

struct MainMenuView: View {
    @State private var navigateToGame = false
    @State private var navigateToOnline = false
    @AppStorage("boardTheme") var boardTheme = BoardTheme.classic
    @StateObject private var fbManager = FirebaseManager.shared
    
    @State private var joinCode = ""
    @State private var isCreating = false
    @State private var isJoining = false
    @State private var showCodeAlert = false
    @State private var createdCode = ""
    @State private var activeGameCode = "" // Explicitly store the active code
    @State private var errorMessage = ""
    @State private var showError = false
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 40) {

                    // Logo or Title
                    VStack(spacing: 10) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.whitePiece)
                            .shadow(radius: 10)
                        
                        Text("Chess Master")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.heavy)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Menu Buttons
                    VStack(spacing: 20) {
                        // Pass & Play
                        NavigationLink(destination: ContentView(mode: .passAndPlay), isActive: $navigateToGame) {
                            MenuButton(icon: "person.2.fill", title: "Pass & Play", subtitle: "Play with a friend locally") {
                                navigateToGame = true
                            }
                        }
                        
                        // Online
                        MenuButton(icon: "globe", title: "Play Online", subtitle: "Create or Join a room") {
                            isCreating = true
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
                
                // Online Overlay/Sheet
                if isCreating {
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture { isCreating = false }
                    
                    VStack(spacing: 20) {
                        Text("Online Multiplayer")
                            .font(.title2.bold())
                        
                        if isJoining {
                            TextField("Enter 6-digit Code", text: $joinCode)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .padding()
                            
                            Button("Join Room") {
                                fbManager.joinGame(code: joinCode) { result in
                                    switch result {
                                    case .success:
                                        activeGameCode = joinCode // Set active code
                                        navigateToOnline = true
                                        isCreating = false
                                        isJoining = false
                                    case .failure(let error):
                                        errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Create Game") {
                                fbManager.createGame { result in
                                    switch result {
                                    case .success(let code):
                                        createdCode = code
                                        showCodeAlert = true
                                    case .failure(let error):
                                        errorMessage = error.localizedDescription
                                        showError = true
                                        isCreating = false
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.bottom)
                            
                            Button("Join Game") {
                                isJoining = true
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Button("Cancel") {
                            isCreating = false
                            isJoining = false
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                    .background(Material.regular)
                    .cornerRadius(20)
                    .padding(.horizontal, 40)
                }
                
                // Invisible link for Online Game
                NavigationLink(destination: ContentView(mode: .online(code: activeGameCode)), isActive: $navigateToOnline) {
                    EmptyView()
                }
            }
        }
        .preferredColorScheme(.dark) // Default to dark for menu? Or respect system.
        .alert("Game Created", isPresented: $showCodeAlert) {
            Button("Enter Game") {
                activeGameCode = createdCode // Set active code
                navigateToOnline = true
                isCreating = false
            }
        } message: {
            Text("Share this code with your friend:\n\n\(createdCode)")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .frame(width: 50)
                    .foregroundColor(Theme.accent)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Theme.panelBackground)
            .cornerRadius(16)
        }
    }
}
