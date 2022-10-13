//
//  JYScrollView.swift
//  JYPageController
//
//  Created by wang tao on 2022/10/12.
//

import UIKit

public class JYScrollView: UIScrollView {

    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let view = gestureRecognizer.view;
        NSLog(view?.description ?? "")
        return true
    }
    
    
}
