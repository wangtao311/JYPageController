//
//  JYMenuViewEqualItemWidthLineController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/10/9.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

import JYPageController

class JYMenuViewEqualItemWidthLineController: JYPageController {
    
    let titles = ["推荐","手机","男装","食品","百货","女装","电脑","鞋包","医药","电器","水果"]
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .darkText
        config.normalTitleFontWeight = .regular
        config.normalTitleFont = 16
        
        config.selectedTitleColor = .red
        config.selectedTitleFontWeight = .medium
        config.selectedTitleFont = 16

        config.indicatorStyle = .equalItemWidthLine
        config.indicatorHeight = 2.5
        
        config.itemsMargin = 20
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


extension JYMenuViewEqualItemWidthLineController  {
    
    
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
        return titles[index]
    }

    override func numberOfChildControllers() -> Int {
        return titles.count
    }
    
    override func childController(atIndex index: Int) -> JYPageChildContollerProtocol {
        let vc = JYTableViewController();
        vc.segmentTitle = titles[index]
        return vc
    }
    
    
}
