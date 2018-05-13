//
//  MainViewController.swift
//  GestureVideoPlayer
//
//  Created by 이동건 on 2018. 5. 10..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit
import MediaPlayer
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
    var panStartLocation:CGPoint!
    var prePanLocation:CGPoint!
    var currentPanLocation:CGPoint!
    var volumeIndicatorViewHeightConstraint:NSLayoutConstraint!
    var brightnessIndicatorViewHeightConstraint:NSLayoutConstraint!
    let audioSession = AVAudioSession.sharedInstance()
    var isPanDragging:Bool = false
    //MARK: Outlets
    @IBOutlet weak var containerView: UIView!
    var panGestureArea: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var volumeView: MPVolumeView = {
        let view = MPVolumeView(frame: .zero)
        view.isHidden = true
        return view
    }()
    let volumeIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.green
        view.alpha = 0
        return view
    }()
    let brightnessIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.green
        view.alpha = 0
        return view
    }()
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        initailizeAnimation()
        setupGesture()
        listenVolumeButton()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = containerView.frame // because sublayers were not resizing autumatically
        panGestureArea.frame = playbackControllerView.panGestureArea.frame
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
        self.containerView.addSubview(panGestureArea)
        //Setup PlaybackControllerView
        playbackControllerView.delegate = self
        playbackControllerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(playbackControllerView)
        playbackControllerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        playbackControllerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        playbackControllerView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        playbackControllerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        self.view.addSubview(volumeView)
        self.containerView.addSubview(volumeIndicatorView)
        volumeIndicatorView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
        volumeIndicatorView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 0.5).isActive = true
        volumeIndicatorView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        let currentVolume = audioSession.outputVolume
        volumeIndicatorViewHeightConstraint = volumeIndicatorView.heightAnchor.constraint(equalToConstant: CGFloat(currentVolume) * self.containerView.frame.height)
        volumeIndicatorViewHeightConstraint.isActive = true
        
        self.containerView.addSubview(brightnessIndicatorView)
        brightnessIndicatorView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
        brightnessIndicatorView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 0.5).isActive = true
        brightnessIndicatorView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        
        brightnessIndicatorViewHeightConstraint = brightnessIndicatorView.heightAnchor.constraint(equalToConstant: UIScreen.main.brightness * self.containerView.frame.height)
        brightnessIndicatorViewHeightConstraint.isActive = true
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
            playbackControllerView.alpha = 1
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
    func listenVolumeButton() {
        do {
            try audioSession.setActive(true)
        } catch {
            print("some error")
        }
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        
        if keyPath == "outputVolume" && !isPanDragging{
            print("Device Volume Changed by Button")
            volumeIndicatorViewHeightConstraint.constant = CGFloat(audioSession.outputVolume) * containerView.frame.height
            self.volumeIndicatorView.alpha = 0.5
            UIView.animate(withDuration: 0.5) {
                self.volumeIndicatorView.alpha = 0
            }
        }else if keyPath == #keyPath(AVPlayerItem.status){
            guard context == &playerItemContext else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
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
