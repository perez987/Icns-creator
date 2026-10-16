//
//  ImageProcessing.swift
//  Icns creator
//
//  Created by perez987 on 16.12.2024.
//

import Cocoa
import Foundation

private func renderImageAtExactPixelSize(size: Int, drawing: (NSRect) -> Void) -> NSImage? {
    guard size > 0 else { return nil }

    let targetRect = NSRect(x: 0, y: 0, width: size, height: size)
    guard let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        return nil
    }

    bitmapRep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: bitmapRep) else {
        NSGraphicsContext.restoreGraphicsState()
        return nil
    }

    NSGraphicsContext.current = context
    drawing(targetRect)
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()

    let finalImage = NSImage(size: targetRect.size)
    finalImage.addRepresentation(bitmapRep)
    return finalImage
}

private func aspectFitRect(for image: NSImage, in bounds: NSRect) -> NSRect {
    let sourceSize = image.size
    guard sourceSize.width > 0, sourceSize.height > 0, bounds.width > 0, bounds.height > 0 else {
        return bounds
    }

    let scale = min(bounds.width / sourceSize.width, bounds.height / sourceSize.height)
    let fittedSize = NSSize(width: sourceSize.width * scale, height: sourceSize.height * scale)

    return NSRect(
        x: bounds.midX - (fittedSize.width / 2),
        y: bounds.midY - (fittedSize.height / 2),
        width: fittedSize.width,
        height: fittedSize.height
    )
}

private func drawImageAspectFit(_ image: NSImage, in bounds: NSRect) {
    image.draw(in: aspectFitRect(for: image, in: bounds), from: .zero, operation: .sourceOver, fraction: 1.0)
}

func createIconsetImage(from path: String, size: Int) -> NSImage? {
    guard let image = NSImage(contentsOfFile: path), size > 0 else { return nil }

    return renderImageAtExactPixelSize(size: size) { targetRect in
        NSColor.clear.setFill()
        targetRect.fill()
        drawImageAspectFit(image, in: targetRect)
    }
}

/// -------------------------------------------------------------------------------------------------
/// CREATE ROUNDED CORNERS
/// -------------------------------------------------------------------------------------------------
func createRoundedImage(from path: String, size: Int, _isRoundCornersEnabled: Bool, _enableShadow: Bool, _enablePadding: Bool, g _: GlobalVariables) -> NSImage? {
    guard let image = NSImage(contentsOfFile: path) else { return nil }
    // let image = loadImage(named: path)

    // Ensure size is valid
    guard size > 0 else {
        print("Invalid size: \(size). Returning nil.")
        return nil
    }

    // Scale down sizes according to the specified rules
    var scaledSize: Int
    if _enablePadding {
        switch size {
        case 1024: scaledSize = 824
        case 512: scaledSize = 412
        case 256: scaledSize = 206
        case 128: scaledSize = 103
        case 64: scaledSize = 52
        case 32: scaledSize = 28
        case 16: scaledSize = 14
        default: scaledSize = size // Fallback to original size if not specified
        }
    } else {
        scaledSize = size
    }

    let targetRect = NSRect(x: 0, y: 0, width: size, height: size)

    // Calculate radius for rounded corners
    var radiusVal: Double = 0
    if _isRoundCornersEnabled {
        radiusVal = 0.225 * Double(scaledSize)
    }
    let bezierPath = NSBezierPath(roundedRect: targetRect, xRadius: radiusVal, yRadius: radiusVal)

    return renderImageAtExactPixelSize(size: size) { _ in
        NSColor.clear.setFill()
        targetRect.fill()

        // Clip to the larger rounded rectangle
        bezierPath.addClip()

        // Calculate the origin to center the scaled-down image
        let xOffset = (size - scaledSize) / 2
        let yOffset = (size - scaledSize) / 2
        let scaledRect = NSRect(x: xOffset, y: yOffset, width: scaledSize, height: scaledSize)

        if _enableShadow {
            let shadow = NSShadow()
            let shadowRadius = floor(Double(scaledSize) * 0.034)
            shadow.shadowOffset = NSSize(width: 0, height: -1)
            shadow.shadowBlurRadius = CGFloat(shadowRadius)
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
            shadow.set()
        }

        let scaledBezierPath = NSBezierPath(roundedRect: scaledRect, xRadius: radiusVal, yRadius: radiusVal)

        if _isRoundCornersEnabled {
            scaledBezierPath.addClip()
        }

        image.draw(in: scaledRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    }
}

func loadImage(named imageName: String) -> NSImage? {
    // Attempt to load the image from the app bundle
    if let image = NSImage(named: imageName) {
        return image
    }

    // Optionally, you can try loading from a specific path
    if let path = Bundle.main.path(forResource: imageName, ofType: "png") {
        guard let image = NSImage(contentsOfFile: path) else { return nil }
        return image
    }

    return nil // Return nil if the image could not be loaded
}

extension NSBitmapImageRep {
    func pngRepresentation() -> Data? {
        return representation(using: .png, properties: [:])
    }
}
