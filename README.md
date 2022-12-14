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
8.支持标题tab显示在导航栏  
9.保证childViewController生命周期  
10.标题下指示器支持多样式,支持自定义View     
11.menuView的item支持自定义View    
12.menuview样式目前主流APP以下划线或者或者自定义image为主。暂时不打算支持其他非主流的样式   
13.支持头部headerView，menuview可以悬停  




感谢[WMPageController](https://github.com/wangmchn/WMPageController) 作者，childController生命周期逻辑和item缩放过程中颜色变化逻辑借鉴WMPageController    
但同时也解决了使用WMPageController过程中遇到两个的问题  
1.选中和非选中字体差距较大时候，选中的item和非选中的item间距变的很小,UI不能接受   
2.item在放大的过程中，item的badgeView是不动的，放大后位置出现偏差



## NEXT       
1.优化menuview悬停的过程，目前悬停过程中有停顿    
2.增加刷新headerView的方法，支持动态高度的headerView


## Preview 
|    Style                    |                           Preview                                     |                     
| :-------------------------- | ----------------------------------------------------------------------|
|showInNavigationBar |  ![image](https://upload-images.jianshu.io/upload_images/3614407-b99da7b7e2628425.gif?imageMogr2/auto-orient/strip) | 
|customSizeLine      |  ![image](https://upload-images.jianshu.io/upload_images/3614407-38e5da7c01071cfe.gif?imageMogr2/auto-orient/strip) | 
|equalItemWidthLine  |  ![image](https://upload-images.jianshu.io/upload_images/3614407-de0d28a3407cbc8c.gif?imageMogr2/auto-orient/strip) |
|customIndicator     |  ![image](https://upload-images.jianshu.io/upload_images/3614407-a8134ea4d6b2bbde.gif?imageMogr2/auto-orient/strip) |
|customItem          |  ![image](https://upload-images.jianshu.io/upload_images/3614407-5b9a2e38966742ff.gif?imageMogr2/auto-orient/strip) |  
|headerView          |  ![image](https://upload-images.jianshu.io/upload_images/3614407-7c5a8659fa8a6a09.gif?imageMogr2/auto-orient/strip) |  
 


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




## Author

wangtao, henandaxuewangtao@126.com

## License

JYPageController is available under the MIT license. See the LICENSE file for more info.
