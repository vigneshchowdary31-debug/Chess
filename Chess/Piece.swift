//
//  Piece.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import Foundation

enum PieceType: String, Codable {
    case pawn, rook, knight, bishop, queen, king
}

enum PieceColor: String, Codable {
    case white, black
    
    var opponent: PieceColor {
        self == .white ? .black : .white
    }
}

struct Piece: Identifiable, Equatable, Hashable, Codable {
    var id = UUID()
    var type: PieceType
    var color: PieceColor
    var hasMoved: Bool = false
    
    // For Equatable mostly we care about type/color/hasMoved, but id makes them unique instances.
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.id == rhs.id
    }
}
