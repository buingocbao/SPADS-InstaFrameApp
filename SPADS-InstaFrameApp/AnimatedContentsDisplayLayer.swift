//
//  AnimatedContentsDisplayLayer.swift
//  TestParse4-AsyncDisplayKit
//
//  Created by BBaoBao on 4/8/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit

class AnimatedContentsDisplayLayer: _ASDisplayLayer {
    override func actionForKey(event: String!) -> CAAction! {
        if let action = super.actionForKey(event) {
            return action
        }
        
        if event == "contents" && contents == nil {
            let transition = CATransition()
            transition.duration = 0.6
            transition.type = kCATransitionFade
            return transition
        }
        
        return nil
    }
}
