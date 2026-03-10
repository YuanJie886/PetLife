import Foundation
import FirebaseFirestore

struct PetAlbum: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var coverImageUrl: String?
    var createdAt: Date
}

struct PetPhoto: Codable, Identifiable {
    @DocumentID var id: String?
    var albumId: String
    var title: String
    var imageUrl: String
    var createdAt: Date
}
