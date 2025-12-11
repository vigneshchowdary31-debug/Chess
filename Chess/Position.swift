//
//  Position.swift
//  Chess
//
//  Created by Vignesh Chowdary on 24/11/25.
//

import Foundation

/// Board coordinate: file (0..7), rank (0..7)
struct Position: Hashable, Codable, Identifiable {
    let file: Int // 0..7 (a..h)
    let rank: Int // 0..7 (1..8)
    
    // Use a stable identifier combining file and rank
    var id: Int { rank * 8 + file }
    
    init(file: Int, rank: Int) {
        self.file = file
        self.rank = rank
    }
    
    func offsetBy(_ df: Int, _ dr: Int) -> Position? {
        let f = file + df, r = rank + dr
        guard (0...7).contains(f) && (0...7).contains(r) else { return nil }
        return Position(file: f, rank: r)
    }
}

