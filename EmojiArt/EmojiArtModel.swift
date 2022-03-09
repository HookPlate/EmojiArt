//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by robin tetley on 29/12/2021.
//  This is the Model

import Foundation
import CloudKit

struct EmojiArtModel: Codable {
    var background = Background.blank
    var emojis = [Emoji]()


    struct Emoji: Identifiable, Hashable, Codable {
        let text: String
        var x: Int //offset from the centre
        var y: Int  //offset from the centre
        var size: Int
        var id: Int
        
        fileprivate init (text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    //spits back out whatever it receives as JSON
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArtModel(json: data)
    }
    
    init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
}
