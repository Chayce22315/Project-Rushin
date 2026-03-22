import Foundation
import CoreNFC
import Combine

class NFCController: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var credits: Int = 1  // start with your card credits
    private var session: NFCNDEFReaderSession?

    // start scanning for NFC card
    func startScan() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC reading not supported on this device")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Tap your arcade card"
        session?.begin()
    }

    // manually add credit (for testing or tap-based)
    func insertCredit() {
        credits += 1
        print("Credit added! Total credits: \(credits)")
    }

    // MARK: - NFCNDEFReaderSessionDelegate
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC session ended: \(error.localizedDescription)")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            self.insertCredit()
        }
    }
}