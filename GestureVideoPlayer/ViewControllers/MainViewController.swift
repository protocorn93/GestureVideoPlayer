//
//  MainViewController.swift
//  GestureVideoPlayer
//
//  Created by 이동건 on 2018. 5. 10..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit
import AVKit

class MainViewController: UIViewController {
    
    //MARK: Properties
    var player: AVPlayer!
    var asset:AVAsset!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    var playbackControllerView: PlaybackControllerView = PlaybackControllerView.initFromNib()
    private var playerItemContext = 0 // Key-value observing context
    let requiredAssetKeys = ["playable", "hasProtectedContent"]
    var showAnimation:UIViewPropertyAnimator!
    var hideAnimation:UIViewPropertyAnimator!
    var toBeHide:Bool = true
    //MARK: Outlets
    @IBOutlet weak var containerView: UIView!
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        initailizeAnimation()
        setupGesture()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = containerView.frame // because sublayers were not resizing autumatically
    }
    //MARK: AVPlayer
    fileprivate func setupPlayer(){
        guard let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {return}
        asset = AVAsset(url: url)
        playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: requiredAssetKeys)
        //observce play item status
        playerItem.addObserver(self,forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new],context: &playerItemContext)
        player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = false
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        containerView.layer.addSublayer(playerLayer)

        //setup Playback Controller view
        setupPlaybackControllerView()
        //observe playback timeline
        observeCurrentPlaybackTime()
    }
    
    fileprivate func observeCurrentPlaybackTime(){
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let timeInterval = CMTime(seconds: 1, preferredTimescale: timeScale)
        player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] (time) in
            self?.playbackControllerView.synchronizeSlider(with: time, of: self?.player)
        }
    }
}
//MARK:- PlaybackControllerViewDelegate
extension MainViewController: PlaybackControllerViewDelegate {
    fileprivate func setupPlaybackControllerView(){
        //Setup PlaybackControllerView
        playbackControllerView.delegate = self
        playbackControllerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(playbackControllerView)
        playbackControllerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        playbackControllerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        playbackControllerView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        playbackControllerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    func playbackControllerView(valueDidChange slider: UISlider) {
        let percentage = slider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, Int32(NSEC_PER_SEC))
        if slider.isTracking {
            hideAnimation.stopAnimation(true)
            showAnimation.stopAnimation(true)
            return
        }
        player.seek(to: seekTime) { (_) in
            self.initailizeAnimation()
            self.hideAnimation.startAnimation(afterDelay: 3)
        }
    }
    
    func playbackControllerView(toBePlay: Bool) {
        hideAnimation.stopAnimation(true)
        initailizeAnimation()
        showAnimation.startAnimation()
        if toBePlay {
            player.play()
        }else{
            player.pause()
        }
    }
}
//MARK:- KVO
extension MainViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                print("ready to play item")
                player.play()
                playbackControllerView.playPauseButton.isSelected = true
                hideAnimation.startAnimation(afterDelay: 3)
                break
            case .failed:
                break
            case .unknown:
                break
            }
        }
    }
}
