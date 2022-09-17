//
//  JYPageMenuView.swift
//  JYPageController
//
//  Created by wang tao on 2022/7/14.
//

import UIKit

@objc public protocol JYPageMenuViewDataSource {
    
    ///item number
    func numberOfMenuItems() -> Int
    
    ///item title
    func menuView(_ menuView: JYPageMenuView, titleAt index: Int) -> String
    
    ///自定义item,实现该方法并返回UIView后优先展示customView，title被忽略。customView需要设置frame
//    @objc optional func menuView(_ menuView: JYPageMenuView, customViewAt index: Int) -> UIView?
    
    ///item上的badgeView (eg. 标签/小红点/icon, 必须设置frame.size)
    @objc optional func menuView(_ menuView: JYPageMenuView, badgeViewAt index: Int) -> UIView?
    
}

@objc public protocol JYPageMenuViewDelegate {
    
    @objc optional func menuView(_ menuView: JYPageMenuView, didSelectItemAt index: Int)
}




public class JYPageMenuView: UIView {
    
    ///config
    var config: JYPageConfig = JYPageConfig()
    
    ///代理
    weak public var delegate: JYPageMenuViewDelegate?
    
    ///数据源
    weak public var dataSource: JYPageMenuViewDataSource? {
        didSet {
            getItemsCount()
        }
    }
    
    ///当前选中的index
    private var selectedIndex: Int = 0
    
    ///item数量
    private var itemsCount: Int = 0
    
    ///items数组
    private var items = [JYPageMenuItem]()
    
    ///第一次初始化和reload的时候用来标记，layoutSubview中layoutItems方法只调用一次。原因：在对默认选中的item多次设置transform的时，tranform有值，但获取到的frame却没有变
    var layoutOnceToken: Bool = false
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentView)
        contentView.addSubview(indicatorLineView)
    }
    
    public convenience init(pageConfig: JYPageConfig) {
        self.init()
        
        config = pageConfig
        contentView.bounces = config.bounces
        if config.showIndicator {
            indicatorLineView.backgroundColor = config.indicatorLineViewColor
            indicatorLineView.layer.cornerRadius = config.indicatorLineViewCornerRadius
        }else{
            indicatorLineView.removeFromSuperview()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            reload()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = self.bounds
        layoutItems()
        indicatorLineViewMoveTo(selectedIndex, animate: false)
        resetHorContentOffset(animate: false)
    }
    
    private func getItemsCount() {
        guard let source = dataSource else {
            return
        }
        itemsCount = source.numberOfMenuItems()
    }
    
    //MARK: - Public
    
    ///单独使用menuview，动态改变数据源的时候调用(数据源改变之后先reload，如需要设置默认index，再调select)。其他场景不需要主动调用
    public func reload() {
        guard let source = dataSource, source.numberOfMenuItems() > 0 else {
            return
        }
        
        getItemsCount()
        addMenuItems()
        layoutOnceToken = false
        layoutItems()
        
        contentView.bringSubview(toFront: indicatorLineView)
        resetHorContentOffset(animate: false)
        indicatorLineViewMoveTo(selectedIndex, animate: false)
    }
    
    ///获取当前选中的index
    public func currentSelectedIndex() -> Int {
        return selectedIndex
    }
    
    ///获取menuview的contentsize
    public func contentSize() -> CGSize {
        return contentView.contentSize
    }
    
    ///更新/设置menuview的frame
    public func updateFrame(frame: CGRect) {
        self.frame = frame
        layoutIfNeeded()
        resetHorContentOffset(animate: false)
    }
    
    ///更新指定index的menuItem的badgeView，传nil把badgeView置空
    public func updateMenuitemBadgeView(_ badgeView: UIView?, atIndex index: Int) {
        guard let menuItem = itemWithIndex(index) else {
           return
        }

        if let badge = badgeView {
            if menuItem.hasBadgeView {
                menuItem.badgeView?.removeFromSuperview()
            }
            menuItem.badgeView = badge
            contentView.addSubview(badge)
            updateItemsFrame()
        }else{
            if menuItem.hasBadgeView {
                menuItem.badgeView?.removeFromSuperview()
                menuItem.badgeView = nil
                updateItemsFrame()
            }
        }
        indicatorLineViewMoveTo(selectedIndex, animate: false)
    }
    
    ///页面滚动过程中，持续调用
    public func menuViewScroll(by pageView: UIScrollView) {
        changeItemsByScrollViewDidScroll(scrollView: pageView)
        updateItemsFrame()
    }
    
    ///页面滚动停止，scrollVIew代理方法scrollEndDecelerating中调用
    public func menuViewScrollEnd(byScrollEndDecelerating pageView: UIScrollView) {
        
        let offsetX = pageView.contentOffset.x
        let currentIndex = Int(offsetX/pageView.frame.width)
        selectedIndex = currentIndex
        itemWithIndex(selectedIndex)?.selected = true
        itemWithIndex(selectedIndex)?.font = UIFont.systemFont(ofSize: config.normalTitleFont, weight: config.selectedTitleFontWeight)
        for item in items {
            if (item.tag - kMenuItemTagExtenValue) != selectedIndex {
                item.selected = false
                item.font = UIFont.systemFont(ofSize: config.normalTitleFont, weight: config.normalTitleFontWeight)
            }
        }
        
        resetHorContentOffset(animate: true)
        indicatorLineViewMoveTo(selectedIndex, animate: true)
    }
    
    ///设置选中index
    public func select(_ index: Int) {
        if index < itemsCount {
            itemWithIndex(index)?.selected = true
            selectedIndex = index
            reload()
            delegate?.menuView?(self, didSelectItemAt: selectedIndex)
        }
    }
    
    //MARK: - Private
    ///滚动过程中item的渐变效果
    private func changeItemsByScrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.frame.size.width <= 0 {
            return
        }
        
        let offsetX = scrollView.contentOffset.x
        let rate = offsetX.truncatingRemainder(dividingBy: scrollView.frame.size.width)/scrollView.frame.size.width
        
        if rate <= 0 {
            return
        }
         
        var selectedItem = itemWithIndex(selectedIndex)
        var targetItem: JYPageMenuItem?
        
        if offsetX > CGFloat(selectedIndex) * scrollView.frame.size.width {
            
            let targetIndex =  Int(offsetX/scrollView.frame.size.width) + 1
            targetItem = itemWithIndex(targetIndex)
            
            //备注:处理手指连续快速向左滑动时候，selectedIndex没有及时改变造成计算fromItem和toItem错乱问题
            if selectedIndex !=  Int(offsetX/scrollView.frame.size.width) {
                itemWithIndex(selectedIndex)?.transform = .identity
                if let item = targetItem {
                    item.transform = CGAffineTransform(scaleX:maxScale, y: maxScale)
                }
                selectedIndex = Int(offsetX/scrollView.frame.size.width)
                selectedItem = itemWithIndex(selectedIndex)
                resetHorContentOffset(animate: true)
                updateItemColor()
            }
        }else{
            
            let targetIndex =  Int(offsetX/scrollView.frame.size.width)
            targetItem = itemWithIndex(targetIndex)
            
            //备注:处理手指连续快速向右滑动时候，selectedIndex没有及时改变造成计算fromItem和toItem错乱问题
            if selectedIndex != Int(offsetX/scrollView.frame.size.width) + 1 {
                itemWithIndex(selectedIndex)?.transform = .identity
                if let item = targetItem {
                    item.transform = CGAffineTransform(scaleX:maxScale , y: maxScale)
                }
                selectedIndex = Int(offsetX/scrollView.frame.size.width) + 1
                selectedItem = itemWithIndex(selectedIndex)
                resetHorContentOffset(animate: true)
                updateItemColor()
            }
        }
        
        guard let toItem = targetItem, let fromItem = selectedItem  else {
            return
        }

        if fromItem.tag < toItem.tag {
            fromItem.rate = 1 - rate
            toItem.rate = rate
            let fromItemCurrentScaleX = maxScale - (maxScale - 1) * rate
            let fromItemCurrentScaleY = maxScale - (maxScale - 1) * rate
            let toItemCurrentScaleX = 1 + (maxScale - 1) * rate
            let toItemCurrentScaleY = 1 + (maxScale - 1) * rate

            fromItem.transform = CGAffineTransform(scaleX: fromItemCurrentScaleX, y: fromItemCurrentScaleY)
            toItem.transform = CGAffineTransform(scaleX: toItemCurrentScaleX, y: toItemCurrentScaleY)
        }else {
            fromItem.rate = rate
            toItem.rate = 1 - rate
            let fromItemCurrentScaleX = maxScale - (maxScale - 1) * (1 - rate)
            let fromItemCurrentScaleY = maxScale - (maxScale - 1) * (1 - rate)
            let toItemCurrentScaleX = 1 + (maxScale - 1) * (1 - rate)
            let toItemCurrentScaleY = 1 + (maxScale - 1) * (1 - rate)

            fromItem.transform = CGAffineTransform(scaleX: fromItemCurrentScaleX, y: fromItemCurrentScaleY)
            toItem.transform = CGAffineTransform(scaleX: toItemCurrentScaleX, y: toItemCurrentScaleY)
        }
        
        if config.showIndicator {
            indicatorLineViewMove(fromItem: fromItem, toItem: toItem, offsetX: offsetX, rate: rate, pageView: scrollView)
        }
    }
    
    private func updateItemColor() {
        items.forEach { item in
            if item.tag == selectedIndex + kMenuItemTagExtenValue {
                item.selected = true
            }else{
                item.selected = false
            }
        }
    }
     
    private func indicatorLineViewMove(fromItem: JYPageMenuItem, toItem: JYPageMenuItem, offsetX: CGFloat, rate: CGFloat, pageView: UIScrollView) {
        
        if fromItem.tag < toItem.tag {
            
            let scrollViewWidth = pageView.frame.width
            var currentIndicatorViewWidth: CGFloat = 0
            let indicatorLineViewMaxWidth = toItem.center.x -  fromItem.center.x
            let tempOffetX = offsetX.truncatingRemainder(dividingBy: scrollViewWidth)
            
            if tempOffetX <= scrollViewWidth/2 {
                let percent_min_max = tempOffetX/scrollViewWidth*2
                currentIndicatorViewWidth = config.indicatorLineViewSize.width + percent_min_max * (indicatorLineViewMaxWidth - config.indicatorLineViewSize.width)
            }else{
                let percent_max_min = (tempOffetX - scrollViewWidth/2)/scrollViewWidth*2
                currentIndicatorViewWidth = config.indicatorLineViewSize.width + (1 - percent_max_min)*(indicatorLineViewMaxWidth - config.indicatorLineViewSize.width)
            }
            
            indicatorLineView.center = CGPoint(x: fromItem.center.x + rate * indicatorLineViewMaxWidth, y: indicatorLineView.center.y)
            var frame = indicatorLineView.frame
            frame.size.width = currentIndicatorViewWidth
            frame.size.height = indicatorLineView.frame.size.height
            indicatorLineView.frame = frame
        }else{
            
            let scrollViewWidth = pageView.frame.width
            var currentIndicatorViewWidth: CGFloat = 0
            let indicatorLineViewMaxWidth = fromItem.center.x - toItem.center.x
            let tempOffetX = offsetX.truncatingRemainder(dividingBy: scrollViewWidth)
            
            if tempOffetX <= scrollViewWidth/2 {
                let percent_min_max = tempOffetX/scrollViewWidth*2
                currentIndicatorViewWidth = config.indicatorLineViewSize.width + percent_min_max * (indicatorLineViewMaxWidth - config.indicatorLineViewSize.width)
            }else{
                let percent_max_min = (tempOffetX - scrollViewWidth/2)/scrollViewWidth*2
                currentIndicatorViewWidth = config.indicatorLineViewSize.width + (1 - percent_max_min)*(indicatorLineViewMaxWidth - config.indicatorLineViewSize.width)
            }
            
            indicatorLineView.center = CGPoint(x: fromItem.center.x -  (1 - rate) * indicatorLineViewMaxWidth, y: indicatorLineView.center.y)
            var frame = indicatorLineView.frame
            frame.size.width = currentIndicatorViewWidth
            frame.size.height = indicatorLineView.frame.size.height
            indicatorLineView.frame = frame
        }
    }
    
    private func addMenuItems() {
        guard let source = dataSource else{
            return
        }
        
        for item in items {
            item.removeFromSuperview()
            item.badgeView?.removeFromSuperview()
        }
        items.removeAll()
        
        for i in 0 ..< itemsCount {
            //add item
            let title = source.menuView(self, titleAt: i)
            let item = JYPageMenuItem()
            item.backgroundColor = .clear
            item.text = title
            item.tag = i + kMenuItemTagExtenValue
            item.config = config
            item.delegate = self
            contentView.addSubview(item)
            items.append(item)
            
            //item badgeView添加
            if let badgeView = source.menuView?(self, badgeViewAt: i) {
                item.badgeView = badgeView
                contentView.addSubview(badgeView)
            }
        }
    }
    
    ///更改指示器位置
    private func indicatorLineViewMoveTo(_ index: Int, animate: Bool) {
        guard let menuItem = itemWithIndex(selectedIndex), config.showIndicator, itemsCount > 0  else {
           return
        }
        
        let rect = CGRect(x: (menuItem.frame.width - config.indicatorLineViewSize.width)/2 + menuItem.frame.origin.x, y: frame.height - config.indicatorLineViewBottom - config.indicatorLineViewSize.height, width: config.indicatorLineViewSize.width, height: config.indicatorLineViewSize.height)
        contentView.bringSubview(toFront: indicatorLineView)
        var duration: Double = 0
        if animate {
            duration = kMenuItemAnimateDuration
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.indicatorLineView.frame = rect
        }, completion: nil)
    }
    
    ///选中item之后判断是是否需要调整contentOffsetX
    private func resetHorContentOffset(animate: Bool) {
        guard let selectedItem = itemWithIndex(selectedIndex) else {
            return
        }
        let contentSize = contentView.contentSize
        let width = contentView.frame.size.width
        if contentSize.width > width {
            //计算当前选中的item中心点是否超过scrollView宽度的一半
            let itemCenterX = selectedItem.center.x
            if itemCenterX < width/2 {
                contentView.setContentOffset(CGPoint(x: 0, y: 0), animated: animate)
            }else{
                if (contentSize.width - itemCenterX) > width/2 {
                    //item中心点相对于屏幕左边的距离
                    let itemCenterByScreen = selectedItem.frame.origin.x - contentView.contentOffset.x + selectedItem.frame.size.width/2
                    let itemCenterToContentCenterDis = width/2 - itemCenterByScreen
                    contentView.setContentOffset(CGPoint(x:contentView.contentOffset.x - itemCenterToContentCenterDis, y: 0), animated: animate)
                }else{
                    contentView.setContentOffset(CGPoint(x:contentSize.width - width, y: 0), animated: animate)
                }
            }
        }
    }
    
    
    private func layoutItems() {
        var totalWidth: CGFloat = 0
        if frame.size.height > 1, frame.size.width > 1, layoutOnceToken == false {
            for (index,item) in items.enumerated() {
                
                //备注：itemWidth取max，解决无论字体从regular->medium 还是medium->regular，文字都能正确显示
                let selectedItemWidth = sizeForItem(item, font: UIFont.systemFont(ofSize: config.normalTitleFont, weight: config.selectedTitleFontWeight)).width
                let normalItemWidth = sizeForItem(item, font: UIFont.systemFont(ofSize: config.normalTitleFont, weight: config.normalTitleFontWeight)).width
                let itemWidth = max(normalItemWidth,selectedItemWidth)
                
                let itemHeight = sizeForItem(item, font: UIFont.systemFont(ofSize: config.normalTitleFont, weight: config.selectedTitleFontWeight)).height
                
                if index == 0 {
                    item.frame = CGRect(x: 0, y: config.menuItemTop ?? (frame.size.height - itemHeight)/2, width: itemWidth, height: itemHeight)
                    totalWidth = totalWidth + itemWidth
                }else{
                    item.frame = CGRect(x: totalWidth + config.menuItemMargin, y:config.menuItemTop ?? (frame.size.height - itemHeight)/2, width: itemWidth, height: itemHeight)
                    totalWidth = totalWidth + itemWidth + config.menuItemMargin
                }
                
                if index == selectedIndex {
                    item.transform = CGAffineTransform(scaleX: maxScale, y: maxScale)
                    item.textColor = config.selectedTitleColor
                    item.font = UIFont.systemFont(ofSize: config.normalTitleFont, weight: config.selectedTitleFontWeight)
                }else{
                    item.transform = .identity
                    item.font = normalFont
                    item.textColor = config.normalTitleColor
                }
            }
            ///调用该方法原因: 设置完选中的item.transform之后更新frame, itemMargin, contentsize
            updateItemsFrame()
            layoutOnceToken = true
        }
    }
    
    
    ///更新itemsframe
    private func updateItemsFrame() {
        
        let width = calculateTotalWidth()
        var startX: CGFloat = 0
        if config.alignment == .center, width < frame.width {
            startX = (frame.width - width)/2
        }
        
        if config.alignment == .right, width < frame.width {
            startX = frame.width - width
        }
        
        var totalWidth: CGFloat = 0
        for (index,item) in items.enumerated() {
            if index == 0 {
                item.frame = CGRect(x: startX , y: item.frame.origin.y, width: item.frame.width, height: item.frame.height)
                item.badgeView?.frame = CGRect(x: item.frame.width + config.badgeViewOffset.x, y: item.frame.origin.y - item.badgeViewHeight/2 + config.badgeViewOffset.y, width: item.badgeViewWidth, height: item.badgeViewHeight)
                totalWidth = startX + item.frame.width
            }else{
                item.frame = CGRect(x: totalWidth + config.menuItemMargin , y: item.frame.origin.y, width: item.frame.width, height: item.frame.height)
                item.badgeView?.frame = CGRect(x: item.frame.width + item.frame.origin.x + config.badgeViewOffset.x, y: item.frame.origin.y - item.badgeViewHeight/2 + config.badgeViewOffset.y, width: item.badgeViewWidth, height: item.badgeViewHeight)
                totalWidth = totalWidth + item.frame.width + config.menuItemMargin
            }
        }
        contentView.contentSize = CGSize(width: totalWidth, height: frame.size.height)
    }
    
    private func calculateTotalWidth() -> CGFloat {
        var totalWidth: CGFloat = 0
        for (index,item) in items.enumerated() {
            if index == 0 {
                totalWidth = totalWidth + item.frame.width + item.badgeViewWidth + config.badgeViewOffset.x
            }else{
                totalWidth = totalWidth + item.frame.width + item.badgeViewWidth + config.menuItemMargin + config.badgeViewOffset.x
            }
        }
        return totalWidth
    }
    
    private func itemWithIndex(_ index: Int) -> JYPageMenuItem? {
        if let item = contentView.viewWithTag(index+kMenuItemTagExtenValue) as? JYPageMenuItem {
            return item
        }
        return nil
    }
    
    
    
    //MARK: - Lazy
    private lazy var contentView : UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = config.bounces
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    private lazy var indicatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = config.indicatorLineViewColor
        view.layer.cornerRadius = config.indicatorLineViewCornerRadius
        return view
    }()
    
    private lazy var maxScale: CGFloat = {
        return config.selectedTitleFont/config.normalTitleFont
    }()
    
    private lazy var normalFont: UIFont = {
        let font = UIFont.systemFont(ofSize: config.normalTitleFont, weight: config.normalTitleFontWeight)
        return font
    }()
    
    private lazy var selectedFont: UIFont = {
        let font = UIFont.systemFont(ofSize: config.selectedTitleFont, weight: config.selectedTitleFontWeight)
        return font
    }()
    
    
    //MARK: - Contant
    private let kMenuItemTagExtenValue: Int = 1000000
    private let kMenuItemAnimateDuration: Double = 0.3
}


//MARK: - JYPageMenuItemDelegate - 选中item事件逻辑处理extension
extension JYPageMenuView: JYPageMenuItemDelegate {
    
    func menuItemDidSelected(_ item: JYPageMenuItem) {
        let targetIndex = item.tag - kMenuItemTagExtenValue
        menuViewSelectedItemChange(fromIndex: selectedIndex, toIndex: targetIndex)
        selectedIndex = targetIndex
        indicatorLineViewMoveTo(targetIndex, animate: true)
        delegate?.menuView?(self, didSelectItemAt: targetIndex)
    }
    
    private func menuViewSelectedItemChange(fromIndex: Int, toIndex: Int) {
        
        guard let fromItem = itemWithIndex(fromIndex), let toItem = itemWithIndex(toIndex) else {
            return
        }
        
        toItem.selected = true
        fromItem.selected = false
        var rate: CGFloat = 0
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: kMenuItemAnimateDuration/100)
        timer.setEventHandler(handler: {
            rate = rate + 0.01
            fromItem.rate = 1 - rate
            toItem.rate = rate
        })
        timer.resume()

        UIView.animate(withDuration: kMenuItemAnimateDuration, delay: 0, options: .curveEaseInOut, animations: {
            fromItem.textColor = self.config.normalTitleColor
            toItem.textColor = self.config.selectedTitleColor
            fromItem.transform = CGAffineTransform(scaleX: 1, y: 1)
            toItem.transform = CGAffineTransform(scaleX: self.maxScale, y: self.maxScale)
            self.updateItemsFrame()
            
        }) { finished in
            timer.cancel()
            toItem.textColor = self.config.selectedTitleColor
            toItem.font = UIFont.systemFont(ofSize: self.config.normalTitleFont, weight: self.config.selectedTitleFontWeight)
            fromItem.textColor = self.config.normalTitleColor
            fromItem.font = self.normalFont
            
            self.resetHorContentOffset(animate: true)
        }
    }
    
    ///计算item的大小
    private func sizeForItem(_ item: JYPageMenuItem, font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        var titleSize: CGSize = NSString(string: item.text ?? "").boundingRect(with: CGSize.init(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size

        if titleSize.width < config.menuItemMinWidth, config.menuItemMinWidth > 0 {
            titleSize = CGSize(width: config.menuItemMinWidth, height: titleSize.height)
        }

        if titleSize.width > config.menuItemMaxWidth, config.menuItemMaxWidth > 0 {
            titleSize = CGSize(width: config.menuItemMaxWidth, height: titleSize.height)
        }
        return titleSize
    }
    
}


