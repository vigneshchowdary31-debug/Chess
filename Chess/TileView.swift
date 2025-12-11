//
//  TileView.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

struct TileView: View {
    let position: Position
    let piece: Piece?
    let isSelected: Bool
    let legalMove: Bool
    let isLastMoveTarget: Bool // Used for zIndex to keep moving piece on top
    let isFlipped: Bool // Counter-rotate pieces if board is flipped
    var pieceNamespace: Namespace.ID
    
    @AppStorage("showCoordinates") var showCoordinates = true
    @AppStorage("highlightMoves") var highlightMoves = true
    @AppStorage("showLegalMoves") var showLegalMoves = true
    @AppStorage("boardTheme") var boardTheme = BoardTheme.classic
    // autoFlipBoard is handled by parent passing isFlipped
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
            // highlight selected or legal
            // highlight selected or legal
            if isSelected {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Theme.selection, lineWidth: 4)
                    .padding(2)
            } else if legalMove && showLegalMoves {
                Circle()
                    .fill(Theme.legalMove)
                    .frame(width: 24, height: 24)
            }
            // Last move highlight
            if isLastMoveTarget && highlightMoves {
                 Rectangle()
                    .fill(Theme.lastMoveHighlight)
            }
            if let piece = piece {
                PieceView(piece: piece)
                    .matchedGeometryEffect(id: piece.id, in: pieceNamespace)
                    .rotationEffect(Angle(degrees: isFlipped ? 180 : 0))
                    .animation(.easeInOut(duration: 1.0), value: isFlipped)
                    .padding(6)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(isLastMoveTarget ? 100 : 1)
            }
            
            // Coordinates
            if showCoordinates {
                if position.file == 0 {
                    Text("\(position.rank + 1)")
                        .font(.caption2)
                        .foregroundColor(coordinateColor)
                        .padding(2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                if position.rank == 0 {
                    Text(position.fileString)
                        .font(.caption2)
                        .foregroundColor(coordinateColor)
                        .padding(2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
        }
    }
    
    var backgroundColor: Color {
        let isLight = (position.file + position.rank) % 2 == 0
        return isLight ? Theme.lightSquare : Theme.darkSquare
    }
    
    var coordinateColor: Color {
        let isLight = (position.file + position.rank) % 2 == 0
        return isLight ? Theme.darkSquare : Theme.lightSquare
    }
}
