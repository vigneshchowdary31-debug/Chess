import Foundation
import Combine
import AudioToolbox
import SwiftUI
import UIKit

final class GameViewModel: ObservableObject {
    @Published private(set) var board: ChessBoard = ChessBoard()
    @Published var selected: Position? = nil
    @Published var legalMoves: [Position] = []
    @Published var currentTurn: PieceColor = .white
    @Published var checkmated: Bool = false
    @Published var stalemated: Bool = false
    @Published var showPromotionFor: Position? = nil
    @Published var lastMove: Move? = nil
    @Published var inCheck: Bool = false
    
    // Online
    @Published var onlineMode = false
    @Published var localPlayerColor: PieceColor? = nil // if nil, allow both (hotseat)
    private var cancellables = Set<AnyCancellable>()
    
    /// Move history (for undo or en-passant detection)
    private(set) var history: [Move] = []
    
    @Published var capturedPieces: [Piece] = []
    
    init() {
        reset()
    }
    

    func reset() {
        board = ChessBoard()
        selected = nil
        legalMoves = []
        currentTurn = .white
        checkmated = false
        stalemated = false
        showPromotionFor = nil
        lastMove = nil
        history = []
        lastMove = nil
        history = []
        inCheck = false
        capturedPieces = []
        // Don't reset online mode params unless explicit?
        // Actually reset() is called by "Reset" button. In online, reset is voted?
        // For now, if online, maybe just reset board state but keep connection?
        // Or if reset() is called, maybe it just resets local state?
        // Let's assume reset() is for local only or restarts game.
    }
    
    func startOnlineGame(code: String) {
        onlineMode = true
        FirebaseManager.shared.listenToGame(code: code)
        
        FirebaseManager.shared.$currentGame
            .sink { [weak self] game in
                guard let self = self, let game = game else { return }
                self.syncGameState(game: game)
            }
            .store(in: &cancellables)
    }
    
    func syncGameState(game: OnlineGame) {
        // Determine my color
        if game.whitePlayerId == FirebaseManager.shared.myId {
            localPlayerColor = .white
        } else if game.blackPlayerId == FirebaseManager.shared.myId {
            localPlayerColor = .black
        } else {
            // Observer?
            localPlayerColor = nil
        }
        
        // Apply moves I don't have
        if game.moves.count > self.history.count {
            for i in self.history.count..<game.moves.count {
                let move = game.moves[i]
                // Apply this move
                self.makeMove(move, silent: false, fromNetwork: true)
            }
        }
    }
    
    // MARK: - Selection & move generation
    func selectSquare(_ pos: Position) {
        // If a move is in progress: try to move
        if let sel = selected, legalMoves.contains(pos) {
            makeMove(Move(from: sel, to: pos))
            return
        }
        selected = nil
        legalMoves = []
        guard let piece = board.piece(at: pos) else { return }
        guard piece.color == currentTurn else { return }
        
        // Online check
        if let local = localPlayerColor, onlineMode {
            guard piece.color == local else { return }
        }
        
        selected = pos
        legalMoves = generateLegalMoves(from: pos)
    }
    
    func generateLegalMoves(from: Position) -> [Position] {
        guard let piece = board.piece(at: from) else { return [] }
        let pseudo = generatePseudoLegalMoves(from: from, piece: piece, board: board)
        // Filter out moves that leave king in check by making the move on a copy
        var legal: [Position] = []
        for to in pseudo {
            var copy = board.copied()
            let move = Move(from: from, to: to)
            applyMoveOnBoard(&copy, move: move, forReal: false)
            if !isKingInCheck(color: piece.color, board: copy) {
                legal.append(to)
            }
        }
        return legal
    }
    
    // PSEUDO-LEGAL (doesn't check leaving king in check)
    func generatePseudoLegalMoves(from: Position, piece: Piece, board: ChessBoard) -> [Position] {
        var moves: [Position] = []
        let color = piece.color
        switch piece.type {
        case .pawn:
            let forward = (color == .white) ? 1 : -1
            // one step
            if let one = from.offsetBy(0, forward), board.piece(at: one) == nil {
                moves.append(one)
                // two-step
                let startRank = (color == .white) ? 1 : 6
                if from.rank == startRank {
                    if let two = from.offsetBy(0, forward * 2), board.piece(at: two) == nil {
                        moves.append(two)
                    }
                }
            }
            // captures
            for df in [-1, 1] {
                if let cap = from.offsetBy(df, forward) {
                    if let target = board.piece(at: cap), target.color != color {
                        moves.append(cap)
                    } else {
                        // en passant possibility
                        if let last = lastMove {
                            // last move was two-step pawn adjacent to from
                            if let lastPiece = board.piece(at: last.to), lastPiece.type == .pawn, lastPiece.color != color {
                                // last move was two-step from starting rank to adjacent rank
                                let expectedFromRank = (lastPiece.color == .white) ? 1 : 6
                                if last.from.rank == expectedFromRank && last.to.rank == from.rank {
                                    if last.to.file == from.file + df {
                                        // target square for en passant capture
                                        if let epTarget = from.offsetBy(df, forward) {
                                            moves.append(epTarget) // mark as possible and we'll check later in apply
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        case .knight:
            let offsets = [(1,2),(2,1),(2,-1),(1,-2),(-1,-2),(-2,-1),(-2,1),(-1,2)]
            for (df, dr) in offsets {
                if let to = from.offsetBy(df, dr) {
                    if let p = board.piece(at: to) {
                        if p.color != color { moves.append(to) }
                    } else { moves.append(to) }
                }
            }
        case .bishop, .rook, .queen:
            var directions: [(Int,Int)] = []
            if piece.type == .bishop || piece.type == .queen {
                directions += [(1,1),(1,-1),(-1,1),(-1,-1)]
            }
            if piece.type == .rook || piece.type == .queen {
                directions += [(1,0),(-1,0),(0,1),(0,-1)]
            }
            for (df, dr) in directions {
                var step = 1
                while let to = from.offsetBy(df*step, dr*step) {
                    if let p = board.piece(at: to) {
                        if p.color != color { moves.append(to) }
                        break
                    } else {
                        moves.append(to)
                    }
                    step += 1
                }
            }
        case .king:
            for df in -1...1 {
                for dr in -1...1 {
                    if df==0 && dr==0 { continue }
                    if let to = from.offsetBy(df, dr) {
                        if let p = board.piece(at: to) {
                            if p.color != color { moves.append(to) }
                        } else { moves.append(to) }
                    }
                }
            }
            // Castling: check rook hasn't moved and king hasn't moved; spaces empty; not in check; path not attacked.
            if !piece.hasMoved {
                // King-side
                let rookPosK = Position(file: 7, rank: from.rank)
                if let rook = board.piece(at: rookPosK), rook.type == .rook, !rook.hasMoved {
                    // squares between
                    let between = [Position(file: 5, rank: from.rank), Position(file: 6, rank: from.rank)]
                    if between.allSatisfy({ board.piece(at: $0) == nil }) {
                        // cannot castle through check: ensure squares king passes are not attacked
                        var safe = true
                        for sq in [from] + between {
                            var copy = board.copied()
                            // move king to sq (simulate)
                            copy.setPiece(Piece(type: .king, color: color, hasMoved: true), at: sq)
                            copy.setPiece(nil, at: from)
                            if isKingInCheck(color: color, board: copy) { safe = false; break }
                        }
                        if safe { moves.append(Position(file: 6, rank: from.rank)) } // castling destination
                    }
                }
                // Queen-side
                let rookPosQ = Position(file: 0, rank: from.rank)
                if let rook = board.piece(at: rookPosQ), rook.type == .rook, !rook.hasMoved {
                    // squares between
                    let between = [Position(file: 3, rank: from.rank), Position(file: 2, rank: from.rank), Position(file: 1, rank: from.rank)]
                    if between.allSatisfy({ board.piece(at: $0) == nil }) {
                        var safe = true
                        for sq in [from, Position(file:3, rank:from.rank), Position(file:2, rank:from.rank)] {
                            var copy = board.copied()
                            copy.setPiece(Piece(type: .king, color: color, hasMoved: true), at: sq)
                            copy.setPiece(nil, at: from)
                            if isKingInCheck(color: color, board: copy) { safe = false; break }
                        }
                        if safe { moves.append(Position(file: 2, rank: from.rank)) } // castling destination
                    }
                }
            }
        }
        return moves
    }
    
    // MARK: - Checking attacks
    func isSquareAttacked(_ square: Position, by attacker: PieceColor, board: ChessBoard) -> Bool {
        // Generate pseudo-attacks from attacker and see if any reach square.
        // For pawns, attacks differ from move direction.
        for (pos, piece) in board.squares where piece.color == attacker {
            switch piece.type {
            case .pawn:
                let forward = (attacker == .white) ? 1 : -1
                for df in [-1, 1] {
                    if let attack = pos.offsetBy(df, forward), attack == square { return true }
                }
            case .knight:
                let offsets = [(1,2),(2,1),(2,-1),(1,-2),(-1,-2),(-2,-1),(-2,1),(-1,2)]
                for (df, dr) in offsets {
                    if let to = pos.offsetBy(df, dr), to == square { return true }
                }
            case .bishop:
                if isOnRay(pos: pos, target: square, deltas: [(1,1),(1,-1),(-1,1),(-1,-1)], board: board) { return true }
            case .rook:
                if isOnRay(pos: pos, target: square, deltas: [(1,0),(-1,0),(0,1),(0,-1)], board: board) { return true }
            case .queen:
                if isOnRay(pos: pos, target: square, deltas: [(1,1),(1,-1),(-1,1),(-1,-1),(1,0),(-1,0),(0,1),(0,-1)], board: board) { return true }
            case .king:
                for df in -1...1 {
                    for dr in -1...1 {
                        if df==0 && dr==0 { continue }
                        if let t = pos.offsetBy(df, dr), t == square { return true }
                    }
                }
            }
        }
        return false
    }
    
    private func isOnRay(pos: Position, target: Position, deltas: [(Int,Int)], board: ChessBoard) -> Bool {
        for (df, dr) in deltas {
            var step = 1
            while let p = pos.offsetBy(df*step, dr*step) {
                if p == target { return true }
                if board.piece(at: p) != nil { break }
                step += 1
            }
        }
        return false
    }
    
    func isKingInCheck(color: PieceColor, board: ChessBoard) -> Bool {
        // find king
        guard let kingEntry = board.squares.first(where: { $0.value.type == .king && $0.value.color == color }) else { return false }
        return isSquareAttacked(kingEntry.key, by: color.opponent, board: board)
    }
    
    // MARK: - Apply move
    func makeMove(_ move: Move, silent: Bool = false, fromNetwork: Bool = false) {
        // Determine if move is promotion/en-passant/castling by analyzing board
        _ = move
        // If pawn reaches last rank -> prompt promotion
        // But if move.promotion is already set (e.g. from undo replay or explicit choice), skip prompt
        if move.promotion == nil, let moving = board.piece(at: move.from), moving.type == .pawn {
            let lastRank = moving.color == .white ? 7 : 0
            if move.to.rank == lastRank {
                // show promotion UI before finalizing
                showPromotionFor = move.to
                // We keep selected/from info in a temp way by storing move in lastMove? We'll store the move's from->to in a variable
                // Save lastMove temporarily in history? We'll store pending move in lastMove variable with promotion nil and handle after selection
                lastMove = Move(from: move.from, to: move.to)
                return
            }
        }
        var boardCopy = board
        if let captured = applyMoveOnBoard(&boardCopy, move: move, forReal: true) {
            capturedPieces.append(captured)
        }
        
        if silent {
            board = boardCopy
        } else {
            // Use withAnimation to drive matchedGeometryEffect
            // Slower, smoother spring for better visual tracking
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                board = boardCopy
            }
        }
        
        // toggle turn and update history
        currentTurn = currentTurn.opponent
        history.append(move)
        lastMove = move
        selected = nil
        legalMoves = []
        // Sounds
        if !silent {
            if UserDefaults.standard.bool(forKey: "enableSound") {
                AudioServicesPlaySystemSound(1104) // Tock
            }
            triggerHaptic()
        }
        // check game end states
        updateGameEndConditions()
        
        if onlineMode && !fromNetwork {
            if let gameId = FirebaseManager.shared.currentGame?.id {
                FirebaseManager.shared.sendMove(gameId: gameId, move: move)
            }
        }
    }
    
    func undo() {
        guard !history.isEmpty else { return }
        let movesToReplay = history.dropLast()
        
        // Reset board to initial state
        reset()
        
        // Replay all previous moves silently
        // We need to restore 'history' manually after reset because reset clears it,
        // but makeMove appends to it. So strictly speaking we can just call makeMove for each.
        // reset() clears history, so we are good.
        
        for move in movesToReplay {
            makeMove(move, silent: true)
        }
    }
    
    /// Called to finalize promotion selection (choose queen/rook/bishop/knight)
    func finalizePromotion(to type: PieceType) {
        guard let pending = lastMove else { return }
        var move = pending
        move.promotion = type
        var boardCopy = board
        if let captured = applyMoveOnBoard(&boardCopy, move: move, forReal: true) {
            capturedPieces.append(captured)
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
            board = boardCopy
        }
        
        currentTurn = currentTurn.opponent
        history.append(move)
        lastMove = move
        showPromotionFor = nil
        selected = nil
        legalMoves = []
        if UserDefaults.standard.bool(forKey: "enableSound") {
            AudioServicesPlaySystemSound(1104)
        }
        triggerHaptic()
        updateGameEndConditions()
        
        if onlineMode {
            if let gameId = FirebaseManager.shared.currentGame?.id {
                FirebaseManager.shared.sendMove(gameId: gameId, move: move)
            }
        }
    }
    
    /// Applies move onto given board. if forReal==true, update hasMoved flags, handle en-passant removal, castling rook move, promotion.
    /// Returns captured piece if any (only accurate if forReal=true or we don't care about flags, but capture logic depends on board state)
    @discardableResult
    func applyMoveOnBoard(_ b: inout ChessBoard, move: Move, forReal: Bool) -> Piece? {
        guard var piece = b.piece(at: move.from) else { return nil }
        var captured: Piece? = nil
        
        // detect en-passant
        var actualMove = move
        if piece.type == .pawn {
            if move.to.file != move.from.file && b.piece(at: move.to) == nil {
                // capture en-passant
                actualMove.isEnPassant = true
            }
        }
        // detect castling (king two-square move)
        if piece.type == .king && abs(move.to.file - move.from.file) == 2 {
            actualMove.isCastling = true
        }
        
        // Handle capture
        if actualMove.isEnPassant {
            let capturedPawnPos = Position(file: actualMove.to.file, rank: actualMove.from.rank)
            captured = b.piece(at: capturedPawnPos)
            b.setPiece(nil, at: capturedPawnPos)
        } else {
            captured = b.piece(at: actualMove.to)
        }
        
        // Move piece
        b.setPiece(nil, at: actualMove.from)
        // handle promotion - if move.promotion exists or we have promotion implied
        if piece.type == .pawn {
            let lastRank = piece.color == .white ? 7 : 0
            if actualMove.to.rank == lastRank {
                if let prom = actualMove.promotion {
                    piece.type = prom
                } else {
                    // default queen if not specified (should normally be specified via finalizePromotion)
                    piece.type = .queen
                }
            }
        }
        // mark as moved
        if forReal { piece.hasMoved = true }
        b.setPiece(piece, at: actualMove.to)
        // handle castling rook movement
        if actualMove.isCastling {
            if actualMove.to.file == 6 {
                // king-side
                let rookFrom = Position(file:7, rank: actualMove.from.rank)
                let rookTo = Position(file:5, rank: actualMove.from.rank)
                if let rook = b.piece(at: rookFrom) {
                    var r = rook
                    if forReal { r.hasMoved = true }
                    b.setPiece(nil, at: rookFrom)
                    b.setPiece(r, at: rookTo)
                }
            } else if actualMove.to.file == 2 {
                // queen-side
                let rookFrom = Position(file:0, rank: actualMove.from.rank)
                let rookTo = Position(file:3, rank: actualMove.from.rank)
                if let rook = b.piece(at: rookFrom) {
                    var r = rook
                    if forReal { r.hasMoved = true }
                    b.setPiece(nil, at: rookFrom)
                    b.setPiece(r, at: rookTo)
                }
            }
        }
        
        return captured
    }
    
    // MARK: - Endgame checks
    func updateGameEndConditions() {
        // checkmate or stalemate: if current player has no legal moves and either in check -> checkmate else stalemate
        var hasAnyLegal = false
        for (pos, piece) in board.squares where piece.color == currentTurn {
            let moves = generateLegalMoves(from: pos)
            if !moves.isEmpty { hasAnyLegal = true; break }
        }

        
        // Update check status regardless of game end
        inCheck = isKingInCheck(color: currentTurn, board: board)
        
        if hasAnyLegal {
            checkmated = false
            stalemated = false
            return
        } else {
            if inCheck {
                checkmated = true
                stalemated = false
            } else {
                checkmated = false
                stalemated = true
            }
        }
    }

    func triggerHaptic() {
        if UserDefaults.standard.bool(forKey: "enableHaptics") {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }
    }
}
