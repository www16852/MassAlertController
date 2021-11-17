//
//  ViewController.swift
//  MassAlertControllerDemo
//
//  Created by cm0673 on 2021/11/17.
//

import UIKit

func getFirstKeyWindowVC() -> UIViewController? {
    let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
    return rootVC
}

class ViewController: UITableViewController {
    
    var testSetting: [(String, Selector)] = [
        ("標題+描述", #selector(titleMessage)),
        ("標題+描述+圖片", #selector(titleMessageImage)),
        ("當高度過高", #selector(overHeight)),
        ("調換順序", #selector(changeSort))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // 在AppDlegate設定一次即可，Demo為求好讀放在這邊
        MassAlertController.defaultParentVC = {
            return getFirstKeyWindowVC()
        }
    }

    @objc
    func titleMessage() {
        let alert = MassAlertController(title: "title", message: "message", image: nil)
        let action = MassAlertAction(title: "確定", actionType: .main, action: {})
        alert.actions = [action]
        alert.show()
    }
    
    @objc
    func titleMessageImage() {
        let image = UIImage(named: "apple")
        let alert = MassAlertController(title: "title", message: "message", image: image)
        let action = MassAlertAction(title: "確定", actionType: .main, action: {})
        alert.actions = [action]
        alert.show()
    }
    
    @objc
    func overHeight() {
        let image = UIImage(named: "apple")
        let message = """
        overHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\noverHeight\n last Message
        """
        let alert = MassAlertController(title: "title", message: message, image: image)
        let action = MassAlertAction(title: "確定", actionType: .main, action: {})
        alert.actions = [action]
        alert.show()
    }
    
    @objc
    func changeSort() {
        let image = UIImage(named: "apple")
        let alert = MassAlertController(title: "title", message: "message", image: image, order: [.image, .title, .message])
        let action = MassAlertAction(title: "確定", actionType: .main, action: {})
        alert.actions = [action]
        alert.show()
    }
    
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        testSetting.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        guard let cell = cell else {return UITableViewCell()}
        let info = testSetting[indexPath.row]
        cell.textLabel?.text = info.0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = testSetting[indexPath.row]
        perform(info.1)
    }
    
}
