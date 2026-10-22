import Foundation

struct Exercise: Codable, Identifiable, Hashable {
    var id = UUID()
    let name: String
    let sets: String
    let reps: String
    let videoUrl: String?
    enum CodingKeys: String, CodingKey {
        case id, name, sets, reps
        case videoUrl = "video_url"
    }
    init(id: UUID = UUID(), name: String, sets: String, reps: String, videoUrl: String?) {
        self.id = id; self.name = name; self.sets = sets; self.reps = reps; self.videoUrl = videoUrl
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        sets = try c.decode(String.self, forKey: .sets)
        reps = try c.decode(String.self, forKey: .reps)
        videoUrl = try c.decodeIfPresent(String.self, forKey: .videoUrl)
    }
}
