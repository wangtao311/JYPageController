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
    
    let titles = ["I like","Like me"]
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .darkText
        config.normalTitleFontWeight = .regular
        config.normalTitleFont = 16
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .regular
        config.selectedTitleFont = 20

        config.indicatorStyle = .customSizeLine
        config.indicatorSize = CGSize(width: 14, height: 3)
        config.indicatorCornerRadius = 2
        
        config.menuItemMargin = 35
        config.alignment = .right
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
    
    
    override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        
        var menuViewY : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            menuViewY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: menuViewY, width: view.frame.size.width, height: 50)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        
        var menuViewY : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            menuViewY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: menuViewY + 50, width: view.frame.size.width, height: view.frame.height - 50 - menuViewY)
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

