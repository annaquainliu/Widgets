//
//  ImageOrGifView.swift
//  Widgets
//
//  Created by Anna Liu on 7/27/23.
//

import Foundation
import SwiftUI

struct ImageOrGifView : View {
    
    @EnvironmentObject var store : WidgetStore
    @State var fileName : [URL] = []
    @State var backButtonPressed = false
    @State var info = WidgetTypeInfo()
    
    var body : some View {
        if backButtonPressed {
            ContentView()
        } else {
            VStack(alignment: .leading) {
                WidgetTypeTab(backButtonPressed: $backButtonPressed, titleText: "Image/Gif")
                Spacer().frame(height: 30)
                HStack {
                    FilePicker(files: $fileName)
                    Spacer(minLength: 40)
                    WidgetMenu(type: WidgetInfo.types.image, info: $info, fileNames: $fileName)
                }.padding()
            }.padding()
             .frame(width: 1200, height: 700)
        }
    }
}

struct ImageOrGifView_Providers: PreviewProvider {
    static var previews: some View {
        ImageOrGifView()
    }
}
