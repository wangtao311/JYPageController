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
    func childController(atIndex index: Int) -> JYPageChildContollerProtocol
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
    
    ///headerView
    public var headerView: UIView? {
        didSet {
            layoutSubviewsIfHaveHeaderView()
        }
    }
    
    ///scrollView
    public var scrollView: UIScrollView? {
        get {
            if headerView != nil {
                return verScrollView
            }else {
                return nil
            }
        }
    }
    
    ///header view height
    private var headerHeight: CGFloat = 0
    
    ///当前选中的index
    public var selectedIndex: Int = 0
    
    ///delegate
    weak public var delegate: JYPageControllerDelegate?
    
    ///dataSource
    weak public var dataSource: JYPageControllerDataSource?
    
    ///childViewController cache
    private var childControllerCache: NSCache = NSCache<NSString, UIViewController>()
    
    ///缓存当前scrollView上展示的vc，用于处理子vc的生命周期逻辑
    private var displayControllerCache = Dictionary<NSString, UIViewController>()
    
    ///childController scrollView cache
    private var childScrollViewCache: Dictionary = Dictionary<NSString, UIScrollView>()
    
    ///menuview frame
    private var menuViewFrame: CGRect = .zero
    
    ///滚动区域container(scrollView)的frame
    private var childControllerViewFrame: CGRect = .zero
    
    ///标记scorllView滚动是否由拖拽触发
    private var scrollByDragging = false
    
    ///当前的偏移量，用来判断向左还是向右滑动
    private var currentOffsetX: CGFloat = 0
    
    ///有headerView的场景，记录menuView是都在顶部悬停
    private var scrollToTop: Bool = false
    
    ///竖直方向滚动的scrollView，contentOffsetY
    private var verScrollViewContentOffsetY: CGFloat = 0
    
    deinit {
        childScrollViewCache.forEach { (key: NSString, value: UIScrollView) in
            value.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        delegate = self
        dataSource = self
        /**
         子类重写init方法，设置pageConfig,menuConfig的属性
         eg.
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
        menuView.select(selectedIndex)
    }
    
    
    //MARK: - Public
    ///刷新方法，动态改变数据源的时候调用，其他场景不需要主动调用
    public func reload() {
        for i in 0 ..< childControllersCount {
            let cacheKey = String(i) as NSString
            if let childController = childControllerCache.object(forKey: cacheKey) {
                childController.view.removeFromSuperview()
                childController.willMove(toParentViewController: nil)
                childController.removeFromParentViewController()
            }
        }
        verScrollView.removeFromSuperview()
        
        childControllersCount = dataSource?.numberOfChildControllers() ?? 0
        childControllerCache.removeAllObjects()
        displayControllerCache.removeAll()
        
        menuView.reload()
        menuView.select(selectedIndex)
        
        pageView_setup()
        horScrollView.setContentOffset(CGPoint(x: CGFloat(selectedIndex) * childControllerViewFrame.width, y: 0), animated: false)
        layoutSubviewsIfHaveHeaderView()
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
        childControllerViewFrame = source.pageController(self, frameForContainerView: horScrollView)
        
        var verScrollViewY : CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            verScrollViewY = navBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        }
        
        menuView.frame = menuViewFrame
        horScrollView.frame = childControllerViewFrame
        verScrollView.frame = CGRect(x: menuViewFrame.origin.x, y: verScrollViewY, width: menuViewFrame.width, height: childControllerViewFrame.origin.y + childControllerViewFrame.height)
        verScrollView.contentSize = CGSize(width: childControllerViewFrame.width, height: verScrollView.frame.height)
        
        let contentSize = CGSize(width: CGFloat(childControllersCount)*childControllerViewFrame.width, height: childControllerViewFrame.height)
        horScrollView.contentSize = contentSize
        
        if config.menuViewShowInNavigationBar {
            view.addSubview(horScrollView)
            navigationItem.titleView = menuView
        }else {
            view.addSubview(verScrollView)
            verScrollView.addSubview(menuView)
            verScrollView.addSubview(horScrollView)
        }
    }
    
    //有headerView的场景重新布局
    private func layoutSubviewsIfHaveHeaderView() {
        if let header = headerView {
            headerHeight = header.frame.size.height
            verScrollView.addSubview(header)
            
            menuView.frame = CGRect(x: menuView.frame.origin.x, y: menuView.frame.origin.y, width: menuView.frame.size.width, height: menuView.frame.size.height)
            
            horScrollView.frame = CGRect(x: childControllerViewFrame.origin.x, y: menuView.frame.origin.y + menuView.frame.height, width: childControllerViewFrame.size.width, height: childControllerViewFrame.size.height)
            let contentSize = CGSize(width: CGFloat(childControllersCount)*childControllerViewFrame.size.width, height: horScrollView.frame.size.height)
            horScrollView.contentSize = contentSize
            
            verScrollView.contentSize = CGSize(width: verScrollView.frame.width, height: verScrollView.contentSize.height + headerHeight)
        }
    }
    
    ///添加指定index的controller
    private func addChildController(index: Int) {
        
        var childController = UIViewController()
        let cacheKey = String(index) as NSString
        if let controlller = childControllerCache.object(forKey: cacheKey) {
            childController = controlller
        }else {
            if let controlller = dataSource?.childController(atIndex: index) {
                if let childScrollView = controlller.fetchChildControllScrollView?(),childScrollView.isKind(of: UIScrollView.classForCoder()) {
                    childScrollView.addObserver(self, forKeyPath: "contentOffset", options: [.old,.new], context: nil)
                    childScrollViewCache[cacheKey] = childScrollView
                }
                childControllerCache.setObject(controlller, forKey: cacheKey)
                delegate?.pageController?(self, didLoadChildController: controlller, index: index)
                childController = controlller
            }
        }
        
        if displayControllerCache[cacheKey] == nil {
            addChildViewController(childController)
        }
        
        childController.view.frame = CGRect(x: CGFloat(index)*childControllerViewFrame.size.width, y: 0, width: childControllerViewFrame.size.width, height: childControllerViewFrame.size.height)
        childController.didMove(toParentViewController: self)
        horScrollView.addSubview(childController.view)
        displayControllerCache[cacheKey] = childController
    }
    
    private func loadChildControllerIfNeeded() {
        
        let offsetX = horScrollView.contentOffset.x
        if offsetX < 0 || offsetX > horScrollView.contentSize.width {
            return
        }
        guard offsetX.truncatingRemainder(dividingBy: childControllerViewFrame.size.width) == 0 else {
            var targetIndex = 0
            if offsetX > currentOffsetX {
                targetIndex = Int(offsetX/childControllerViewFrame.size.width) + 1
            }else {
                targetIndex = Int(offsetX/childControllerViewFrame.size.width)
            }
            let cacheKey = String(targetIndex) as NSString
            let controller = displayControllerCache[cacheKey]
            if targetIndex < childControllersCount, controller == nil {
                addChildController(index: targetIndex)
            }
            return
        }
    }
    
    private func removeChildControllerIfNeeded() {
        for i in 0 ..< childControllersCount {
            let cacheKey = String(i) as NSString
            if let childController = displayControllerCache[cacheKey], childControllerIsInScreen(childController) == false {
                childController.view.removeFromSuperview()
                childController.willMove(toParentViewController: nil)
                childController.removeFromParentViewController()
                displayControllerCache.removeValue(forKey: cacheKey)
            }
        }
    }
    
    private func childControllerIsInScreen(_ childController: UIViewController) -> Bool {
        let offsetX = horScrollView.contentOffset.x
        let screenWidth = horScrollView.frame.width
        let childViewMaxX = childController.view.frame.maxX
        let childViewMinX = childController.view.frame.minX

        if childViewMaxX > offsetX, childViewMinX - offsetX < screenWidth {
            return true
        }else{
            return false
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let cacheKey = String(selectedIndex) as NSString
        if keyPath == "contentOffset", headerHeight > 0, let scrollView = childScrollViewCache[cacheKey], scrollView.isKind(of: UIScrollView.classForCoder()) {
            if let newContentOffset = change?[NSKeyValueChangeKey.newKey] as? CGPoint, newContentOffset.y > 0 {
                if verScrollView.contentOffset.y < headerHeight, scrollToTop == false {
                    scrollView.setContentOffset(.zero, animated: false)
                }
            }else{
                scrollView.setContentOffset(.zero, animated: false)
            }
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
    
    private lazy var horScrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    private lazy var verScrollView : JYScrollView = {
        let scrollView = JYScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
}

//MARK: - UIScrollViewDelegate
extension JYPageController:UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == horScrollView {
            currentOffsetX = scrollView.contentOffset.x
            scrollByDragging = true
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == horScrollView {
            selectedIndex = Int(scrollView.contentOffset.x/scrollView.frame.width)
            menuView.menuViewScrollEnd(byScrollEndDecelerating: scrollView)
            delegate?.pageController?(self, didSelectControllerAt: selectedIndex)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == horScrollView {
            removeChildControllerIfNeeded()
            if scrollByDragging {
                loadChildControllerIfNeeded()
                menuView.menuViewScroll(by:scrollView)
                currentOffsetX = scrollView.contentOffset.x
            }
        }
        
        if scrollView == verScrollView, headerView != nil {
            let cacheKey = String(selectedIndex) as NSString
            if let childVCScrollView = childScrollViewCache[cacheKey], childVCScrollView.isKind(of: UIScrollView.classForCoder()), childVCScrollView.contentOffset.y > 0 {
                scrollView.setContentOffset(CGPoint(x: 0, y: headerHeight), animated: false)
            }
            
            if scrollView.contentOffset.y >= headerHeight {
                scrollToTop = true
                scrollView.setContentOffset(CGPoint(x: 0, y: headerHeight), animated: false)
            }else{
                scrollToTop = false
            }
            
            //子页面左右滚动的时候不让上下滚动
            if horScrollView.contentOffset.x.truncatingRemainder(dividingBy: childControllerViewFrame.size.width) > 0, verScrollView.contentOffset.y != verScrollViewContentOffsetY {
                verScrollView.setContentOffset(CGPoint(x: 0, y: verScrollViewContentOffsetY), animated: false)
            }
            verScrollViewContentOffsetY = verScrollView.contentOffset.y
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

    open func childController(atIndex index: Int) -> JYPageChildContollerProtocol {
        return JYPlaceHolderController()
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
        let controller = displayControllerCache[cacheKey]
        if index < childControllersCount {
            if controller == nil {
                addChildController(index: index)
            }
            selectedIndex = index
            let contentOffsetX = CGFloat(index)*childControllerViewFrame.size.width
            horScrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: config.scrollViewAnimationWhenMenuItemSelected)
            delegate?.pageController?(self, didSelectControllerAt: index)
        }
    }
}




