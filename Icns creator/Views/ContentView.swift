//
//  ContentView.swift
//  Icns creator
//
//  Created by alp tugan on 10.08.2023.
//  Modified by perez987 on 16/12/2025

import SwiftUI
import Foundation
import Cocoa
import Combine

// MAIN CONTENT VIEW TABS
struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var g: GlobalVariables // Access the global variables
    
    
    var body: some View {
        
        // NAVIGATION MENU
        // If image is selected then show the tabs
        if g.selectedImage != nil {
            if #available(macOS 14.0, *) {
                VStack() {
                    Picker("", selection: $selectedTab) {
                        Text(NSLocalizedString(".iconset", comment: "")).tag(0)
                        Text(NSLocalizedString(".icns", comment: "")).tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(height: 10)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .accentColor(.blue)
                    .onChange(of: selectedTab) { oldValue, newValue in
                        // window size
                        let newHeight: CGFloat = newValue == 0 ? 550 : 600
                        resizeWindow(g: g, to: CGSize(width: g.win.size.width, height: newHeight))
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        
                    }
                    .onAppear {
                        resizeWindow(g: g, to: CGSize(width: g.win.size.width, height: 550))
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        
                    }
                }
            }else{
                VStack() {
                    Picker("", selection: $selectedTab) {
                        Text(NSLocalizedString(".iconset", comment: "")).tag(0)
                        Text(NSLocalizedString(".icns", comment: "")).tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(height: 10)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .accentColor(.blue)
                    .onChange(of: selectedTab) { newValue in
                        // window size
                        let newHeight: CGFloat = newValue == 0 ? 550 : 600
                        resizeWindow(g: g, to: CGSize(width: g.win.size.width, height: newHeight))
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        
                    }
                    .onAppear {
                        resizeWindow(g: g, to: CGSize(width: g.win.size.width, height: 550))
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        
                    }
                }
            }
        }
        
        // Contents
        ZStack {
            CommonView()
                .onAppear{
                    g.win.size.width = 350
                    g.win.size.height = 250
                    g.dragAreaPos.x = 210
                    g.dragAreaPos.y = -250
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        }
        
        // Generate  Buttons
        VStack() {
            switch selectedTab {
            case 0:
                GenerateView_ICONSET()
            case 1:
                GenerateView_ICNS()
            default:
                EmptyView()
            }
        }
    }
}


// COMMON ELEMENTS
struct CommonView: View {
    @EnvironmentObject var g: GlobalVariables // Access the global variables
    @State private var showScrollBars: String = "When scrolling"
       @State private var clickAction: String = "Jump to the next page"
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .frame(width:280,height: 250) // The size of drop image area
                    .overlay(
                        Group {
                            GeometryReader { geometry in
                                // dash line around the drop location
                                RoundedRectangle(cornerRadius: 27.1)
                                    .stroke(g.dragOver ? Color.blue : Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 3, dash:[4]))
                                    .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.85)
                                    .background(g.dragOver ? Color.blue.opacity(0.1) : Color.white) // If nothing dragged onto section
                                    .cornerRadius(27.1)
                                    .position(x: geometry.frame(in: .local).midX, y:geometry.frame(in: .local).midY)
                                
                                VStack {
                                    //Spacer()
                                    // If the image is selected - Preview of the image
                                    if g.selectedImage != nil {
                                        GeometryReader { geo in
                                            let localFrame = geo.frame(in: .local)
                                            let ww = g.enablePadding ? g.imgW - 20 : g.imgW
                                            let hh = g.enablePadding ? g.imgH - 20 : g.imgH
                                            VStack {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: g.enableRoundedCorners ? 27.1 : 0)
                                                        .frame(width: ww , height: hh)
                                                        .shadow(radius: g.enableIconShadow ? 10 : 0)
                                                    
                                    Image(nsImage: g.selectedImage!)
                                        .resizable()
                                        .frame(width: ww , height: hh)
                                        .background(Color(g.selectedBackgroundColor))
                                        .cornerRadius(g.enableRoundedCorners ? 27.1 : 0)
                                                        
                                                }.position(x:localFrame.midX, y: localFrame.maxY)
                                                
                                            }
                                        }
                                    }
                                    
                                    // If no image is selected
                                    if g.selectedImage == nil {
                                        ZStack {
                                            GeometryReader { geo in
                                                let localFrame = geo.frame(in: .local)
                                                Image("Imgcolor")
                                                    .resizable()
                                                    .scaleEffect(g.dragOver ? 1.0 : 0.1)
                                                    .position(x:g.dragOver ? localFrame.midX : localFrame.midX, y: localFrame.maxY - 20)
                                                
                                                Image("Drag")
                                                    .resizable()
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .position(x: localFrame.midX + 10, y: g.dragOver ? localFrame.maxY  : localFrame.maxY - 15)
                                                    .opacity(g.dragOver ? 0 : 1)
                                            }
                                        }.frame(width: g.imgW, height: g.imgH)
                                    }
                                    
                                    // Display the text always
                                    GeometryReader { geo in
                                        let localFrame = geo.frame(in: .local)
                                        VStack {
                                            
                                            HStack {
                                                Text(NSLocalizedString("drag_image_text", comment: ""))
                                                    .foregroundColor(.gray)
                                                    .font(.subheadline)
                                                
                                                Text(NSLocalizedString("browse_button", comment: ""))
                                                    .foregroundColor(.blue)
                                                    .font(.headline).bold()
                                                    .padding(-6)
                                                    .onHover { isHover in
                                                        if isHover {
                                                            NSCursor.pointingHand.set()
                                                        }else{
                                                            NSCursor.arrow.set()
                                                        }
                                                    }
                                            }
                                        }.position(x:localFrame.midX, y: localFrame.maxY + 15)
                                        
                                        //-------------------------------------------------------------------------------
                                        // ICON OPTIONS
                                        //-------------------------------------------------------------------------------
                                        if g.selectedImage != nil {
                                            // Toggle for enabling ROUNDED corners
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text(NSLocalizedString("options_title", comment: ""))
                                                    .font(.callout)
                                                
                                                HStack {
                                                    Text(NSLocalizedString("enable_rounded_corners", comment: ""))
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                    
                                                    Toggle(isOn: $g.enableRoundedCorners) {
                                                        //Label("Flag", systemImage: "flag.fill")
                                                    }
                                                    .toggleStyle(SwitchToggleStyle())
                                                    .labelsHidden()
                                                    .scaleEffect(0.7)
                                                    .offset(x:5)
                                                }
                                                
                                                //.position(x: localFrame.midX, y: 0) // Position the toggle
                                                
                                                HStack {
                                                    Text(NSLocalizedString("enable_subtle_shadow", comment: ""))
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                    
                                                    Toggle(isOn: $g.enableIconShadow) {
                                                    }
                                                    .toggleStyle(SwitchToggleStyle())
                                                    .labelsHidden()
                                                    .fixedSize()
                                                    .scaleEffect(0.7)
                                                    .offset(x:5)
                                                }
                                                
                                                HStack {
                                                    Text(NSLocalizedString("enable_original_padding", comment: ""))
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                    
                                                    Toggle(isOn: $g.enablePadding) {
                                                    }
                                                    .toggleStyle(SwitchToggleStyle())
                                                    .labelsHidden()
                                                    .fixedSize()
                                                    .scaleEffect(0.7)
                                                    .offset(x:5)
                                                }
                                                
                                                HStack {
                                                    Text(NSLocalizedString("set_background_color", comment: ""))
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                        .offset(y:3)
                                                    Spacer()
                                                    
                                                    
                                                    // Custom color picker
                                                    ColorPicker("", selection: Binding(
                                                        get: { Color(g.selectedBackgroundColor) },
                                                        set: { newColor in
                                                            g.colorOption = "custom"
                                                            // Ensure you handle the optional binding for cgColor safely
                                                            if let cgColor = newColor.cgColor {
                                                                g.selectedBackgroundColor = NSColor(cgColor: cgColor) ?? NSColor.white
                                                            }
                                                        }
                                                    ))
                                                    .labelsHidden() // 1. Hides the empty label spacing
                                                    .frame(width: 15, height: 15) // 2. MUST be a square for a perfect circle
                                                    .clipShape(Circle()) // 3. Crops the view into a circle
                                                    .overlay(Circle().stroke(Color.blue.opacity(1), lineWidth: 1))
                                                    .offset(x:-10, y:3)
                                                    .help("Custom background color")
                                                    
                                                }
                                            }
                                            //--------------------------------------------------------------------------
                                            // Stroke Around Options
                                            //--------------------------------------------------------------------------
                                            .padding(.all, 12)
                                            //.frame(width: g.win.size.width - 70, height: 300)
                                            .background(Color.white.opacity(0.05))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .strokeBorder(Color.secondary.opacity(0.4), antialiased: false)
                                                //.stroke(Color.secondary.opacity(0.5), lineWidth: 1) // Stroke color and width
                                                    
                                            )
                                            .position(x: localFrame.midX, y: localFrame.maxY + 95) // Position the toggle
                                        }
                                    }

                                }
                            }
                        }
                    ) // Inside The content
                    .onDrop(of: ["public.file-url"], isTargeted: Binding<Bool>(get: { g.dragOver }, set: { g.dragOver = $0 }).animation()) { providers in

                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { data, error in

                            if let imageData = data, let path = NSString(data: imageData, encoding: String.Encoding.utf8.rawValue), // Use UTF-8 encoding
                               let url = URL(string: path as String) {

                                // Ensure updates to the model happen on the main thread
                                DispatchQueue.main.async {
                                    g.imagePath = url.path
                                    g.selectedImageName = url.deletingPathExtension().lastPathComponent
                                    if let image = NSImage(contentsOf: url) {
                                        g.selectedImage = image
                                    }
                                }
                            }
                        })
                        return true
                    } // Show dropped image
                    .onTapGesture {
                        selectFileFromSystem(g:g)
                    } // Show Browse window
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.top, g.selectedImage == nil ? 20 : 0)
        }.environmentObject(g.win)
    }
}


// ONLY CREATE ICONSET FOLDER
struct GenerateView_ICONSET: View {
    @EnvironmentObject var g: GlobalVariables // Access the global variables

    var body: some View {
        // After the image is displayed in the container, show the Convert <Button>
        if g.selectedImage != nil {
            VStack {
                Spacer(minLength: 220)
                HStack {
                    Button(NSLocalizedString("generate_iconset", comment: "")) {
                        let openPanel = createOpenPanel(defaultDirectory: URL(fileURLWithPath: NSHomeDirectory()))

                        // Show the panel and handle the user's selection
                        openPanel.begin { response in
                            if response == .OK, let selectedDirectory = openPanel.url {
                                g.destinationPath = selectedDirectory.path
                                
                                // Generate images
                                runShellCommand(g: g)
                                generateCombinedIcns(g: g)
                            }
                        }
                    }
                }
                Spacer() // Optional: Space below the button
            }
            .frame(maxHeight: .infinity) // Ensure VStack takes full height
        }
    }
}


struct GenerateView_ICNS: View {
    @EnvironmentObject var g: GlobalVariables // Access the global variables

    var allTogglesOff: Bool {
        return !g.isToggled_All && !g.isToggled_16 && !g.isToggled_32 && !g.isToggled_64 && !g.isToggled_128 && !g.isToggled_256 && !g.isToggled_512 && !g.isToggled_1024
    }
    var body: some View {
        VStack {
            Spacer(minLength: 220)
            if g.selectedImage != nil {
                Spacer()
                HStack {
                    if #available(macOS 14.0, *) {
                        Toggle(NSLocalizedString("all", comment: ""), isOn: $g.isToggled_All)
                            .onChange(of: g.isToggled_All) {
                                oldvalue, newValue in
                                //if newValue {
                                g.isToggled_16 = newValue
                                g.isToggled_32 = newValue
                                g.isToggled_64 = newValue
                                g.isToggled_128 = newValue
                                g.isToggled_256 = newValue
                                g.isToggled_512 = newValue
                                g.isToggled_1024 = newValue
                                //}
                            }
                    }else{
                        Toggle(NSLocalizedString("all", comment: ""), isOn: $g.isToggled_All)
                            .onChange(of: g.isToggled_All) {
                                newValue in
                                //if newValue {
                                g.isToggled_16 = newValue
                                g.isToggled_32 = newValue
                                g.isToggled_64 = newValue
                                g.isToggled_128 = newValue
                                g.isToggled_256 = newValue
                                g.isToggled_512 = newValue
                                g.isToggled_1024 = newValue
                                //}
                            }
                    }
                    Toggle(NSLocalizedString("size_16", comment: ""), isOn: $g.isToggled_16)
                    Toggle(NSLocalizedString("size_32", comment: ""), isOn: $g.isToggled_32)
                    Toggle(NSLocalizedString("size_64", comment: ""), isOn: $g.isToggled_64)
                } // Toggle buttons first row
                HStack {
                    Toggle(NSLocalizedString("size_128", comment: ""), isOn: $g.isToggled_128)
                    Toggle(NSLocalizedString("size_256", comment: ""), isOn: $g.isToggled_256)
                    Toggle(NSLocalizedString("size_512", comment: ""), isOn: $g.isToggled_512)
                    Toggle(NSLocalizedString("size_1024", comment: ""), isOn: $g.isToggled_1024)
                } // Toggle buttons second row
                Spacer(minLength: 5)

                HStack {
                    Button(NSLocalizedString("generate_icns", comment: "")) {
                        let openPanel = createOpenPanel(defaultDirectory: URL(fileURLWithPath: NSHomeDirectory()))
                        
                        // Show the panel and handle the user's selection
                        openPanel.begin { response in
                            if response == .OK, let selectedDirectory = openPanel.url {
                                g.destinationPath = selectedDirectory.path
                                
                                if(g.isToggled_16 == true) {
                                    runShellCommand2(res:16,g:g)
                                }
                                
                                if(g.isToggled_32 == true) {
                                    runShellCommand2(res:32, g:g)
                                }
                                
                                if(g.isToggled_64 == true) {
                                    runShellCommand2(res:64, g:g)
                                }
                                
                                if(g.isToggled_128 == true) {
                                    runShellCommand2(res:128, g:g)
                                }
                                
                                if(g.isToggled_256 == true) {
                                    runShellCommand2(res:256, g:g)
                                }
                                
                                if(g.isToggled_512 == true) {
                                    runShellCommand2(res:512, g:g)
                                }
                                
                                if(g.isToggled_1024 == true) {
                                    runShellCommand2(res:1024, g:g)
                                }
                            }
                        }
                        
                        
                    }
                    .disabled(allTogglesOff)
                } // Button
                Spacer() // Optional: Space below the button
            }
        }
        .frame(maxHeight: .infinity) // Ensure VStack takes full height

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
