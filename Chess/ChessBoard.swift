//
//  ChessBoard.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import Foundation

/// Represents the board state and helpers to clone/apply moves
struct ChessBoard {
    // 8x8 board, index [file][rank] for convenience
    // stored as dictionary Position -> Piece to ease cloning
    var squares: [Position: Piece] = [:]
    
    init() {
        setupInitialPosition()
    }
    
    mutating func setupInitialPosition() {
        squares.removeAll()
        // Place pawns
        for f in 0...7 {
            squares[Position(file: f, rank: 1)] = Piece(type: .pawn, color: .white)
            squares[Position(file: f, rank: 6)] = Piece(type: .pawn, color: .black)
        }
        // Rooks
        squares[Position(file: 0, rank: 0)] = Piece(type: .rook, color: .white)
        squares[Position(file: 7, rank: 0)] = Piece(type: .rook, color: .white)
        squares[Position(file: 0, rank: 7)] = Piece(type: .rook, color: .black)
        squares[Position(file: 7, rank: 7)] = Piece(type: .rook, color: .black)
        // Knights
        squares[Position(file: 1, rank: 0)] = Piece(type: .knight, color: .white)
        squares[Position(file: 6, rank: 0)] = Piece(type: .knight, color: .white)
        squares[Position(file: 1, rank: 7)] = Piece(type: .knight, color: .black)
        squares[Position(file: 6, rank: 7)] = Piece(type: .knight, color: .black)
        // Bishops
        squares[Position(file: 2, rank: 0)] = Piece(type: .bishop, color: .white)
        squares[Position(file: 5, rank: 0)] = Piece(type: .bishop, color: .white)
        squares[Position(file: 2, rank: 7)] = Piece(type: .bishop, color: .black)
        squares[Position(file: 5, rank: 7)] = Piece(type: .bishop, color: .black)
        // Queens
        squares[Position(file: 3, rank: 0)] = Piece(type: .queen, color: .white)
        squares[Position(file: 3, rank: 7)] = Piece(type: .queen, color: .black)
        // Kings
        squares[Position(file: 4, rank: 0)] = Piece(type: .king, color: .white)
        squares[Position(file: 4, rank: 7)] = Piece(type: .king, color: .black)
    }
    
    func piece(at pos: Position) -> Piece? {
        squares[pos]
    }
    
    mutating func setPiece(_ piece: Piece?, at pos: Position) {
        if let p = piece { squares[pos] = p } else { squares.removeValue(forKey: pos) }
    }
    
    /// return copy
    func copied() -> ChessBoard {
        var n = ChessBoard()
        n.squares = self.squares
        return n
    }
}
