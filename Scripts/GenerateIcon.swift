#!/usr/bin/env swift
import Cocoa

// Create icon with USB/installer design
func createIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))

    image.lockFocus()

    let bounds = NSRect(x: 0, y: 0, width: size, height: size)

    // Background gradient (blue)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.2, green: 0.5, blue: 0.95, alpha: 1.0),
        NSColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0)
    ])!

    let bgPath = NSBezierPath(roundedRect: bounds.insetBy(dx: size * 0.05, dy: size * 0.05),
                               xRadius: size * 0.18, yRadius: size * 0.18)
    gradient.draw(in: bgPath, angle: -90)

    // Draw USB drive shape
    NSColor.white.setFill()

    // Main body
    let bodyWidth = size * 0.5
    let bodyHeight = size * 0.55
    let bodyX = (size - bodyWidth) / 2
    let bodyY = size * 0.15

    let bodyRect = NSRect(x: bodyX, y: bodyY, width: bodyWidth, height: bodyHeight)
    let bodyPath = NSBezierPath(roundedRect: bodyRect, xRadius: size * 0.04, yRadius: size * 0.04)
    bodyPath.fill()

    // USB connector
    let connectorWidth = size * 0.3
    let connectorHeight = size * 0.15
    let connectorX = (size - connectorWidth) / 2
    let connectorY = bodyY + bodyHeight - size * 0.01

    let connectorRect = NSRect(x: connectorX, y: connectorY, width: connectorWidth, height: connectorHeight)
    let connectorPath = NSBezierPath(roundedRect: connectorRect, xRadius: size * 0.02, yRadius: size * 0.02)
    connectorPath.fill()

    // USB connector details (two rectangles inside)
    NSColor(red: 0.15, green: 0.35, blue: 0.85, alpha: 1.0).setFill()
    let detailWidth = size * 0.08
    let detailHeight = size * 0.06
    let detailY = connectorY + (connectorHeight - detailHeight) / 2

    let detail1 = NSRect(x: connectorX + size * 0.04, y: detailY, width: detailWidth, height: detailHeight)
    NSBezierPath(roundedRect: detail1, xRadius: size * 0.01, yRadius: size * 0.01).fill()

    let detail2 = NSRect(x: connectorX + connectorWidth - size * 0.04 - detailWidth, y: detailY, width: detailWidth, height: detailHeight)
    NSBezierPath(roundedRect: detail2, xRadius: size * 0.01, yRadius: size * 0.01).fill()

    // Draw a simple arrow pointing down (download/install symbol)
    NSColor(red: 0.15, green: 0.35, blue: 0.85, alpha: 1.0).setFill()

    let arrowPath = NSBezierPath()
    let centerX = size / 2
    let arrowTop = bodyY + bodyHeight * 0.75
    let arrowBottom = bodyY + bodyHeight * 0.25
    let arrowWidth = size * 0.15
    let arrowHeadWidth = size * 0.22
    let arrowHeadHeight = size * 0.12

    // Arrow shaft
    arrowPath.move(to: NSPoint(x: centerX - arrowWidth/2, y: arrowTop))
    arrowPath.line(to: NSPoint(x: centerX - arrowWidth/2, y: arrowBottom + arrowHeadHeight))
    arrowPath.line(to: NSPoint(x: centerX - arrowHeadWidth/2, y: arrowBottom + arrowHeadHeight))
    arrowPath.line(to: NSPoint(x: centerX, y: arrowBottom))
    arrowPath.line(to: NSPoint(x: centerX + arrowHeadWidth/2, y: arrowBottom + arrowHeadHeight))
    arrowPath.line(to: NSPoint(x: centerX + arrowWidth/2, y: arrowBottom + arrowHeadHeight))
    arrowPath.line(to: NSPoint(x: centerX + arrowWidth/2, y: arrowTop))
    arrowPath.close()
    arrowPath.fill()

    image.unlockFocus()

    return image
}

func saveIcon(_ image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        return
    }
    try? pngData.write(to: URL(fileURLWithPath: path))
}

// Get the script directory
let scriptPath = CommandLine.arguments[0]
let scriptURL = URL(fileURLWithPath: scriptPath).deletingLastPathComponent()
let projectRoot = scriptURL.deletingLastPathComponent()
let iconsetPath = projectRoot.appendingPathComponent("Resources/AppIcon.iconset").path

// Create iconset directory
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

// Generate all required sizes
let sizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (filename, size) in sizes {
    let icon = createIcon(size: size)
    saveIcon(icon, to: "\(iconsetPath)/\(filename)")
    print("Created \(filename)")
}

print("Icon set created at: \(iconsetPath)")
