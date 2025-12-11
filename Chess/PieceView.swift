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
            .font(.system(size: 36))
            .foregroundColor(pieceColor)
            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var symbol: String {
        switch piece.type {
        case .king: return "♚"
        case .queen: return "♛"
        case .rook: return "♜"
        case .bishop: return "♝"
        case .knight: return "♞"
        case .pawn: return "♟︎"
        }
    }
    
    var pieceColor: Color {
        piece.color == .white ? Theme.whitePiece : Theme.blackPiece
    }
}
