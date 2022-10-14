//
//  JYPageController.swift
//  JYPageController
//
//  Created by wang tao on 2022/7/14.
//

import UIKit


@objc public protocol JYPageControllerDataSource {
    
    ///menuview frame
    func pageController(_ pageController: JYPageController, frameForMenuView menu: JYPageMenuView) -> CGRect
    
    ///menuview下滚动区域frame
    func pageController(_ pageController: JYPageController, frameForContainerView container: UIScrollView) -> CGRect
    
    ///第index位置上item的title
    func pageController(_ pageController: JYPageController, titleAt index: Int) -> String
    
    ///第index位置上自定义item
    @objc optional func pageController(_ pageController: JYPageController, customViewAt index: Int) -> UIView?
    
    ///第index位置上item右上角的badgeView(eg. 标签/小红点，必须设置frame.size)
    @objc optional func pageController(_ pageController: JYPageController, badgeViewAt index: Int) -> UIView?
    
    ///子页面数量
    func numberOfChildControllers() -> Int
    
    ///返回第index位置上的UIViewController
    func childController(atIndex index: Int) -> UIViewController
}

@objc public protocol JYPageControllerDelegate {
    
    ///第一次加载childController调用
    @objc optional func pageController(_ pageController: JYPageController, didLoadChildController: UIViewController, index: Int)
    
    ///scrollView停止滚动，childController完全显示调用
    @objc optional func pageController(_ pageController: JYPageController, didSelectControllerAt index: Int)
    
}


open class JYPageController: UIViewController {
    
    ///config
    public var config: JYPageConfig = JYPageConfig.init()
    
    ///当前选中的index
    public var selectedIndex: Int = 0
    
    ///delegate
    weak public var delegate: JYPageControllerDelegate?
    
    ///dataSource
    weak public var dataSource: JYPageControllerDataSource?
    
    ///childView cache
    private var memoryCache: NSCache = NSCache<NSString, UIViewController>()
    
    ///缓存当前scrollView上展示的vc，用于处理子vc的生命周期逻辑
    private var displayControllers = Dictionary<NSString, UIViewController>()
    
    ///menuview frame
    private var menuViewFrame: CGRect = .zero
    
    ///滚动区域container(scrollView)的frame
    private var containerViewFrame: CGRect = .zero
    
    ///标记scorllView滚动是否由拖拽触发
    private var scrollByDragging = false
    
    ///当前的偏移量，用来判断向左还是向右滑动
    private var currentOffsetX: CGFloat = 0
    
    

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        delegate = self
        dataSource = self
        /**
         子类重写init方法，设置pageConfig,menuConfig的属性
         eg.
         config.bounces = true
         config.showIndicatorLineView = false
         config.selectedTitleColor = .red
         config.normalTitleColor = .red
         config.selectedTitleFont = .systemFont(ofSize: 18, weight: .medium)
         config.normalTitleFont = .systemFont(ofSize: 18, weight: .medium)
         config.menuItemMargin = 10
         */
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pageView_setup()
        
        menuView.frame = menuViewFrame
        scrollView.frame = containerViewFrame
        
        if config.menuViewShowInNavigationBar {
            view.addSubview(scrollView)
            navigationItem.titleView = menuView
        }else {
            view.addSubview(scrollView)
            view.addSubview(menuView)
        }
        
        menuView_setDefaultIndex()
    }
    
    
    //MARK: - Public
    
    ///刷新方法，动态改变数据源的时候调用，其他场景不需要主动调用
    public func reload() {
        for i in 0 ..< childControllersCount {
            let cacheKey = String(i) as NSString
            if let childController = memoryCache.object(forKey: cacheKey) {
                childController.view.removeFromSuperview()
                childController.willMove(toParentViewController: nil)
                childController.removeFromParentViewController()
            }
        }
        
        childControllersCount = dataSource?.numberOfChildControllers() ?? 0
        memoryCache.removeAllObjects()
        displayControllers.removeAll()
        
        menuView.reload()
        menuView.select(selectedIndex)
        
        pageView_setup()
        scrollView.setContentOffset(CGPoint(x: CGFloat(selectedIndex) * containerViewFrame.width, y: 0), animated: false)
        
    }
    
    ///获取menuview中scrollview的contentsize
    public func contentSizeForMenuView() -> CGSize {
        return menuView.contentSize()
    }
    
    ///更新menuview的frame
    public func updateMenuViewFrame(frame: CGRect) {
        menuViewFrame = frame
        menuView.updateFrame(frame: frame)
    }
    
    ///添加指定index的menuItem的badgeView
    public func insertMenuItemBadgeView(_ badgeView: UIView, atIndex index: Int) {
        menuView.insertMenuItemBadgeView(badgeView, atIndex: index)
    }
    
    ///移除指定index的menuItem的badgeView
    public func removeMenuItemBadgeView(atIndex index: Int) {
        menuView.removeMenuItemBadgeView(atIndex: index)
    }
    
    //MARK: - Private
    private func pageView_setup() {
        guard let source = dataSource else {
            return
        }
        menuViewFrame = source.pageController(self, frameForMenuView: menuView)
        containerViewFrame = source.pageController(self, frameForContainerView: scrollView)
        
        let contentSize = CGSize(width: CGFloat(childControllersCount)*containerViewFrame.size.width, height: containerViewFrame.size.height)
        scrollView.contentSize = contentSize
    }
    
    private func menuView_setDefaultIndex() {
        menuView.select(selectedIndex)
    }
    
    ///添加指定index的controller
    private func addChildController(index: Int) {
        
        var childController = UIViewController()
        let cacheKey = String(index) as NSString
        if let controlller = memoryCache.object(forKey: cacheKey) {
            childController = controlller
        }else {
            if let controlller = dataSource?.childController(atIndex: index) {
                memoryCache.setObject(controlller, forKey: cacheKey)
                delegate?.pageController?(self, didLoadChildController: controlller, index: index)
                childController = controlller
            }
        }
        
        if displayControllers[cacheKey] == nil {
            addChildViewController(childController)
        }
        
        childController.view.frame = CGRect(x: CGFloat(index)*containerViewFrame.size.width, y: 0, width: containerViewFrame.size.width, height: containerViewFrame.size.height)
        childController.didMove(toParentViewController: self)
        scrollView.addSubview(childController.view)
        displayControllers[cacheKey] = childController
    }
    
    private func loadChildControllerIfNeeded() {
        
        let offsetX = scrollView.contentOffset.x
        if offsetX < 0 || offsetX > scrollView.contentSize.width {
            return
        }
        guard offsetX.truncatingRemainder(dividingBy: containerViewFrame.size.width) == 0 else {
            var targetIndex = 0
            if offsetX > currentOffsetX {
                targetIndex = Int(offsetX/containerViewFrame.size.width) + 1
            }else {
                targetIndex = Int(offsetX/containerViewFrame.size.width)
            }
            let cacheKey = String(targetIndex) as NSString
            let controller = displayControllers[cacheKey]
            if targetIndex < childControllersCount, controller == nil {
                addChildController(index: targetIndex)
            }
            return
        }
    }
    
    private func removeChildControllerIfNeeded() {
        for i in 0 ..< childControllersCount {
            let cacheKey = String(i) as NSString
            if let childController = displayControllers[cacheKey], childControllerIsInScreen(childController) == false {
                childController.view.removeFromSuperview()
                childController.willMove(toParentViewController: nil)
                childController.removeFromParentViewController()
                displayControllers.removeValue(forKey: cacheKey)
            }
        }
    }
    
    private func childControllerIsInScreen(_ childController: UIViewController) -> Bool {
        let offsetX = scrollView.contentOffset.x
        let screenWidth = scrollView.frame.width
        let childViewMaxX = childController.view.frame.maxX
        let childViewMinX = childController.view.frame.minX

        if childViewMaxX > offsetX, childViewMinX - offsetX < screenWidth {
            return true
        }else{
            return false
        }
    }
    
    //MARK: - Lazy
    private lazy var childControllersCount: Int = {
        return dataSource?.numberOfChildControllers() ?? 0
    }()
    
    private lazy var menuView: JYPageMenuView = {
        let menuView = JYPageMenuView.init(pageConfig: config)
        menuView.dataSource = self
        menuView.delegate = self
        return menuView
    }()
    
    public lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
}

//MARK: - UIScrollViewDelegate
extension JYPageController:UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentOffsetX = scrollView.contentOffset.x
        scrollByDragging = true
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectedIndex = Int(scrollView.contentOffset.x/scrollView.frame.width)
        menuView.menuViewScrollEnd(byScrollEndDecelerating: scrollView)
        delegate?.pageController?(self, didSelectControllerAt: selectedIndex)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        removeChildControllerIfNeeded()
        if scrollByDragging {
            loadChildControllerIfNeeded()
            menuView.menuViewScroll(by:scrollView)
            currentOffsetX = scrollView.contentOffset.x
        }
    }
}



//MARK: - JYPageControllerDelegate, JYPageControllerDataSource
extension JYPageController: JYPageControllerDelegate, JYPageControllerDataSource {
    
    open func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        return .zero
    }

    open func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        return .zero
    }

    open func pageController(_ pageView: JYPageController, titleAt index: Int) -> String {
        return ""
    }
    
    open func pageController(_ pageController: JYPageController, customViewAt index: Int) -> UIView? {
        return nil
    }
    
    open func pageController(_ pageView: JYPageController, badgeViewAt index: Int) -> UIView? {
        return nil
    }

    open func numberOfChildControllers() -> Int {
        return 0
    }

    open func childController(atIndex index: Int) -> UIViewController {
        return UIViewController.init()
    }
    
    open func pageController(_ pageController: JYPageController, didLoadChildController: UIViewController, index: Int) {
    }
    
    open func pageController(_ pageController: JYPageController, didSelectControllerAt index: Int) {
    }
}


//MARK: - JYPageMenuViewDelegate,JYPageMenuViewDataSource
extension JYPageController: JYPageMenuViewDelegate, JYPageMenuViewDataSource {
    public func numberOfMenuItems() -> Int {
        return childControllersCount
    }
    
    public func menuView(_ menuView: JYPageMenuView, titleAt index: Int) -> String {
        guard let source = dataSource else {
            return ""
        }
        return source.pageController(self, titleAt: index)
    }
    
    public func menuView(_ menuView: JYPageMenuView, customViewAt index: Int) -> UIView? {
        guard let source = dataSource else {
            return nil
        }
        return source.pageController?(self, customViewAt: index)
    }
    
    public func menuView(_ menuView: JYPageMenuView, badgeViewAt index: Int) -> UIView? {
        guard let source = dataSource else {
            return nil
        }
        return source.pageController?(self, badgeViewAt: index)
    }
    
    public func menuView(_ menuView: JYPageMenuView, didSelectItemAt index: Int) {
        scrollByDragging = false
        let cacheKey = String(index) as NSString
        let controller = displayControllers[cacheKey]
        if index < childControllersCount {
            if controller == nil {
                addChildController(index: index)
            }
            selectedIndex = index
            let contentOffsetX = CGFloat(index)*containerViewFrame.size.width
            scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: config.scrollViewAnimationWhenMenuItemSelected)
            delegate?.pageController?(self, didSelectControllerAt: index)
        }
    }
}




