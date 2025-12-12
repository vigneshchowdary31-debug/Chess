//
//  ChessApp.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

import FirebaseCore

@main
struct ChessApp: App {
    init() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        } else {
            print("⚠️ WARNING: GoogleService-Info.plist NOT FOUND. Online features will crash or fail.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}

