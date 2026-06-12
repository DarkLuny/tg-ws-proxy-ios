import Foundation
import UIKit
import AVFoundation
import CoreLocation

class BackgroundManager: NSObject, ObservableObject {
    static let shared = BackgroundManager()
    
    @Published var isBackgroundActive = false
    
    private var bgTask: UIBackgroundTaskIdentifier = .invalid
    private var audioPlayer: AVAudioPlayer?
    private var keepAliveTimer: Timer?
    private var locationManager: CLLocationManager?
    private var bgRefreshTimer: Timer?
    
    private override init() {
        super.init()
    }
    
    func startBackgroundTask() {
        guard !isBackgroundActive else { return }
        
        beginBackgroundTask()
        startSilentAudio()
        startLocationUpdates()
        startKeepAliveTimer()
        startBackgroundRefresh()
        
        isBackgroundActive = true
        NSLog("[Background] Started")
    }
    
    func stopBackgroundTask() {
        endBackgroundTask()
        stopSilentAudio()
        stopLocationUpdates()
        stopKeepAliveTimer()
        stopBackgroundRefresh()
        
        isBackgroundActive = false
        NSLog("[Background] Stopped")
    }
    
    // MARK: - Background Task
    
    private func beginBackgroundTask() {
        guard bgTask == .invalid else { return }
        bgTask = UIApplication.shared.beginBackgroundTask(withName: "TgWsProxyKeepAlive") { [weak self] in
            NSLog("[Background] Task expired, refreshing...")
            self?.refreshBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        guard bgTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(bgTask)
        bgTask = .invalid
    }
    
    private func refreshBackgroundTask() {
        endBackgroundTask()
        beginBackgroundTask()
    }
    
    // MARK: - Silent Audio
    
    private func startSilentAudio() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .defaultToSpeaker])
            try session.setActive(true)
            
            guard let url = Bundle.main.url(forResource: "silence", withExtension: "mp3") else {
                createAndPlaySilentAudio()
                return
            }
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0.001
            audioPlayer?.play()
        } catch {
            createAndPlaySilentAudio()
        }
    }
    
    private func createAndPlaySilentAudio() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("tgwsproxy_silence.mp3")
        
        guard let file = try? AVAudioFile(forWriting: fileURL, settings: format.settings) else { return }
        
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100)!
        buffer.frameLength = 44100
        
        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(buffer.frameLength) {
                channelData[i] = 0.0001
            }
        }
        
        try? file.write(from: buffer)
        
        audioPlayer = try? AVAudioPlayer(contentsOf: fileURL)
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.volume = 0.001
        audioPlayer?.play()
    }
    
    private func stopSilentAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    // MARK: - Location Updates (keeps app alive)
    
    private func startLocationUpdates() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.showsBackgroundLocationIndicator = false
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager?.startUpdatingLocation()
    }
    
    private func stopLocationUpdates() {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }
    
    // MARK: - Keep Alive Timer
    
    private func startKeepAliveTimer() {
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            self?.refreshBackgroundTask()
        }
    }
    
    private func stopKeepAliveTimer() {
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
    }
    
    // MARK: - Background Refresh
    
    private func startBackgroundRefresh() {
        bgRefreshTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.performBackgroundRefresh()
        }
    }
    
    private func stopBackgroundRefresh() {
        bgRefreshTimer?.invalidate()
        bgRefreshTimer = nil
    }
    
    private func performBackgroundRefresh() {
        UIApplication.shared.beginBackgroundTask(withName: "Refresh") { [weak self] in
            self?.performBackgroundRefresh()
        }
    }
}

extension BackgroundManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location update keeps app alive
        NSLog("[Background] Location update received")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("[Background] Location error: \(error)")
    }
}
