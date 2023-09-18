//
//  ViewController.swift
//  JYPageController
//
//  Created by wangtao on 09/08/2022.
//  Copyright (c) 2022 wangtao. All rights reserved.
//

import UIKit
import JYPageController
import MJRefresh

class JYNormalDemoController: JYPageController {
    
    let titles = ["推荐","手机","男装","食品","百货","女装","电脑","鞋包","医药","电器","水果"]
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .darkText
        config.normalTitleFont = 17
        
        config.selectedTitleColor = .red
        config.selectedTitleFont = 17
        
        //默认选中第一个子页面
        selectedIndex = 1
        
        //下划线指示器的粘性动画
        config.indicatorStickyAnimation = true
//        config.indicatorWidth = 14
        
        //segmentedView  item之间的间距
        config.itemsMargin = 20
        //segmentedView左右边距
        config.leftPadding = 20
        config.rightPadding = 20
    }
    

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
    }
    
}


extension JYNormalDemoController {
    
    
    override func pageController(_ pageView: JYPageController, frameForSegmentedView segmentedView: JYSegmentedView) -> CGRect {
        return CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 44)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        
        var top : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: 44, width: view.frame.size.width, height: view.frame.height - 44 - top)
    }

    override func pageController(_ pageView: JYPageController, titleAt index: Int) -> String {
        return titles[index]
    }
    
    override func pageController(_ pageView: JYPageController, badgeViewAt index: Int) -> UIView? {
        
        if index == 1 {
            let badge = UIImageView.init(image: UIImage(named: "badge"))
            badge.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
            return badge
        }else if index == 4 {
            let label = UILabel()
            label.text = "99+"
            label.textColor = .red
            label.font = UIFont.systemFont(ofSize: 12)
            label.sizeToFit()
            return label
        }else {
            return nil
        }
        
    }

    override func numberOfChildControllers() -> Int {
        return titles.count
    }
    
    override func childController(atIndex index: Int) -> JYPageChildContollerProtocol {
        let vc = JYTableViewController();
        vc.segmentTitle = titles[index]
        return vc
    }
    
    
    override func pageController(_ pageController: JYPageController, didEnterControllerAt index: Int) {
        if index == 4 {
            removeMenuItemBadgeView(atIndex: 4)
        }
    }
    
}














