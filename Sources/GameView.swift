import SwiftUI

struct GameView: View {
    // Player
    @State private var playerX: CGFloat = 150
    @State private var playerY: CGFloat = 300
    @State private var velocityY: CGFloat = 0
    
    @State private var isJumping = false
    @State private var isCrouching = false
    @State private var isDashing = false
    
    @State private var moveLeft = false
    @State private var moveRight = false
    
    // Game constants
    let gravity: CGFloat = 0.8
    let groundY: CGFloat = 300
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Player
            Rectangle()
                .fill(Color.green)
                .frame(width: 40, height: isCrouching ? 20 : 40)
                .position(x: playerX, y: playerY)
            
            VStack {
                Spacer()
                
                // Controls
                HStack(spacing: 20) {
                    
                    // LEFT
                    Button("⬅️") {}
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in moveLeft = true }
                                .onEnded { _ in moveLeft = false }
                        )
                    
                    // RIGHT
                    Button("➡️") {}
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in moveRight = true }
                                .onEnded { _ in moveRight = false }
                        )
                    
                    // JUMP
                    Button("⬆️") {
                        jump()
                    }
                    .frame(width: 60, height: 60)
                    .background(Color.blue.opacity(0.4))
                    .cornerRadius(10)
                    
                    // CROUCH
                    Button("⬇️") {
                        isCrouching.toggle()
                    }
                    .frame(width: 60, height: 60)
                    .background(Color.orange.opacity(0.4))
                    .cornerRadius(10)
                    
                    // DASH
                    Button("⚡") {
                        dash()
                    }
                    .frame(width: 60, height: 60)
                    .background(Color.purple.opacity(0.4))
                    .cornerRadius(10)
                }
                .foregroundColor(.white)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            gameLoop()
        }
    }
    
    // 🎮 GAME LOOP
    func gameLoop() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            
            // Gravity
            velocityY += gravity
            playerY += velocityY
            
            // Ground collision
            if playerY >= groundY {
                playerY = groundY
                velocityY = 0
                isJumping = false
            }
            
            // Movement
            if moveLeft { playerX -= 4 }
            if moveRight { playerX += 4 }
            
            // Screen bounds
            if playerX < 20 { playerX = 20 }
            if playerX > 350 { playerX = 350 }
        }
    }
    
    // ⬆️ JUMP
    func jump() {
        if !isJumping {
            velocityY = -15
            isJumping = true
        }
    }
    
    // ⚡ DASH
    func dash() {
        if !isDashing {
            isDashing = true
            playerX += 60
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isDashing = false
            }
        }
    }
}
