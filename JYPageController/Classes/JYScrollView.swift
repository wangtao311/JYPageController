//
//  JYScrollView.swift
//  JYPageController
//
//  Created by wang tao on 2022/10/12.
//

import UIKit

public class JYScrollView: UITableView,UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())
    }

}


