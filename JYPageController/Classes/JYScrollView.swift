//
//  JYScrollView.swift
//  JYPageController
//
//  Created by wang tao on 2022/10/12.
//

import UIKit

public class JYScrollView: UIScrollView,UIGestureRecognizerDelegate {
    
    var otherCanScroll: Bool = false
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if otherCanScroll == true {
//            return true
//        }
//        print("shouldBeRequiredToFailBy")
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
//        if let otherView = otherGestureRecognizer.view {
//            if otherView.isKind(of: UIScrollView.classForCoder()), NSStringFromClass(otherGestureRecognizer.classForCoder) == "UIScrollViewPanGestureRecognizer" {
//                return false
//            }
//        }
//
//        if let otherView = otherGestureRecognizer.view {
//            if NSStringFromClass(otherView.classForCoder) == "UILayoutContainerView", NSStringFromClass(otherGestureRecognizer.classForCoder) == "_UIParallaxTransitionPanGestureRecognizer" {
//                return false
//            }
//        }
//        if otherCanScroll == true {
//            print("otherCanScroll == true")
//            return false
//        }
        
        return true
    }

}


