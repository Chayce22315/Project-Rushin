import CoreNFC
import SwiftUI

class NFCController: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var lastUID: String = ""
    @Published var message: String = "Tap your card or play as guest!"
    @Published var credits: Int = 0
    @Published var gameScore: Int = 0

    var session: NFCNDEFReaderSession?

    // your real D&B card UID
    let myCardUID = "040cd3122b2291"

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            message = "NFC not supported on this device"
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your card near the top of your iPhone."
        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.message = "Scan cancelled or failed: \(error.localizedDescription)"
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            // assign the UID
            self.lastUID = self.myCardUID
            self.message = "Card detected! UID: \(self.lastUID)"
            self.grantArcadeCredit()
            self.startGame()
        }
    }

    // arcade-style: 1 credit per scan
    func grantArcadeCredit() {
        credits += 1
    }

    func startGame() {
        message = "Game started! Tap to score!"
        gameScore = 0
    }

    func incrementScore() {
        // anyone can score
        gameScore += 1
    }

    func playAsGuest() {
        lastUID = "" // clear UID
        grantArcadeCredit()
        startGame()
    }
}