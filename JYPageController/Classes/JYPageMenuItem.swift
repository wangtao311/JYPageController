//
//  JYPageMenuItem.swift
//  JYPageController
//
//  Created by wang tao on 2022/7/14.
//

import UIKit

@objc enum JYMenuItemType: Int {
    case text = 0
    case custom = 1
}

@objc protocol JYPageMenuItemDelegate {
    func menuItemDidSelected(_ item: JYPageMenuItem)
}

class JYPageMenuItem: UIView {
    
    weak open var delegate: JYPageMenuItemDelegate?
    
    var badgeView: UIView?
    
    var customView: UIView?
    
    var type: JYMenuItemType = .text
    
    var normalColorRed: CGFloat = 0, normalColorGreen: CGFloat = 0, normalColorBlue: CGFloat = 0, normalColorAlpha: CGFloat = 0
    
    var selectedColorRed: CGFloat = 0, selectedColorGreen: CGFloat = 0, selectedColorBlue: CGFloat = 0, selectedColorAlpha: CGFloat = 0
    
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
                textLabel.textColor = config.selectedTitleColor
            }else{
                textLabel.textColor = config.normalTitleColor
            }
        }
    }
    
    var font: UIFont? {
        didSet {
            textLabel.font = font
        }
    }
    
    var textColor: UIColor? {
        didSet {
            textLabel.textColor = textColor
        }
    }
    
    var text: String? {
        get {
            return textLabel.text
        }
    }
    
    
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
            textLabel.textColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAtion(_:)))
        addGestureRecognizer(tap)
    }
    
    public convenience init(text: String) {
        self.init(frame: .zero)
        
        addSubview(textLabel)
        textLabel.text = text
        type = .text
    }
    
    public convenience init(customItemView: UIView) {
        self.init(frame: .zero)
        
        addSubview(customItemView)
        customView = customItemView
        type = .custom
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds
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
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
}

