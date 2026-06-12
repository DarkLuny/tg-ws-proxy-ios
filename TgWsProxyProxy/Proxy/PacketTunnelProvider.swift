import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        NSLog("[PacketTunnel] Starting tunnel...")
        
        let config = self.protocolConfiguration as! NETunnelProviderProtocol
        let settings = config.providerConfiguration ?? [:]
        
        let port = settings["port"] as? Int ?? 1443
        let secretKey = settings["secretKey"] as? String ?? ""
        let dcIps = settings["dcIps"] as? String ?? ""
        let poolSize = settings["poolSize"] as? Int ?? 4
        let cfEnabled = settings["cfEnabled"] as? Bool ?? true
        let cfDomain = settings["cfDomain"] as? String ?? ""
        
        NSLog("[PacketTunnel] Config: port=\(port), secret=\(secretKey.prefix(8))..., cf=\(cfEnabled)")
        
        SetPoolSize(Int32(poolSize))
        SetCfProxyCacheDir(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? "")
        SetCfProxyConfig(cfEnabled ? 1 : 0, 1, cfDomain)
        
        let result = StartProxy("127.0.0.1", Int32(port), dcIps, secretKey, 1)
        
        if result == 0 {
            NSLog("[PacketTunnel] Proxy started on port \(port)")
            completionHandler(nil)
        } else {
            NSLog("[PacketTunnel] Failed to start proxy: \(result)")
            completionHandler(NSError(domain: "com.tgwsproxy", code: Int(result), userInfo: [NSLocalizedDescriptionKey: "Failed to start proxy: \(result)"]))
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        NSLog("[PacketTunnel] Stopping tunnel...")
        StopProxy()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)? = nil) {
        let message = String(data: messageData, encoding: .utf8) ?? ""
        
        switch message {
        case "stats":
            if let stats = GetStats() {
                let statsStr = String(cString: stats)
                FreeString(stats)
                completionHandler?(statsStr.data(using: .utf8))
            } else {
                completionHandler?(nil)
            }
        default:
            completionHandler?(nil)
        }
    }
}
