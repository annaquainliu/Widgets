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
    @State var hover = false
    
    var body: some View {
        HStack {
            VStack {
                if fileSelected && filename != nil {
                    Image(nsImage: NSImage(contentsOf: filename!)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("Import a photo/gif").font(.headline)
                    Image(systemName: "photo.fill")
                        .font(.system(size: hover ? 30 : 20))
                        .scaledToFit()
                        .frame(width: 32.0, height: 32.0)
                }
            }.frame(width: 150, height: 150)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white, lineWidth: fileSelected ? 0 : 2))
            .animation(.default, value: hover)
            .onHover { over in
                hover = over
            }
            .cornerRadius(16)
            .contentShape(Rectangle())
            .onTapGesture {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = true
                panel.directoryURL = URL.downloadsDirectory
                if panel.runModal() == .OK {
                    self.filename = panel.url ?? nil
                    if filename != nil && filename!.absoluteString.contains("file:///Users/\(NSUserName())/Documents/") {
                        _ = alertMessage(question: "Your file cannot be from your Documents folder", text: "")
                        return 
                    }
                    
                    fileSelected = true
                }
            }
        }
    }
}

//struct FilePicker_Previews : PreviewProvider {
//    static var previews : some View {
//        FilePickerView()
//    }
//}
struct FilePickerView : View {
    @State var url : URL? = nil
    
    var body: some View {
        FilePicker(filename: $url)
    }
}
