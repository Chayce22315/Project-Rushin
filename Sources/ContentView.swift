import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var nfc = NFCController()
    @State private var showGame = false

    var body: some View {
        ZStack {
            if showGame {
                SpriteGameView()
                    .edgesIgnoringSafeArea(.all)
            } else {
                VStack(spacing: 20) {
                    Text("SWIPE CARD")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()

                    Text("CREDITS: \(nfc.credits)")
                        .foregroundColor(.white)
                        .font(.title2)

                    Button(action: {
                        nfc.startScan()
                    }) {
                        Text("TAP TO SCAN CARD")
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }

                    Button(action: startGameIfReady) {
                        Text("START GAME")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }
        }
    }

    private func startGameIfReady() {
        if nfc.credits > 0 {
            nfc.credits -= 1
            showGame = true
        }
    }
}

// MARK: - SpriteKit Game Scene Wrapper
struct SpriteGameView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: UIScreen.main.bounds)
        let scene = GameScene(size: UIScreen.main.bounds.size)
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) { }
}

// MARK: - GameScene (2D Cube)
class GameScene: SKScene {
    private var cube: SKSpriteNode!
    private var finishLine: SKSpriteNode!
    private var timerLabel: SKLabelNode!
    private var timeLeft: TimeInterval = 60

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupCube()
        setupFinishLine()
        setupTimer()
    }

    private func setupCube() {
        cube = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        cube.position = CGPoint(x: frame.minX + 60, y: frame.midY)
        addChild(cube)
    }

    private func setupFinishLine() {
        finishLine = SKSpriteNode(color: .red, size: CGSize(width: 50, height: frame.height))
        finishLine.position = CGPoint(x: frame.maxX - 50, y: frame.midY)
        addChild(finishLine)
    }

    private func setupTimer() {
        timerLabel = SKLabelNode(fontNamed: "Helvetica")
        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(timerLabel)
        updateTimerLabel()
    }

    private func updateTimerLabel() {
        timerLabel.text = "Time Left: \(Int(timeLeft))s"
    }

    override func update(_ currentTime: TimeInterval) {
        timeLeft -= 1/60
        updateTimerLabel()
        if timeLeft <= 0 {
            gameOver(failed: true)
        }
        if cube.frame.intersects(finishLine.frame) {
            gameOver(failed: false)
        }
    }

    private func gameOver(failed: Bool) {
        let message = failed ? "You exploded!" : "You escaped!"
        let label = SKLabelNode(text: message)
        label.fontSize = 36
        label.fontColor = failed ? .red : .green
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(label)
        isPaused = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        cube.position = location
    }
}