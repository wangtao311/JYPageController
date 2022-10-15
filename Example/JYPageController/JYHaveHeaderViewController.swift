//
//  JYHaveHeaderViewController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/10/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

import JYPageController

class JYHaveHeaderViewController: JYPageController {
    
    let titles = ["Home","New","Music","Near"]
    let headerViewHeight: CGFloat = 300
    let menuViewHeight: CGFloat = 44
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .darkText
        config.normalTitleFontWeight = .medium
        config.normalTitleFont = 16
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .medium
        config.selectedTitleFont = 16
        
        config.menuItemMargin = 30
        config.indicatorStyle = .none
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        var headerY: CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            headerY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        
        let header = UIView(frame: CGRect(x: 0, y: headerY, width: view.frame.width, height: headerViewHeight))
        header.backgroundColor = .red
        headerView = header
    }
    
}


extension JYHaveHeaderViewController {
    
    
    override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        
        var menuViewY : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            menuViewY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: menuViewY + headerViewHeight, width: view.frame.size.width, height: menuViewHeight)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        
        var menuViewY : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            menuViewY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: menuViewY + menuViewHeight + headerViewHeight, width: view.frame.size.width, height: view.frame.height - menuViewHeight - menuViewY)
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
        if index == 1 {
            return JYViewController()
        }else{
            return JYTableViewController()
        }
    }
    
    
}










