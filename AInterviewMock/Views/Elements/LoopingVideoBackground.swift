//
//  LoopingVideoBackground.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/20.
//


import SwiftUI
import AVKit

struct LoopingVideoBackground: View {
    let videoName: String
    let fileExtension: String

    private var player: AVPlayer {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: fileExtension) else {
            fatalError("LoopingVideoBackground | 找不到影片 \(videoName).\(fileExtension)")
        }
        let player = AVPlayer(url: url)
        player.isMuted = true
        player.actionAtItemEnd = .none
        return player
    }

    @State private var playerInstance: AVPlayer? = nil

    var body: some View {
        VideoPlayer(player: playerInstance)
            .ignoresSafeArea()
            .onAppear {
                playerInstance = player
                playerInstance?.play()
                
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: playerInstance?.currentItem,
                    queue: .main
                ) { _ in
                    playerInstance?.seek(to: .zero)
                    playerInstance?.play()
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(
                    self,
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: playerInstance?.currentItem
                )
                playerInstance?.pause()
                playerInstance = nil
            }
    }
}
