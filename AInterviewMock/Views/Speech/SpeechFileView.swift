//
//  SpeechFileView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/16.
//

import SwiftUI

struct SpeechFileView: View {
    
    @Binding var selected: SpeechProfile?
    @State private var selectionFiles: [String] = []
    @State private var focusState: Int = -1
    @State private var showDocPicker = false
    @State private var filesName: [String] = Array(repeating: "", count: 20)
    @State private var filesSize: [Double] = Array(repeating: 0, count: 20)

    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(NSLocalizedString("SpeechFileView_titleLine1", comment: "First line of the title on the file selection screen"))
                Text(NSLocalizedString("SpeechFileView_titleLine2", comment: "Second line of the title on the file selection screen"))
            }
            .font(.largeTitle)
            .bold()
            .padding(.horizontal)
            ScrollView{
                Color.clear
                    .frame(height: 5)
                VStack(alignment: .leading, spacing: 15){
                    ForEach(selectionFiles.indices, id: \.self){ index in
                        VStack(alignment: .leading){
                            HStack{
                                Text("\(index+1)")
                                    .bold()
                                    .foregroundStyle(Color(.accent))
                                    .frame(minWidth: 20)
                                Text(filesName[index])
                                    .lineLimit(1)
                                Spacer()
                                Text(String(format: NSLocalizedString("SpeechFileView_fileSizeFormatMB", comment: "Format string for file size in MB, e.g. '%.2f MB'. The %.2f will be replaced by the file size."), filesSize[index]))
                                    .foregroundStyle(Color(.systemGray))
                            }
                            if (filesSize[index] > 5){
                                HStack{
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                    Text(NSLocalizedString("SpeechFileView_fileTooLargeError", comment: "Error message when a selected file is too large."))
                                }
                                .foregroundStyle(Color(.red))
                            }
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    focusState == index
                                    ? Color.accentColor
                                    : Color(.systemGray3),
                                    lineWidth: 2
                                )
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusState = index
                            showDocPicker = true
                        }
                        .padding(.horizontal)
                    }
                    if (selectionFiles.count < 5){
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color(.accent))
                                Text(NSLocalizedString("SpeechFileView_addNewFileButton", comment: "Button text to add a new file"))
                                    .bold()
                                    .foregroundStyle(Color(.accent))
                                    .frame(minWidth: 20)
                                Spacer()
                            }
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    focusState == -1
                                    ? Color.accentColor
                                    : Color(.systemGray3),
                                    lineWidth: 2
                                )
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusState = -1
                            selectionFiles.append("")
                        }
                        .padding(.horizontal)
                    }
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "trash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text(NSLocalizedString("SpeechFileView_clearAllFilesButton", comment: "Button text to clear all selected files"))
                                .bold()
                                .frame(minWidth: 20)
                            Spacer()
                        }
                        .foregroundStyle(Color(.red))
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke( Color(.red),
                                lineWidth: 2
                            )
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectionFiles.removeAll()
                        filesName = Array(repeating: "", count: 20)
                        filesSize = Array(repeating: 0, count: 20)
                    }
                    .padding(.horizontal)
                }
                
                Color.clear
                    .frame(height: 300)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            if let selected = selected {
                selectionFiles = selected.filesPath
                
                for index in selectionFiles.indices {
                    if let url = URL(string: selectionFiles[index]) {
                        
                        filesName[index] = url.lastPathComponent
                        
                        var fileSize: Int = 0
                        do {
                            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                            fileSize = attrs[.size] as? Int ?? 0
                        } catch {
                            fileSize = 0
                            print("無法取得檔案大小：\(error)")
                        }
                        let sizeKB = Double(fileSize) / 1024.0
                        let sizeMB = sizeKB / 1024.0
                        filesSize[index] = sizeMB
                        
                        if (sizeMB > 4){
                            selectionFiles[index] = ""
                        }
                    }
                }
            }
        }
        .onChange(of: selectionFiles){ _ in
            if selected != nil {
                selected!.filesPath = selectionFiles
            }
        }
        .sheet(isPresented: $showDocPicker) {
            UIDocPicker(allowedTypes: [.pdf]) { urls in
                if let url = urls.first {
                    selectionFiles[focusState] = url.path
                    
                    filesName[focusState] = url.lastPathComponent
                    
                    var fileSize: Int = 0
                    do {
                        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                        fileSize = attrs[.size] as? Int ?? 0
                    } catch {
                        fileSize = 0
                        print("無法取得檔案大小：\(error)")
                    }
                    let sizeKB = Double(fileSize) / 1024.0
                    let sizeMB = sizeKB / 1024.0
                    filesSize[focusState] = sizeMB
                    
                    if (sizeMB > 4){
                        selectionFiles[focusState] = ""
                    }
                    
                }
            }
        }
    }
    
}

#Preview{
    SpeechFileView(selected: .constant(DefaultSpeechProfile.test))
}
