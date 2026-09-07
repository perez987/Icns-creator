//
//  ContentView.swift
//  Icns creator
//
//  Created by alp tugan on 10.08.2023.
//  Modified by perez987 on 16/12/2025
//

import Cocoa
import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var g: GlobalVariables
    private let contentPadding: CGFloat = 14

    var body: some View {
        if #available(macOS 14.0, *) {
            content
                .onAppear {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        } else {
            content
                .onAppear {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        }
    }

    private var content: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(red: 0.88, green: 0.93, blue: 1.0),
                    Color(red: 0.97, green: 0.92, blue: 0.98),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 380, height: 380)
                .blur(radius: 80)
                .offset(x: -220, y: -240)

            Circle()
                .fill(Color.blue.opacity(0.18))
                .frame(width: 340, height: 340)
                .blur(radius: 110)
                .offset(x: 210, y: 220)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    HeaderCard(selectedTab: $selectedTab)
                    CommonView(selectedTab: selectedTab)

                    if g.selectedImage != nil {
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
                .padding(contentPadding)
            }
        }
    }
}

struct HeaderCard: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var g: GlobalVariables

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Icns Creator")
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                if g.selectedImageName.isEmpty {
                    Text(NSLocalizedString("app_subtitle", comment: ""))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(g.selectedImageName)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            Spacer(minLength: 12)

            if g.selectedImage != nil {
                Picker("", selection: $selectedTab) {
                    Text(NSLocalizedString(".iconset", comment: "")).tag(0)
                    Text(NSLocalizedString(".icns", comment: "")).tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 184)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 24, y: 10)
    }
}

struct CommonView: View {
    @EnvironmentObject var g: GlobalVariables
    let selectedTab: Int

    var body: some View {
        VStack(spacing: 16) {
            PreviewDropCard(selectedTab: selectedTab)

            if g.selectedImage != nil && selectedTab == 1 {
                IcnsOptionsCard()
            }
        }
    }
}

struct PreviewDropCard: View {
    @EnvironmentObject var g: GlobalVariables
    let selectedTab: Int

    private var hasImage: Bool {
        g.selectedImage != nil
    }

    private let previewCardMaxHeight: CGFloat = 320

    var body: some View {
        VStack(spacing: 12) {
            Button {
                selectFileFromSystem(g: g)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.regularMaterial)

                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .strokeBorder(
                            g.dragOver ? Color.blue.opacity(0.8) : Color.white.opacity(0.45),
                            style: StrokeStyle(lineWidth: g.dragOver ? 3 : 1.5, dash: hasImage ? [] : [10])
                        )

                    if hasImage, let image = g.selectedImage {
                        PreviewImageStage(selectedTab: selectedTab, image: image)
                            .padding(22)
                    } else {
                        PlaceholderStage()
                            .padding(22)
                    }
                }
                .frame(minHeight: hasImage ? 290 : 270, maxHeight: previewCardMaxHeight)
            }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: Binding(get: { g.dragOver }, set: { g.dragOver = $0 })) { providers in
                handleDrop(providers: providers)
            }
            .accessibilityLabel(Text(NSLocalizedString("browse_artwork_label", comment: "")))
            .accessibilityHint(Text(NSLocalizedString("drop_artwork_hint", comment: "")))
            .accessibilityValue(Text(NSLocalizedString(hasImage ? "selected_state" : "not_selected_state", comment: "")))

            HStack(spacing: 6) {
                Text(NSLocalizedString("drag_image_text", comment: ""))
                    .foregroundStyle(.primary)
                Button(NSLocalizedString("browse_button", comment: "")) {
                    selectFileFromSystem(g: g)
                }
                .buttonStyle(.plain)
                .underline()
                .foregroundStyle(.primary)
                .fontWeight(.semibold)
            }
            .font(.title3)

//            if hasImage {
//                Text(g.selectedImageName)
//                    .font(.body.weight(.medium))
//                    .foregroundStyle(.secondary)
//                    .lineLimit(1)
//                    .truncationMode(.middle)
//            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 24, y: 10)
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) else {
            return false
        }

        provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
            guard let imageData = data,
                  let url = URL(dataRepresentation: imageData, relativeTo: nil),
                  let image = NSImage(contentsOf: url)
            else {
                return
            }

            DispatchQueue.main.async {
                g.imagePath = url.path
                g.selectedImageName = url.deletingPathExtension().lastPathComponent
                g.selectedImage = image
            }
        }
        return true
    }
}

struct PlaceholderStage: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 88, height: 88)

                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 8) {
                Text(NSLocalizedString("drop_artwork_title", comment: ""))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(NSLocalizedString("drop_artwork_subtitle", comment: ""))
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
            }
        }
    }
}

struct PreviewImageStage: View {
    @EnvironmentObject var g: GlobalVariables
    let selectedTab: Int
    let image: NSImage

    private var cornerRadius: CGFloat {
        g.enableRoundedCorners && selectedTab == 1 ? 44 : 0
    }

    private var previewPadding: CGFloat {
        g.enablePadding && selectedTab == 1 ? 34 : 0
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.42))

            if selectedTab == 1 {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(g.selectedBackgroundColor))
                    .padding(previewPadding)
                    .shadow(color: Color.black.opacity(g.enableIconShadow ? 0.14 : 0), radius: g.enableIconShadow ? 24 : 0, y: 12)
            }

            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(previewPadding)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .shadow(color: Color.black.opacity(g.enableIconShadow && selectedTab == 1 ? 0.16 : 0), radius: g.enableIconShadow && selectedTab == 1 ? 18 : 0, y: 10)
                .padding(24)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }
}

struct IcnsOptionsCard: View {
    @EnvironmentObject var g: GlobalVariables

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(NSLocalizedString("options_title", comment: ""))
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            OptionToggleRow(title: NSLocalizedString("enable_rounded_corners", comment: ""), isOn: $g.enableRoundedCorners)
            OptionToggleRow(title: NSLocalizedString("enable_subtle_shadow", comment: ""), isOn: $g.enableIconShadow)
            OptionToggleRow(title: NSLocalizedString("enable_original_padding", comment: ""), isOn: $g.enablePadding)

//            HStack(spacing: 16) {
//                Text(NSLocalizedString("set_background_color", comment: ""))
//                    .font(.title3)
//                    .foregroundStyle(.secondary)
//                Spacer()
//                ColorPicker("", selection: Binding(
//                    get: { Color(g.selectedBackgroundColor) },
//                    set: { newColor in
//                        g.colorOption = "custom"
//                        g.selectedBackgroundColor = NSColor(newColor)
//                    }
//                ))
//                .labelsHidden()
//                .frame(width: 34, height: 34)
//            }
        }
        .padding(18)
        .foregroundStyle(.primary)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 24, y: 10)
    }
}

struct OptionToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.title3)
                .foregroundStyle(.primary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .scaleEffect(1.05)
        }
    }
}

struct GenerateView_ICONSET: View {
    @EnvironmentObject var g: GlobalVariables

    var body: some View {
        ActionCard {
            Button(NSLocalizedString("generate_iconset", comment: "")) {
                let openPanel = createOpenPanel(defaultDirectory: g.defaultSaveDirectory)
                openPanel.begin { response in
                    if response == .OK, let selectedDirectory = openPanel.url {
                        g.destinationPath = selectedDirectory.path
                        runShellCommand(g: g)
                        generateCombinedIcns(g: g)
                    }
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
    }
}

struct GenerateView_ICNS: View {
    @EnvironmentObject var g: GlobalVariables

    private let columns = [
        GridItem(.adaptive(minimum: 116), spacing: 10),
    ]

    private var allTogglesOff: Bool {
        !g.isToggled_16 && !g.isToggled_32 && !g.isToggled_64 && !g.isToggled_128 && !g.isToggled_256 && !g.isToggled_512 && !g.isToggled_1024
    }

    private var allSizesSelected: Bool {
        g.isToggled_16 && g.isToggled_32 && g.isToggled_64 && g.isToggled_128 && g.isToggled_256 && g.isToggled_512 && g.isToggled_1024
    }

    var body: some View {
        ActionCard {
            VStack(alignment: .leading, spacing: 18) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                    SizeSelectionChip(title: NSLocalizedString("all", comment: ""), isOn: Binding(
                        get: { allSizesSelected },
                        set: { setAllSizes($0) }
                    ))
                    SizeSelectionChip(title: NSLocalizedString("size_16", comment: ""), isOn: sizeBinding(\.isToggled_16))
                    SizeSelectionChip(title: NSLocalizedString("size_32", comment: ""), isOn: sizeBinding(\.isToggled_32))
                    SizeSelectionChip(title: NSLocalizedString("size_64", comment: ""), isOn: sizeBinding(\.isToggled_64))
                    SizeSelectionChip(title: NSLocalizedString("size_128", comment: ""), isOn: sizeBinding(\.isToggled_128))
                    SizeSelectionChip(title: NSLocalizedString("size_256", comment: ""), isOn: sizeBinding(\.isToggled_256))
                    SizeSelectionChip(title: NSLocalizedString("size_512", comment: ""), isOn: sizeBinding(\.isToggled_512))
                    SizeSelectionChip(title: NSLocalizedString("size_1024", comment: ""), isOn: sizeBinding(\.isToggled_1024))
                }

                Button(NSLocalizedString("generate_icns", comment: "")) {
                    let openPanel = createOpenPanel(defaultDirectory: g.defaultSaveDirectory)
                    openPanel.begin { response in
                        if response == .OK, let selectedDirectory = openPanel.url {
                            g.destinationPath = selectedDirectory.path
                            if g.isToggled_16 { runShellCommand2(res: 16, g: g) }
                            if g.isToggled_32 { runShellCommand2(res: 32, g: g) }
                            if g.isToggled_64 { runShellCommand2(res: 64, g: g) }
                            if g.isToggled_128 { runShellCommand2(res: 128, g: g) }
                            if g.isToggled_256 { runShellCommand2(res: 256, g: g) }
                            if g.isToggled_512 { runShellCommand2(res: 512, g: g) }
                            if g.isToggled_1024 { runShellCommand2(res: 1024, g: g) }
                        }
                    }
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .disabled(allTogglesOff)
            }
        }
    }

    private func sizeBinding(_ keyPath: ReferenceWritableKeyPath<GlobalVariables, Bool>) -> Binding<Bool> {
        Binding(
            get: { g[keyPath: keyPath] },
            set: { newValue in
                g[keyPath: keyPath] = newValue
            }
        )
    }

    private func setAllSizes(_ isSelected: Bool) {
        g.isToggled_16 = isSelected
        g.isToggled_32 = isSelected
        g.isToggled_64 = isSelected
        g.isToggled_128 = isSelected
        g.isToggled_256 = isSelected
        g.isToggled_512 = isSelected
        g.isToggled_1024 = isSelected
    }
}

struct ActionCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 14) {
            content
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 24, y: 10)
    }
}

struct SizeSelectionChip: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
        }
        .toggleStyle(ChipToggleStyle())
        .accessibilityValue(Text(NSLocalizedString(isOn ? "selected_state" : "not_selected_state", comment: "")))
    }
}

struct ChipToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(configuration.isOn ? Color.white : Color(nsColor: .labelColor))
                configuration.label
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(configuration.isOn ? Color.white : Color(nsColor: .labelColor))
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(configuration.isOn ? Color.blue : Color.white.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(configuration.isOn ? Color.blue.opacity(0.9) : Color.white.opacity(0.65), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityValue(Text(NSLocalizedString(configuration.isOn ? "selected_state" : "not_selected_state", comment: "")))
        .accessibilityAddTraits(configuration.isOn ? .isSelected : [])
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(buttonBackground(isPressed: configuration.isPressed))
            )
            .foregroundStyle(isEnabled ? .white : .white.opacity(0.75))
            .shadow(color: Color.blue.opacity(isEnabled ? (configuration.isPressed ? 0.12 : 0.22) : 0.08), radius: isEnabled ? (configuration.isPressed ? 8 : 16) : 8, y: isEnabled ? (configuration.isPressed ? 4 : 10) : 4)
            .opacity(isEnabled ? 1 : 0.7)
            .scaleEffect(isEnabled && configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }

    private func buttonBackground(isPressed: Bool) -> AnyShapeStyle {
        if isEnabled {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(isPressed ? 0.82 : 0.95),
                        Color.purple.opacity(isPressed ? 0.72 : 0.88),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        } else {
            return AnyShapeStyle(Color(nsColor: .quaternaryLabelColor))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GlobalVariables())
            .frame(width: kDefaultWindowWidth, height: kDefaultWindowHeight)
    }
}
