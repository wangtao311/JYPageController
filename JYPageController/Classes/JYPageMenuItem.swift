//
//  JYPageMenuItem.swift
//  JYPageController
//
//  Created by wang tao on 2022/7/14.
//

import UIKit

@objc protocol JYPageMenuItemDelegate {
    func menuItemDidSelected(_ item: JYPageMenuItem)
}

class JYPageMenuItem: UILabel {
    
    weak open var delegate: JYPageMenuItemDelegate?
    
    var badgeView: UIView?
    
    var badgeViewWidth: CGFloat {
        get {
            return badgeView?.frame.width ?? 0
        }
    }
    
    var badgeViewHeight: CGFloat {
        get {
            return badgeView?.frame.height ?? 0
        }
    }
    
    var hasBadgeView: Bool {
        get {
            if badgeView == nil {
                return false
            }else{
                return true
            }
        }
    }
    
    var selected: Bool = false {
        didSet {
            if selected {
                textColor = config.selectedTitleColor
            }else{
                textColor = config.normalTitleColor
            }
        }
    }
    
    private var normalColorRed: CGFloat = 0, normalColorGreen: CGFloat = 0, normalColorBlue: CGFloat = 0, normalColorAlpha: CGFloat = 0
    
    private var selectedColorRed: CGFloat = 0, selectedColorGreen: CGFloat = 0, selectedColorBlue: CGFloat = 0, selectedColorAlpha: CGFloat = 0
    
    var config: JYPageConfig = JYPageConfig() {
        didSet {
            config.normalTitleColor.getRed(&normalColorRed, green: &normalColorGreen, blue: &normalColorBlue, alpha: &normalColorAlpha)
            config.selectedTitleColor.getRed(&selectedColorRed, green: &selectedColorGreen, blue: &selectedColorBlue, alpha: &selectedColorAlpha)
        }
    }
    
    var rate: CGFloat = 0 {
        didSet {
            let red: CGFloat = normalColorRed + (selectedColorRed - normalColorRed) * rate
            let green: CGFloat = normalColorGreen + (selectedColorGreen - normalColorGreen) * rate
            let blue: CGFloat = normalColorBlue + (selectedColorBlue - normalColorBlue) * rate
            let alpha: CGFloat = normalColorAlpha + (selectedColorAlpha - normalColorAlpha) * rate
            textColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .center
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAtion(_:)))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    @objc private func tapAtion(_ gesture: UIGestureRecognizer) {
        if !selected {
            delegate?.menuItemDidSelected(self)
        }
    }
    
}

