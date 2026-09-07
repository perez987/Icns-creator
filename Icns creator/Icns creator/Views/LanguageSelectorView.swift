//
//  LanguageSelectorView.swift
//  Mp3Player
//
//  Language selector view with flag emojis
//

import SwiftUI

struct LanguageItem: Identifiable {
    let id: String
    let code: String
    let name: String
    let flag: String

    init(code: String, name: String, flag: String) {
        self.id = code
        self.code = code
        self.name = name
        self.flag = flag
    }
}

struct LanguageSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedLanguage: String
    @State private var showRestartAlert = false
    private let initialLanguage: String
    private let softenedSelectionBlue = Color(red: 0.31, green: 0.53, blue: 0.94)

    // Available languages sorted by code
    private let languages: [LanguageItem] = [
        LanguageItem(code: "de", name: "Deutsch", flag: "🇩🇪"),
        LanguageItem(code: "en", name: "English", flag: "🇬🇧"),
        LanguageItem(code: "es", name: "Español", flag: "🇪🇸"),
        LanguageItem(code: "fr", name: "Français", flag: "🇫🇷"),
        LanguageItem(code: "it", name: "Italiano", flag: "🇮🇹")
    ]
    
    private var hasLanguageChanged: Bool {
        selectedLanguage != initialLanguage
    }

    init() {
        // Load current language preference
        let currentLang = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?
            .first?.components(separatedBy: "-").first
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
        _selectedLanguage = State(initialValue: currentLang)
        initialLanguage = currentLang
    }

    var body: some View {
        selectorCard
        .onExitCommand {
            if showRestartAlert {
                showRestartAlert = false
            } else {
                dismiss()
            }
        }
        .alert(
            NSLocalizedString("language_changed_title", comment: "Language changed alert title"),
            isPresented: $showRestartAlert
        ) {
//            Button(NSLocalizedString("cancel", comment: "Cancel button"), role: .cancel) {}
            Button(NSLocalizedString("ok", comment: "OK button")) {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text(NSLocalizedString("language_changed_message", comment: "Language changed message"))
        }
    }

    private func saveLanguagePreference() {
        UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    private func confirmSelection() {
        if hasLanguageChanged {
            saveLanguagePreference()
            showRestartAlert = true
        } else {
            dismiss()
        }
    }

    private func languageRowTextColor(for code: String) -> Color {
        if selectedLanguage == code {
            return .white
        }
        return colorScheme == .dark ? Color.black.opacity(0.85) : Color(nsColor: .labelColor)
    }
}

private extension LanguageSelectorView {
    var selectorCard: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(red: 0.88, green: 0.93, blue: 1.0),
                    Color(red: 0.97, green: 0.92, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 200, height: 200)
                .blur(radius: 48)
                .offset(x: -90, y: -130)

            Circle()
                .fill(Color.blue.opacity(0.16))
                .frame(width: 230, height: 230)
                .blur(radius: 60)
                .offset(x: 110, y: 120)

            VStack(spacing: 20) {
                
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.20))
                        .frame(width: 54, height: 54)
                    Image(systemName: "globe")
                        .font(.system(size: 32))
                        .foregroundStyle(.blue)
                }

                Text(NSLocalizedString("language_selector_title", comment: "Language selector title"))
                    .font(.title2.weight(.semibold))
                    .padding(.top)

                List(languages, selection: $selectedLanguage) { language in
                    HStack {
                        Text(language.flag)
                            .font(.title2)
                        Text(language.name)
                            .font(.body)
                    }
                    .foregroundStyle(languageRowTextColor(for: language.code))
                    .tag(language.code)
                    .padding(.vertical, 4)
                }
                .frame(width: 222, height: 208)
                .scrollContentBackground(.hidden)
                .listStyle(.inset)
                .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                )

                HStack(spacing: 12) {
                    Spacer()

                    Button(NSLocalizedString("cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    .buttonStyle(.borderedProminent)

                    Spacer()

                    Button(NSLocalizedString("accept", comment: "Accept button")) {
                        confirmSelection()
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .tint(softenedSelectionBlue)

                    Spacer()
                }
                .padding(.bottom)
            }
            .padding()
            .frame(width: 300)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 24, y: 10)
            .tint(softenedSelectionBlue)
        }
        .frame(width: 360)

    }
}

#Preview {
    LanguageSelectorView()
}
