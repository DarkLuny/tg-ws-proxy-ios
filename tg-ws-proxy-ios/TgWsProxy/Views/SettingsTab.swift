import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var proxyManager: ProxyManager
    @EnvironmentObject var settings: SettingsStore
    @State private var showIpSetup = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(.blue)
                        Text("Подключение")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Порт")
                        Spacer()
                        TextField("1443", text: $settings.port)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .disabled(proxyManager.isRunning)
                    }

                    Button(action: { showIpSetup = true }) {
                        HStack {
                            Image(systemName: "gearshape")
                                .foregroundColor(.blue)
                            Text(settings.cfproxyEnabled ? "CF включен" : "Настроить DC адреса")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(settings.cfproxyEnabled || proxyManager.isRunning)
                }

                Section {
                    HStack {
                        Image(systemName: "layers")
                            .foregroundColor(.blue)
                        Text("WS Pool")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    Picker("Размер пула", selection: $settings.poolSize) {
                        Text("2").tag(2)
                        Text("4").tag(4)
                        Text("6").tag(6)
                    }
                    .pickerStyle(.segmented)
                    .disabled(proxyManager.isRunning)
                }

                Section {
                    HStack {
                        Image(systemName: "key")
                            .foregroundColor(.blue)
                        Text("Секретный ключ")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text(settings.secretKey)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button(action: {
                            settings.generateNewSecret()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                        .disabled(proxyManager.isRunning)
                    }
                }

                Section {
                    Toggle(isOn: $settings.cfproxyEnabled) {
                        HStack {
                            Image(systemName: "cloud")
                                .foregroundColor(.blue)
                            Text("CloudFlare CDN")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .disabled(proxyManager.isRunning)
                    .onChange(of: settings.cfproxyEnabled) { newValue in
                        settings.isDcAuto = newValue
                    }
                }

                Section {
                    Toggle(isOn: $settings.autoStartOnBoot) {
                        HStack {
                            Image(systemName: "power")
                                .foregroundColor(.blue)
                            Text("Автозапуск")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Настройки")
            .sheet(isPresented: $showIpSetup) {
                IpSetupSheet()
            }
        }
    }
}

struct IpSetupSheet: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if settings.isExperimentalMode {
                    Section("Основные DC") {
                        DcInput(label: "DC1", value: $settings.dc1)
                        DcInput(label: "DC2", value: $settings.dc2)
                        DcInput(label: "DC3", value: $settings.dc3)
                        DcInput(label: "DC4", value: $settings.dc4)
                        DcInput(label: "DC5", value: $settings.dc5)
                        DcInput(label: "DC203", value: $settings.dc203)
                    }

                    Section("Media DC") {
                        DcInput(label: "DC1m", value: $settings.dc1m)
                        DcInput(label: "DC2m", value: $settings.dc2m)
                        DcInput(label: "DC3m", value: $settings.dc3m)
                        DcInput(label: "DC4m", value: $settings.dc4m)
                        DcInput(label: "DC5m", value: $settings.dc5m)
                        DcInput(label: "DC203m", value: $settings.dc203m)
                    }
                } else {
                    Section("DC адреса") {
                        DcInput(label: "DC2", value: $settings.dc2)
                        DcInput(label: "DC4", value: $settings.dc4)
                    }
                }

                Section {
                    Toggle("Экспериментальный режим", isOn: $settings.isExperimentalMode)
                }
            }
            .navigationTitle("Настройка DC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct DcInput: View {
    let label: String
    @Binding var value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.blue)
                .frame(width: 60, alignment: .leading)
            TextField("IP адрес", text: $value)
                .keyboardType(.numbersAndPunctuation)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }
}
