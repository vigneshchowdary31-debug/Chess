//
//  Move.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import Foundation

struct Move: Equatable {
    let from: Position
    let to: Position
    /// promotion piece type (if pawn promotion)
    var promotion: PieceType? = nil
    /// is this move an en passant capture?
    var isEnPassant: Bool = false
    /// is this move a castling?
    var isCastling: Bool = false
}
