//
//  PalleteStore.swift
//  EmojiArt
//
//  Created by robin tetley on 02/03/2022.
//

import SwiftUI
//the below is the Model
struct Palette: Identifiable, Codable, Hashable {
    var name: String
    var emojis: String
    var id: Int
    
    fileprivate init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}
//The below is your second ViewModel
class PaletteStore: ObservableObject {
    let name: String
    
    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    private var userDefaultsKey: String {
        "PaletteStore" + name
    }
    
    private func storeInUserDefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey), let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData) {
                palettes = decodedPalettes
        }
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        if palettes.isEmpty {
            print("Using built in palettes")
            insertPalette(named: "Vehicles", emojis: "🚢🚐🚙🚌🏎✈️🚝⛵️🛰🚢🚎🚉🚋🚟🚖🚍🚜🚛🚚🚑🚓")
            insertPalette(named: "Sports", emojis: "⚽️🏈🏓🥋🏋🏼‍♀️🏄🏼🤽🏼‍♂️🧗🏻🏊🏼🤸🏻🏸🎱")
            insertPalette(named: "Music", emojis: "🥁🪘🎷🎺🪗🎸🪕🎻")
            insertPalette(named: "Animals", emojis: "🐶🐹🐼🦁🐸🐵🐣🐺🦆🦄🐛🐌🪰🕷🐍🦕🦑🐳🦈🐅🦧🦬🦢🐿🦨🐓🐏🦒")
            insertPalette(named: "Flora", emojis: "🌴🌱🍃🍄🌷🌼🌹🥀🌺🌻")
            insertPalette(named: "Weather", emojis: "🌤🌦🌧⛈🌩❄️🌨💨☔️")
            insertPalette(named: "Covid", emojis: "😷🤧🤒🤮🥴🤢")
            insertPalette(named: "Faces", emojis: "😅🤣🥲😍😘🥸🥳😡😤😱😲😵")
        } else {
          print("Succesfully loaded palletes from UserDefaults: \(palettes)")
        }
    }
    
    // MARK: - Intent
    
    //gets a palette at a certain index
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    //Removes a palette at a certain index
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    //Inserts palette at certain index. Thanks to filePrivate this is the only way to make a Pallete
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: {$0.id < $1.id})?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
    
    
    
}
