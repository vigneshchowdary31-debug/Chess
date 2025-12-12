//
//  ContentView.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import SwiftUI

enum GameMode: Equatable {
    case passAndPlay
    case online(code: String)
}

struct ContentView: View {
    @StateObject var vm = GameViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // Mode passed from Menu
    var mode: GameMode = .passAndPlay
    
    @Namespace var pieceNamespace
    @State private var showSettings = false
    @AppStorage("autoFlipBoard") var autoFlipBoard = false
    @AppStorage("boardTheme") var boardTheme = BoardTheme.classic
    @AppStorage("isDarkMode") var isDarkMode = true
    
    init(mode: GameMode = .passAndPlay) {
        self.mode = mode
    }
    
    var shouldFlipBoard: Bool {
        if vm.onlineMode {
            return vm.localPlayerColor == .black
        } else {
            return autoFlipBoard && vm.currentTurn == .black
        }
    }
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Player (Opponent)
                // Top Player (Opponent)
                playerInfo(color: shouldFlipBoard ? .white : .black)
                    .rotationEffect(Angle(degrees: (autoFlipBoard && !vm.onlineMode) ? 180 : 0))
                
                Spacer()
                
                board
                    .padding(.horizontal)
                
                Spacer()
                
                // Bottom Player (Active/You)
                playerInfo(color: shouldFlipBoard ? .black : .white)
            }
            .padding(.vertical)
            .padding(.bottom, 120) // Increase space for floating controls
        }
        .onAppear {
            if case .online(let code) = mode {
                vm.startOnlineGame(code: code)
            }
        }
        .overlay(alignment: .topTrailing) {
            if case .online(let code) = mode {
                Text("Room: \(code)")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .overlay(alignment: .bottom) {
            floatingControls
                .padding(.bottom, 20)
        }
        .sheet(item: $vm.showPromotionFor, content: { pos in
            PromotionPicker { chosen in
                vm.finalizePromotion(to: chosen)
            }
        })
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .overlay(
            Group {
                if vm.checkmated || vm.stalemated {
                    GameOverView(
                        checkmated: vm.checkmated,
                        stalemated: vm.stalemated,
                        winnerColor: vm.checkmated ? vm.currentTurn.opponent : nil,
                        onReset: { vm.reset() }
                    )
                } else if vm.inCheck {
                    VStack {
                        Text("CHECK!")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.9))
                            .clipShape(Capsule())
                            .shadow(radius: 10)
                            .transition(.scale.combined(with: .opacity))
                        Spacer()
                    }
                    .padding(.top, 100) // Adjust position
                    .zIndex(100)
                }
            }
        )

    }
    
    // Old header removed/replaced
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
                                     isLastMoveTarget: vm.lastMove?.to == pos || vm.lastMove?.from == pos,
                                     isFlipped: shouldFlipBoard,
                                     pieceNamespace: pieceNamespace)
                            .frame(width: size/8, height: size/8)
                            .onTapGesture {
                                vm.selectSquare(pos)
                            }
                        }
                    }
                }
            }
            .cornerRadius(4)
            .shadow(radius: 10)
        }
        .aspectRatio(1, contentMode: .fit)
            .cornerRadius(4)
            .shadow(radius: 10)
            .rotationEffect(Angle(degrees: shouldFlipBoard ? 180 : 0))
            .animation(.easeInOut(duration: 1.0), value: vm.currentTurn)
    }
    
    // MARK: - New Subviews
    
    @ViewBuilder
    func playerInfo(color: PieceColor) -> some View {
        HStack {
            // Avatar / Icon
            Circle()
                .fill(color == .white ? Theme.whitePiece : Theme.blackPiece)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(color == .white ? "W" : "B")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(color == .white ? .black : .white)
                )
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(color == .white ? "White" : "Black")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.primary)
                
                // Show pieces captured BY this color (so pieces of opposite color)
                CapturedPiecesView(pieces: vm.capturedPieces, color: color.opponent)
            }
            
            Spacer()
            
            // Turn indicator (if active)
            if vm.currentTurn == color && !vm.checkmated && !vm.stalemated {
                Text("Thinking...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(Theme.panelBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    var floatingControls: some View {
        HStack(spacing: 20) {
            Button { vm.undo() } label: {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title3)
                    Text("Undo").font(.caption2)
                }
                .foregroundColor(.primary)
            }.disabled(vm.history.isEmpty || vm.onlineMode)
            
            Button { vm.reset() } label: {
                 VStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                    Text("Reset").font(.caption2)
                }
                .foregroundColor(.primary)
            }.disabled(vm.onlineMode)
            
            Button { showSettings = true } label: {
                 VStack(spacing: 4) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                    Text("Settings").font(.caption2)
                }
                .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 12)
        .background(.thinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
