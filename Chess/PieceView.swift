//
//  PieceView.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

struct PieceView: View {
    let piece: Piece
    
    var body: some View {
        Text(symbol)
            .font(.system(size: 28))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var symbol: String {
        switch (piece.type, piece.color) {
        case (.king, .white): return "♔"
        case (.queen, .white): return "♕"
        case (.rook, .white): return "♖"
        case (.bishop, .white): return "♗"
        case (.knight, .white): return "♘"
        case (.pawn, .white): return "♙"
        case (.king, .black): return "♚"
        case (.queen, .black): return "♛"
        case (.rook, .black): return "♜"
        case (.bishop, .black): return "♝"
        case (.knight, .black): return "♞"
        case (.pawn, .black): return "♟︎"
        }
    }
}
