//
//  ViewController.swift
//  JYPageController
//
//  Created by wangtao on 09/08/2022.
//  Copyright (c) 2022 wangtao. All rights reserved.
//

import UIKit
import JYPageController

class ViewController: JYPageController {
    
    let titles = ["推荐","最新","音乐","体育","附近动态","Apple","海外","股票"]
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .systemGray
        config.normalTitleFontWeight = .regular
        config.normalTitleFont = 16
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .regular
        config.selectedTitleFont = 20

        config.indicatorLineViewSize = CGSize(width: 14, height: 3)
        config.indicatorLineViewCornerRadius = 2
        
        config.menuItemMargin = 25
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


extension ViewController {
    
    
    override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        return CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 50)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        return CGRect.init(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.height - 50)
    }

    override func pageController(_ pageView: JYPageController, titleAt index: Int) -> String {
        return titles[index]
    }
    
    override func pageController(_ pageView: JYPageController, badgeViewAt index: Int) -> UIView? {
        
        if index == 1 {
            let badge = UIImageView.init(image: UIImage(named: "badge"))
            badge.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
            return badge
        }else {
            return nil
        }
        
    }

    override func numberOfChildControllers() -> Int {
        return titles.count
    }
    
    override func childController(atIndex index: Int) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = randomRGB()
        return vc
    }
    
    
    
    
    func randomRGB() -> UIColor {
            return UIColor.init(red: CGFloat(arc4random()%256)/255.0, green: CGFloat(arc4random()%256)/255.0, blue: CGFloat(arc4random()%256)/255.0, alpha: 1)

    }
    
}














