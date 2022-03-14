//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by robin tetley on 07/03/2022.
//

import SwiftUI
//this is the view that is the combination of the pallete and the palette icon
struct PaletteChooser: View {
    
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font {.system(size: emojiFontSize)}
    
    @EnvironmentObject var store: PaletteStore
    
    @State private var chosenPaletteIndex = 0
    
    
    var body: some View {
        HStack {
            paletteControlButton
            body(for: store.palette(at: chosenPaletteIndex))
        }
        .clipped()
    }
    
    var paletteControlButton: some View {
        Button {
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1) % store.palettes.count
            }
            
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu { contextMenu }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
//            isEditing = true
            paletteToEdit = store.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insertPalette(named: "New", emojis: "", at: chosenPaletteIndex)
            paletteToEdit = store.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            store.removePalette(at: chosenPaletteIndex)
        }
        goToMenu
        
    }
    
    var goToMenu: some View {
        Menu {
            ForEach (store.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.index(matching: palette) {
                        chosenPaletteIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            scrollingEmojisView(emojis: palette.emojis)
                .font(.system(size: emojiFontSize))
        }
        .id(palette.id)
        .transition(rollTransition)
//        .popover(isPresented: $isEditing) {
//            PaletteEditor(palette: $store.palettes[chosenPaletteIndex])
//        }
        .popover(item: $paletteToEdit) { palette in
            PaletteEditor(palette: $store.palettes[palette])
        }
    }
    
//    @State private var isEditing = false
    @State private var paletteToEdit: Palette?
    
    
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: emojiFontSize),
            removal: .offset(x: 0, y: -emojiFontSize)
        )
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
