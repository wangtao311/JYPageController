//
//  JYHaveHeaderViewController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/10/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JYPageController
import MJRefresh

class JYHaveHeaderViewController: JYPageController {
    
    var titles = ["Home","New","Music","Near"]
    let headerViewHeight: CGFloat = 300
    let menuViewHeight: CGFloat = 44
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .lightGray
        config.normalTitleFontWeight = .medium
        config.normalTitleFont = 16
        
        config.selectedTitleColor = .black
        config.selectedTitleFontWeight = .medium
        config.selectedTitleFont = 16
        
        config.menuItemMargin = 25
        
        config.indicatorColor = .black
        config.indicatorStyle = .customSizeLine
        config.indicatorWidth = 10
        config.indicatorHeight = 3
        
        config.indicatorBottom = 5
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerViewHeight))
        let imageView = UIImageView(image: UIImage(named: "apple"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 44, width: view.frame.width, height: headerViewHeight - 44*2)
        header.addSubview(imageView)
        headerView = header
        
        scrollView?.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.scrollView?.mj_header?.endRefreshing()
                self.titles = ["Home","New"]
                self.reload()
            }
        })

    }
}


extension JYHaveHeaderViewController {
    
    
    override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        return CGRect.init(x: 20, y: headerViewHeight, width: view.frame.size.width-20, height: menuViewHeight)
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

    override func numberOfChildControllers() -> Int {
        return titles.count
    }
    
    override func childController(atIndex index: Int) -> JYPageChildContollerProtocol {
        if index == 2 {
            return JYViewController()
        }else{
            return JYTableViewController()
        }
    }
    
    
}










