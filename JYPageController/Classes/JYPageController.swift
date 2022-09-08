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
    var memoryCache: NSCache = NSCache<NSString, UIViewController>()
    
    ///menuview frame
    private var menuViewFrame: CGRect = .zero
    
    ///滚动区域container(scrollView)的frame
    private var containerViewFrame: CGRect = .zero
    
    ///标记scorllView滚动是否由拖拽触发
    private var scrollByDragging = false
    

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        delegate = self
        dataSource = self
        /**
         子类重写init方法，设置pageConfig,menuConfig的属性
         eg.
         pageConfig.bounces = true
         menuConfig.showIndicatorLineView = false
         menuConfig.selectedTitleColor = .red
         menuConfig.normalTitleColor = .red
         menuConfig.selectedTitleFont = .systemFont(ofSize: 18, weight: .medium)
         menuConfig.normalTitleFont = .systemFont(ofSize: 18, weight: .medium)
         menuConfig.menuItemMargin = 10
         */
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        edgesForExtendedLayout = []
        
        view.addSubview(scrollView)
        view.addSubview(menuView)
        pageView_setup()
        pageView_setContentSize()
        menuView_setDefaultIndex()
        pageView_setDefaultIndex()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuView.frame = menuViewFrame
        scrollView.frame = containerViewFrame
    }
    
    
    //MARK: - Public
    
    ///刷新方法，动态改变数据源的时候调用，其他场景不需要主动调用
    public func reload() {
        for i in 0 ..< childControllersCount {
            let cacheKey = String(i) as NSString
            if let childController = memoryCache.object(forKey: cacheKey) {
                childController.view.removeFromSuperview()
            }
        }
        
        childControllersCount = dataSource?.numberOfChildControllers() ?? 0
        memoryCache.removeAllObjects()
        
        menuView.reload()
        menuView.select(selectedIndex)
        
        pageView_setup()
        pageView_setContentSize()
        scrollView.setContentOffset(CGPoint(x: CGFloat(selectedIndex) * containerViewFrame.width, y: 0), animated: false)
        loadChildViewIfNeeded()
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
    
    ///更新指定index的menuItem的badgeView，传nil会把badgeView置空
    public func updateMenuBadgeView(_ badgeView: UIView?, atIndex index: Int) {
        menuView.updateMenuitemBadgeView(badgeView, atIndex: index)
    }
    
    //MARK: - Private
    private func pageView_setup() {
        guard let source = dataSource else {
            return
        }
        menuViewFrame = source.pageController(self, frameForMenuView: menuView)
        containerViewFrame = source.pageController(self, frameForContainerView: scrollView)
    }
    
    private func menuView_setDefaultIndex() {
        menuView.select(selectedIndex)
    }
    
    private func pageView_setDefaultIndex() {
        if selectedIndex < childControllersCount {
            let initializedController = loadChildController(selectedIndex)
            addChildView(selectedIndex, childView: initializedController.view)
            let contentOffsetX = CGFloat(selectedIndex)*containerViewFrame.size.width
            scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: false)
        }
    }
    
    ///计算scrollView的contentsize
    private func pageView_setContentSize() {
        let contentSize = CGSize(width: CGFloat(childControllersCount)*containerViewFrame.size.width, height: containerViewFrame.size.height)
        scrollView.contentSize = contentSize
    }
    
    ///加载指定index的controller
    private func loadChildController(_ index: Int) -> UIViewController {
        let cacheKey = String(index) as NSString
        if let controlller = memoryCache.object(forKey: cacheKey) {
            return controlller
        }
        
        if let controlller = dataSource?.childController(atIndex: index) {
            memoryCache.setObject(controlller, forKey: cacheKey)
            delegate?.pageController?(self, didLoadChildController: controlller, index: index)
            return controlller
        }
        return UIViewController.init()
    }
    
    ///添加指定index的view到scrollView上
    private func addChildView(_ index: Int, childView: UIView) {
        scrollView.addSubview(childView)
        childView.frame = CGRect(x: CGFloat(index)*containerViewFrame.size.width, y: 0, width: containerViewFrame.size.width, height: containerViewFrame.size.height)
    }
    
    //MARK: - Lazy
    private lazy var childControllersCount: Int = {
        return dataSource?.numberOfChildControllers() ?? 0
    }()
    
    private lazy var menuView: JYPageMenuView = {
        let menuView = JYPageMenuView.init(pageConfig: config)
        menuView.backgroundColor = .white
        menuView.dataSource = self
        menuView.delegate = self
        return menuView
    }()
    
    private lazy var scrollView : UIScrollView = {
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
        scrollByDragging = true
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectedIndex = Int(scrollView.contentOffset.x/scrollView.frame.width)
        menuView.menuViewScrollEnd(byScrollEndDecelerating: scrollView)
        delegate?.pageController?(self, didSelectControllerAt: selectedIndex)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollByDragging {
            loadChildViewIfNeeded()
            menuView.menuViewScroll(by:scrollView)
        }
    }
    
    func loadChildViewIfNeeded() {
        let offsetX = scrollView.contentOffset.x
        let targetIndex = Int(offsetX/containerViewFrame.size.width)>0 ? Int(offsetX/containerViewFrame.size.width)+1 : 0
        let cacheKey = String(targetIndex) as NSString
        let view = memoryCache.object(forKey: cacheKey)
        if targetIndex < childControllersCount, view == nil {
            let targetChildController = loadChildController(targetIndex)
            addChildView(targetIndex, childView: targetChildController.view)
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
    
    public func menuView(_ menuView: JYPageMenuView, badgeViewAt index: Int) -> UIView? {
        guard let source = dataSource else {
            return nil
        }
        return source.pageController?(self, badgeViewAt: index)
    }
    
    public func menuView(_ menuView: JYPageMenuView, didSelectItemAt index: Int) {
        scrollByDragging = false
        let cacheKey = String(index) as NSString
        let view = memoryCache.object(forKey: cacheKey)
        if index < childControllersCount {
            if view == nil {
                let targetChildController = loadChildController(index)
                addChildView(index, childView: targetChildController.view)
            }
            selectedIndex = index
            let contentOffsetX = CGFloat(index)*containerViewFrame.size.width
            scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: config.scrollViewAnimationWhenMenuItemSelected)
            delegate?.pageController?(self, didSelectControllerAt: index)
        }
    }
}




