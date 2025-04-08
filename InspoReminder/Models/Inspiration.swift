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
    
    init(type: InspirationType, content: String) {
        self.type = type
        self.content = content
    }
}