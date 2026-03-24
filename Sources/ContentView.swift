import SwiftUI

struct ContentView: View {
    @StateObject var nfc = NFCController()

    var body: some View {
        VStack(spacing: 30) {
            Text("Arcade Game")
                .font(.largeTitle)
                .bold()

            Text("Credits: \(nfc.credits)")
                .font(.title)

            Text(nfc.message)
                .multilineTextAlignment(.center)
                .padding()

            Text("Score: \(nfc.gameScore)")
                .font(.title2)

            HStack(spacing: 20) {
                Button("Scan Card") {
                    nfc.beginScanning()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Tap Game") {
                    nfc.incrementScore()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Play as Guest") {
                    nfc.playAsGuest()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }
}