//
//  InterviewEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI

struct InterviewView: View {
    
    @EnvironmentObject var vm: ViewManager
    @EnvironmentObject var it: InterviewTool
    @State private var aip: [InterviewProfile] = []
    
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
                    .frame(height: 400, alignment: .top)
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
                        vm.setTopView(InterviewView_Holder(ip: InterviewProfile(templateName: "notset", templateDescription: "", templatePrompt: "")))
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
                                    Text("每個附件")
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
                    
                    VStack(alignment: .leading){
                        ForEach(aip.indices, id: \.self){ index in
                            let i = aip[index]
                            Button{
                                vm.setTopView(InterviewView_Holder(ip: i))
                            } label: {
                                HStack{
                                    Text(i.name.isEmpty ? i.templateName : i.name)
                                }
                            }
                            if(index < aip.count-1){
                                Divider()
                                    .padding(.vertical, 6.5)
                            }
                        }
                    }
                    .inifBlock(fgColor: Color.accentColor, bgColor: Color("BackgroundR1"))
                    
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
            load()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: vm.rn){ _ in
            load()
        }
    }
    
    func load() {
        aip = it.load(all: InterviewProfile.self).sorted(by: { $0.date > $1.date })
    }
}

struct InterviewView_Holder: View {
    
    @EnvironmentObject var vm: ViewManager
    @State var ip: InterviewProfile
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                if ip.status == .completed {
                    Button{
                        vm.clearTopView()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(8)
                            .background(Color("AccentBackgroundP1"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
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
            
            switch(ip.status){
            case .notStarted:
                InterviewView_Entry(ip: $ip)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .prepared:
                InterviewView_Prepared(ip: $ip)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .generateQuestions:
                InterviewView_GenerateQuestions(ip: $ip)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .inProgress:
                InterviewView_Progress(ip: $ip)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .generateResults:
                InterviewView_GenerateResults(ip: $ip)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .completed:
                InterviewView_Completed(ip: $ip)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .background(
            VStack{
                Image("HomeView_Img1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 400)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .white]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea(edges: [.top])
                Spacer()
            }
        )
        .background(Color("AccentBackground"))
        .animation(.spring(duration: 0.3), value: ip.status)
    }
}

struct InterviewView_Entry: View {
    
    @EnvironmentObject var vm: ViewManager
    @EnvironmentObject var it: InterviewTool
    
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
                                         onTap: { vm.clearTopView() }
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
                            Text("提供關於\(ip.templateName)的附件")
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
                                         onTap: {
                                saveTempFile()
                                ip.status = .prepared
                            }
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
        .animation(.easeInOut(duration: 0.3), value: session)
        
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
            HStack{
                Spacer()
                Text(title)
                    .bold()
                Spacer()
            }
            .inifBlock(fgColor: isDisabled ? Color(.systemGray2) : Color(.white), bgColor: isDisabled ? Color("BackgroundR1") : Color("AccentBackground") )
        }
        .disabled(isDisabled)
        .animation(.easeInOut, value: isDisabled)
    }
    
    private func saveTempFile() {
        var files: [String] = []
        for f in tempFilePath {
            if let urlString = it.saveFile(from: f, for: ip.id){
                files.append(urlString)
            }
        }
        ip.filesPath = files
    }
    
}

struct InterviewView_Prepared: View {
    
    @EnvironmentObject var vm: ViewManager
    
    @Binding var ip: InterviewProfile
    @EnvironmentObject var it: InterviewTool
    @EnvironmentObject var ups: UserProfileService
    
    private var cost: Int {
        var cost = 10
        cost += ip.filesPath.count
        cost += ip.questionNumbers
        return cost
    }
    
    var body: some View {
        
        ScrollView{
            
            VStack(alignment: .leading, spacing: 15){
                
                Group {
                    VStack(alignment: .leading){
                        Text("模擬面試即將開始")
                            .bold()
                            .font(.title)
                        Text("請再調整面試檔案的細節")
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
                        Divider()
                            .padding(.vertical, 6.5)
                        HStack{
                            Text("檔案問題")
                            Spacer()
                            Text("\(ip.preQuestions.filter { $0.required && !$0.answer.isEmpty } .count) / \(ip.preQuestions.count) 題已回答")
                                .foregroundStyle(Color(.systemGray))
                        }
                        Divider()
                            .padding(.vertical, 6.5)
                        HStack{
                            Text("檔案附件")
                            Spacer()
                            Text("\(ip.filesPath.count) 件")
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
                    .inifBlock(bgColor: Color("BackgroundR1"))
                    
                    Text("檔案設定")
                        .foregroundStyle(Color(.systemGray))
                        .font(.caption)
                    
                    VStack{
                        HStack{
                            Text("問題數量")
                                .bold()
                            Spacer()
                        }
                        HStack(spacing: 3){
                            Text("\(ip.questionNumbers)")
                                .font(.title3)
                            Text("題")
                            Spacer()
                        }
                        .animation(.easeInOut, value: ip.questionNumbers)
                        HStack(spacing: 3){
                            Button {
                                ip.questionNumbers = 5
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("基礎")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                            Button {
                                ip.questionNumbers = 8
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("一般")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                            Button {
                                ip.questionNumbers = 10
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("完整")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                            Button {
                                ip.questionNumbers = 15
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("最多")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .inifBlock(bgColor: Color("BackgroundR1"))
                    
                    VStack{
                        HStack{
                            Text("正式程度")
                                .bold()
                            Spacer()
                        }
                        HStack(spacing: 3){
                            Text(String(format: "%.0f", ip.questionFormalStyle*100))
                                .font(.title3)
                            Text("%")
                            Spacer()
                        }
                        .animation(.easeInOut, value: ip.questionFormalStyle)
                        HStack(spacing: 3){
                            Button {
                                ip.questionFormalStyle = 0.2
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("輕鬆")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                            Button {
                                ip.questionFormalStyle = 0.5
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("一般")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                            Button {
                                ip.questionFormalStyle = 0.8
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("正式")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                            Button {
                                ip.questionFormalStyle = 1
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("嚴謹")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .inifBlock(bgColor: Color("BackgroundR1"))
                    
                    VStack{
                        HStack{
                            Text("嚴格程度")
                                .bold()
                            Spacer()
                        }
                        HStack(spacing: 3){
                            Text(String(format: "%.0f", ip.questionStrictStyle*100))
                                .font(.title3)
                            Text("%")
                            Spacer()
                        }
                        .animation(.easeInOut, value: ip.questionStrictStyle)
                        HStack(spacing: 3){
                            Button {
                                ip.questionStrictStyle = 0.2
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("簡單")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                            Button {
                                ip.questionStrictStyle = 0.5
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("一般")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                            Button {
                                ip.questionStrictStyle = 0.8
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("嚴格")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                            Button {
                                ip.questionStrictStyle = 1
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("嚴厲")
                                    Spacer()
                                }
                                .padding(5)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentBackground"))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .inifBlock(bgColor: Color("BackgroundR1"))
                    
                    Text("費用")
                        .foregroundStyle(Color(.systemGray))
                        .font(.caption)
                    
                    VStack{
                        HStack{
                            Text("啟動費用")
                                .bold()
                            Spacer()
                            Text("\(cost)")
                                .bold()
                            Image(systemName: "hockey.puck.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color("AppGold"))
                            
                        }
                        Divider()
                        HStack{
                            Text("基礎費用")
                            Spacer()
                            Text("10")
                            Image(systemName: "hockey.puck.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                        }
                        .foregroundStyle(Color(.systemGray))
                        HStack{
                            Text("附件")
                            Spacer()
                            Text("\(ip.filesPath.count)")
                            Image(systemName: "hockey.puck.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                        }
                        .foregroundStyle(Color(.systemGray))
                        HStack{
                            Text("問題")
                            Spacer()
                            Text("\(ip.questionNumbers)")
                            Image(systemName: "hockey.puck.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                        }
                        .foregroundStyle(Color(.systemGray))
                    }
                    .inifBlock(bgColor: Color("BackgroundR1"))
                    
                    HStack{
                        actionButton(title: "儲存並退出",
                                     requirements: { true },
                                     onTap: {
                            save()
                            vm.clearTopView()
                        }
                        )
                        .frame(maxWidth: 150)
                        actionButton(title: "開始",
                                     requirements: { true },
                                     onTap: {
                            save()
                            ups.coinRequest(type: .pay(item: "模擬面試"), amount: -cost, onConfirm: {
                                ip.status = .generateQuestions
                                let _ = it.save(ip)
                            }, onCancel: {
                                print("InterviewView | 取消開始面試")
                            })
                        }
                        )
                    }
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
    
    @ViewBuilder
    private func actionButton(title: String, requirements: @escaping () -> Bool, onTap: @escaping () -> Void) -> some View {
        let isDisabled = !(requirements())
        Button {
            onTap()
        } label: {
            HStack{
                Spacer()
                Text(title)
                    .bold()
                Spacer()
            }
            .inifBlock(fgColor: isDisabled ? Color(.systemGray2) : Color(.white), bgColor: isDisabled ? Color("BackgroundR1") : Color("AccentBackground") )
        }
        .disabled(isDisabled)
        .animation(.easeInOut, value: isDisabled)
    }
    
    private func save() {
        Task {
            let _ = it.save(ip)
        }
    }

}

struct InterviewView_GenerateQuestions: View {
    
    @Binding var ip: InterviewProfile
    @EnvironmentObject var it: InterviewTool
    @EnvironmentObject var ups: UserProfileService
    
    @State private var loadingProcess: String = "生成題目中"
    
    var body: some View {
        
        VStack(spacing: 15){
            
            Spacer()
            
            LoadViewElement(circleLineWidth: 7)
                .frame(width: 50, height: 50)
            Text(loadingProcess)
            
            Spacer()
            
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .background(Color("Background"))
        .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
        .ignoresSafeArea(edges: [.bottom])
        .onAppear {
            Task{
                if let ri = await it.generateQuestions(i: ip) {
                    ip = ri
                    let _ = it.save(ip)
                } else {
                    loadingProcess = "生目失敗。請重啟 app，點擊該檔案重試"
                    print("Generate Failed")
                }
            }
        }
    }

}

struct InterviewView_Progress: View {
    
    @EnvironmentObject var vm: ViewManager
    
    @Binding var ip: InterviewProfile
    @EnvironmentObject var it: InterviewTool
    @EnvironmentObject var ups: UserProfileService
    
    @State private var cur: Int = 0
    @State private var timer: Timer? = nil
    @State private var timerSec: Int = 0
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15){
            
            Text("第 \(cur+1) 題")
            
            Text(ip.questions[cur].question)
                .bold()
                .font(.title2)
            
            Spacer()
            
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color(.red))
                            .opacity(timerSec%2 == 0 ? 1 : 0.5)
                            .animation(.linear(duration: 1), value: timerSec)
                        Text("錄製中")
                            .bold()
                    }
                    Text("系統正錄製您的回答")
                }
                Spacer()
                Text(String(format: "%02d:%02d", timerSec/60, timerSec%60))
                    .font(.title3)
                    .bold()
            }
            .inifBlock(bgColor: Color("BackgroundR1"))
            
            HStack{
                actionButton(title: cur < ip.questions.count-1 ? "下一題" : "完成", requirements: { true }, onTap: {
                    next()
                })
            }
            
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .background(Color("Background"))
        .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
        .ignoresSafeArea(edges: [.bottom])
        .onAppear {
            startTimer()
            it.startRecording()
        }
        .onDisappear {
            stopTimer()
        }
        
    }
    
    @ViewBuilder
    private func actionButton(title: String, requirements: @escaping () -> Bool, onTap: @escaping () -> Void) -> some View {
        let isDisabled = !(requirements())
        Button {
            onTap()
        } label: {
            HStack{
                Spacer()
                Text(title)
                    .bold()
                Spacer()
            }
            .inifBlock(fgColor: isDisabled ? Color(.systemGray2) : Color(.white), bgColor: isDisabled ? Color("BackgroundR1") : Color("AccentBackground") )
        }
        .disabled(isDisabled)
        .animation(.easeInOut, value: isDisabled)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        stopTimer()
        timerSec = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ _ in
            timerSec += 1
        }
    }

    private func next() {
        ip.questions[cur].answerAudioPath = it.saveFile(from: it.stopRecording()!, for: ip.id)!
        
        if (cur < ip.questions.count-1) {
            it.startRecording()
            cur += 1
        } else {
            ip.status = .generateResults
            let _ = it.save(ip)
        }
    }
    
}

struct InterviewView_GenerateResults: View {
    
    @Binding var ip: InterviewProfile
    @EnvironmentObject var it: InterviewTool
    @EnvironmentObject var ups: UserProfileService
    
    @State private var loadingProcess: String = "生成結果中"
    
    var body: some View {
        
        VStack(spacing: 15){
            
            Spacer()
            
            LoadViewElement(circleLineWidth: 7)
                .frame(width: 50, height: 50)
            Text(loadingProcess)
            
            Spacer()
            
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .background(Color("Background"))
        .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
        .ignoresSafeArea(edges: [.bottom])
        .onAppear {
            Task{
                // 1. 轉錄音訊
                for (index, question) in ip.questions.enumerated() {
                    let _ = question
                    loadingProcess = "生成結果中 - 轉錄回答 \(index+1)"
                    ip.questions[index].answer = await it.generateAudioText(source: ip.questions[index].answerAudioPath)
                }
                
                // 2. 生成回答
                loadingProcess = "生成結果中 - 分析結果"
                if let ri = await it.generateResults(i: ip) {
                    ip = ri
                    let _ = it.save(ip)
                } else {
                    loadingProcess = "分析失敗。請重啟 app，點擊該檔案重試"
                    print("Generate Failed")
                }
            }
        }
    }

}

struct InterviewView_Completed: View {
    
    @Binding var ip: InterviewProfile
    @EnvironmentObject var it: InterviewTool
    @EnvironmentObject var ups: UserProfileService
    
    @State private var displayBlockScore: CGFloat = 100
    
    var body: some View {
        
        ScrollView{
            
            VStack(alignment: .leading, spacing: 15){
                
                Group {
                    
                    VStack(alignment: .leading){
                        Text(ip.name)
                            .bold()
                            .font(.title)
                        Text(ip.templateName)
                        HStack{
                            Spacer()
                            Text({
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                                return formatter.string(from: ip.date)
                            }())
                        }
                    }
                    
                    VStack(alignment: .leading){
                        Text("得分")
                        Text("\(ip.overallRating)")
                            .font(.title)
                            .bold()
                        HStack(spacing: 0){
                            Rectangle()
                                .fill(Color("AccentBackground"))
                                .frame(width: (displayBlockScore/100 * CGFloat(ip.overallRating)))
                                .animation(.spring(duration: 2.0), value: displayBlockScore)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            Rectangle()
                                .fill(Color("Background"))
                        }
                        .frame(height: 8)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top, -10)
                        .background(GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    self.displayBlockScore = proxy.size.width
                                }
                                .onChange(of: proxy.size){ t in
                                    self.displayBlockScore = t.width
                                }
                        })
                    }
                    .inifBlock(bgColor: Color("BackgroundR1"))
                    
                    VStack(alignment: .leading){
                        Text("整體評價")
                            .bold()
                        Text(ip.feedback)
                    }
                    .inifBlock(bgColor: Color("BackgroundR1"))
                    
                    Text("回饋")
                        .foregroundStyle(Color(.systemGray))
                        .font(.caption)
                    
                    ForEach(ip.feedbacks) { i in
                        VStack(alignment: .leading){
                            Text(i.content)
                                .bold()
                            Text(i.suggestion)
                        }
                        .inifBlock(bgColor: Color("BackgroundR1"))
                    }
                    
                    Text("問答")
                        .foregroundStyle(Color(.systemGray))
                        .font(.caption)
                    
                    ForEach(ip.questions) { i in
                        VStack(alignment: .leading){
                            Text(i.question)
                                .padding(.leading, 10)
                                .overlay(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray))
                                        .frame(width: 4)
                                }
                                .padding(.bottom, 2)
                            Text(i.answer)
                            Divider()
                            Text("\(i.score) 分")
                                .bold()
                            Text(i.feedback)
                        }
                        .inifBlock(bgColor: Color("BackgroundR1"))
                    }
                    
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
    
}

#Preview {
    InterviewView()
        .environmentObject(ViewManager())
}
