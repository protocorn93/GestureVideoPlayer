//
//  CMTime + toDisplayString.swift
//  GestureVideoPlayer
//
//  Created by 이동건 on 2018. 5. 11..
//  Copyright © 2018년 이동건. All rights reserved.
//

import CoreMedia

extension CMTime {
    func toDisplayString()->String {
        let duration = Int(CMTimeGetSeconds(self))
        
        let seconds = duration % 60
        let minute = duration % 3600 / 60
        let hour:String? = minute / 3600 == 0 ? nil : "\(duration / 3600)"
        if let hour = hour {
            return String(format: "%02d:%02d:%02d", arguments: [hour, minute, seconds])
        }else {
            return String(format: "%02d:%02d", arguments: [minute, seconds])
        }
    }
}
