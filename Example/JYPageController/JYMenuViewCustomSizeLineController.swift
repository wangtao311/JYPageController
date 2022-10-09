//
//  JYMenuViewBadgeOffsetDemoController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/9/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JYPageController

class JYMenuViewCustomSizeLineController: JYPageController {
    
    let titles = ["Home","New","Music","😁","Near","Apple","Moment","Shares"]
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .darkText
        config.normalTitleFontWeight = .regular
        config.normalTitleFont = 16
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .regular
        config.selectedTitleFont = 20

        config.indicatorStyle = .customSizeLine
        config.indicatorWidth = 14
        config.indicatorHeight = 3
        config.indicatorCornerRadius = 2
        
        config.menuItemMargin = 40
        
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


extension JYMenuViewCustomSizeLineController {
    
    
    override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        
        var menuViewY : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            menuViewY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: menuViewY, width: view.frame.size.width, height: 44)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        
        var menuViewY : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            menuViewY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: menuViewY + 44, width: view.frame.size.width, height: view.frame.height - 44 - menuViewY)
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
    
    override func childController(atIndex index: Int) -> UIViewController {
        let tableViewController = JYTableViewController()
        let viewController = JYViewController()
        if index == 1 {
            return viewController
        }else{
            return tableViewController
        }
    }
    
    
}
