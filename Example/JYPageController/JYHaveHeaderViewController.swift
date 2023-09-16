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
    
    var titles = ["商品","详情","评价"]
    let headerViewHeight: CGFloat = 300
    let menuViewHeight: CGFloat = 44
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        config.normalTitleColor = .black
        config.normalTitleFont = 17
        
        config.selectedTitleColor = .red
        config.selectedTitleFont = 17
        
        config.itemMargin = 44
        config.alignment = .center
        
        config.indicatorColor = .red
        config.indicatorStyle = .equalItemWidthLine
        config.indicatorHeight = 2
        
        //底部的下划线指示器距离底部的大小
        config.indicatorBottom = 5
        
        //下拉刷新位置
        config.headerRefreshLocation = .headerViewTop
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerViewHeight))
        let imageView = UIImageView(image: UIImage(named: "xiaomi"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = header.bounds
        header.backgroundColor = .groupTableViewBackground
        header.addSubview(imageView)
        headerView = header
        
        scrollView?.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.scrollView?.mj_header?.endRefreshing()
                self.config.alignment = .left
                self.config.itemMargin = 20
                self.titles = ["推荐","最新"]
                self.reload()
            }
        })

    }
}


extension JYHaveHeaderViewController {
    
    
    override func pageController(_ pageView: JYPageController, frameForSegmentedView segmentedView: JYSegmentedView) -> CGRect {
        return CGRect.init(x: 19, y: 0, width: view.frame.size.width - 38, height: menuViewHeight)
    }

    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        
        var menuViewY : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            menuViewY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        return CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.height - menuViewHeight - menuViewY)
    }

    override func pageController(_ pageView: JYPageController, titleAt index: Int) -> String {
        return titles[index]
    }

    override func numberOfChildControllers() -> Int {
        return titles.count
    }
    
    override func childController(atIndex index: Int) -> JYPageChildContollerProtocol {
        let vc = JYTableViewController()
        vc.segmentTitle = titles[index]
        return vc
    }
    
    
}










