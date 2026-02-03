import Cocoa

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var mainViewController: MainViewController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        mainViewController = MainViewController()

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 340),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Bootable Installer Creator"
        window.contentViewController = mainViewController
        window.center()
        window.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// MARK: - Main View Controller
class MainViewController: NSViewController {

    // UI Elements
    private var installerLabel: NSTextField!
    private var installerPathField: NSTextField!
    private var installerBrowseButton: NSButton!

    private var volumeLabel: NSTextField!
    private var volumePathField: NSTextField!
    private var volumeBrowseButton: NSButton!

    private var progressBar: NSProgressIndicator!
    private var statusLabel: NSTextField!
    private var createButton: NSButton!

    // State
    private var selectedInstaller: String?
    private var selectedVolume: String?
    private var isRunning = false
    private var process: Process?

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 340))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        let margin: CGFloat = 20
        let labelWidth: CGFloat = 100
        let buttonWidth: CGFloat = 80
        let rowHeight: CGFloat = 24
        let spacing: CGFloat = 16

        var y = view.bounds.height - margin - rowHeight

        // Title
        let titleLabel = NSTextField(labelWithString: "Create Bootable macOS Installer")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.frame = NSRect(x: margin, y: y, width: view.bounds.width - margin * 2, height: 24)
        view.addSubview(titleLabel)

        y -= rowHeight + spacing

        // Installer selection
        installerLabel = NSTextField(labelWithString: "Installer:")
        installerLabel.frame = NSRect(x: margin, y: y, width: labelWidth, height: rowHeight)
        view.addSubview(installerLabel)

        installerBrowseButton = NSButton(title: "Browse...", target: self, action: #selector(browseInstaller))
        installerBrowseButton.bezelStyle = .rounded
        installerBrowseButton.frame = NSRect(x: view.bounds.width - margin - buttonWidth, y: y - 2, width: buttonWidth, height: rowHeight + 4)
        view.addSubview(installerBrowseButton)

        installerPathField = NSTextField(string: "No installer selected")
        installerPathField.isEditable = false
        installerPathField.isSelectable = true
        installerPathField.textColor = .secondaryLabelColor
        installerPathField.frame = NSRect(x: margin + labelWidth + 8, y: y, width: view.bounds.width - margin * 2 - labelWidth - buttonWidth - 16, height: rowHeight)
        view.addSubview(installerPathField)

        y -= rowHeight + spacing

        // Volume selection
        volumeLabel = NSTextField(labelWithString: "Target Volume:")
        volumeLabel.frame = NSRect(x: margin, y: y, width: labelWidth, height: rowHeight)
        view.addSubview(volumeLabel)

        volumeBrowseButton = NSButton(title: "Browse...", target: self, action: #selector(browseVolume))
        volumeBrowseButton.bezelStyle = .rounded
        volumeBrowseButton.frame = NSRect(x: view.bounds.width - margin - buttonWidth, y: y - 2, width: buttonWidth, height: rowHeight + 4)
        view.addSubview(volumeBrowseButton)

        volumePathField = NSTextField(string: "No volume selected")
        volumePathField.isEditable = false
        volumePathField.isSelectable = true
        volumePathField.textColor = .secondaryLabelColor
        volumePathField.frame = NSRect(x: margin + labelWidth + 8, y: y, width: view.bounds.width - margin * 2 - labelWidth - buttonWidth - 16, height: rowHeight)
        view.addSubview(volumePathField)

        y -= rowHeight + spacing * 2

        // Warning box
        let warningBox = NSBox(frame: NSRect(x: margin, y: y - 50, width: view.bounds.width - margin * 2, height: 60))
        warningBox.title = ""
        warningBox.boxType = .custom
        warningBox.fillColor = NSColor.systemYellow.withAlphaComponent(0.15)
        warningBox.borderColor = NSColor.systemYellow.withAlphaComponent(0.5)
        warningBox.borderWidth = 1
        warningBox.cornerRadius = 8
        view.addSubview(warningBox)

        let warningLabel = NSTextField(wrappingLabelWithString: "Warning: The target volume will be completely ERASED. Make sure you have selected the correct USB drive and backed up any important data.")
        warningLabel.font = NSFont.systemFont(ofSize: 11)
        warningLabel.textColor = .labelColor
        warningLabel.frame = NSRect(x: 10, y: 8, width: warningBox.bounds.width - 20, height: 44)
        warningBox.addSubview(warningLabel)

        y -= 70 + spacing

        // Progress bar
        progressBar = NSProgressIndicator(frame: NSRect(x: margin, y: y, width: view.bounds.width - margin * 2, height: 20))
        progressBar.style = .bar
        progressBar.minValue = 0
        progressBar.maxValue = 100
        progressBar.doubleValue = 0
        progressBar.isIndeterminate = false
        view.addSubview(progressBar)

        y -= rowHeight + 8

        // Status label
        statusLabel = NSTextField(labelWithString: "Ready")
        statusLabel.font = NSFont.systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.frame = NSRect(x: margin, y: y, width: view.bounds.width - margin * 2, height: rowHeight)
        view.addSubview(statusLabel)

        y -= rowHeight + spacing

        // Create button
        createButton = NSButton(title: "Create Bootable Installer", target: self, action: #selector(createInstaller))
        createButton.bezelStyle = .rounded
        createButton.keyEquivalent = "\r"
        let buttonW: CGFloat = 180
        createButton.frame = NSRect(x: (view.bounds.width - buttonW) / 2, y: margin, width: buttonW, height: 32)
        view.addSubview(createButton)
    }

    @objc private func browseInstaller() {
        let panel = NSOpenPanel()
        panel.title = "Select macOS Installer"
        panel.message = "Choose a macOS installer application"
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.directoryURL = URL(fileURLWithPath: "/Applications")

        if panel.runModal() == .OK, let url = panel.url {
            let path = url.path
            let createInstallMediaPath = "\(path)/Contents/Resources/createinstallmedia"

            if FileManager.default.fileExists(atPath: createInstallMediaPath) {
                selectedInstaller = path
                installerPathField.stringValue = url.lastPathComponent
                installerPathField.textColor = .labelColor
            } else {
                showAlert(message: "Invalid Installer", info: "The selected application does not contain createinstallmedia. Please select a valid macOS installer.", style: .warning)
            }
        }
    }

    @objc private func browseVolume() {
        let panel = NSOpenPanel()
        panel.title = "Select Target Volume"
        panel.message = "Choose the USB volume to use (WILL BE ERASED!)"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.directoryURL = URL(fileURLWithPath: "/Volumes")

        if panel.runModal() == .OK, let url = panel.url {
            selectedVolume = url.path
            volumePathField.stringValue = url.lastPathComponent
            volumePathField.textColor = .labelColor
        }
    }

    @objc private func createInstaller() {
        guard let installer = selectedInstaller else {
            showAlert(message: "No Installer Selected", info: "Please select a macOS installer application.", style: .warning)
            return
        }

        guard let volume = selectedVolume else {
            showAlert(message: "No Volume Selected", info: "Please select a target USB volume.", style: .warning)
            return
        }

        let volumeName = URL(fileURLWithPath: volume).lastPathComponent
        let installerName = URL(fileURLWithPath: installer).lastPathComponent

        // Confirmation dialog
        let alert = NSAlert()
        alert.messageText = "Create Bootable Installer?"
        alert.informativeText = "All data on \"\(volumeName)\" will be ERASED to create a bootable installer from \"\(installerName)\".\n\nThis cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Create")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() != .alertFirstButtonReturn {
            return
        }

        // Get admin password
        guard let password = promptForPassword() else {
            return
        }

        startInstallerCreation(installer: installer, volume: volume, password: password)
    }

    private func promptForPassword() -> String? {
        let alert = NSAlert()
        alert.messageText = "Administrator Password Required"
        alert.informativeText = "Enter your administrator password to continue:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let passwordField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        alert.accessoryView = passwordField

        alert.window.initialFirstResponder = passwordField

        if alert.runModal() == .alertFirstButtonReturn {
            let password = passwordField.stringValue
            if !password.isEmpty {
                return password
            }
        }
        return nil
    }

    private func startInstallerCreation(installer: String, volume: String, password: String) {
        isRunning = true
        updateUIForRunningState(true)

        statusLabel.stringValue = "Starting..."
        progressBar.doubleValue = 0

        let createInstallMediaPath = "\(installer)/Contents/Resources/createinstallmedia"

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.runCreateInstallMedia(toolPath: createInstallMediaPath, volume: volume, password: password)
        }
    }

    private func runCreateInstallMedia(toolPath: String, volume: String, password: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = ["-S", toolPath, "--volume", volume, "--nointeraction"]

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        self.process = process

        // Handle output
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                self?.parseOutput(output)
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                self?.parseOutput(output)
            }
        }

        do {
            try process.run()

            // Send password
            let passwordData = (password + "\n").data(using: .utf8)!
            inputPipe.fileHandleForWriting.write(passwordData)
            inputPipe.fileHandleForWriting.closeFile()

            process.waitUntilExit()

            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil

            let success = process.terminationStatus == 0

            DispatchQueue.main.async { [weak self] in
                self?.finishCreation(success: success)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.finishCreation(success: false, error: error.localizedDescription)
            }
        }
    }

    private func parseOutput(_ output: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Parse progress percentages
            let lines = output.components(separatedBy: CharacterSet.newlines)
            for line in lines {
                if line.contains("Erasing disk") {
                    self.statusLabel.stringValue = "Erasing disk..."
                    if let progress = self.extractLastPercentage(from: line) {
                        self.progressBar.doubleValue = Double(progress) * 0.1 // 0-10%
                    }
                } else if line.contains("Copying essential files") {
                    self.statusLabel.stringValue = "Copying essential files..."
                    self.progressBar.doubleValue = 12
                } else if line.contains("Copying the macOS RecoveryOS") {
                    self.statusLabel.stringValue = "Copying macOS Recovery..."
                    self.progressBar.doubleValue = 15
                } else if line.contains("Making disk bootable") {
                    self.statusLabel.stringValue = "Making disk bootable..."
                    self.progressBar.doubleValue = 18
                } else if line.contains("Copying to disk") {
                    self.statusLabel.stringValue = "Copying installer files..."
                    if let progress = self.extractLastPercentage(from: line) {
                        self.progressBar.doubleValue = 20 + Double(progress) * 0.8 // 20-100%
                    }
                } else if line.contains("Install media now available") {
                    self.statusLabel.stringValue = "Complete!"
                    self.progressBar.doubleValue = 100
                }
            }
        }
    }

    private func extractLastPercentage(from text: String) -> Int? {
        let pattern = #"(\d+)%"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)

        if let lastMatch = matches.last,
           let percentRange = Range(lastMatch.range(at: 1), in: text) {
            return Int(text[percentRange])
        }
        return nil
    }

    private func finishCreation(success: Bool, error: String? = nil) {
        isRunning = false
        process = nil
        updateUIForRunningState(false)

        if success {
            progressBar.doubleValue = 100
            statusLabel.stringValue = "Bootable installer created successfully!"
            showAlert(message: "Success!", info: "The bootable installer has been created successfully.", style: .informational)
        } else {
            progressBar.doubleValue = 0
            statusLabel.stringValue = "Failed to create installer"
            let errorMsg = error ?? "An unknown error occurred. Make sure you selected a valid USB drive and entered the correct password."
            showAlert(message: "Failed", info: errorMsg, style: .critical)
        }
    }

    private func updateUIForRunningState(_ running: Bool) {
        createButton.isEnabled = !running
        installerBrowseButton.isEnabled = !running
        volumeBrowseButton.isEnabled = !running

        if running {
            createButton.title = "Creating..."
        } else {
            createButton.title = "Create Bootable Installer"
        }
    }

    private func showAlert(message: String, info: String, style: NSAlert.Style) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = info
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - Main Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
