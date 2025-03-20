
//
//  ContentView.swift
//  ping pong
//
//  Created by Tipu Sultan on 3/19/25.
//

import SwiftUI

struct HomeScreenView: View {
    @State private var ballPosition: CGPoint = CGPoint(x: 200, y: 200)
    @State private var ballVelocity: CGVector = CGVector(dx: 4, dy: 4)
    @State private var playerPaddlePosition: CGFloat = 100
    @State private var aiPaddlePosition: CGFloat = 100
    @State private var scorePlayer = 0
    @State private var scoreAI = 0
    @State private var isGameOver = false
    
    let ballRadius: CGFloat = 15
    let paddleWidth: CGFloat = 100
    let paddleHeight: CGFloat = 20
    let gameWidth: CGFloat = 400
    let gameHeight: CGFloat = 800
    
    let topBoundaryY: CGFloat = 50
    let bottomBoundaryY: CGFloat = 750
    
    let playerScoreKey = "playerScore"
    let aiScoreKey = "aiScore"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Colorful gradient background
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue, .pink]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                // Ball with glow effect
                Circle()
                    .frame(width: ballRadius * 2, height: ballRadius * 2)
                    .position(ballPosition)
                    .foregroundColor(.white)
                    .shadow(color: .yellow, radius: 10)
                
                // Player Paddle (Green)
                Rectangle()
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(x: playerPaddlePosition, y: gameHeight - 80)
                    .foregroundColor(.green)
                    .cornerRadius(10)
                
                // AI Paddle (Orange)
                Rectangle()
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(x: aiPaddlePosition, y: 80)
                    .foregroundColor(.orange)
                    .cornerRadius(10)
                
                VStack {
                    HStack {
                        Text("Player: \(scorePlayer)")
                            .font(.title)
                            .foregroundColor(.white)
                        Spacer()
                        Text("AI: \(scoreAI)")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }.padding()
                
                if isGameOver {
                    VStack {
                        Text("Game Over")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Text("Player: \(scorePlayer) - AI: \(scoreAI)")
                            .foregroundColor(.white)
                            .font(.title)
                        Button(action: resetGame) {
                            Text("Play Again")
                                .font(.title2)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.8))
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .onAppear {
                loadScores()
                startGameLoop()
            }
            .gesture(DragGesture().onChanged { value in
                playerPaddlePosition = min(max(value.location.x, paddleWidth / 2), gameWidth - paddleWidth / 2)
            })
        }
    }
    
    func startGameLoop() {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if !isGameOver {
                updateBallPosition()
                checkCollisions()
                updateAIPaddlePosition()
            }
        }
    }
    
    func updateBallPosition() {
        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy
        
        if ballPosition.x <= ballRadius || ballPosition.x >= gameWidth - ballRadius {
            ballVelocity.dx = -ballVelocity.dx
        }
        
        if ballPosition.y <= topBoundaryY + ballRadius {
            ballVelocity.dy = -ballVelocity.dy
            scorePlayer += 1
            saveScores()
            endGame()
        }
        
        if ballPosition.y >= bottomBoundaryY - ballRadius {
            ballVelocity.dy = -ballVelocity.dy
            scoreAI += 1
            saveScores()
            endGame()
        }
    }
    
    func checkCollisions() {
        if ballPosition.y + ballRadius >= gameHeight - paddleHeight - 50 &&
            ballPosition.x >= playerPaddlePosition - paddleWidth / 2 &&
            ballPosition.x <= playerPaddlePosition + paddleWidth / 2 {
            ballVelocity.dy = -ballVelocity.dy
        }
        
        if ballPosition.y - ballRadius <= paddleHeight + 50 &&
            ballPosition.x >= aiPaddlePosition - paddleWidth / 2 &&
            ballPosition.x <= aiPaddlePosition + paddleWidth / 2 {
            ballVelocity.dy = -ballVelocity.dy
        }
    }
    
    func updateAIPaddlePosition() {
        aiPaddlePosition = ballPosition.x
    }
    
    func endGame() {
        isGameOver = true
    }
    
    func resetGame() {
        ballPosition = CGPoint(x: 200, y: 200)
        ballVelocity = CGVector(dx: 4, dy: 4)
        playerPaddlePosition = 100
        aiPaddlePosition = 100
        isGameOver = false
    }
    
    func loadScores() {
        if let savedPlayerScore = UserDefaults.standard.value(forKey: playerScoreKey) as? Int {
            scorePlayer = savedPlayerScore
        }
        if let savedAIScore = UserDefaults.standard.value(forKey: aiScoreKey) as? Int {
            scoreAI = savedAIScore
        }
    }
    
    func saveScores() {
        UserDefaults.standard.set(scorePlayer, forKey: playerScoreKey)
        UserDefaults.standard.set(scoreAI, forKey: aiScoreKey)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
