//
//  ImageProcessing.swift
//  Icns creator
//
//  Created by perez987 on 16.12.2024.
//

import Foundation
import Cocoa

//-------------------------------------------------------------------------------------------------
// CREATE ROUNDED CORNERS
//-------------------------------------------------------------------------------------------------
func createRoundedImage(from path: String, size: Int, _isRoundCornersEnabled: Bool, _enableShadow: Bool, _enablePadding: Bool, g: GlobalVariables) -> NSImage? {
    guard let image = NSImage(contentsOfFile: path) else { return nil }
   // let image = loadImage(named: path)

    // Ensure size is valid
    guard size > 0 else {
        print("Invalid size: \(size). Returning nil.")
        return nil
    }
    
    // Scale down sizes according to the specified rules
    var scaledSize: Int
    if (_enablePadding) {
        switch size {
        case 1024: scaledSize = 824
        case 512:  scaledSize = 412
        case 256:  scaledSize = 206
        case 128:  scaledSize = 103
        case 64:   scaledSize = 52
        case 32:   scaledSize = 28
        case 16:   scaledSize = 14
        default:   scaledSize = size // Fallback to original size if not specified
        }
    }else{
        scaledSize = size
    }
    
    // Create a new NSImage with the original size
    let finalImage = NSImage(size: NSSize(width: size, height: size))
    
    // Calculate radius for rounded corners
    var radiusVal:Double = 0
    if (_isRoundCornersEnabled) {
        radiusVal = 0.225 * Double(scaledSize)
    }
    let bezierPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size), xRadius: radiusVal, yRadius: radiusVal)

    finalImage.lockFocus()
    
    // Clip to the larger rounded rectangle
    bezierPath.addClip()

    // Calculate the origin to center the scaled-down image
    let xOffset = (size - scaledSize) / 2
    let yOffset = (size - scaledSize) / 2

    // Create a new NSImage for the scaled image
    let scaledImage = NSImage(size: NSSize(width: scaledSize, height: scaledSize))
    scaledImage.lockFocus()

    // Create a path for the scaled image with rounded corners
    let scaledBezierPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: scaledSize, height: scaledSize), xRadius: radiusVal, yRadius: radiusVal)
    
    
    // Clip to the rounded rectangle for the scaled image
    scaledBezierPath.addClip()
    
    // Fill with blue background (now respects the rounded clip)
    g.selectedBackgroundColor.setFill()
    scaledBezierPath.fill()
    
    // Draw the scaled image centered
    image.draw(in: NSRect(x: 0, y: 0, width: scaledSize, height: scaledSize), from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

    // Unlock the scaled image focus
    scaledImage.unlockFocus()

    // Prepare to draw the shadow for the scaled image
    if(_enableShadow) {
        let shadow = NSShadow()
        let shadowRadius = floor(Double(scaledSize) * 0.034)
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.shadowBlurRadius = CGFloat(shadowRadius)  // Set shadow blur radius
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)  // Set shadow color
        
        // Draw the shadow and the scaled image
        finalImage.lockFocus()
        shadow.set()
    }
    // Draw the scaled image in the final image
    scaledImage.draw(in: NSRect(x: xOffset, y: yOffset, width: scaledSize, height: scaledSize), from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

    finalImage.unlockFocus()

    return finalImage
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
        return self.representation(using: .png, properties: [:])
    }
}
