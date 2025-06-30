//
//  DiaryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/30.
//

import SwiftUI

struct DiaryView: View {
    
    @EnvironmentObject var vm: ViewManager
    @EnvironmentObject var dt: DiaryTool
    @State private var adp: [DiaryProfile] = []
    
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
            
            HStack{
                Text("日記")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color(.white))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 30)
            
            ScrollView{
                
                VStack(alignment: .leading, spacing: 15){
                    
                    Button {
                        vm.setTopView(DiaryView_Holder(dp: DiaryProfile(status: .prepared)))
                    } label: {
                        HStack{
                            Spacer()
                            Text("開始紀錄日記")
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
                                        Text("0")
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
                                        Text("1")
                                            .font(.title2)
                                            .bold()
                                        Image(systemName: "hockey.puck.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(Color("AppGold"))
                                    }
                                    Text("聽眾留言")
                                        .font(.caption)
                                }
                            }
                        }
                        .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
                    }
                    
                    Text("紀錄")
                        .foregroundStyle(Color(.systemGray))
                    
                    VStack(alignment: .leading){
                        ForEach(adp.indices, id: \.self){ index in
                            let i = adp[index]
                            Button{
                                vm.setTopView(DiaryView_Holder(dp: i))
                            } label: {
                                HStack{
                                    Text(i.diaryTitle)
                                }
                            }
                            if(index < adp.count-1){
                                Divider()
                                    .padding(.vertical, 6.5)
                            }
                        }
                        
                        if (adp.count == 0){
                            Text("尚無紀錄")
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
                    .inifBlock(fgColor: Color.accentColor, bgColor: Color("BackgroundR1"))
                    
                }
                .padding(25)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .background(Color("Background").clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20)))
        
        }
        .background(
            VStack{
                Image("HomeView_Img4")
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
                Spacer()
            }
                .ignoresSafeArea(.all)
        )
        .background(
            VStack{
                Color("AccentBackground")
                Color("Background")
            }
                .ignoresSafeArea(.all)
        )
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
        adp = dt.load(all: DiaryProfile.self).sorted(by: { $0.date > $1.date })
    }
}

struct DiaryView_Holder: View {
    
    @EnvironmentObject var vm: ViewManager
    @State var dp: DiaryProfile
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                if dp.status == .completed {
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
                Text("日記")
                    .font(.title)
                    .fontWeight(.heavy)
                Spacer()
            }
            .foregroundStyle(Color(.white))
            .padding(.horizontal)
            .padding(.vertical, 5)
            .padding(.bottom, 5)
            
            switch(dp.status){
            case .notStarted:
                EmptyView() // 目前尚未使用到
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .prepared:
                DiaryView_Prepared(dp: $dp)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .inProgress:
                DiaryView_Progress(dp: $dp)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .generateContent:
                DiaryView_GenerateContent(dp: $dp)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .completed:
                DiaryView_Completed(dp: $dp)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .background(
            VStack{
                Image("HomeView_Img4")
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
                Spacer()
            }
                .ignoresSafeArea(.all)
        )
        .background(
            VStack{
                Color("AccentBackground")
                Color("Background")
            }
                .ignoresSafeArea(.all)
        )
        .animation(.spring(duration: 0.3), value: dp.status)
    }
}

struct DiaryView_Prepared: View {
    
    @EnvironmentObject var vm: ViewManager
    
    @Binding var dp: DiaryProfile
    @EnvironmentObject var ups: UserProfileService
    
    private var cost: Int {
        let cost = 0
        return cost
    }
    
    var body: some View {
        
        ScrollView{
            
            VStack(alignment: .leading, spacing: 15){
                
                Group {
                    VStack(alignment: .leading){
                        Text("即將開始紀錄日記")
                            .bold()
                            .font(.title)
                        Text("請再確認日記檔案的細節")
                    }
                    
                    Text("檔案資訊")
                        .foregroundStyle(Color(.systemGray))
                        .font(.caption)
                    VStack{
                        HStack{
                            Text("檔案名稱")
                            Spacer()
                            Text("日記")
                                .foregroundStyle(Color(.systemGray))
                        }
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
                            Text("0")
                            Image(systemName: "hockey.puck.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                        }
                        .foregroundStyle(Color(.systemGray))
                    }
                    .inifBlock(bgColor: Color("BackgroundR1"))
                    
                    HStack{
                        actionButton(title: "退出",
                                     requirements: { true },
                                     onTap: {
                            vm.clearTopView()
                        }
                        )
                        .frame(maxWidth: 150)
                        actionButton(title: "開始",
                                     requirements: { true },
                                     onTap: {
                            ups.coinRequest(type: .pay(item: "日記"), amount: -cost, onConfirm: {
                                dp.status = .inProgress
                            }, onCancel: {
                                print("InterviewView | 取消開始紀錄日記")
                            })
                        }
                        )
                    }
                }
                
            }
            .padding(25)
            .frame(maxHeight: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        .background(Color("Background").clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20)))
        
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

}

struct DiaryView_Progress: View {
    
    @EnvironmentObject var vm: ViewManager
    
    @Binding var dp: DiaryProfile
    @EnvironmentObject var dt: DiaryTool
    @EnvironmentObject var ups: UserProfileService
    
    @State private var cur: Int = 0
    @State private var timer: Timer? = nil
    @State private var timerSec: Int = 0
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15){
            
            Text("紀錄中")
            
            Text("請直接開始唸出您的日記內容。")
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
                actionButton(title: "完成", requirements: { true }, onTap: {
                    finish()
                })
            }
            
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .background(Color("Background").clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20)))
        .ignoresSafeArea(edges: [.bottom])
        .onAppear {
            startTimer()
            dt.startRecording()
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

    private func finish() {
        dp.diaryPath = dt.saveFile(from: dt.stopRecording()!, for: dp.id)!
        dp.status = .generateContent
        let _ = dt.save(dp)
    }
    
}

struct DiaryView_GenerateContent: View {
    
    @Binding var dp: DiaryProfile
    @EnvironmentObject var dt: DiaryTool
    @EnvironmentObject var ups: UserProfileService
    
    @State private var loadingProcess: String = "生成中"
    
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
        .background(Color("Background").clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20)))
        .ignoresSafeArea(edges: [.bottom])
        .onAppear {
            Task{
                // 1. 生成回答
                loadingProcess = "生成中"
                if let ri = await dt.generateContent(i: dp) {
                    dp = ri
                    let _ = dt.save(dp)
                } else {
                    loadingProcess = "生成失敗。請重啟 app，點擊該檔案重試"
                    print("Generate Failed")
                }
            }
        }
    }

}

struct DiaryView_Completed: View {
    
    @Binding var dp: DiaryProfile
    @EnvironmentObject var dt: DiaryTool
    @EnvironmentObject var ups: UserProfileService
    @EnvironmentObject var vm: ViewManager
    
    @State private var displayCopy: Bool = false
    @State private var displayDeleteConfirm: Bool = false
    
    var body: some View {
        
        ScrollView{
            
            VStack(alignment: .leading, spacing: 15){
                
                VStack(alignment: .leading){
                    Text(dp.diaryTitle)
                        .bold()
                        .font(.title)
                    Text({
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd HH:mm"
                        return formatter.string(from: dp.date)
                    }())
                }
                
                VStack(alignment: .leading){
                    Text(dp.diaryContent)
                }
                .inifBlock(bgColor: Color("BackgroundR1"))
                
                VStack(alignment: .leading){
                    Button {
                        UIPasteboard.general.string = dp.diaryContent
                        withAnimation(.easeInOut(duration: 0.1)) {
                            displayCopy = true
                        }
                    } label: {
                        if displayCopy {
                            HStack{
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                Text("已複製")
                                    .bold()
                            }
                        } else {
                            HStack{
                                Image(systemName: "document.on.clipboard")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                Text("複製")
                            }
                        }
                    }
                }
                .inifBlock(fgColor: Color.accentColor, bgColor: Color("BackgroundR1"))
                
                Text("聽眾留言")
                    .foregroundStyle(Color(.systemGray))
                    .font(.caption)
                
                Text("操作")
                    .foregroundStyle(Color(.systemGray))
                    .font(.caption)
                
                VStack{
                    if (displayDeleteConfirm){
                        Button {
                            dt.delete(for: dp.id)
                            vm.clearTopView()
                        } label: {
                            Text("確認刪除？")
                                .bold()
                        }
                    } else {
                        Button {
                            withAnimation(.easeIn(duration: 0.1)) {
                                displayDeleteConfirm = true
                            }
                        } label: {
                            Text("刪除")
                        }
                    }
                }
                .inifBlock(fgColor: Color(.red), bgColor: Color("BackgroundR1"))
                
            }
            .padding(25)
            .frame(maxHeight: .infinity)
            
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        .background(Color("Background").clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20)))
        
    }
    
}
