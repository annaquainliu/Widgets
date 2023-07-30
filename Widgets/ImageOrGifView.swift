//
//  ImageOrGifView.swift
//  Widgets
//
//  Created by Anna Liu on 7/27/23.
//

import Foundation
import SwiftUI

struct ImageOrGifView : View {
    
    var body : some View {
        VStack(alignment: .leading) {
            TitleText(text : "Image/Gif")
            Spacer().frame(height: 30)
            HStack {
                ImportPhoto()
                Spacer(minLength: 40)
                WidgetMenu()
            }.padding()
        }.padding()
         .frame(width: 1000, height: 700)
    }
}

struct ImageOrGifView_Providers: PreviewProvider {
    static var previews: some View {
        ImageOrGifView()
    }
}
