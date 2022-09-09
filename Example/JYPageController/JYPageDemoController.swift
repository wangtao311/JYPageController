//
//  ViewController.swift
//  JYPageController
//
//  Created by wangtao on 09/08/2022.
//  Copyright (c) 2022 wangtao. All rights reserved.
//

import UIKit
import JYPageController

class JYPageDemoController: JYPageController {
    
    let titles = ["Recommend","New","Music","😁","Near","Apple","Moment","Shares"]
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .systemGray
        config.normalTitleFontWeight = .regular
        config.normalTitleFont = 16
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .regular
        config.selectedTitleFont = 21

        config.indicatorLineViewSize = CGSize(width: 14, height: 3)
        config.indicatorLineViewCornerRadius = 2
        
        config.menuItemMargin = 25
        
        selectedIndex = 2
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "JYPageController"
    }
    
}


extension JYPageDemoController {
    
    
    override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        return CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 50)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        
        return CGRect.init(x: 0, y: 66, width: view.frame.size.width, height: UIScreen.main.bounds.size.height - 34 - 44 - 66)
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
        let vc = JYTableViewController()
        return vc
    }
    
    
}














