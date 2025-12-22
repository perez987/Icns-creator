//
//  FileSystemHelpers.swift
//  Icns creator
//
//  Created by perez987 on 16.12.2024.
//

import Foundation
import Cocoa

extension NSOpenPanel {
    static func openImage(completion: @escaping (_ result: Result<NSImage, Error>, _ url: URL?) -> ()) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        if #available(macOS 12.0, *) {
            panel.allowedContentTypes = [.image]
        }else{
            panel.allowedFileTypes = ["jpg", "jpeg", "png", "gif", "psd"]
        }
        panel.begin { result in
            if result == .OK, let url = panel.urls.first, let image = NSImage(contentsOf: url) {
                completion(.success(image), url)
                //self.imagepa
            }else{
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("failed_to_get_location", comment: "")])), nil)
            }
        }
    }
}

func selectFileFromSystem(g: GlobalVariables) {
    let openPanel = NSOpenPanel()
    if #available(macOS 12.0, *) {
        openPanel.allowedContentTypes = [.image]
    }else{
        openPanel.allowedFileTypes = ["jpg", "jpeg", "png", "gif"]
    }
    openPanel.canChooseFiles = true
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false

    openPanel.begin { result in
        if result == .OK, let url = openPanel.url {
            if let image = NSImage(contentsOf: url) { // Load the image properly
                g.selectedImage = image
                g.imagePath = url.path
                g.selectedImageName = url.deletingPathExtension().lastPathComponent
            } else {
                print("Failed to load image.")
            }
        }
    }
}

// File location choose dialog
func createOpenPanel(defaultDirectory: URL? = nil) -> NSOpenPanel {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.title = NSLocalizedString("choose_destination_title", comment: "")
    openPanel.message = NSLocalizedString("choose_destination_message", comment: "")
    openPanel.prompt = NSLocalizedString("choose_button", comment: "")
    
    if let defaultDirectory = defaultDirectory {
        openPanel.directoryURL = defaultDirectory // Set default directory
    }
        
    return openPanel
}
