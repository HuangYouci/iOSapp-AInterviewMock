//
//  InterviewFileView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/6.
//

import SwiftUI

struct InterviewFileView: View {
    
    @Binding var selected: InterviewProfile?
    @State private var selectionFiles: [String] = []
    @State private var focusState: Int = -1
    @State private var showDocPicker = false
    @State private var filesName: [String] = Array(repeating: "", count: 20)
    @State private var filesSize: [Double] = Array(repeating: 0, count: 20)

    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text("有檔案")
                Text("需要提供嗎？")
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
                                Text("\(String(format: "%.2f", filesSize[index])) MB")
                                    .foregroundStyle(Color(.systemGray))
                            }
                            if (filesSize[index] > 5){
                                HStack{
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                    Text("檔案過大！請重新選擇小於 4MB 的檔案。")
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
                                Text("新增新檔案")
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
                            Text("清除所有檔案")
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
                    .frame(height: 200)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            if let selected = selected {
                selectionFiles = selected.filesPath
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
                    
                    // Name
                    filesName[focusState] = url.lastPathComponent
                    
                    // Size
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
                    
                    // Size Check
                    if (sizeMB > 4){
                        selectionFiles[focusState] = ""
                    }
                    
                }
            }
        }
    }
    
}

#Preview{
    InterviewFileView(selected: .constant(DefaultInterviewType.college))
}
