//
//  config.indicatorStyle = .customView         let indicator = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 15))         indicator.image = UIImage(named: "Indicator") JYCustomIndicatorDemoController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/9/18.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JYPageController

class JYCustomIndicatorDemoController: JYPageController {
    
    let titles = ["Home","New","Music","Near","Apple","Moment","Shares"]
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .darkText
        config.normalTitleFontWeight = .regular
        config.normalTitleFont = 16
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .regular
        config.selectedTitleFont = 16
        
        config.menuItemMargin = 30
        
        let customIndicator = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 15))
        customIndicator.image = UIImage(named: "Indicator")
        config.customIndicator = customIndicator
        config.indicatorStyle = .customView
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


extension JYCustomIndicatorDemoController {
    
    
    override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        return CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 44)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        
        var top: CGFloat = 0
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
        if index == 1 {
            return JYViewController()
        }else{
            return JYTableViewController()
        }
    }
    
    
}
