//
//  FirebaseManager.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import Combine

struct OnlineGame: Codable, Identifiable {
    var id: String // The 6-digit code
    var whitePlayerId: String?
    var blackPlayerId: String?
    // Use "moves" only; remove "maneuvers" to avoid initializer mismatch and Codable ambiguity.
    var moves: [Move] = []
    var currentTurn: String = "white" // "white" or "black"
    var status: String = "waiting" // waiting, playing, finished
    var winner: String?
}

@MainActor
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    private var db: Firestore?
    
    @Published var currentGame: OnlineGame?
    private var listenerRegistration: ListenerRegistration?
    
    // Store simple unique ID for this device
    let myId: String
    
    init() {
        let key = "chess_user_id"
        if let saved = UserDefaults.standard.string(forKey: key) {
            self.myId = saved
        } else {
            let new = UUID().uuidString
            UserDefaults.standard.set(new, forKey: key)
            self.myId = new
        }
        
        // Safe init
        if FirebaseApp.app() != nil {
            self.db = Firestore.firestore()
        }
    }
    
    // Create a game and return the code
    func createGame(completion: @escaping (Result<String, Error>) -> Void) {
        guard let db = db else {
            let error = NSError(domain: "FirebaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Firebase not configured. Check GoogleService-Info.plist."])
            completion(.failure(error))
            return
        }
        
        let code = String(Int.random(in: 100000...999999))
        let game = OnlineGame(
            id: code,
            whitePlayerId: myId,
            blackPlayerId: nil,
            moves: [],
            currentTurn: "white",
            status: "waiting"
        )
        
        do {
            try db.collection("games").document(code).setData(from: game) { error in
                if let error = error {
                    print("Error creating game: \(error)")
                    completion(.failure(error))
                } else {
                    self.listenToGame(code: code)
                    completion(.success(code))
                }
            }
        } catch {
            print("Error encoding game: \(error)")
            completion(.failure(error))
        }
    }
    
    // Join a game
    func joinGame(code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let db = db else {
            completion(.failure(NSError(domain: "Chess", code: 404, userInfo: [NSLocalizedDescriptionKey: "Firebase not configured."])))
            return
        }
        let docRef = db.collection("games").document(code)
        
        docRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "Chess", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"])))
                return
            }
            
            do {
                var game = try snapshot.data(as: OnlineGame.self)
                if game.whitePlayerId == self.myId {
                    // Rejoining as white
                    self.listenToGame(code: code)
                    completion(.success(()))
                } else if game.blackPlayerId == nil {
                    // Join as black
                    game.blackPlayerId = self.myId
                    game.status = "playing"
                    try? docRef.setData(from: game)
                    self.listenToGame(code: code)
                    completion(.success(()))
                } else if game.blackPlayerId == self.myId {
                    // Rejoining as black
                    self.listenToGame(code: code)
                    completion(.success(()))
                } else {
                    // Game full
                    completion(.failure(NSError(domain: "Chess", code: 403, userInfo: [NSLocalizedDescriptionKey: "Game is full"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Listen to updates
    func listenToGame(code: String) {
        listenerRegistration?.remove()
        guard let db = db else { return }
        
        listenerRegistration = db.collection("games").document(code)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                // Update on MainActor
                Task { @MainActor in
                    try? self.currentGame = snapshot.data(as: OnlineGame.self)
                }
            }
    }
    
    // Send a move
    func sendMove(gameId: String, move: Move) {
        guard var game = currentGame else { return }
        guard let db = db else { return }
        
        game.moves.append(move)
        game.currentTurn = (game.currentTurn == "white") ? "black" : "white"
        
        do {
            try db.collection("games").document(gameId).setData(from: game)
        } catch {
            print("Error parsing move: \(error)")
        }
    }
    
    func quitGame() {
        listenerRegistration?.remove()
        currentGame = nil
    }
}
