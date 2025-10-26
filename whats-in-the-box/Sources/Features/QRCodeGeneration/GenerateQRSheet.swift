import SwiftUI

struct GenerateQRSheet: View {
    let box: StorageBox
    @State private var qrCodeImage: PlatformImage?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let qrCodeImage = qrCodeImage {
                    VStack(spacing: 16) {
                        Text("Scan this QR code to open the box details.")
                            .font(themeManager.selectedTheme.bodyTextFont)
                            .foregroundColor(themeManager.selectedTheme.bodyTextColor.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Image(platformImage: qrCodeImage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)


                        Text(box.name)
                            .font(themeManager.selectedTheme.textTitleFont)
                    }

                    HStack(spacing: 12) {
                        ShareLink(item: Image(platformImage: qrCodeImage), preview: SharePreview("QR Code for \(box.name)", image: Image(platformImage: qrCodeImage))) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button {
                            ImageSaver().writeToPhotoAlbum(image: qrCodeImage)
                            // Maybe show a confirmation
                        } label: {
                            Label("Save", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(.horizontal)

                } else {
                    ProgressView("Generating QR Code...")
                        .tint(themeManager.selectedTheme.primaryThemeColor)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(themeManager.selectedTheme.textBoxColor.ignoresSafeArea())
            .navigationTitle("Box QR Code")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
                }
            }
            .onAppear(perform: generateQRCode)
        }
        .environmentObject(themeManager)
    }

    private func generateQRCode() {
        do {
            let feature = GenerateBoxQRFeature()
            // Using a placeholder logo for now.
            // In a real app, you might have a specific app logo asset.
            #if os(macOS)
            let logo = PlatformImage(systemSymbolName: "shippingbox.fill", accessibilityDescription: nil) ?? PlatformImage()
            #else
            let logo = PlatformImage(systemName: "shippingbox.fill")?.withTintColor(.black) ?? PlatformImage()
            #endif
            qrCodeImage = try feature.executeWithLogo(for: box, logo: logo)
        } catch {
            print("Error generating QR code: \(error)")
            // Optionally show an error to the user
            dismiss()
        }
    }
}
