//
//  JYPageConfig.swift
//  JYPageController
//
//  Created by wang tao on 2022/7/14.
//

import UIKit


@objc enum JYMenuItemState: Int {
    case normal = 0
    case selected = 1
}

@objc public enum JYMenuViewAlignment: Int {
    case left
    case right
    case center
}

///IndicatorStyle
@objc public enum JYMenuViewIndicatorStyle: Int {
    case none                 //none
    case followItemSizeLine   //equal to title width
    case customSizeLine       //need set indicatorSize property
    case customView           //custom view，need set customIndicator property
}



public class JYPageConfig: NSObject {
    
    ///normal status title color, default black
    public var normalTitleColor: UIColor = .black
    
    ///normal status title font, default size:16
    public var normalTitleFont: CGFloat = 16
    
    ///normal status fontWeight, default regular
    public var normalTitleFontWeight: UIFont.Weight = .regular
    
    ///selected status title color, default black
    public var selectedTitleColor: UIColor = .black
    
    ///selected status title fontsize, default size:16
    public var selectedTitleFont: CGFloat = 16
    
    ///selected status title fontWeight, default regular
    public var selectedTitleFontWeight: UIFont.Weight = .regular
    
    ///indicator style, default none
    public var indicatorStyle: JYMenuViewIndicatorStyle = .none
    
    ///custom indicatorView, if indicatorStyle = .customView, set this property
    public var customIndicator: UIView?
    
    ///indicator size, if indicatorStyle = .customSizeLine, set this property
    public var indicatorSize: CGSize = CGSize(width: 14, height: 2)
    
    ///indicator bottom distance from menuview bottom，default 0
    public var indicatorBottom: CGFloat = 0
    
    ///indicator color, if indicatorStyle =.customSizeLine ||  indicatorStyle =.followItemSizeLine, you can set this property
    public var indicatorColor: UIColor = .red
    
    ///indicator cornerRadius, default 0
    public var indicatorCornerRadius: CGFloat = 0
    
    ///item margin
    public var menuItemMargin: CGFloat = 15
    
    ///item min width, if text width < minwidth, item width = menuItemMinWidth
    public var menuItemMinWidth: CGFloat = 0
    
    ///item max width, if text width > maxwidth, item width = menuItemMaxWidth
    public var menuItemMaxWidth: CGFloat = 0
    
    ///item top distance from meuuview top, default ver center
    public var menuItemTop: CGFloat?
    
    ///alignment, default center
    public var alignment: JYMenuViewAlignment = .left
    
    ///bounces
    public var bounces: Bool = false
    
    ///badgeViewOffSet，default badgeView.left = item.right， badgeView.centerY = item.top  After you set badgeViewOffset,  badgeView.left = item.right+offet.x, badgeView.centerY = item.top + offsetY
    public var badgeViewOffset: CGPoint = .zero
    
    ///when the menuItem is clicked，scrollView change to target page  need animation?
    public var scrollViewAnimationWhenMenuItemSelected: Bool = false
    
    ///menuView show in navigation bar, default false
    public var menuViewShowInNavigationBar: Bool = false
    
}
 
