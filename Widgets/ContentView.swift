//
//  ContentView.swift
//  Widgets
//
//  Created by Anna Liu on 7/26/23.
//

import SwiftUI

struct ContentView: View {
    @State var tab: String = "Menu"
    
    var body: some View {
        switch tab {
            case "Menu":
                MainMenu(tab: $tab)
            case "Calendar":
                CalendarView()
            case "Desktop":
                ScreenSaverView()
            case "Countdown":
                CountdownView()
            case "Text":
                TextWidgetView()
            case "Library":
                LibraryView()
            default:
                ImageOrGifView()
        }
    }
}

struct MainMenu : View {

    @EnvironmentObject var store : WidgetStore
    @Binding var tab : String
    
    var body : some View {
        VStack(alignment : .center) {
            HStack {
                Spacer()
                Button {
                   tab = "Library"
                } label: {
                    Text("My Library")
                }.padding([.top, .trailing])
            }
            TitleText(text: "MacWidgets")
            Text("Make your own widgets appear based on **triggers**!").padding([.bottom, .leading], 20)
            Spacer().frame(maxHeight: 10)
            VStack {
                HStack {
                    MenuButton(title: "Image/GIF", ImageName: "photo.fill", tab: $tab)
                    MenuButton(title: "Desktop", ImageName:"desktopcomputer", tab: $tab)
                    MenuButton(title: "Countdown", ImageName: "calendar.badge.clock", tab: $tab)
                }
                HStack {
                    MenuButton(title : "Text", ImageName:
                                "textformat", tab: $tab)
                    MenuButton(title: "Calendar", ImageName: "calendar", tab: $tab)
                }
            }.padding(30)
        }.padding([.top, .bottom], 30)
    }
}

struct MenuButton : View {
    
    var title : String
    var ImageName : String
    @Binding var tab : String
    
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
         .contentShape(RoundedRectangle(cornerRadius: 16))
         .background()
         .cornerRadius(16)
         .onTapGesture {
            tab = title
         }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
