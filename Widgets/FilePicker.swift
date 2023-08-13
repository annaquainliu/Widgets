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

  var body: some View {
      HStack {
          ImportPhoto()
          .onTapGesture {
              let panel = NSOpenPanel()
              panel.allowsMultipleSelection = false
              panel.canChooseDirectories = true
              panel.directoryURL = URL.downloadsDirectory
              if panel.runModal() == .OK {
                  self.filename = panel.url ?? nil
              }
          }
      }
  }
}
