
import SwiftUI

struct GameOverView: View {
    let checkmated: Bool
    let stalemated: Bool
    let winnerColor: PieceColor? // The color that WON (opposite of currentTurn if checkmated)
    let onReset: () -> Void
    
    var body: some View {
        ZStack {
            Theme.background.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                if checkmated {
                    Text("Checkmate!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let winner = winnerColor {
                        Text("\(winner.rawValue.capitalized) Wins")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.9))
                    }
                } else if stalemated {
                    Text("Stalemate")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    Text("Draw")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Button(action: onReset) {
                    Text("New Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Theme.accent)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.top, 10)
            }
            .padding(40)
            .background(Theme.panelBackground)
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}
