# JYPageController

[![CI Status](https://img.shields.io/travis/wangtao/JYPageController.svg?style=flat)](https://travis-ci.org/wangtao/JYPageController)
[![Version](https://img.shields.io/cocoapods/v/JYPageController.svg?style=flat)](https://cocoapods.org/pods/JYPageController)
[![License](https://img.shields.io/cocoapods/l/JYPageController.svg?style=flat)](https://cocoapods.org/pods/JYPageController)
[![Platform](https://img.shields.io/cocoapods/p/JYPageController.svg?style=flat)](https://cocoapods.org/pods/JYPageController)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JYPageController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JYPageController'
```

## 功能
1.继承JYPageController 在init方法中配置config属性  
2.支持设置字体大小颜色   
3.支持设置标题间间距  
4.支持设置默认的selectedIndex  
5.支持设置/清空每个标题的badgeView,以及badgeview和标题item的间距  
6.支持设置下划线颜色，宽高，圆角，是否显示下划线指示器  
7.在滚动过程中，每个标题item放大缩小过程中，item间距保持不变  
8.感谢WMPageController作者，有些思路借鉴WMPageController  
9.持续完善中。。。。  


eg.

    在继承JYPageController的子类的init方法中配置
    //normal字体大小颜色
    config.normalTitleColor = .systemGray
    config.normalTitleFont = 16
    
    //selected字体大小颜色
    config.selectedTitleColor = .red
    config.selectedTitleFont = 21

    //indicatorLine size  cornerRadius color
    config.indicatorLineViewSize = CGSize(width: 14, height: 3)
    config.indicatorLineViewCornerRadius = 2
    
    //item间距
    config.menuItemMargin = 25
    
    //默认选中的index
    selectedIndex = 2
    
    .....


## Demo GIF
![image](https://github.com/wangtao311/JYPageController/blob/master/gif1.gif )   



## Author

wangtao, henandaxuewangtao@126.com

## License

JYPageController is available under the MIT license. See the LICENSE file for more info.
