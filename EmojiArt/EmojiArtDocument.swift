//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by robin tetley on 30/12/2021.
// This is the ViewModel

import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            scheduleAutoSave()
           // autoSave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageIfNecessary()
            }
        }
    }
    
    private var autosaveTimer : Timer?
    
    private func scheduleAutoSave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
            self.autoSave()
        }
    }
    
    private struct Autosave {
        static let filename = "Autosave.emojiart"
        static var url: URL? {//clever way of tidying getting a url.
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval = 5.0
    }
    
    private func autoSave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()//the method that calls the encode on the model
            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        }catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) couldn't encode EmojArt as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisFunction) error = \(error)")
        }
    }
    
    init () {
        if let url = Autosave.url, let autoSavedEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autoSavedEmojiArt
            fetchBackgroundImageIfNecessary()
        } else {
            emojiArt = EmojiArtModel()
        }
//        emojiArt.addEmoji("🤨", at: (x: -300, y: -100), size: 40)
//        emojiArt.addEmoji("🤪", at: (x: 500, y: 100), size: 80)
    }
    
    var emojis: [EmojiArtModel.Emoji] {emojiArt.emojis}
    var background: EmojiArtModel.Background {emojiArt.background}
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageIfNecessary() {
            backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {//background thread since might take a while
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                    
                }
            }
            
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank :
            break
        }
    }
    
    //MARK: - Intents
    
    func setBackground(background: EmojiArtModel.Background) {
        emojiArt.background = background
        print("Set background to \(background)")
    }
    
    func addEmoji (_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji (_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji (_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
