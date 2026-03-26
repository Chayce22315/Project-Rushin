import SwiftUI

struct Obstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
}

struct GameView: View {
    
    // PLAYER
    @State private var playerX: CGFloat = 150
    @State private var playerY: CGFloat = 300
    @State private var velocityY: CGFloat = 0
    
    @State private var isJumping = false
    @State private var isCrouching = false
    @State private var isDashing = false
    
    @State private var moveLeft = false
    @State private var moveRight = false
    
    // GAME
    @State private var obstacles: [Obstacle] = []
    @State private var gameOver = false
    
    // CAMERA
    @State private var cameraOffset: CGFloat = 0
    
    // TIMER
    @State private var timeLeft: Int = 60
    
    let gravity: CGFloat = 0.8
    let groundY: CGFloat = 300
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // WORLD (moves with camera)
            ZStack {
                
                // Obstacles
                ForEach(obstacles) { obs in
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 40, height: 40)
                        .position(x: obs.x - cameraOffset, y: obs.y)
                }
                
                // Player (centered)
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 40, height: isCrouching ? 20 : 40)
                    .position(x: playerX, y: playerY)
                
            }
            
            // 💣 TIMER (cut off bottom right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("💣 \(timeLeft)")
                        .font(.largeTitle)
                        .padding()
                        .offset(x: 40, y: 40) // pushes it off screen a bit
                }
            }
            
            // 💀 GAME OVER TEXT
            if gameOver {
                Text("YOU DIED 💀")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
            
            // 🎮 CONTROLS (split layout)
            VStack {
                Spacer()
                
                HStack {
                    
                    // LEFT SIDE (movement)
                    VStack {
                        HStack {
                            controlButton("⬅️") { moveLeft = true } release: { moveLeft = false }
                            controlButton("➡️") { moveRight = true } release: { moveRight = false }
                        }
                    }
                    
                    Spacer()
                    
                    // RIGHT SIDE (actions)
                    VStack(spacing: 10) {
                        controlButton("⬆️") { jump() }
                        HStack {
                            controlButton("⬇️") { isCrouching.toggle() }
                            controlButton("⚡") { dash() }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            gameLoop()
            spawnLoop()
            timerLoop()
        }
    }
    
    // 🎮 BUTTON HELPER
    func controlButton(_ text: String, action: @escaping () -> Void, release: (() -> Void)? = nil) -> some View {
        Text(text)
            .frame(width: 60, height: 60)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
            .foregroundColor(.white)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in action() }
                    .onEnded { _ in release?() }
            )
    }
    
    // 🎮 GAME LOOP
    func gameLoop() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            
            if gameOver { return }
            
            // Gravity
            velocityY += gravity
            playerY += velocityY
            
            // Ground
            if playerY >= groundY {
                playerY = groundY
                velocityY = 0
                isJumping = false
            }
            
            // Movement
            if moveLeft { playerX -= 4 }
            if moveRight { playerX += 4 }
            
            // Camera follows player
            cameraOffset += 2
            
            // Move obstacles
            for i in obstacles.indices {
                obstacles[i].x -= 2
            }
            
            // Collision
            for obs in obstacles {
                if abs((obs.x - cameraOffset) - playerX) < 30 &&
                   abs(obs.y - playerY) < 30 {
                    gameOver = true
                }
            }
        }
    }
    
    // ⏱️ TIMER
    func timerLoop() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if gameOver { return }
            
            timeLeft -= 1
            if timeLeft <= 0 {
                // next level later 👀
                timeLeft = 60
            }
        }
    }
    
    // 💀 SPAWN OBSTACLES
    func spawnLoop() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if gameOver { return }
            
            let new = Obstacle(
                x: cameraOffset + 400,
                y: groundY
            )
            
            obstacles.append(new)
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
