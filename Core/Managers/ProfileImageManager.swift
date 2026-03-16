import SwiftUI
import Combine

class ProfileImageManager: ObservableObject {
    @Published var profileImage: UIImage?
    
    private let fileName = "user_profile_image.jpg"
    
    init() {
        loadImage()
    }
    
    // MARK: - Save Image
    func saveImage(_ image: UIImage) {
        // Update published var immediately for UI snappiness
        self.profileImage = image
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            // Compress JPEG
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                print("Error: Could not compress image")
                return
            }
            
            let url = self.getDocumentsDirectory().appendingPathComponent(self.fileName)
            
            do {
                try data.write(to: url)
                print("Image saved successfully to \(url.path)")
            } catch {
                print("Error saving image: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Load Image
    func loadImage() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                if let loadedImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImage = loadedImage
                    }
                }
            } catch {
                print("Error loading image from disk: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Delete Image
    func deleteImage() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
                
                DispatchQueue.main.async {
                    self.profileImage = nil
                }
                print("Image deleted successfully")
            } catch {
                print("Error deleting image: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helpers
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
