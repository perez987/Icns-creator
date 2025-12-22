//
//  Icns_creatorApp.swift
//  Icns creator
//
//  Created by alp tugan on 10.08.2023.
//  Update: v2.2 on 07.09.2024
//  Update: v2.4 on 08.09.2024
//  Update: v3.4 on 09.09.2024 - scaleFactor warnings cleared, Thread optimization (waiting)
//  Update: v3.5 on 14.09.2024 - ask for destination path: destinationPath,selectedImageName
//  Update: v3.6.1 on 19.03.2025 - fix blank spaced input issue
//  Update: v3.6.2 on 11.04.2025 - generateCombinedIcns() replaced with safer version
//                               - Rounded corner preview fixed
//                               - runShellCommand2() updated. Image generation might be problematic
//  Copyright © 2024-2025. All rights reserved.
//  Update perez987: v3.8.0 on 16/12/2025 - quit app when closing window from red button
//  Update perez987: v3.8.1 on 19/12/2025 - fix Cmd+N new window state inheritance issue
//  Update perez987: v3.8.2 on 19/12/2025 - fix Cmd+N new windows opening as tabs instead of separate windows

import SwiftUI
import AppKit

// AppDelegate to handle window closing behavior
// This ensures the application quits when the user closes the window using the red close button
class AppDelegate: NSObject, NSApplicationDelegate {
    // Called when the application finishes launching
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Disable automatic window tabbing to ensure new windows open as separate windows
        // rather than tabs of existing windows
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    // Called when the last window is closed to determine if the app should terminate
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

class WindowSize: ObservableObject {
    @Published var size: CGSize = .zero
}

class GlobalVariables: ObservableObject {
    @Published var winSize: CGSize = .zero
    
    @Published var dragAreaPos : CGPoint = .zero
    @Published var isToggled_All = false
    @Published var isToggled_16 = false
    @Published var isToggled_32 = false
    @Published var isToggled_64 = false
    @Published var isToggled_128 = false
    @Published var isToggled_256 = false
    @Published var isToggled_512 = false
    @Published var isToggled_1024 = true
    @Published var imagePath: String?
    @Published var imgW: CGFloat = 150
    @Published var imgH: CGFloat = 150
    @Published var urlg:URL?
    
    @Published var outputText = ""
    @Published var outputText2 = ""
    
    @Published var dragOver : Bool = false
    @Published var selectedImage = NSImage(named: "image")
    @Published var win = WindowSize()
    
    // Options
    @Published var enableRoundedCorners: Bool = true // Toggle state
    @Published var enableIconShadow: Bool = true // Toggle state
    @Published var enablePadding: Bool = true // Toggle state
    
    // Color Selection
    @Published var selectedBackgroundColor: NSColor = NSColor(white: 1.0, alpha: 1.0) // Default: white, transparent
    @Published var colorOption: String = "custom" // "blue", "graphite", "purple", or "custom"
    
    
    // Destination Path
    @Published var destinationPath = ""
    @Published var selectedImageName = ""
    
    // Computed property to get the default directory for saving files
     var defaultSaveDirectory: URL {
         if let imagePath = imagePath {
             return URL(fileURLWithPath: imagePath).deletingLastPathComponent()
         } else {
             return URL(fileURLWithPath: NSHomeDirectory())
         }
     }
}


// Window dimension constants
private let kDefaultWindowWidth: CGFloat = 350
private let kDefaultWindowHeight: CGFloat = 320

// Wrapper view to ensure each window gets its own GlobalVariables instance
// This is crucial for Cmd+N (New Window) behavior - each new window should start
// with a fresh state (no image loaded) rather than inheriting the state from existing windows
struct RootView: View {
    @StateObject private var globalVariables = GlobalVariables()
    
    var body: some View {
        ContentView()
            .frame(minWidth: kDefaultWindowWidth, maxWidth: kDefaultWindowWidth, minHeight: kDefaultWindowHeight)
            .environmentObject(globalVariables)
            .onAppear {
                DispatchQueue.main.async {
                    resizeWindow(g: globalVariables, to: CGSize(width: kDefaultWindowWidth, height: kDefaultWindowHeight))
                }
            }
    }
}

@main
struct icns_creatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .defaultWindowSize(CGSize(width: kDefaultWindowWidth, height: kDefaultWindowHeight))
        //.defaultPosition(.center)
        //.windowResizabilityContentSize()
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

extension Scene {
    func defaultWindowSize(_ size: CGSize) -> some Scene {
        if #available(macOS 13.0, *) {
            return self.defaultSize(size)
        } else {
            return self
        }
    }
    
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}
