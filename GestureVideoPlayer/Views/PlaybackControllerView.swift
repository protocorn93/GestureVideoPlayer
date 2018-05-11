//
//  PlaybackControlView.swift
//  GestureVideoPlayer
//
//  Created by 이동건 on 2018. 5. 10..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit
import AVKit

protocol PlaybackControllerViewDelegate: class {
    func playbackControllerView(toBePlay: Bool)
    func playbackControllerView(valueDidChange slider: UISlider)
}

class PlaybackControllerView: UIView {
    //MARK: Outlets
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet{
            playPauseButton.setImage(#imageLiteral(resourceName: "play") , for: .normal)
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .selected)
        }
    }
    @IBOutlet weak var enlargeShrinkButton: UIButton! {
        didSet{
            enlargeShrinkButton.setImage(#imageLiteral(resourceName: "fill"), for: .normal)
            enlargeShrinkButton.setImage(#imageLiteral(resourceName: "shrink"), for: .selected)
        }
    }
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playbackSlider: UISlider! {
        didSet{
            let image = UIImage(cgImage: #imageLiteral(resourceName: "thumbImage").cgImage!, scale: 4, orientation: UIImageOrientation.up)
            playbackSlider.setThumbImage(image, for: .normal)
        }
    }
    //MARK: Properties
    var isLandscapeMode:Bool = false
    var isHiding:Bool = false
    weak var delegate: PlaybackControllerViewDelegate?
    //MARK: Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        playbackSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    //MARK: Initializer
    static func initFromNib()->PlaybackControllerView {
        let view = Bundle.main.loadNibNamed(PlaybackControllerView.identifier, owner: self, options: nil)?.first as! PlaybackControllerView
        return view
    }
    //MARK: Method
    func synchronizeSlider(with time:CMTime, of player: AVPlayer!){
        self.currentTimeLabel.text = time.toDisplayString()
        if let durationTime = player.currentItem?.duration, player.currentItem?.status == .readyToPlay{
            self.durationLabel.text = durationTime.toDisplayString()
            self.playbackSlider.value = Float(CMTimeGetSeconds(time)) / Float(CMTimeGetSeconds(durationTime))
        }
    }
    //MARK: IBAction
    @objc func sliderValueChanged(_ sender: UISlider) {
        delegate?.playbackControllerView(valueDidChange: sender)
    }
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        let isSelected = !playPauseButton.isSelected
        playPauseButton.isSelected = isSelected
        delegate?.playbackControllerView(toBePlay: isSelected)
    }
    @IBAction func enlargeShrinkButtonTapped(_ sender: Any) {
        let value:Int!
        if isLandscapeMode {
            value = UIInterfaceOrientation.portrait.rawValue
            isLandscapeMode = false
        }else {
            value = UIInterfaceOrientation.landscapeRight.rawValue
            isLandscapeMode = true
        }
        enlargeShrinkButton.isSelected = isLandscapeMode
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}
