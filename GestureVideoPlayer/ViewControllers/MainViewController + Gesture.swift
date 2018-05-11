//
//  MainViewController + Gesture.swift
//  GestureVideoPlayer
//
//  Created by 이동건 on 2018. 5. 11..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

extension MainViewController {
    
    func setupGesture(){
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowHideOnContainerView(_:))))
        self.playbackControllerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowHideOnPlaybackControllerView(_:))))
    }
    
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
