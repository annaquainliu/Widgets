//
//  ContentView.swift
//  Widgets
//
//  Created by Anna Liu on 7/26/23.
//

import SwiftUI

let textColor = Color(hue: 0.5, saturation: 1, brightness: 0.7)

func TitleText(text : String) -> some View {
    return Text(text)
        .bold()
        .padding(20)
        .font(.system(size: 60)
            .weight(.bold))
        .foregroundColor(.white)
}

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

    @Binding var tab : String
    
    var body : some View {
        VStack(alignment : .center) {
            HStack {
                Spacer()
                Button {
                   tab = "Library"
                } label: {
                    Text("My Library")
                }
                .padding([.top, .trailing])
            }
            TitleText(text: "MacWidgets")
            Text("Make your own widgets appear based on **triggers**!").padding([.bottom, .leading], 20)
                .foregroundColor(.white)
            ScrollView {
                    MenuButton(title: "Image/GIF", ImageName: "photo.fill", tab: $tab)
                    MenuButton(title: "Desktop", ImageName:"desktopcomputer", tab: $tab)
                    MenuButton(title: "Countdown", ImageName: "calendar.badge.clock", tab: $tab)
                    MenuButton(title : "Text", ImageName:
                                "textformat", tab: $tab)
                    MenuButton(title: "Calendar", ImageName: "calendar", tab: $tab)
            }
            .frame(minHeight: 200)
            .padding(10)
        }.padding([.top, .leading, .trailing], 10)
        .frame(minHeight: 500)
        .background(
            AngularGradient(gradient: Gradient(colors: [.green, .blue]), center: .bottomTrailing)
        )
    }
}

struct MenuButton : View {
    
    var title : String
    var ImageName : String
    @Binding var tab : String
    
    var body : some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .foregroundColor(textColor)
                    .fontWeight(.light)
                Spacer().frame(height: 20)
                Image(systemName: ImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60.0)
                // rgba(120, 176, 190, 0.95)
                    .foregroundColor(textColor)
            }.padding()

        }.frame(width: 600, height: 150, alignment:.leading)
         .background(.white)
         .cornerRadius(16)
         .padding([.top, .leading, .trailing], 20)
         .shadow(color: Color(nsColor: NSColor(deviceRed: 0.1, green: 0.2, blue: 0.2, alpha: 0.25)), radius: 10, x: 0, y: 5)
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
