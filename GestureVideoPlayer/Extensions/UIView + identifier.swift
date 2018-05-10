//
//  UIView + identifier.swift
//  GestureVideoPlayer
//
//  Created by 이동건 on 2018. 5. 10..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

extension UIView {
    static var identifier: String {
        return String(describing: self)
    }
}
