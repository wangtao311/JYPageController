//
//  JYHaveHeaderView2Controller.swift
//  JYPageController_Example
//
//  Created by wang tao on 2023/9/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import JYPageController
import MJRefresh

class JYHaveHeaderView2Controller: JYPageController {
    
    var titles = ["商品","详情","评价"]
    let headerViewHeight: CGFloat = 300
    let menuViewHeight: CGFloat = 44
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .black
        config.normalTitleFont = 17
        
        config.selectedTitleColor = .red
        config.selectedTitleFont = 17
        
        config.itemsMargin = 44
        config.alignment = .center
        
        config.indicatorColor = .red
        config.indicatorHeight = 3
        config.indicatorWidth = 12
        
        //底部的下划线指示器距离底部的大小
        config.indicatorBottom = 2
        
        config.indicatorStickyAnimation = true
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerViewHeight))
        let imageView = UIImageView(image: UIImage(named: "xiaomi"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = header.bounds
        header.backgroundColor = .groupTableViewBackground
        header.addSubview(imageView)
        headerView = header
    }
}


extension JYHaveHeaderView2Controller {
    
    override func pageController(_ pageView: JYPageController, frameForSegmentedView segmentedView: JYSegmentedView) -> CGRect {
        return CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: menuViewHeight)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        return CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.height - menuViewHeight)
    }

    override func pageController(_ pageView: JYPageController, titleAt index: Int) -> String {
        return titles[index]
    }

    override func numberOfChildControllers() -> Int {
        return titles.count
    }
    
    override func childController(atIndex index: Int) -> JYPageChildContollerProtocol {
        let vc = JYTableViewController()
        vc.segmentTitle = titles[index]
        return vc
    }
    
    
}
