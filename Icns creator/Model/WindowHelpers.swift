//
//  WindowHelpers.swift
//  Icns creator
//
//  Created by perez987 on 16.12.2024.
//

import Foundation
import Cocoa

// Global function to resize the window
func resizeWindow(g: GlobalVariables, to size: CGSize) {
    // Print the size for debugging
    // print("Resizing window to \(size)")
    
    // Use keyWindow to target the currently active window, or fall back to first window
     if let window = NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first {
         window.setContentSize(size)
        // Optionally, you can also center the window
        //window.center()
        
        window.disableCursorRects()
        window.styleMask.remove(.resizable)
        
    }
}
