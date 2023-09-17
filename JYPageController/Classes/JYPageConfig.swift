//
//  JYPageConfig.swift
//  JYPageController
//
//  Created by wang tao on 2022/7/14.
//

import UIKit


@objc enum JYSegmentedItemState: Int {
    case normal = 0
    case selected = 1
}

@objc public enum JYSegmentedViewAlignment: Int {
    case left
    case right
    case center
}

///IndicatorStyle
@objc public enum JYSegmentedViewIndicatorStyle: Int {
    case none                 //不显示指示器.  indicator hidden
    case equalItemWidthLine   //指示器下划线宽度等于标题的文字宽度.  equal to title width
    case customSizeLine       //指示器自己设置size，有粘性动画效果.  need set indicatorSize property
    case customView           //自定义view做指示器,需要设置customIndicator属性. custom view，need set customIndicator property
}

///refresh location
@objc public enum JYHeaderRefreshLocation: Int {
    case headerViewTop            //下拉刷新位置在headerView顶部.    refresh headerView at headerView top
    case childControllerViewTop   //下拉刷新位置在子页面的scrollView顶部.   refresh headerView at childControllerViewtop
}



public class JYPageConfig: NSObject {
    
    ///非选中状态segmentItem标题颜色. normal status title color, default black
    public var normalTitleColor: UIColor = .black
    
    ///非选中状态segmentItem标题大小. normal status title font, default size:16
    public var normalTitleFont: CGFloat = 16
    
    ///非选中状态segmentItem标题字重. normal status fontWeight, default regular
    public var normalTitleFontWeight: UIFont.Weight = .regular
    
    ///选中状态segmentItem标题颜色. selected status title color, default black
    public var selectedTitleColor: UIColor = .black
    
    ///选中状态segmentItem标题大小. selected status title fontsize, default size:16
    public var selectedTitleFont: CGFloat = 16
    
    ///选中状态segmentItem标题字重. selected status title fontWeight, default regular
    public var selectedTitleFontWeight: UIFont.Weight = .regular
    
    ///segmentedView指示器样式,默认不显示指示器. indicator style, default none
    public var indicatorStyle: JYSegmentedViewIndicatorStyle = .none
    
    ///segmentedView自定义view指示器. custom indicatorView, if indicatorStyle = .customView, set this property
    public var customIndicator: UIView?
    
    ///segmentedView指示器宽度. indicator width, if indicatorStyle = .customSizeLine, set this property
    public var indicatorWidth: CGFloat = 14
    
    ///segmentedView指示器高度. indicator height, if indicatorStyle = .customSizeLine || = .equalItemWidth, set this property
    public var indicatorHeight: CGFloat = 2
    
    ///segmentedView指示器距离segmentedView底部间距. indicator bottom distance from menuview bottom，default 0
    public var indicatorBottom: CGFloat = 0
    
    ///segmentedView指示器颜色.  indicator color, if indicatorStyle =.customSizeLine ||  indicatorStyle =.followItemSizeLine, you can set this property
    public var indicatorColor: UIColor = .red
    
    ///segmentedView指示器圆角.  indicator cornerRadius, default 0
    public var indicatorCornerRadius: CGFloat = 0
    
    ///segmentedView item之间间距.  item margin
    public var itemsMargin: CGFloat = 15
    
    ///segmentedView item最小宽度.  item min width, if text width < minwidth, item width = menuItemMinWidth
    public var itemMinWidth: CGFloat = 0
    
    ///segmentedView item最大宽度.  item max width, if text width > maxwidth, item width = menuItemMaxWidth
    public var itemMaxWidth: CGFloat = 0
    
    ///segmentedView item距离segmentedView顶部的距离，默认垂直方向居中.  item top distance from meuuview top, default ver center
    public var itemTop: CGFloat?
    
    ///segmentedView aligment默认left.  default .left
    public var alignment: JYSegmentedViewAlignment = .left
    
    ///segmentedView左边距,默认0.  segmentedView leftPadding
    public var leftPadding: CGFloat = 0
    
    ///segmentedView右边距,默认0.  segmentedView rightPadding
    public var rightPadding: CGFloat = 0
    
    ///segmentedView item的角标位置X,Y方向调整
    ///badgeViewOffSet，default badgeView.left = item.right， badgeView.centerY = item.top  After you set badgeViewOffset,  badgeView.left = item.right+offet.x, badgeView.centerY = item.top + offsetY
    public var badgeViewOffset: CGPoint = .zero
    
    ///点击segmentedView的item时候下面的子页面切换是否需要滚动动画，默认false.   when the menuItem is clicked，scrollView change to target page.  need animation?
    public var scrollViewAnimationWhenSegmentItemSelected: Bool = false
    
    ///segmentedView是否显示在导航栏. segmentedView show in navigation bar, default false
    public var segmentedViewShowInNavigationBar: Bool = false
    
    ///有headerView的时候下拉刷新位置在子页面的顶部，还是在headerView的顶部,默认在headerView的顶部.  when pageController has headerView, header refresh location. defalut: at headerView top
    public var headerRefreshLocation: JYHeaderRefreshLocation = .headerViewTop
    
}
 
