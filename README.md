# MassAlertController
### 客製化的Alert  
blog: https://www16852.medium.com/34e3f4c4a1df  
開發目的:  將設計圖客製化Alert規格化，減少重複拉畫面的工作與時間。  
![Nov-17-2021 16-21-49](https://user-images.githubusercontent.com/15730633/142167444-294b4287-140a-469a-967e-1a494483076f.gif)

### 特色
- 內容順序可調動
- 限制最高高度，超出後自動能滑動
- 全自動高度調整，依照內容去變動排版

### 使用設定
自行決定取得最底層VC的方法，會使用該VC的view去做畫面遮罩

```swift
	func getFirstKeyWindowVC() -> UIViewController? {
	    let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
	    return rootVC
	}
	
	MassAlertController.defaultParentVC = {
	    return getFirstKeyWindowVC()
	}
```

### 註記
此Alert僅依我目前專案需要去做調整  
所以沒有過多的接口  
不過constraint的拉法概念都是可以通用的，歡迎在Issues提出建議，或者fork更改
