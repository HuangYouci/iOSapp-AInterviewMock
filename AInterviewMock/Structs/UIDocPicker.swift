//
//  UIDocPicker.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/6.
//


import SwiftUI
import UniformTypeIdentifiers

struct UIDocPicker: UIViewControllerRepresentable {
    
    /// 檔案類型（預設為全部）
    var allowedTypes: [UTType] = [.data]
    
    /// 是否允許多選（預設為 false）
    var allowsMultipleSelection: Bool = false

    /// 選取完成的 callback
    var onPicked: ([URL]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = allowsMultipleSelection
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPicked: ([URL]) -> Void

        init(onPicked: @escaping ([URL]) -> Void) {
            self.onPicked = onPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onPicked(urls)
        }
    }
}
