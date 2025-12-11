//
//  Piece.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//
import Foundation

enum PieceColor: String, Codable {
    case white, black
    
    var opponent: PieceColor { self == .white ? .black : .white }
}

enum PieceType: String, Codable {
    case king, queen, rook, bishop, knight, pawn
}

struct Piece: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: PieceType
    var color: PieceColor
    /// used to check castling and pawn first-move
    var hasMoved: Bool = false
}

