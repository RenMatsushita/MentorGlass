//
//  CGRect.swift
//  MentorGlass
//
//  Created by Ren Matsushita on 2019/12/27.
//  Copyright © 2019 Ren Matsushita. All rights reserved.
//

import UIKit

extension CGRect {
    func scaledForCropping(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: (self.size.width * size.width),
            height: (self.size.height * size.height)
        )
    }
}
