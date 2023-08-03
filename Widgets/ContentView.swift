//
//  ContentView.swift
//  Widgets
//
//  Created by Anna Liu on 7/26/23.
//

import SwiftUI

struct ContentView: View {
    @State var tab: String = "Menu"
    var store : WidgetStore

    var body: some View {
        if tab == "Menu" {
            VStack(alignment : .center) {
                TitleText(text: "Widgets")
                Text("Make your own widgets appear based on **triggers**!").padding([.bottom, .leading], 20)
                Spacer().frame(maxHeight: 10)
                VStack {
                    HStack {
                        MenuButton(title: "Image/GIF", ImageName: "photo.fill", parent:self)
                        MenuButton(title: "Image Slideshow", ImageName:"photo.stack", parent:self)
                        MenuButton(title: "Weather", ImageName:"sun.min", parent:self)
                    }
                    HStack {
                        MenuButton(title : "Text", ImageName:
                                    "textformat", parent:self)
                        MenuButton(title: "Calendar", ImageName: "calendar", parent:self)
                    }
                }.padding(30)
            }.padding([.top, .bottom], 30)
        } else {
            let map = ["Image/GIF" : ImageOrGifView(store: store)]
            map[tab]
        }
    }
}

struct MenuButton : View {
    
    var title : String
    var ImageName : String
    var parent : ContentView
    
    var body : some View {
        VStack {
            Text(title).font(.headline)
            Image(systemName: ImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 32.0, height: 32.0)
        }.frame(width: 150, height: 150)
         .overlay(RoundedRectangle(cornerRadius: 16)
         .stroke(.white, lineWidth: 2))
         .contentShape(Rectangle())
          .onTapGesture {
             parent.tab = title
          }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: WidgetStore())
    }
}
