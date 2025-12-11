//
//  ContentView.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = GameViewModel()
    @Namespace var pieceNamespace
    
    var body: some View {
        VStack {
            header
            board
            controls
        }
        .padding()
        .sheet(item: $vm.showPromotionFor, content: { pos in
            PromotionPicker { chosen in
                vm.finalizePromotion(to: chosen)
            }
        })
    }
    
    var header: some View {
        HStack {
            Text(vm.checkmated ? "\(vm.currentTurn.rawValue.capitalized) is checkmated" :
                    vm.stalemated ? "Stalemate" :
                    vm.currentTurn == .white ? "White to move" : "Black to move")
                .font(.title2)
                .bold()
            Spacer()
            Button(action: { vm.reset() }) {
                Label("New Game", systemImage: "arrow.counterclockwise")
            }
        }
        .padding(.horizontal)
    }
    
    var board: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            VStack(spacing:0) {
                ForEach((0..<8).reversed(), id: \.self) { rank in
                    HStack(spacing:0) {
                        ForEach(0..<8, id: \.self) { file in
                            let pos = Position(file: file, rank: rank)
                            TileView(position: pos,
                                     piece: vm.board.piece(at: pos),
                                     isSelected: vm.selected == pos,
                                     legalMove: vm.legalMoves.contains(pos),
                                     pieceNamespace: pieceNamespace)
                            .frame(width: size/8, height: size/8)
                            .onTapGesture {
                                vm.selectSquare(pos)
                            }
                        }
                    }
                }
            }
            .cornerRadius(8)
            .shadow(radius: 6)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
    
    var controls: some View {
        HStack {
            Button { /* undo future */ } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
            }.disabled(vm.history.isEmpty)
            Spacer()
            Text("Last move: \(vm.lastMove != nil ? "\(vm.lastMove!.from.file),\(vm.lastMove!.from.rank) → \(vm.lastMove!.to.file),\(vm.lastMove!.to.rank)" : "—")")
                .font(.caption)
        }
        .padding(.horizontal)
    }
}
