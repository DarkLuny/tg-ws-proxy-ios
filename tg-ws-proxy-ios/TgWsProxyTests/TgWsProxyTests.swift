import XCTest
@testable import TgWsProxy

final class TgWsProxyTests: XCTestCase {

    func testSettingsStoreDefaults() throws {
        let store = SettingsStore()
        XCTAssertEqual(store.port, "1443")
        XCTAssertEqual(store.poolSize, 4)
        XCTAssertTrue(store.cfproxyEnabled)
        XCTAssertFalse(store.isDcAuto)
    }

    func testSettingsStoreProxyUrl() throws {
        let store = SettingsStore()
        let url = store.proxyUrl()
        XCTAssertTrue(url.contains("t.me/proxy"))
        XCTAssertTrue(url.contains("127.0.0.1"))
        XCTAssertTrue(url.contains("1443"))
    }

    func testSettingsStoreGenerateSecret() throws {
        let secret = SettingsStore.generateRandomSecret()
        XCTAssertEqual(secret.count, 32)
        XCTAssertTrue(secret.allSatisfy { $0.isHexDigit })
    }

    func testSettingsStoreBuildDcIps() throws {
        let store = SettingsStore()
        store.isDcAuto = true
        XCTAssertEqual(store.buildDcIps(), "")

        store.isDcAuto = false
        store.dc2 = "1.2.3.4"
        store.dc4 = "5.6.7.8"
        let ips = store.buildDcIps()
        XCTAssertTrue(ips.contains("2:1.2.3.4"))
        XCTAssertTrue(ips.contains("4:5.6.7.8"))
    }
}

extension Character {
    var isHexDigit: Bool {
        return isHexDigit || isNumber
    }
}
