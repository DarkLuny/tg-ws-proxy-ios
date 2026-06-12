import Foundation
import UIKit
import AVFoundation

class BackgroundManager {
    static let shared = BackgroundManager()
    
    private var bgTask: UIBackgroundTaskIdentifier = .invalid
    private var keepAliveTimer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    func startBackgroundTask() {
        beginBackgroundTask()
        startSilentAudio()
        startKeepAliveTimer()
    }
    
    func stopBackgroundTask() {
        endBackgroundTask()
        stopSilentAudio()
        stopKeepAliveTimer()
    }
    
    private func beginBackgroundTask() {
        guard bgTask == .invalid else { return }
        bgTask = UIApplication.shared.beginBackgroundTask(withName: "TgWsProxy") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        guard bgTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(bgTask)
        bgTask = .invalid
    }
    
    private func startSilentAudio() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            
            guard let url = Bundle.main.url(forResource: "silence", withExtension: "mp3") else {
                createSilentAudioAndPlay()
                return
            }
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0.01
            audioPlayer?.play()
        } catch {
            print("Background audio failed: \(error)")
        }
    }
    
    private func createSilentAudioAndPlay() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("silence.mp3")
        
        guard let file = try? AVAudioFile(forWriting: fileURL, settings: format.settings) else { return }
        
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100)!
        buffer.frameLength = 44100
        
        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(buffer.frameLength) {
                channelData[i] = 0.001
            }
        }
        
        try? file.write(from: buffer)
        
        audioPlayer = try? AVAudioPlayer(contentsOf: fileURL)
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.volume = 0.01
        audioPlayer?.play()
    }
    
    private func stopSilentAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private func startKeepAliveTimer() {
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.refreshBackgroundTask()
        }
    }
    
    private func stopKeepAliveTimer() {
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
    }
    
    private func refreshBackgroundTask() {
        endBackgroundTask()
        beginBackgroundTask()
    }
}
