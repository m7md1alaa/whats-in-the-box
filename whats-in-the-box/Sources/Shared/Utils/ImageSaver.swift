import SwiftUI

#if os(iOS)
import UIKit
#endif

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: PlatformImage) {
        #if os(iOS)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        #elseif os(macOS)
        // On macOS, save to the downloads folder.
        guard let data = image.tiffRepresentation else { return }
        let bitmap = NSBitmapImageRep(data: data)
        guard let jpegData = bitmap?.representation(using: .jpeg, properties: [:]) else { return }
        
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let fileURL = downloadsURL.appendingPathComponent("QRCode-\(UUID().uuidString).jpg")
        
        do {
            try jpegData.write(to: fileURL)
            print("Image saved to \(fileURL.path)")
        } catch {
            print("Error saving image: \(error)")
        }
        #endif
    }

    #if os(iOS)
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
    #endif
}
