//
//  JYPageContollerProtocol.swift
//  JYPageController
//
//  Created by wang tao on 2022/10/15.
//

import UIKit


@objc public protocol JYPageChildContollerProtocol where Self: UIViewController {
    
    ///fetch child controller scrollView 有 headerView的时候menuview需要悬浮的时候实现
    @objc optional func fetchChildControllerScrollView() -> UIScrollView?
    
}


class JYPlaceHolderController: UIViewController,JYPageChildContollerProtocol {
    
}
