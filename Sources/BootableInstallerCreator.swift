import Cocoa

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var splashViewController: SplashViewController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        splashViewController = SplashViewController()

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Bootable Installer Creator"
        window.contentViewController = splashViewController
        window.center()
        window.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// MARK: - Splash View Controller
class SplashViewController: NSViewController {

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 400))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        let margin: CGFloat = 40
        let centerX = view.bounds.width / 2

        // App icon
        let iconSize: CGFloat = 80
        let iconView = NSImageView(frame: NSRect(x: centerX - iconSize/2, y: view.bounds.height - margin - iconSize, width: iconSize, height: iconSize))
        iconView.image = NSApp.applicationIconImage
        iconView.imageScaling = .scaleProportionallyUpOrDown
        view.addSubview(iconView)

        // Title
        let titleLabel = NSTextField(labelWithString: "Bootable Installer Creator")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 24)
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: margin, y: view.bounds.height - margin - iconSize - 50, width: view.bounds.width - margin * 2, height: 30)
        view.addSubview(titleLabel)

        // Subtitle
        let subtitleLabel = NSTextField(labelWithString: "Create bootable macOS installation drives")
        subtitleLabel.font = NSFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.alignment = .center
        subtitleLabel.frame = NSRect(x: margin, y: view.bounds.height - margin - iconSize - 80, width: view.bounds.width - margin * 2, height: 20)
        view.addSubview(subtitleLabel)

        // Option buttons container
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 100
        let buttonSpacing: CGFloat = 30
        let totalWidth = buttonWidth * 2 + buttonSpacing
        let startX = (view.bounds.width - totalWidth) / 2
        let buttonY: CGFloat = 80

        // Get macOS Installer button
        let getInstallerButton = createOptionButton(
            title: "Get macOS Installer",
            subtitle: "Download from Apple",
            icon: "arrow.down.circle.fill",
            frame: NSRect(x: startX, y: buttonY, width: buttonWidth, height: buttonHeight)
        )
        getInstallerButton.target = self
        getInstallerButton.action = #selector(getInstallerClicked)
        view.addSubview(getInstallerButton)

        // Create Bootable Volume button
        let createVolumeButton = createOptionButton(
            title: "Create Bootable Volume",
            subtitle: "Use existing installer",
            icon: "externaldrive.fill.badge.plus",
            frame: NSRect(x: startX + buttonWidth + buttonSpacing, y: buttonY, width: buttonWidth, height: buttonHeight)
        )
        createVolumeButton.target = self
        createVolumeButton.action = #selector(createVolumeClicked)
        view.addSubview(createVolumeButton)
    }

    private func createOptionButton(title: String, subtitle: String, icon: String, frame: NSRect) -> NSButton {
        let button = NSButton(frame: frame)
        button.bezelStyle = .rounded
        button.isBordered = true

        // Create a container view for the button content
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: frame.width, height: frame.height))

        // Icon
        let iconSize: CGFloat = 32
        let iconY = frame.height - 30
        if #available(macOS 11.0, *) {
            let config = NSImage.SymbolConfiguration(pointSize: iconSize, weight: .medium)
            if let symbolImage = NSImage(systemSymbolName: icon, accessibilityDescription: nil)?.withSymbolConfiguration(config) {
                let iconView = NSImageView(frame: NSRect(x: (frame.width - iconSize) / 2, y: iconY - iconSize, width: iconSize, height: iconSize))
                iconView.image = symbolImage
                iconView.contentTintColor = .controlAccentColor
                containerView.addSubview(iconView)
            }
        }

        // Title
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.boldSystemFont(ofSize: 13)
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 5, y: 28, width: frame.width - 10, height: 18)
        containerView.addSubview(titleLabel)

        // Subtitle
        let subtitleLabel = NSTextField(labelWithString: subtitle)
        subtitleLabel.font = NSFont.systemFont(ofSize: 11)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.alignment = .center
        subtitleLabel.frame = NSRect(x: 5, y: 10, width: frame.width - 10, height: 16)
        containerView.addSubview(subtitleLabel)

        button.addSubview(containerView)

        return button
    }

    @objc private func getInstallerClicked() {
        let getInstallerVC = GetInstallerViewController()
        getInstallerVC.onBack = { [weak self] in
            self?.view.window?.contentViewController = self
        }
        view.window?.contentViewController = getInstallerVC
    }

    @objc private func createVolumeClicked() {
        let mainVC = MainViewController()
        mainVC.onBack = { [weak self] in
            self?.view.window?.contentViewController = self
        }
        view.window?.contentViewController = mainVC
    }
}

// MARK: - Get Installer View Controller
class GetInstallerViewController: NSViewController {

    var onBack: (() -> Void)?

    private let installerOptions: [(name: String, version: String, url: String)] = [
        ("macOS Sequoia", "15", "macappstore://apps.apple.com/app/macos-sequoia/id6596773750"),
        ("macOS Sonoma", "14", "macappstore://apps.apple.com/app/macos-sonoma/id6450717509"),
        ("macOS Ventura", "13", "macappstore://apps.apple.com/app/macos-ventura/id1638787999"),
        ("macOS Monterey", "12", "macappstore://apps.apple.com/app/macos-monterey/id1576738294"),
        ("macOS Big Sur", "11", "macappstore://apps.apple.com/app/macos-big-sur/id1526878132")
    ]

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 400))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        let margin: CGFloat = 20

        // Back button
        let backButton = NSButton(title: "< Back", target: self, action: #selector(backClicked))
        backButton.bezelStyle = .rounded
        backButton.frame = NSRect(x: margin, y: view.bounds.height - margin - 24, width: 70, height: 24)
        view.addSubview(backButton)

        // Title
        let titleLabel = NSTextField(labelWithString: "Get macOS Installer")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 20)
        titleLabel.frame = NSRect(x: margin, y: view.bounds.height - margin - 70, width: view.bounds.width - margin * 2, height: 28)
        view.addSubview(titleLabel)

        // Subtitle
        let subtitleLabel = NSTextField(labelWithString: "Select a macOS version to download from the App Store:")
        subtitleLabel.font = NSFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.frame = NSRect(x: margin, y: view.bounds.height - margin - 95, width: view.bounds.width - margin * 2, height: 18)
        view.addSubview(subtitleLabel)

        // Installer list
        let listStartY = view.bounds.height - 140
        let rowHeight: CGFloat = 50

        for (index, installer) in installerOptions.enumerated() {
            let rowY = listStartY - CGFloat(index) * rowHeight

            let rowBox = NSBox(frame: NSRect(x: margin, y: rowY - rowHeight + 10, width: view.bounds.width - margin * 2, height: rowHeight - 5))
            rowBox.boxType = .custom
            rowBox.fillColor = NSColor.controlBackgroundColor
            rowBox.borderColor = NSColor.separatorColor
            rowBox.borderWidth = 1
            rowBox.cornerRadius = 8
            view.addSubview(rowBox)

            // Name label
            let nameLabel = NSTextField(labelWithString: installer.name)
            nameLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
            nameLabel.frame = NSRect(x: 15, y: 15, width: 200, height: 18)
            rowBox.addSubview(nameLabel)

            // Version label
            let versionLabel = NSTextField(labelWithString: "Version \(installer.version)")
            versionLabel.font = NSFont.systemFont(ofSize: 11)
            versionLabel.textColor = .secondaryLabelColor
            versionLabel.frame = NSRect(x: 15, y: 2, width: 100, height: 14)
            rowBox.addSubview(versionLabel)

            // Download button
            let downloadButton = NSButton(title: "Open in App Store", target: self, action: #selector(downloadClicked(_:)))
            downloadButton.bezelStyle = .rounded
            downloadButton.tag = index
            downloadButton.frame = NSRect(x: rowBox.bounds.width - 140, y: 10, width: 125, height: 26)
            rowBox.addSubview(downloadButton)
        }

        // Terminal option
        let terminalY = listStartY - CGFloat(installerOptions.count) * rowHeight - 30

        let terminalLabel = NSTextField(labelWithString: "Or download via Terminal:")
        terminalLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        terminalLabel.frame = NSRect(x: margin, y: terminalY, width: view.bounds.width - margin * 2, height: 16)
        view.addSubview(terminalLabel)

        let commandBox = NSBox(frame: NSRect(x: margin, y: terminalY - 35, width: view.bounds.width - margin * 2, height: 30))
        commandBox.boxType = .custom
        commandBox.fillColor = NSColor(white: 0.15, alpha: 1.0)
        commandBox.borderWidth = 0
        commandBox.cornerRadius = 6
        view.addSubview(commandBox)

        let commandLabel = NSTextField(labelWithString: "softwareupdate --fetch-full-installer")
        commandLabel.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        commandLabel.textColor = NSColor(white: 0.9, alpha: 1.0)
        commandLabel.frame = NSRect(x: 10, y: 6, width: commandBox.bounds.width - 80, height: 18)
        commandBox.addSubview(commandLabel)

        let copyButton = NSButton(title: "Copy", target: self, action: #selector(copyCommand))
        copyButton.bezelStyle = .rounded
        copyButton.frame = NSRect(x: commandBox.bounds.width - 60, y: 3, width: 50, height: 24)
        commandBox.addSubview(copyButton)
    }

    @objc private func backClicked() {
        onBack?()
    }

    @objc private func downloadClicked(_ sender: NSButton) {
        let installer = installerOptions[sender.tag]
        if let url = URL(string: installer.url) {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func copyCommand() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("softwareupdate --fetch-full-installer", forType: .string)

        // Show brief feedback
        let alert = NSAlert()
        alert.messageText = "Copied!"
        alert.informativeText = "Command copied to clipboard. Paste it in Terminal to download the latest macOS installer."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - Main View Controller (Create Bootable Volume)
class MainViewController: NSViewController {

    var onBack: (() -> Void)?

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
        view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 400))
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

        // Back button
        let backButton = NSButton(title: "< Back", target: self, action: #selector(backClicked))
        backButton.bezelStyle = .rounded
        backButton.frame = NSRect(x: margin, y: y, width: 70, height: 24)
        view.addSubview(backButton)

        y -= rowHeight + spacing

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

        // Create button
        createButton = NSButton(title: "Create Bootable Installer", target: self, action: #selector(createInstaller))
        createButton.bezelStyle = .rounded
        createButton.keyEquivalent = "\r"
        let buttonW: CGFloat = 180
        createButton.frame = NSRect(x: (view.bounds.width - buttonW) / 2, y: margin, width: buttonW, height: 32)
        view.addSubview(createButton)
    }

    @objc private func backClicked() {
        onBack?()
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
