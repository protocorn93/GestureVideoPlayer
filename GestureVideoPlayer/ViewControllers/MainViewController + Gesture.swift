//
//  MainViewController + Gesture.swift
//  GestureVideoPlayer
//
//  Created by 이동건 on 2018. 5. 11..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit
import AVKit

extension MainViewController {
    func setupGesture(){
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowHideOnContainerView(_:))))
        self.panGestureArea.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        self.playbackControllerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowHideOnPlaybackControllerView(_:))))
        self.playbackControllerView.panGestureArea.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
    }
    //MARK: UIPanGesture
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer){
        if gesture.state == .began { // Pan Start
            isPanDragging = true
            panStartLocation = gesture.location(in: self.playbackControllerView.panGestureArea)
            prePanLocation = panStartLocation
            self.capturedTime = self.playerItem.currentTime() // Capture Current Time
            let initailVelocity = gesture.velocity(in: self.playbackControllerView.panGestureArea) // Initial Velocity for detecting Pan Direction
            panDirection = abs(initailVelocity.x) > abs(initailVelocity.y) ? .horizontal : .vertical
        }
        else if gesture.state == .changed { // Pan Changing
            guard let direction = self.panDirection else {return}
            let translation = gesture.translation(in: self.playbackControllerView.panGestureArea)
            let xDiff = translation.x
            let yDiff = translation.y
            if abs(xDiff) > abs(yDiff) && direction == .horizontal{ // Horizontal
                let time = Int(xDiff) / 10
                timeToSeekByPanGesture = time
                timeLabel.text = CMTime.updatePanGestureSeekTimeLabel(captured: capturedTime, time: time)
                timeLabel.isHidden = false
            }else if abs(xDiff) < abs(yDiff) && direction == .vertical{ // Vertical
                currentPanLocation = gesture.location(in: self.playbackControllerView.panGestureArea)
                let diff = currentPanLocation.y - prePanLocation.y
                prePanLocation = currentPanLocation
                if panStartLocation.x < self.containerView.frame.width / 2 { // Brightness
                    brightnessIndicatorViewHeightConstraint.constant -= diff
                    UIScreen.main.brightness = brightnessIndicatorViewHeightConstraint.constant / self.containerView.frame.height
                    UIView.animate(withDuration: 0.5) {
                        self.brightnessIndicatorView.alpha = 0.5
                    }
                }else{ // Volume
                    volumeIndicatorViewHeightConstraint.constant -= diff
                    if let view = volumeView.subviews.first as? UISlider {
                        view.value = Float(volumeIndicatorViewHeightConstraint.constant / self.containerView.frame.height)
                    }
                    if volumeIndicatorViewHeightConstraint.constant > self.view.frame.height {
                        volumeIndicatorViewHeightConstraint.constant = self.view.frame.height
                    }else if volumeIndicatorViewHeightConstraint.constant < 0 {
                        volumeIndicatorViewHeightConstraint.constant = 0
                    }
                    UIView.animate(withDuration: 0.5) {
                        self.volumeIndicatorView.alpha = 0.5
                    }
                }
            }
            
        }
        else if gesture.state == .ended { // Pan End
            UIView.animate(withDuration: 0.5, animations: {
                self.brightnessIndicatorView.alpha = 0
                self.volumeIndicatorView.alpha = 0
                self.isPanDragging = false
            })
            
            timeLabel.isHidden = true
            let seekTime = CMTime(seconds: Double(timeToSeekByPanGesture), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            player.seek(to: CMTimeAdd(capturedTime, seekTime))
        }
    }
    
    //MARK: Playback Controller Animation
    @objc func handleShowHideOnContainerView(_ gesture: UITapGestureRecognizer){
        playbackControllerView.isHidden = false
        fireAnimation()
    }
    @objc func handleShowHideOnPlaybackControllerView(_ gesture: UITapGestureRecognizer){
        toBeHide = !toBeHide
        fireAnimation()
    }
    fileprivate func fireAnimation(){
        self.showAnimation.stopAnimation(true)
        self.hideAnimation.stopAnimation(true)
        initailizeAnimation()
        if toBeHide {
            self.hideAnimation.startAnimation()
        }else{
            self.showAnimation.startAnimation()
        }
    }
    func initailizeAnimation(){
        hideAnimation = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            self.playbackControllerView.alpha = 0.05
        })
        hideAnimation.addCompletion { (_) in
            self.playbackControllerView.isHidden = true
            self.toBeHide = false
        }
        showAnimation = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            self.playbackControllerView.alpha = 1
        })
        showAnimation.addCompletion { (_) in
            self.hideAnimation.startAnimation(afterDelay: 3)
        }
    }
}
