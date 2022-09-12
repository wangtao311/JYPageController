//
//  JYPageConfig.swift
//  JYPageController
//
//  Created by wang tao on 2022/7/14.
//

import UIKit

///item的状态
@objc enum JYMenuItemState: Int {
    case normal = 0
    case selected = 1
}

///menuview的布局方式，居中/居左/居右
@objc public enum JYMenuViewAlignment: Int {
    case left
    case right
    case center
}

///IndicatorStyle  下划线/渐变色下划线/自定义view，默认显示下划线
@objc public enum JYMenuViewIndicatorStyle: Int {
    case defaultStyle
    case gradientStyle
    case customStyle
}



public class JYPageConfig: NSObject {
    
    ///非选中状态文字颜色,默认黑色
    public var normalTitleColor: UIColor = .black
    
    ///非选中状态文字font,默认size:16
    public var normalTitleFont: CGFloat = 16
    
    ///非选中状态文字fontWeight,默认regular
    public var normalTitleFontWeight: UIFont.Weight = .regular
    
    ///选中状态文字颜色,默认黑色
    public var selectedTitleColor: UIColor = .black
    
    ///选中状态文字fontsize,默认size:16
    public var selectedTitleFont: CGFloat = 16
    
    ///选中状态文字fontWeight,默认regular
    public var selectedTitleFontWeight: UIFont.Weight = .regular
    
    ///是否显示指示器，默认显示下划线
    public var showIndicator: Bool = true
    
    ///指示器(下划线)size，默认14,2
    public var indicatorLineViewSize: CGSize = CGSize(width: 14, height: 2)
    
    ///指示器(下划线)距离底部的间距，默认0
    public var indicatorLineViewBottom: CGFloat = 0
    
    ///指示器(下划线)颜色
    public var indicatorLineViewColor: UIColor = .red
    
    ///指示器(下划线)圆角,默认0
    public var indicatorLineViewCornerRadius: CGFloat = 0
    
    ///菜单标题间距
    public var menuItemMargin: CGFloat = 15
    
    ///菜单最小宽度
    public var menuItemMinWidth: CGFloat = 0
    
    ///菜单最大宽度
    public var menuItemMaxWidth: CGFloat = 0
    
    ///菜单文案距离顶部的距离,不设置的话默认居中
    public var menuItemTop: CGFloat?
    
    ///alignment,默认居左， item数目多能滚动的场景，设置center无效
    public var alignment: JYMenuViewAlignment = .left
    
    ///bounces效果
    public var bounces: Bool = false
    
    ///badgeViewOffSet，默认badgeView.left = item.right， badgeView.centerY = item.top 设置后效果badgeView.left = item.right+offet.x, badgeView.centerY = item.top + offsetY
    public var badgeViewOffset: CGPoint = .zero
    
    ///menuItem手动选中时候，下面的scrollView切换页面是否滚动
    public var scrollViewAnimationWhenMenuItemSelected: Bool = false
    
    ///menuView显示在导航栏，默认false
    public var menuViewShowInNavigationBar: Bool = false
    
}
 
