//
//  JYMenuViewAligentDemoController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/9/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JYPageController

class JYMenuViewAligentDemoController: JYPageController {
    
    let titles = ["推荐","最新"]
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .darkText
        config.normalTitleFontWeight = .regular
        config.normalTitleFont = 16
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .regular
        config.selectedTitleFont = 23

        config.indicatorWidth = 14
        config.indicatorHeight = 3
        config.indicatorCornerRadius = 2
        
        config.alignment = .left
        
        //segmentView item之间的间距
        config.itemsMargin = 25
        
        //segmentView左右的边距
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


extension JYMenuViewAligentDemoController {
    
    
    override func pageController(_ pageView: JYPageController, frameForSegmentedView segmentedView: JYSegmentedView) -> CGRect {
        return CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 50)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        var top: CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: 44, width: view.frame.size.width, height: view.frame.height - 50 - top)
    }

    override func pageController(_ pageView: JYPageController, titleAt index: Int) -> String {
        return titles[index]
    }
    
    override func pageController(_ pageView: JYPageController, badgeViewAt index: Int) -> UIView? {
        
        if index == 1 {
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
        if index == 1 {
            removeMenuItemBadgeView(atIndex: 1)
        }
    }
    
    
}

