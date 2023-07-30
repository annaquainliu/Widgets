//
//  Utilities.swift
//  Widgets
//
//  Created by Anna Liu on 7/27/23.
//

import Foundation
import SwiftUI

func TitleText(text : String) -> some View {
    return Text(text)
        .bold()
        .padding()
        .font(.system(size: 50, design: .rounded)
            .weight(.heavy))
}

func ImportPhoto() -> some View {
    return VStack {
        Text("Import a photo/gif").font(.headline)
        Image(systemName: "photo.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 32.0, height: 32.0)
    }.contentShape(Rectangle())
     .frame(width: 150, height: 150)
     .overlay(RoundedRectangle(cornerRadius: 16)
     .stroke(.white, lineWidth: 2))
}

func ImportMultiplePhotos() -> some View {
    return VStack {
        Text("Import multiple photos").font(.headline)
        Image(systemName: "photo.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 32.0, height: 32.0)
    }.contentShape(Rectangle())
     .frame(width: 150, height: 150)
     .overlay(RoundedRectangle(cornerRadius: 16)
     .stroke(.white, lineWidth: 2))
}

func TriggerCategoryText(text : String) -> some View {
    return Text(text)
                .font(.title2)
                .frame(width: 100, alignment: .leading)
                .padding(5)
}

func makeRadioOption(title : String, view : some View, selection : String) -> some View {
    return view.tag(title).disabled(selection != title)
}
