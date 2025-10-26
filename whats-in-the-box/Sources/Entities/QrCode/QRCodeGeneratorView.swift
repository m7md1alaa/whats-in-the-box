import SwiftUI

// MARK: - QR Code Generator View

struct QRCodeGeneratorView: View {
    @State private var inputText: String = ""
    @State private var generatedQRCode: PlatformImage?
    @State private var selectedStyle: QRStyle = .basic
    @State private var selectedColor: Color = .black
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Predefined templates
    @State private var showTemplates = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Input Section
                        inputSection
                        
                        // Style Selector
                        styleSelector
                        
                        // QR Code Display
                        qrCodeDisplay
                        
                        // Action Buttons
                        actionButtons
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("QR Generator")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: $showTemplates) {
                TemplatePickerView { template in
                    inputText = template
                    showTemplates = false
                    generateQRCode()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "qrcode")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Create Your QR Code")
                .font(.title2.bold())
            
            Text("Enter any text, URL, or select a template")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Content", systemImage: "text.bubble")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showTemplates = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("Templates")
                    }
                    .font(.caption.bold())
                    .foregroundColor(.blue)
                }
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                
                TextEditor(text: $inputText)
                    .padding(8)
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                
                if inputText.isEmpty {
                    Text("Enter text, URL, or contact info...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 120)
        }
    }
    
    // MARK: - Style Selector
    
    private var styleSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Style", systemImage: "paintbrush")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(QRStyle.allCases, id: \.self) { style in
                        StyleButton(
                            style: style,
                            isSelected: selectedStyle == style
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedStyle = style
                                if !inputText.isEmpty {
                                    generateQRCode()
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            if selectedStyle == .colored {
                ColorPicker("QR Color", selection: $selectedColor)
                    .onChange(of: selectedColor) { _, _ in
                        if !inputText.isEmpty {
                            generateQRCode()
                        }
                    }
            }
        }
    }
    
    // MARK: - QR Code Display
    
    private var qrCodeDisplay: some View {
        VStack(spacing: 16) {
            if let qrCode = generatedQRCode {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                    
                    VStack(spacing: 16) {
                        Image(platformImage: qrCode)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                            .padding()
                        
                        Text("Scan me!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 350)
                .transition(.scale.combined(with: .opacity))
            } else {
                // Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(.secondary.opacity(0.3))
                        
                        Text("Your QR code will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 350)
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                generateQRCode()
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Generate QR Code")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(inputText.isEmpty)
            .opacity(inputText.isEmpty ? 0.6 : 1)
            
            if let qrCode = generatedQRCode {
                HStack(spacing: 12) {
                    ShareLink(item: Image(platformImage: qrCode), preview: SharePreview("QR Code", image: Image(platformImage: qrCode))) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                    }
                    
                    Button {
                        ImageSaver().writeToPhotoAlbum(image: qrCode)
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Generate QR Code
    
    private func generateQRCode() {
        do {
            let service = QRCodeService.shared
            
            switch selectedStyle {
            case .basic:
                generatedQRCode = try service.generate(from: inputText)
                
            case .colored:
                generatedQRCode = try service.generateColored(
                    from: inputText,
                    foregroundColor: PlatformColor(selectedColor)
                )
                
            case .rounded:
                generatedQRCode = try service.generate(
                    from: inputText,
                    correctionLevel: .high
                )
            }
            
            withAnimation(.spring(response: 0.4)) {
                // Trigger UI update
            }
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - QR Style

enum QRStyle: String, CaseIterable {
    case basic = "Basic"
    case colored = "Colored"
    case rounded = "High Quality"
    
    var icon: String {
        switch self {
        case .basic: return "qrcode"
        case .colored: return "paintpalette"
        case .rounded: return "sparkles"
        }
    }
}

// MARK: - Style Button

struct StyleButton: View {
    let style: QRStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: style.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(style.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            .frame(width: 100, height: 90)
            .background(
                ZStack {
                    if isSelected {
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color.clear
                    }
                }
            )
            .background(.regularMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 8, y: 4)
        }
    }
}

// MARK: - Template Picker

struct TemplatePickerView: View {
    let onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    let templates = [
        ("Website", "https://example.com", "globe"),
        ("Phone", "tel:+966500000000", "phone"),
        ("Email", "mailto:info@example.com", "envelope"),
        ("SMS", "sms:+966500000000", "message"),
        ("WiFi", "WIFI:T:WPA;S:MyNetwork;P:password;;", "wifi"),
        ("Location", "geo:24.7136,46.6753", "location")
    ]
    
    var body: some View {
        NavigationView {
            List(templates, id: \.0) { template in
                Button {
                    onSelect(template.1)
                } label: {
                    HStack {
                        Image(systemName: template.2)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.0)
                                .font(.headline)
                            Text(template.1)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Templates")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    QRCodeGeneratorView()
}
