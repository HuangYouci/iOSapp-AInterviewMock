//
//  ConfirmationDialog.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/22.
//

import SwiftUI

struct ConfirmationDialog: View {
    
    let title: String
    let message: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack{
            Color.clear
                .background(.ultraThinMaterial)
            VStack(alignment: .leading, spacing: 10){
                Text(title)
                    .font(.title3)
                    .bold()
                Text(message)
                HStack(spacing: 10){
                    Spacer()
                    Button {
                        onCancel()
                    } label: {
                        Text(NSLocalizedString("ConfirmationDialog_Cancel", comment: "Cancel"))
                            .padding(10)
                            .padding(.horizontal)
                            .foregroundStyle(Color(.systemGray))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button {
                        onConfirm()
                    } label: {
                        Text(NSLocalizedString("ConfirmationDialog_Confirm", comment: "Confirm"))
                            .padding(10)
                            .padding(.horizontal)
                            .foregroundStyle(Color(.white))
                            .background(Color(.accent))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.top)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        }
    }
}

#Preview {
    ZStack{
        ConfirmationDialog(title: "Are you sure?", message: "That cannot be undone!", onConfirm: {}, onCancel: {})
    }
}
