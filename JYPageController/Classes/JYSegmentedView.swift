//
//  JYPageMenuView.swift
//  JYPageController
//
//  Created by wang tao on 2022/7/14.
//

import UIKit

@objc public protocol JYSegmentedViewDataSource {
    
    ///item count
    func numberOfSegmentedViewItems() -> Int
    
    ///item title
    func segmentedView(_ segmentedView: JYSegmentedView, titleAt index: Int) -> String
    
    ///customView item, customView has higher priority than title，when return customView, ignore title。customView need set frame.size
    @objc optional func segmentedView(_ segmentedView: JYSegmentedView, customViewAt index: Int) -> UIView?
    
    ///item  badgeView (eg. label/red dot/icon, need set frame.size)
    @objc optional func segmentedView(_ segmentedView: JYSegmentedView, badgeViewAt index: Int) -> UIView?
    
}

@objc public protocol JYSegmentedViewDelegate {
    
    @objc optional func segmentedView(_ segmentedView: JYSegmentedView, didSelectItemAt index: Int)
}




public class JYSegmentedView: UIView {
    
    ///config
    var config: JYPageConfig = JYPageConfig()
    
    ///代理
    weak public var delegate: JYSegmentedViewDelegate?
    
    ///数据源
    weak public var dataSource: JYSegmentedViewDataSource? {
        didSet {
            getItemsCount()
        }
    }
    
    ///当前选中的index
    private var selectedIndex: Int = 0
    
    ///item数量
    private var itemsCount: Int = 0
    
    ///items数组
    private var items = [JYSegmentedViewItem]()
    
    ///第一次初始化和reload的时候用来标记，layoutSubview中layoutItems方法只调用一次。原因：在对默认选中的item多次设置transform的时，tranform有值，但获取到的frame却没有变
    var layoutOnceToken: Bool = false
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        addSubview(contentView)
        contentView.addSubview(indicator)
    }
    
    public convenience init(pageConfig: JYPageConfig) {
        self.init()
        
        config = pageConfig
        contentView.bounces = false
        
        if config.indicatorStyle == .equalItemWidthLine || config.indicatorStyle == .customSizeLine {
            indicator.backgroundColor = config.indicatorColor
            indicator.layer.cornerRadius = config.indicatorCornerRadius
        }
        
        if config.indicatorStyle == .none {
            indicator.removeFromSuperview()
        }
        
        if config.indicatorStyle == .customView {
            indicator.removeFromSuperview()
            indicator = config.customIndicator ?? UIView()
            contentView.addSubview(indicator)
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
        indicatorMoveTo(index: selectedIndex, animate: false)
        resetHorContentOffset(animate: false)
    }
    
    private func getItemsCount() {
        guard let source = dataSource else {
            return
        }
        itemsCount = source.numberOfSegmentedViewItems()
    }
    
    //MARK: - Public
    ///单独使用menuview，动态改变数据源的时候调用(数据源改变之后先reload，如需要设置默认index，再调select)。其他场景不需要主动调用
    public func reload() {
        guard let source = dataSource, source.numberOfSegmentedViewItems() > 0 else {
            return
        }
        
        getItemsCount()
        addItems()
        layoutOnceToken = false
        layoutItems()
        
        contentView.bringSubview(toFront: indicator)
        resetHorContentOffset(animate: false)
        indicatorMoveTo(index: selectedIndex, animate: false)
    }
    
    ///获取当前选中的index
    public func currentSelectedIndex() -> Int {
        return selectedIndex
    }
    
    ///获取segmentedview的contentsize
    public func contentSize() -> CGSize {
        return contentView.contentSize
    }
    
    ///更新/设置segmentedview的frame
    public func updateFrame(frame: CGRect) {
        self.frame = frame
        layoutIfNeeded()
        resetHorContentOffset(animate: false)
    }
    
    ///为第index位置上的item添加badgeView
    public func addSegmentedItemBadgeView(_ badgeView: UIView, atIndex index: Int) {
        guard let item = itemWithIndex(index) else {
           return
        }

        if item.hasBadgeView {
            item.badgeView?.removeFromSuperview()
        }
        item.badgeView = badgeView
        contentView.addSubview(badgeView)
        updateItemsFrame()
    }
    
    ///移除指定index的item的badgeView
    public func removeSegmentedItemBadgeView(atIndex index: Int) {
        guard let menuItem = itemWithIndex(index) else {
           return
        }
        
        if menuItem.hasBadgeView {
            menuItem.badgeView?.removeFromSuperview()
            menuItem.badgeView = nil
            updateItemsFrame()
        }
    }
    
    ///页面滚动过程中，持续调用
    public func segmentedViewScroll(by pageView: UIScrollView) {
        changeItemsByScrollViewDidScroll(scrollView: pageView)
        updateItemsFrame()
    }
    
    ///页面滚动停止，scrollVIew代理方法scrollEndDecelerating中调用
    public func segmentedViewScrollEnd(byScrollEndDecelerating pageView: UIScrollView) {
        
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
        indicatorMoveTo(index: selectedIndex, animate: true)
    }
    
    ///设置选中index
    public func select(_ index: Int) {
        if index < itemsCount {
            itemWithIndex(index)?.selected = true
            selectedIndex = index
            reload()
            delegate?.segmentedView?(self, didSelectItemAt: selectedIndex)
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
        var targetItem: JYSegmentedViewItem?
        
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
        
        if config.indicatorStyle != .none {
            indicatorMove(fromItem: fromItem, toItem: toItem, offsetX: offsetX, rate: rate, pageView: scrollView)
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
     
    private func indicatorMove(fromItem: JYSegmentedViewItem, toItem: JYSegmentedViewItem, offsetX: CGFloat, rate: CGFloat, pageView: UIScrollView) {
        
        let scrollViewWidth = pageView.frame.width
        var currentIndicatorWidth: CGFloat = 0
        let indicatorMaxWidth = abs(toItem.center.x -  fromItem.center.x)
        let tempOffetX = offsetX.truncatingRemainder(dividingBy: scrollViewWidth)
        
        switch config.indicatorStyle {
        case .customSizeLine:
            if tempOffetX <= scrollViewWidth/2 {
                let percent_min_max = tempOffetX/scrollViewWidth*2
                currentIndicatorWidth = config.indicatorWidth + percent_min_max * (indicatorMaxWidth - config.indicatorWidth)
            }else{
                let percent_max_min = (tempOffetX - scrollViewWidth/2)/scrollViewWidth*2
                currentIndicatorWidth = config.indicatorWidth + (1 - percent_max_min)*(indicatorMaxWidth - config.indicatorWidth)
            }
            
            if fromItem.tag < toItem.tag {
                indicator.center = CGPoint(x: fromItem.center.x + rate * indicatorMaxWidth, y: indicator.center.y)
            }else{
                indicator.center = CGPoint(x: fromItem.center.x -  (1 - rate) * indicatorMaxWidth, y: indicator.center.y)
            }
            
            var frame = indicator.frame
            frame.size.width = currentIndicatorWidth
            frame.size.height = indicator.frame.size.height
            indicator.frame = frame
            
        case .equalItemWidthLine:
            if fromItem.tag < toItem.tag {
                indicator.center = CGPoint(x: fromItem.center.x + rate * indicatorMaxWidth, y: indicator.center.y)
                currentIndicatorWidth = (toItem.frame.width - fromItem.frame.width) * rate + fromItem.frame.width
            }else{
                indicator.center = CGPoint(x: fromItem.center.x -  (1 - rate) * indicatorMaxWidth, y: indicator.center.y)
                currentIndicatorWidth = (fromItem.frame.width - toItem.frame.width) * rate + toItem.frame.width
            }
            
            var frame = indicator.frame
            frame.size.width = currentIndicatorWidth
            frame.size.height = indicator.frame.size.height
            indicator.frame = frame
        
        case .customView:
            if fromItem.tag < toItem.tag {
                indicator.center = CGPoint(x: fromItem.center.x + rate * indicatorMaxWidth, y: indicator.center.y)
            }else{
                indicator.center = CGPoint(x: fromItem.center.x -  (1 - rate) * indicatorMaxWidth, y: indicator.center.y)
            }
            
        default: break
            
        }
    }
    
    private func addItems() {
        guard let source = dataSource else{
            return
        }
        
        for item in items {
            item.removeFromSuperview()
            item.badgeView?.removeFromSuperview()
        }
        items.removeAll()
        
        for i in 0 ..< itemsCount {
            let customView = source.segmentedView?(self, customViewAt: i)
            var item = JYSegmentedViewItem()
            
            if let customItem = customView {
                item = JYSegmentedViewItem(customItemView: customItem)
            }else{
                let title = source.segmentedView(self, titleAt: i)
                item = JYSegmentedViewItem(text: title)
            }
            item.tag = i + kMenuItemTagExtenValue
            item.config = config
            item.delegate = self
            contentView.addSubview(item)
            items.append(item)
            
            if let badgeView = source.segmentedView?(self, badgeViewAt: i) {
                item.badgeView = badgeView
                contentView.addSubview(badgeView)
            }
        }
    }
    
    ///更改指示器位置
    private func indicatorMoveTo(index: Int, animate: Bool) {
        guard let menuItem = itemWithIndex(selectedIndex), config.indicatorStyle != .none, itemsCount > 0  else {
           return
        }
        
        var indicatorRect: CGRect = .zero
        if config.indicatorStyle == .customSizeLine {
            indicatorRect = CGRect(x: (menuItem.frame.width - config.indicatorWidth)/2 + menuItem.frame.origin.x, y: frame.height - config.indicatorBottom - config.indicatorHeight, width: config.indicatorWidth, height: config.indicatorHeight)
        }else if config.indicatorStyle == .equalItemWidthLine {
            indicatorRect = CGRect(x: menuItem.frame.origin.x, y: frame.height - config.indicatorBottom - config.indicatorHeight, width: menuItem.frame.width, height: config.indicatorHeight)
        }else if config.indicatorStyle == .customView {
            if let indicator = config.customIndicator {
                indicatorRect = CGRect(x: (menuItem.frame.width - indicator.frame.width)/2 + menuItem.frame.origin.x, y: frame.height - config.indicatorBottom - indicator.frame.height, width: indicator.frame.width, height: indicator.frame.height)
            }
        }
        
        var duration: Double = 0
        if animate {
            duration = kMenuItemAnimateDuration
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.indicator.frame = indicatorRect
        }, completion: nil)
        contentView.bringSubview(toFront: indicator)
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
                
                var itemWidth = max(normalItemWidth,selectedItemWidth)
                var itemHeight = sizeForItem(item, font: UIFont.systemFont(ofSize: config.normalTitleFont, weight: config.selectedTitleFontWeight)).height
                
                if item.type == .customView {
                    itemWidth = item.customView?.frame.size.width ?? 0
                    itemHeight = item.customView?.frame.size.height ?? 0
                }
                
                if index == 0 {
                    item.frame = CGRect(x: 0, y: config.itemTop ?? (frame.size.height - itemHeight)/2, width: itemWidth, height: itemHeight)
                    totalWidth = totalWidth + itemWidth
                }else{
                    item.frame = CGRect(x: totalWidth + config.itemMargin, y:config.itemTop ?? (frame.size.height - itemHeight)/2, width: itemWidth, height: itemHeight)
                    totalWidth = totalWidth + itemWidth + config.itemMargin
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
                item.frame = CGRect(x: totalWidth + config.itemMargin , y: item.frame.origin.y, width: item.frame.width, height: item.frame.height)
                item.badgeView?.frame = CGRect(x: item.frame.width + item.frame.origin.x + config.badgeViewOffset.x, y: item.frame.origin.y - item.badgeViewHeight/2 + config.badgeViewOffset.y, width: item.badgeViewWidth, height: item.badgeViewHeight)
                totalWidth = totalWidth + item.frame.width + config.itemMargin
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
                totalWidth = totalWidth + item.frame.width + item.badgeViewWidth + config.itemMargin + config.badgeViewOffset.x
            }
        }
        return totalWidth
    }
    
    private func itemWithIndex(_ index: Int) -> JYSegmentedViewItem? {
        if let item = contentView.viewWithTag(index+kMenuItemTagExtenValue) as? JYSegmentedViewItem {
            return item
        }
        return nil
    }
    
    
    
    //MARK: - Lazy
    private lazy var contentView : UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    private lazy var indicator: UIView = {
        let view = UIView()
        view.backgroundColor = config.indicatorColor
        view.layer.cornerRadius = config.indicatorCornerRadius
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


//MARK: - JYSegmentedViewItemDelegate - 选中item事件逻辑处理extension
extension JYSegmentedView: JYSegmentedViewItemDelegate {
    
    func segmentedItemDidSelected(_ item: JYSegmentedViewItem) {
        let targetIndex = item.tag - kMenuItemTagExtenValue
        segmentedViewSelectedItemChange(fromIndex: selectedIndex, toIndex: targetIndex)
        selectedIndex = targetIndex
        indicatorMoveTo(index: targetIndex, animate: true)
        delegate?.segmentedView?(self, didSelectItemAt: targetIndex)
    }
    
    private func segmentedViewSelectedItemChange(fromIndex: Int, toIndex: Int) {
        
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
    private func sizeForItem(_ item: JYSegmentedViewItem, font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        var titleSize: CGSize = NSString(string: item.text ?? "").boundingRect(with: CGSize.init(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size

        if titleSize.width < config.itemMinWidth, config.itemMinWidth > 0 {
            titleSize = CGSize(width: config.itemMinWidth, height: titleSize.height)
        }

        if titleSize.width > config.itemMaxWidth, config.itemMaxWidth > 0 {
            titleSize = CGSize(width: config.itemMaxWidth, height: titleSize.height)
        }
        return titleSize
    }
    
}


