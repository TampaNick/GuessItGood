//
//  PlayerScoreView.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 9/8/25.
//

import SwiftUI

struct PlayerScoreView: View {
    @ObservedObject var player: Player
    var width: CGFloat
    var height: CGFloat
    var fontSize: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue)
                .frame(width: width, height: height)
            VStack {
                Text(player.name.isEmpty ? "Player \(player.id)" : player.name)
                    .font(.system(size: fontSize))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("\(player.totalScore + player.roundScore)")
                    .font(.system(size: fontSize))
                    .foregroundColor(.white)
                Text("Round: \(player.roundScore)")
                                   .font(.system(size: fontSize * 0.8))
                                   .foregroundColor(.white)
            }
        }
    }
}

#if DEBUG
struct PlayerScoreView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePlayer = Player(id: 1)
        samplePlayer.name = "Player 1"
        samplePlayer.totalScore = 1000
        samplePlayer.roundScore = 200
               return PlayerScoreView(player: samplePlayer, width: 100, height: 50, fontSize: 12)
    }
}
#endif
