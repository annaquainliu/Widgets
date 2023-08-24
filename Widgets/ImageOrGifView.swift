//
//  ImageOrGifView.swift
//  Widgets
//
//  Created by Anna Liu on 7/27/23.
//

import Foundation
import SwiftUI

func ImageOrGifView() -> SuperView {
    return SuperView(title: "Image or Gif", type: WidgetInfo.types.image)
}

func ScreenSaverView() -> SuperView {
    return SuperView(title: "Desktop Background", type: WidgetInfo.types.desktop)
}

struct SuperView: View {
    @EnvironmentObject var store : WidgetStore
    @State var fileName : [URL] = []
    @State var backButtonPressed = false
    @State var info = WidgetTypeInfo()
    var title : String
    var type : WidgetInfo.types
    
    var body : some View {
        if backButtonPressed {
            ContentView()
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    WidgetTypeTab(backButtonPressed: $backButtonPressed, titleText: title)
                    Spacer().frame(height: 30)
                    HStack {
                        FilePicker(files: $fileName)
                        Spacer(minLength: 40)
                        WidgetMenu(type: type, info: $info, fileNames: $fileName)
                    }.padding()
                }.padding()
                 .frame(width: 1200)
            }.frame(height: 700)
        }
    }
}

struct ImageOrGifView_Providers: PreviewProvider {
    static var previews: some View {
        ImageOrGifView()
    }
}
