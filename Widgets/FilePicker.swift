//
//  FilePicker.swift
//  Widgets
//
//  Created by Anna Liu on 8/12/23.
//

import Foundation
import SwiftUI

struct FilePicker: View {
    @Binding var filename : URL?
    @State var showFileChooser = false
    @State var fileSelected = false
    
    var body: some View {
        HStack {
            VStack {
                if fileSelected && filename != nil {
                    Image(nsImage: NSImage(contentsOf: filename!)!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150.0, height: 150.0)
                } else {
                    Text("Import a photo/gif").font(.headline)
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32.0, height: 32.0)
                }
            }.frame(width: 150, height: 150)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(.white, lineWidth: 2))
            .contentShape(Rectangle())
            .onTapGesture {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = true
                panel.directoryURL = URL.downloadsDirectory
                if panel.runModal() == .OK {
                    self.filename = panel.url ?? nil
                    
                    if filename != nil && filename!.absoluteString.contains("/Documents/") {
                        _ = alertMessage(question: "Your file cannot be from your Documents folder", text: "")
                        return 
                    }
                    
                    fileSelected = true
                }
            }
        }
    }
}
