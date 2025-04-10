import Foundation
import SwiftData

@Model
final class Inspiration {
    enum InspirationType: String, Codable {
        case text
        case image
        case link
    }
    
    var type: InspirationType
    var content: String
    var isFavorite: Bool
    
    init(type: InspirationType, content: String, isFavorite: Bool = false) {
        self.type = type
        self.content = content
        self.isFavorite = isFavorite
    }
}