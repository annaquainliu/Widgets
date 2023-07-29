//
//  ContentView.swift
//  Widgets
//
//  Created by Anna Liu on 7/26/23.
//

import SwiftUI

struct ContentViewb: View {
    @State var tab: String = "Menu"
    private var map = [
        "Image/GIF" : ImageOrGifView(),
    ]
    var body: some View {
        if tab == "Menu" {
            VStack(alignment : .leading) {
                Text("Widgets")
                    .bold()
                    .padding()
                    .font(.system(size: 50, design: .rounded)
                        .weight(.heavy))
                Spacer().frame(minHeight: 30)
                HStack {
                    MenuButton(title: "Image/GIF", ImageName: "photo.on.rectangle.angled", parent:self)
                    MenuButton(title: "Weather", ImageName:"sun.min", parent:self)
                }
                HStack {
                    MenuButton(title : "Text", ImageName:
                                "textformat", parent:self)
                    MenuButton(title: "Calendar", ImageName: "calendar", parent:self)
                }
            }.padding(50)
        } else {
            map[tab]
        }
    }
}

struct MenuButton : View {
    
    var title : String
    var ImageName : String
    var parent : ContentViewb
    
    var body : some View {
        VStack {
            Text(title).font(.headline)
            Image(systemName: ImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 32.0, height: 32.0)
        }.contentShape(Rectangle())
         .frame(width: 150, height: 150)
         .overlay(RoundedRectangle(cornerRadius: 16)
         .stroke(.white, lineWidth: 2))
         .onTapGesture {
             parent.tab = title
         }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewb()
    }
}
