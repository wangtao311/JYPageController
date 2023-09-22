//
//  JYPageContollerProtocol.swift
//  JYPageController
//
//  Created by wang tao on 2022/10/15.
//

import UIKit


@objc public protocol JYPageChildContollerProtocol where Self: UIViewController {
    
    ///fetch child controller scrollView. 有headerView的时候segmentedView需要悬浮的时候返回子页面中的tableView/collectionView/scrollView
    @objc optional func fetchChildControllerScrollView() -> UIScrollView?
    
}


class JYPlaceHolderController: UIViewController,JYPageChildContollerProtocol {
    
}
