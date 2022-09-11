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


接下来完善  
fix:保证子控制器生命周期方法  
1.menuview显示在导航栏  
2.下划线支持渐变色  
3. menuview的item支持自定义view   
4.优化代码  


## Use

1.继承JYPageController  
2.在init方法中配置menuview颜色字体大小等

```
override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {  

    super.init(nibName: nil, bundle: nil)  

    config.normalTitleColor = .systemGray
    config.normalTitleFontWeight = .regular
    config.normalTitleFont = 16

    config.selectedTitleColor = .red
    config.selectedTitleFontWeight = .regular
    config.selectedTitleFont = 21

    config.indicatorLineViewSize = CGSize(width: 14, height: 3)
    config.indicatorLineViewCornerRadius = 2

    config.menuItemMargin = 25

    selectedIndex = 2
    
    ...
} 

```


3.实现数据源协议方法  

```
override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {  
    return menuview frame  
}  

override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {   
    return childViewcontroller view frame   
}  

override func pageController(_ pageView: JYPageController, titleAt index: Int) -> String {  
    return title  
}  

override func numberOfChildControllers() -> Int {  
    return title count  
}  

override func childController(atIndex index: Int) -> UIViewController {  
    return child controller  
} 

```


## Preview GIF
![image](https://github.com/wangtao311/JYPageController/blob/master/gif1.gif)   



## Author

wangtao, henandaxuewangtao@126.com

## License

JYPageController is available under the MIT license. See the LICENSE file for more info.
