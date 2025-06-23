//
//  InterviewEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI

struct InterviewView: View {
    
    @EnvironmentObject var vm: ViewManager
    @StateObject private var it: InterviewTool = InterviewTool()
    @State private var aip: [InterviewProfile] = []
    @State private var running: Bool = false
    
    var body: some View {
        VStack(spacing: 0){
            
            HStack{
                Button{
                    vm.perviousPage()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(Color("AccentBackgroundP1"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Text("inif")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Spacer()
            }
            .foregroundStyle(Color(.white))
            .padding(.horizontal)
            .padding(.vertical, 5)
            .padding(.bottom, 5)
            .background(
                Image("HomeView_Img1")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 400)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .white]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            
            ScrollView{
                
                HStack{
                    Text("模擬面試")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color(.white))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 30)
                
                VStack(alignment: .leading, spacing: 15){
                    
                    Button {
                        running = true
                    } label: {
                        HStack{
                            Spacer()
                            Text("開始模擬面試")
                                .font(.title2)
                            Spacer()
                        }
                        .inifBlock(fgColor: Color(.white))
                    }
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text("費用")
                            .foregroundStyle(Color(.systemGray))
                        ScrollView(.horizontal){
                            HStack(spacing: 15){
                                VStack(spacing: 3){
                                    HStack{
                                        Text("10")
                                            .font(.title)
                                            .bold()
                                        Image(systemName: "hockey.puck.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                            .foregroundStyle(Color("AppGold"))
                                    }
                                    Text("基礎費用")
                                }
                                Divider()
                                VStack(spacing: 3){
                                    HStack{
                                        Text("5")
                                            .font(.title2)
                                            .bold()
                                        Image(systemName: "hockey.puck.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(Color("AppGold"))
                                    }
                                    Text("每個檔案")
                                        .font(.caption)
                                }
                                VStack(spacing: 3){
                                    HStack{
                                        Text("5")
                                            .font(.title2)
                                            .bold()
                                        Image(systemName: "hockey.puck.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(Color("AppGold"))
                                    }
                                    Text("每個問題")
                                        .font(.caption)
                                }
                            }
                        }
                        .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
                    }
                    
                    Text("紀錄")
                        .foregroundStyle(Color(.systemGray))
                    
                    ForEach(aip){ ip in
                        Text(ip.templateName)
                    }
                    
                }
                .padding(25)
                .frame(maxWidth: .infinity)
                .background(Color("Background"))
                .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .fixedSize(horizontal: false, vertical: true)
            
            Color("Background")
                .ignoresSafeArea(edges: [.bottom])
        }
        .background(Color("AccentBackground"))
        .navigationBarHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            aip = it.load(all: InterviewProfile.self)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .fullScreenCover(isPresented: $running) {
            InterviewView_Holder(ip: InterviewProfile(templateName: "notset", templateDescription: "", templateImage: "", templatePrompt: ""), running: $running)
        }
    }
}

struct InterviewView_Holder: View {
    
    @State var ip: InterviewProfile
    @Binding var running: Bool
    
    var body: some View {
        switch(ip.status){
        case .notStarted:
            InterviewView_Entry(running: $running, ip: $ip)
        case .prepared:
            Color.red
        case .inProgress:
            Color.green
        case .analyzing:
            Color.yellow
        case .completed:
            Color.purple
        }
    }
}

struct InterviewView_Entry: View {
    
    @Binding var running: Bool
    @Binding var ip: InterviewProfile
    @State private var session: Int = 0
    
    @State private var templates: [InterviewProfile] = []
    
    @State private var tempFilePath: [URL] = []
    @State private var tempFileName: [String] = []
    @State private var tempFileSize: [Double] = []
    @State private var showDocPicker: Bool = false
    private var totalFileSize: Double {
        var sum: Double = 0
        for s in tempFileSize {
            sum += s
        }
        return sum
    }
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Text("inif")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Text("模擬面試")
                    .font(.title)
                    .fontWeight(.heavy)
                Spacer()
            }
            .foregroundStyle(Color(.white))
            .padding(.horizontal)
            .padding(.vertical, 5)
            .padding(.bottom, 5)
            .background(
                Image("HomeView_Img1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400, alignment: .leading)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .white]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            
            ScrollView{
                
                VStack(alignment: .leading, spacing: 15){
                    
                    HStack{
                        Text("第 \(session+1) 步")
                        Spacer()
                    }
                    
                    switch(session) {
                    case 0:
                        Group {
                            VStack(alignment: .leading){
                                Text("模擬面試類型")
                                    .bold()
                                    .font(.title)
                                Text("選擇欲練習的模擬面試類型")
                            }
                            ForEach(templates){ t in
                                chooseTemplate(t)
                            }
                            HStack{
                                actionButton(title: "取消",
                                             requirements: { true },
                                             onTap: { running = false }
                                )
                                .frame(maxWidth: 100)
                                actionButton(title: "下一步",
                                             requirements: { ip.templateName != "notset" },
                                             onTap: { session = 1 }
                                )
                            }
                        }
                        .onAppear {
                            templates = [DefaultInterviewProfile.college,
                                         DefaultInterviewProfile.internship,
                                         DefaultInterviewProfile.jobGeneral]
                        }
                    case 1:
                        Group {
                            VStack(alignment: .leading){
                                Text("面試細節")
                                    .bold()
                                    .font(.title)
                                Text("填寫關於\(ip.templateName)的細節")
                            }
                            ForEach(ip.preQuestions.indices, id: \.self){ index in
                                VStack{
                                    HStack{
                                        Text(ip.preQuestions[index].question)
                                        if(ip.preQuestions[index].required){
                                            Text("*")
                                                .foregroundStyle(Color(.red))
                                        }
                                        Spacer()
                                    }
                                    TextField("答案", text: $ip.preQuestions[index].answer)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .background(Color("BackgroundR1"))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            HStack{
                                actionButton(title: "上一步",
                                             requirements: { true },
                                             onTap: { session = 0 }
                                )
                                .frame(maxWidth: 100)
                                actionButton(title: "下一步",
                                             requirements: {
                                                    ip.preQuestions
                                                        .filter { $0.required }
                                                        .allSatisfy { !$0.answer.isEmpty }
                                             },
                                             onTap: { session = 2 }
                                )
                            }
                        }
                    case 2:
                        Group {
                            VStack(alignment: .leading){
                                Text("面試檔案")
                                    .bold()
                                    .font(.title)
                                Text("提供關於\(ip.templateName)的檔案")
                            }
                            
                            VStack{
                                HStack{
                                    VStack(alignment: .leading){
                                        Text("檔案數")
                                        HStack{
                                            Text("\(tempFilePath.count)")
                                                .font(.title3)
                                                .bold()
                                        }
                                    }
                                    VStack(alignment: .leading){
                                        Text("檔案大小")
                                        HStack(spacing: 2){
                                            Text(String(format: "%.2f", totalFileSize))
                                            .font(.title3)
                                            .bold()
                                            Text("MB")
                                        }
                                    }
                                    Spacer()
                                    Button {
                                        showDocPicker = true
                                    } label: {
                                        Image(systemName: "plus")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(8)
                                            .background(Color("Background"))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                if(totalFileSize > 20){
                                    HStack{
                                        Text("檔案大小不得超過 20 MB")
                                            .foregroundStyle(Color(.red))
                                        Spacer()
                                    }
                                }
                                if(tempFilePath.count > 5){
                                    HStack{
                                        Text("檔案數量不得超過 5 件")
                                            .foregroundStyle(Color(.red))
                                        Spacer()
                                    }
                                }
                            }
                            .inifBlock(bgColor: Color("BackgroundR1"))
                            
                            ForEach(tempFilePath.indices, id: \.self){ index in
                                HStack{
                                    VStack(alignment: .leading){
                                        Text(tempFileName[index])
                                            .bold()
                                        Text(String(format: "%.2f MB", tempFileSize[index]))
                                    }
                                    Spacer()
                                    Button {
                                        tempFileSize.remove(at: index)
                                        tempFileName.remove(at: index)
                                        tempFilePath.remove(at: index)
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(8)
                                            .background(Color("Background"))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .inifBlock(bgColor: Color("BackgroundR1"))
                            }
                            
                            HStack{
                                actionButton(title: "上一步",
                                             requirements: { true },
                                             onTap: { session = 1 }
                                )
                                .frame(maxWidth: 100)
                                actionButton(title: "下一步",
                                             requirements: {
                                                totalFileSize <= 20 && tempFilePath.count <= 5
                                             },
                                             onTap: { session = 3 }
                                )
                            }
                            
                        }
                        .sheet(isPresented: $showDocPicker) {
                            UIDocPicker(allowedTypes: [.pdf]){ urls in
                                if let url = urls.first {
                                    tempFilePath.append(url)
                                    tempFileName.append(url.lastPathComponent)
                                    
                                    var fileSize: Int = 0
                                    do {
                                        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                                        fileSize = attrs[.size] as? Int ?? 100000
                                    } catch {
                                        fileSize = 100000
                                    }
                                    let sizeKB = Double(fileSize) / 1024.0
                                    let sizeMB = sizeKB / 1024.0
                                    tempFileSize.append(sizeMB)
                                }
                            }
                        }
                    case 3:
                        Group {
                            VStack(alignment: .leading){
                                Text("面試檔案確認")
                                    .bold()
                                    .font(.title)
                                Text("請確認所有關於\(ip.templateName)的資訊")
                                Text("完成後無法再修改")
                            }
                            
                            Text("檔案資訊")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                            VStack{
                                HStack{
                                    Text("檔案名稱")
                                    Spacer()
                                    Text(ip.templateName)
                                        .foregroundStyle(Color(.systemGray))
                                }
                            }
                            .inifBlock(bgColor: Color("BackgroundR1"))
                            
                            Text("檔案問題")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                            VStack(alignment: .leading){
                                ForEach(ip.preQuestions.indices, id: \.self){ index in
                                    Text(ip.preQuestions[index].question)
                                        .bold()
                                    
                                    let response = ip.preQuestions[index].answer
                                    if (response.isEmpty){
                                        Text("無回答")
                                            .foregroundStyle(Color(.systemGray))
                                    } else {
                                        Text(response)
                                    }
                                    
                                    if(index < ip.preQuestions.count-1){
                                        Divider()
                                            .padding(.vertical, 6.5)
                                    }
                                }
                            }
                            .inifBlock(bgColor: Color("BackgroundR1"))
                            
                            Text("檔案附件")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                            VStack(alignment: .leading){
                                if(tempFilePath.count == 0){
                                    Text("無附件")
                                        .foregroundStyle(Color(.systemGray))
                                }
                                ForEach(tempFilePath.indices, id: \.self){ index in
                                    Text(tempFileName[index])
                                        .bold()
                                    if(index < tempFilePath.count-1){
                                        Divider()
                                            .padding(.vertical, 6.5)
                                    }
                                }
                            }
                            .inifBlock(bgColor: Color("BackgroundR1"))
                            
                            HStack{
                                actionButton(title: "上一步",
                                             requirements: { true },
                                             onTap: { session = 2 }
                                )
                                .frame(maxWidth: 100)
                                actionButton(title: "完成",
                                             requirements: { true },
                                             onTap: { ip.status = .prepared }
                                )
                            }
                        }
                    default:
                        EmptyView()
                    }
                    
                    
                }
                .padding(25)
                .frame(maxWidth: .infinity)
                .background(Color("Background"))
                .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .background(
                VStack{
                    Color.clear
                        .frame(maxHeight: 100)
                    Color("Background")
                        .ignoresSafeArea(edges: [.bottom])
                }
            )
        }
        .background(Color("AccentBackground"))
    }
    
    @ViewBuilder
    private func chooseTemplate(_ t: InterviewProfile) -> some View {
        Button {
            ip = t
        } label: {
            VStack(alignment: .leading){
                Text(t.templateName)
                    .bold()
                Text(t.templateDescription)
            }
            .inifBlock(fgColor: ip.id == t.id ? Color(.white) : Color.accentColor, bgColor: ip.id == t.id ? Color("AccentBackground") : Color("BackgroundR1") )
        }
    }
    
    @ViewBuilder
    private func actionButton(title: String, requirements: @escaping () -> Bool, onTap: @escaping () -> Void) -> some View {
        let isDisabled = !(requirements())
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading){
                Text(title)
                    .bold()
            }
            .inifBlock(fgColor: isDisabled ? Color(.systemGray2) : Color(.white), bgColor: isDisabled ? Color("BackgroundR1") : Color("AccentBackground") )
        }
        .disabled(isDisabled)
        .animation(.easeInOut, value: isDisabled)
    }
    
}

#Preview {
    InterviewView()
        .environmentObject(ViewManager())
}
