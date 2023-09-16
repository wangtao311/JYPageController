//
//  JYMenuCustomItemController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/10/11.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

import JYPageController

class JYMenuCustomItemController: JYPageController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .darkText
        config.normalTitleFontWeight = .medium
        config.normalTitleFont = 18
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .medium
        config.selectedTitleFont = 18

        config.indicatorStyle = .customSizeLine
        config.indicatorWidth = 14
        config.indicatorHeight = 3
        config.indicatorCornerRadius = 2
        
        config.itemMargin = 30
        
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


extension JYMenuCustomItemController {
    
    
    override func pageController(_ pageView: JYPageController, frameForSegmentedView segmentedView: JYSegmentedView) -> CGRect {
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
        if index == 3 {
            return "item"
        }else {
            return ""
        }
    }
    
    override func pageController(_ pageController: JYPageController, customViewAt index: Int) -> UIView? {
        
        if index == 0 {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "customItem"), for: .normal)
            button.setTitle("鞋包", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
            return button
        }else if index == 1 {
            let img = UIImageView()
            img.image = UIImage(named: "drink")
            img.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            return img
        }else if index == 2 {
            let label = UILabel()
            label.backgroundColor = .red
            label.text = "自定义UIView"
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 15)
            label.textAlignment = .center
            label.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
            return label
        }else{
            return nil
        }
    }

    override func numberOfChildControllers() -> Int {
        return 4
    }
    
    override func childController(atIndex index: Int) -> JYPageChildContollerProtocol {
        let vc = JYTableViewController();
        return vc
    }
    
    
}

