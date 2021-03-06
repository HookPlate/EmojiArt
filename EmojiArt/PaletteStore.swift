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
            insertPalette(named: "Vehicles", emojis: "π’ππππβοΈπβ΅οΈπ°π’πππππππππππ")
            insertPalette(named: "Sports", emojis: "β½οΈπππ₯ππΌββοΈππΌπ€½πΌββοΈπ§π»ππΌπ€Έπ»πΈπ±")
            insertPalette(named: "Music", emojis: "π₯πͺπ·πΊπͺπΈπͺπ»")
            insertPalette(named: "Animals", emojis: "πΆπΉπΌπ¦πΈπ΅π£πΊπ¦π¦πππͺ°π·ππ¦π¦π³π¦ππ¦§π¦¬π¦’πΏπ¦¨πππ¦")
            insertPalette(named: "Flora", emojis: "π΄π±πππ·πΌπΉπ₯πΊπ»")
            insertPalette(named: "Weather", emojis: "π€π¦π§βπ©βοΈπ¨π¨βοΈ")
            insertPalette(named: "Covid", emojis: "π·π€§π€π€?π₯΄π€’")
            insertPalette(named: "Faces", emojis: "ππ€£π₯²πππ₯Έπ₯³π‘π€π±π²π΅")
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
