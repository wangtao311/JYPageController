//
//  JYPageDemoShowInNavController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/9/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JYPageController

class JYShowInNavDemoController: JYPageController {
    
    let titles = ["City","Follow","Shop"]
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .darkText
        config.normalTitleFontWeight = .regular
        config.normalTitleFont = 18
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .regular
        config.selectedTitleFont = 20

        config.indicatorLineViewSize = CGSize(width: 20, height: 3)
        config.indicatorLineViewCornerRadius = 2
        
        config.menuItemMargin = 30
        config.menuViewShowInNavigationBar = true
        config.alignment = .center
        
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


extension JYShowInNavDemoController {
    
    
    override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        return CGRect.init(x: 50, y: 0, width: view.frame.size.width - 100, height: 50)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        
        var originY : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            originY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: originY, width: view.frame.size.width, height: view.frame.height - originY)
    }

    override func pageController(_ pageView: JYPageController, titleAt index: Int) -> String {
        return titles[index]
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

