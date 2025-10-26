import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - QR Code Service

/// Service for generating QR codes with customization options
final class QRCodeService {
    
    // MARK: - Singleton
    static let shared = QRCodeService()
    private init() {}
    
    // MARK: - Error Types
    enum QRError: LocalizedError {
        case invalidInput
        case generationFailed
        case imageFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidInput: return "Invalid QR code data"
            case .generationFailed: return "Failed to generate QR code"
            case .imageFailed: return "Failed to create image from QR code"
            }
        }
    }
    
    // MARK: - QR Code Generation
    
    /// Generates a QR code image from string data
    /// - Parameters:
    ///   - data: The string to encode in the QR code
    ///   - size: The size of the output image (default: 512x512)
    ///   - correctionLevel: Error correction level (L, M, Q, H)
    /// - Returns: PlatformImage of the QR code
    func generate(
        from data: String,
        size: CGFloat = 512,
        correctionLevel: CorrectionLevel = .medium
    ) throws -> PlatformImage {
        
        guard !data.isEmpty else {
            throw QRError.invalidInput
        }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        // Set input data
        guard let inputData = data.data(using: .utf8) else {
            throw QRError.invalidInput
        }
        
        filter.message = inputData
        filter.correctionLevel = correctionLevel.rawValue
        
        // Get output image
        guard let outputImage = filter.outputImage else {
            throw QRError.generationFailed
        }
        
        // Scale to desired size
        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Convert to PlatformImage
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            throw QRError.imageFailed
        }
        
        #if os(macOS)
        return PlatformImage(cgImage: cgImage, size: NSSize(width: size, height: size))
        #else
        return PlatformImage(cgImage: cgImage)
        #endif
    }
    
    /// Generates a colored QR code
    /// - Parameters:
    ///   - data: The string to encode
    ///   - size: Output size
    ///   - foregroundColor: QR code color
    ///   - backgroundColor: Background color
    /// - Returns: Colored PlatformImage of the QR code
    func generateColored(
        from data: String,
        size: CGFloat = 512,
        foregroundColor: PlatformColor = .black,
        backgroundColor: PlatformColor = .white,
        correctionLevel: CorrectionLevel = .medium
    ) throws -> PlatformImage {
        
        let qrImage = try generate(from: data, size: size, correctionLevel: correctionLevel)
        
        guard let ciImage = qrImage.ciImage else {
            throw QRError.imageFailed
        }
        
        // Apply color filter
        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = ciImage
        colorFilter.color0 = CIColor(color: foregroundColor) ?? .black
        colorFilter.color1 = CIColor(color: backgroundColor) ?? .white
        
        guard let outputImage = colorFilter.outputImage else {
            throw QRError.generationFailed
        }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            throw QRError.imageFailed
        }
        
        #if os(macOS)
        return PlatformImage(cgImage: cgImage, size: NSSize(width: size, height: size))
        #else
        return PlatformImage(cgImage: cgImage)
        #endif
    }
    
    /// Generates QR code with logo in center
    /// - Parameters:
    ///   - data: The string to encode
    ///   - size: Output size
    ///   - logo: Logo image to place in center
    ///   - logoSize: Size of the logo (as percentage of QR code, 0.0-0.3 recommended)
    /// - Returns: QR code with embedded logo
    func generateWithLogo(
        from data: String,
        size: CGFloat = 512,
        logo: PlatformImage,
        logoSize: CGFloat = 0.2,
        correctionLevel: CorrectionLevel = .high // Higher correction for logos
    ) throws -> PlatformImage {
        
        let qrImage = try generate(from: data, size: size, correctionLevel: correctionLevel)
        
        let logoSizePixels = size * logoSize
        let logoOrigin = CGPoint(x: (size - logoSizePixels) / 2, y: (size - logoSizePixels) / 2)
        
        #if os(macOS)
        let newImage = PlatformImage(size: NSSize(width: size, height: size), flipped: false) { (rect) -> Bool in
            qrImage.draw(in: rect)
            
            let logoBackgroundRect = CGRect(
                x: logoOrigin.x - 8,
                y: logoOrigin.y - 8,
                width: logoSizePixels + 16,
                height: logoSizePixels + 16
            )
            PlatformColor.white.setFill()
            let path = NSBezierPath(roundedRect: logoBackgroundRect, xRadius: 8, yRadius: 8)
            path.fill()
            
            logo.draw(in: CGRect(x: logoOrigin.x, y: logoOrigin.y, width: logoSizePixels, height: logoSizePixels))
            
            return true
        }
        return newImage
        #else
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // Draw QR code
        qrImage.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        
        // Draw white background for logo
        let logoBackgroundRect = CGRect(
            x: logoOrigin.x - 8,
            y: logoOrigin.y - 8,
            width: logoSizePixels + 16,
            height: logoSizePixels + 16
        )
        PlatformColor.white.setFill()
        UIBezierPath(roundedRect: logoBackgroundRect, cornerRadius: 8).fill()
        
        // Draw logo
        logo.draw(in: CGRect(x: logoOrigin.x, y: logoOrigin.y, width: logoSizePixels, height: logoSizePixels))
        
        guard let finalImage = UIGraphicsGetImageFromCurrentImageContext() else {
            throw QRError.imageFailed
        }
        
        return finalImage
        #endif
    }
}

// MARK: - Correction Level

extension QRCodeService {
    enum CorrectionLevel: String {
        case low = "L"      // ~7% error correction
        case medium = "M"   // ~15% error correction
        case quartile = "Q" // ~25% error correction
        case high = "H"     // ~30% error correction
    }
}

// MARK: - Convenience Extensions

extension QRCodeService {
    
    /// Generate QR code for a URL
    func generateForURL(_ url: URL, size: CGFloat = 512) throws -> PlatformImage {
        try generate(from: url.absoluteString, size: size)
    }
    
    /// Generate QR code for contact information (vCard format)
    func generateForContact(
        name: String,
        phone: String? = nil,
        email: String? = nil,
        size: CGFloat = 512
    ) throws -> PlatformImage {
        
        var vCard = "BEGIN:VCARD\nVERSION:3.0\nFN:\(name)\n"
        
        if let phone = phone {
            vCard += "TEL:\(phone)\n"
        }
        
        if let email = email {
            vCard += "EMAIL:\(email)\n"
        }
        
        vCard += "END:VCARD"
        
        return try generate(from: vCard, size: size)
    }
    
    /// Generate QR code for WiFi credentials
    func generateForWiFi(
        ssid: String,
        password: String,
        security: WiFiSecurity = .wpa
    ) throws -> PlatformImage {
        
        let wifiString = "WIFI:T:\(security.rawValue);S:\(ssid);P:\(password);;"
        return try generate(from: wifiString, size: 512, correctionLevel: .high)
    }
    
    enum WiFiSecurity: String {
        case wpa = "WPA"
        case wep = "WEP"
        case open = "nopass"
    }
}

fileprivate extension PlatformImage {
    var ciImage: CIImage? {
        #if os(macOS)
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return CIImage(bitmapImageRep: bitmap)
        #else
        return CIImage(image: self)
        #endif
    }
}
