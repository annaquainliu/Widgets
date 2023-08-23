//
//  FilePicker.swift
//  Widgets
//
//  Created by Anna Liu on 8/12/23.
//

import Foundation
import SwiftUI

struct FilePicker: View {
    @Binding var files : [URL]
    @State var importFiles : [ImportFile] = []
    
    var body: some View {
        List {
            ForEach(importFiles, id: \.self) { view in
               view
            }
            HStack {
                FileTools(image: "plus.rectangle.fill.on.rectangle.fill").onTapGesture {
                    if importFiles.count == files.count {
                        importFiles.insert(ImportFile(files: $files, index: files.count), at: importFiles.count)
                    }
                }
                FileTools(image: "minus.circle.fill").onTapGesture {
                    if importFiles.count > 0 {
                        if importFiles.count == files.count {
                            files.removeLast()
                        }
                        importFiles.removeLast()
                    }
                    print(files)
                }
            }
        }.frame(width: 190)
          .task {
              importFiles.insert(ImportFile(files: $files, index: files.count), at: importFiles.count)
         }
        .cornerRadius(15)
    }
}

struct FileTools : View {
    var image : String
    var body : some View {
        HStack {
            Image(systemName: image)
            .font(.system(size: 30))
            .multilineTextAlignment(.center)
        }.frame(width: 75, height: 100)
         .contentShape(Rectangle())
    }
}

struct ImportFile : View, Hashable {
    static func == (lhs: ImportFile, rhs: ImportFile) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileSelected)
        hasher.combine(filename)
    }
    
    @State var fileSelected = false
    @State var hover = false
    @State var filename : URL? = nil
    @Binding var files : [URL]
    var index : Int
    var id = UUID()
    
    var body : some View {
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
            panel.allowedContentTypes = [.gif, .png, .jpeg, .heic]
            if panel.runModal() == .OK {
                self.filename = panel.url ?? nil
                if filename != nil && filename!.absoluteString.contains("file:///Users/\(NSUserName())/Documents/") {
                    _ = alertMessage(question: "Your file cannot be from your Documents folder", text: "")
                    return
                }
                if fileSelected {
                    files[index] = filename!
                }
                else {
                    files.insert(filename!, at: files.count)
                    fileSelected = true
                }
            }
        }
    }
}

struct FilePicker_Previews : PreviewProvider {
    static var previews : some View {
        FilePickerView()
    }
}
struct FilePickerView : View {
    @State var url : [URL] = []
    
    var body: some View {
        FilePicker(files: $url)
    }
}
