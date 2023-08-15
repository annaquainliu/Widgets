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
    @State var fileName : URL? = nil
    
    var body : some View {
        VStack(alignment: .leading) {
            TitleText(text : "Image/Gif")
            Spacer().frame(height: 30)
            HStack {
                FilePicker(filename: $fileName)
                Spacer(minLength: 40)
                WidgetMenu(type: WidgetInfo.types.calendar, fileName: $fileName)
            }.padding()
        }.padding()
         .frame(width: 1200, height: 700)
    }
}

struct ImageOrGifView_Providers: PreviewProvider {
    static var previews: some View {
        ImageOrGifView()
    }
}
