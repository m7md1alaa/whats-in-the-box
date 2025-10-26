import SwiftUI

/// Feature: Generate a QR code for a storage box
struct GenerateBoxQRFeature {
    
    func execute(for box: StorageBox) throws -> PlatformImage {
        let deeplink = "whatsinthebox://box/\(box.id)"
        
        return try QRCodeService.shared.generateColored(
            from: deeplink,
            foregroundColor: .black,
            backgroundColor: .white
        )
    }
    
    func executeWithLogo(for box: StorageBox, logo: PlatformImage) throws -> PlatformImage {
        let deeplink = "whatsinthebox://box/\(box.id)"
        
        return try QRCodeService.shared.generateWithLogo(
            from: deeplink,
            logo: logo,
            logoSize: 0.2
        )
    }
}
