//
//  IconGenerationService.swift
//  Icns creator
//
//  Created by perez987 on 16.12.2024.
//

import Cocoa
import Foundation

/// -------------------------------------------------------------------------------------------------
/// PART 1: GENERATE ICONSET
/// -------------------------------------------------------------------------------------------------
func runShellCommand(g: GlobalVariables) -> Bool {
    guard let imagePath = g.imagePath else {
        print("imagePath is nil.")
        return false
    }

    let escapedImagePath = imagePath // Use the original path directly
    // print("Image Path: \(escapedImagePath)")

    // Construct the icon path using URL
    let iconSetName = "\(g.selectedImageName).iconset"
    let escapedIconPath = URL(fileURLWithPath: g.destinationPath).appendingPathComponent(iconSetName).path
    let fileManager = FileManager.default

    // Check and create directory
    var isDirectory: ObjCBool = false
    if !fileManager.fileExists(atPath: escapedIconPath, isDirectory: &isDirectory) {
        print("The directory does not exist. Creating...")
        do {
            try fileManager.createDirectory(atPath: escapedIconPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error)")
            return false
        }
    } else if !isDirectory.boolValue {
        print("A file exists at the specified path, not a directory.")
        return false
    }

    let sizes: [Int] = [16, 32, 128, 256, 512]

    for size in sizes {
        processImage(pixelSize: size, pointSize: size, isRetina: false, escapedImagePath: escapedImagePath, escapedIconPath: escapedIconPath, g: g)
        processImage(pixelSize: size * 2, pointSize: size, isRetina: true, escapedImagePath: escapedImagePath, escapedIconPath: escapedIconPath, g: g)
    }

    let validation = validateGeneratedIconsetDimensions(iconsetPath: escapedIconPath)
    if !validation.isValid {
        g.outputText = validation.message
        print(validation.message)
        return false
    }

    return true
}

private func validateGeneratedIconsetDimensions(iconsetPath: String) -> (isValid: Bool, message: String) {
    let expectedFiles: [(name: String, width: Int, height: Int)] = [
        ("icon_16x16.png", 16, 16),
        ("icon_16x16@2x.png", 32, 32),
        ("icon_32x32.png", 32, 32),
        ("icon_32x32@2x.png", 64, 64),
        ("icon_128x128.png", 128, 128),
        ("icon_128x128@2x.png", 256, 256),
        ("icon_256x256.png", 256, 256),
        ("icon_256x256@2x.png", 512, 512),
        ("icon_512x512.png", 512, 512),
        ("icon_512x512@2x.png", 1024, 1024),
    ]

    for expected in expectedFiles {
        let fileURL = URL(fileURLWithPath: iconsetPath).appendingPathComponent(expected.name)
        guard let image = NSImage(contentsOf: fileURL),
              let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            return (false, "Iconset validation failed: missing or unreadable \(expected.name).")
        }

        if bitmapRep.pixelsWide != expected.width || bitmapRep.pixelsHigh != expected.height {
            return (
                false,
                "Iconset validation failed: \(expected.name) is \(bitmapRep.pixelsWide)x\(bitmapRep.pixelsHigh), expected \(expected.width)x\(expected.height)."
            )
        }
    }

    return (true, "Iconset validation passed.")
}

func processImage(pixelSize: Int, pointSize: Int, isRetina: Bool, escapedImagePath: String, escapedIconPath: String, g: GlobalVariables) {
    guard let iconsetImage = createRoundedImage(from: escapedImagePath, size: pixelSize, _isRoundCornersEnabled: true, _enableShadow: true, _enablePadding: true, g: g) else { return }

    guard let tiffData = iconsetImage.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else { return }

    let outputPath = "\(escapedIconPath)/icon_\(pointSize)x\(pointSize)\(isRetina ? "@2x" : "").png"

    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
    } catch {
        print("Error processing size \(pixelSize): \(error)")
    }
}

/// -------------------------------------------------------------------------------------------------
/// PART 2: RUN FOR SEPERATE .icns files
/// -------------------------------------------------------------------------------------------------
func runShellCommand2(res: Int, g: GlobalVariables) {
    let process = Process()
    // file path with extension
    // var escapedImagePath = g.imagePath!.replacingOccurrences(of: " ", with: "\\ ")
    var escapedImagePath: String = g.imagePath!
    var escapedImagePath2 = g.destinationPath + "/" + g.selectedImageName

    guard let roundedImage = createRoundedImage(from: escapedImagePath, size: res, _isRoundCornersEnabled: g.enableRoundedCorners, _enableShadow: g.enableIconShadow, _enablePadding: g.enablePadding, g: g) else { return }

    guard let tiffData = roundedImage.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else { return }

    let outputPath = "\(String(describing: escapedImagePath2))_\(String(res))x\(String(res)).png"

    escapedImagePath = outputPath.replacingOccurrences(of: " ", with: "\\ ")
    escapedImagePath2 = escapedImagePath2.replacingOccurrences(of: " ", with: "\\ ")

    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))

    } catch {
        print("Error processing size \(res): \(error)")
    }

    var command = ""

    if res == 32 || res == 64 || res == 256 || res == 512 || res == 1024 {
        command = "sips --setProperty dpiWidth 144 --setProperty dpiHeight 144 -s format icns -z \(Int(res)) \(Int(res)) \(String(describing: escapedImagePath)) --out \(escapedImagePath2)_\(String(res))x\(String(res)).icns"
    } else {
        command = "sips --setProperty dpiWidth 72 --setProperty dpiHeight 72 -s format icns -z \(Int(res)) \(Int(res)) \(String(describing: escapedImagePath)) --out \(escapedImagePath2)_\(String(res))x\(String(res)).icns"
    }
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", command]

    let outputPipe = Pipe()
    process.standardOutput = outputPipe

    process.launch()

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: outputData, encoding: .utf8) {
        g.outputText = output
    }

    process.waitUntilExit()

    // Second pass for setting preview image
    let command2 = "sips -i \(String(describing: escapedImagePath2))_\(String(res))x\(String(res)).icns \(String(describing: escapedImagePath2))_\(String(res))x\(String(res)).icns"

    let process2 = Process()
    process2.launchPath = "/bin/zsh"
    process2.arguments = ["-c", command2]

    let outputPipe2 = Pipe()
    process2.standardOutput = outputPipe2

    process2.launch()

    let outputData2 = outputPipe2.fileHandleForReading.readDataToEndOfFile()
    if let output2 = String(data: outputData2, encoding: .utf8) {
        g.outputText2 = output2
    }

    process2.waitUntilExit()

    // Delete the generated PNG file
    let fileManager = FileManager.default
    do {
        try fileManager.removeItem(atPath: outputPath)
        print("Successfully deleted PNG file at path: \(outputPath)")
    } catch {
        print("Error deleting PNG file: \(error)")
    }
}

/// GENERATE .ICONSET File
func generateCombinedIcns(g: GlobalVariables) {
    // --- Uses the DYNAMIC g.selectedImageName ---
    let iconSetName = "\(g.selectedImageName).iconset"
    // let escapedIconPath = URL(fileURLWithPath: g.destinationPath).appendingPathComponent(iconSetName).path
    let outputIcnsPath = URL(fileURLWithPath: g.destinationPath).appendingPathComponent("\(g.selectedImageName).icns").path

    // --- Uses the DYNAMIC g.destinationPath ---
    // Creates a URL from the string path provided by the user
    let destinationURL = URL(fileURLWithPath: g.destinationPath) // Use fileURLWithPath

    // --- Combines the dynamic destination and dynamic icon name ---
    let iconSetURL = destinationURL.appendingPathComponent(iconSetName)
    let iconSetPath = iconSetURL.path // Path string derived from dynamic values

    // --- Uses the derived path (from dynamic values) for directory creation ---
    print("Attempting to create/use iconSetPath:", iconSetPath)
    do {
        try FileManager.default.createDirectory(at: iconSetURL, withIntermediateDirectories: true, attributes: nil)
        print("Successfully created directory (or it already existed): \(iconSetPath)")

        // --- Uses the derived path (from dynamic values) for iconutil ---
        let iconutilProcess = Process()
        iconutilProcess.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
        // Passes the dynamically generated path to iconutil
        iconutilProcess.arguments = ["-c", "icns", iconSetPath, "-o", outputIcnsPath]

        let pipe = Pipe()
        iconutilProcess.standardOutput = pipe
        iconutilProcess.standardError = pipe

        do {
            try iconutilProcess.run()
            iconutilProcess.waitUntilExit()

            let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
            let outputString = String(data: outputData, encoding: .utf8) ?? ""
            print("iconutil output: \(outputString)")

            if iconutilProcess.terminationStatus == 0 {
                print("Successfully created \(g.selectedImageName).icns at \(outputIcnsPath)")
                // Optionally update g.outputText
            } else {
                let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorString = String(data: errorData, encoding: .utf8) ?? ""
                print("Error running iconutil. Termination status: \(iconutilProcess.terminationStatus), Error: \(errorString)")
                // Optionally update g.outputText with the error
            }

        } catch {
            print("Error running iconutil: \(error)")
            // Optionally update g.outputText
        }

    } catch {
        // Updates the DYNAMIC g.outputText on error
        print("Error creating iconset directory: \(error)")
    }
}
