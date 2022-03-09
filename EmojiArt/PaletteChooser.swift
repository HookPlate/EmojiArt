//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by robin tetley on 07/03/2022.
//

import SwiftUI

struct PaletteChooser: View {
    
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font {.system(size: emojiFontSize)}
    
    @EnvironmentObject var store: PaletteStore
    
    
    var body: some View {
        let palette = store.palette(at: 2)
        HStack {
            Text(palette.name)
            scrollingEmojisView(emojis: palette.emojis)
                .font(.system(size: emojiFontSize))
        }
    }
}

struct scrollingEmojisView: View {
    let emojis : String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.withNoRepeatedCharacters.map { String($0)}, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }// .onDrag picks up what's been dragged and saves it as an NSItemProvider (and makes the little green plus)
            }
        }
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}
