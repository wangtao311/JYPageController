//
//  JYDemoController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/9/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class JYDemoController: UITableViewController {
    
    let sectionTitles = ["JYPageController配置","segmentedView样式","自定义segmentedView的item","有headerView场景"]
    let cellTitles = [["segmentedView设置默认选中的index","segmentedView显示在导航栏"],["segmentedView下划线指示器粘性效果","segmentedView指示器跟随item宽度","segmentedView指定下划线指示器size","segmentedView指示器设置为自定义view","segmentedView居左,文字缩放过程间距保持不变"],["segmentedView自定义item"],["有header，segment悬浮,下拉刷新在顶部","有header，segment悬浮,下拉刷新在子页面","有header，segment悬浮。导航栏渐变"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.title = "JYPageController"
        tableView = UITableView(frame: self.view.frame, style: .grouped)
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "reuseIdentifier")
        
    }
    

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles[section].count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = cellTitles[indexPath.section][indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var controller = UIViewController()
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                controller = JYNormalDemoController()
            }else if indexPath.row == 1 {
                controller = JYShowInNavDemoController()
            }
            
        }else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                controller = JYNormalDemoController()
            }else if indexPath.row == 1 {
                controller = JYMenuViewEqualItemWidthLineController()
            }else if indexPath.row == 2 {
                controller = JYMenuViewCustomSizeLineController()
            }else if indexPath.row == 3 {
                controller = JYCustomIndicatorDemoController()
            }else if indexPath.row == 4 {
                controller = JYMenuViewAligentDemoController()
            }
            
        }else if indexPath.section == 2 {
            controller = JYMenuCustomItemController()
        }else if indexPath.section == 3 {
            if indexPath.row == 0 {
                controller = JYHaveHeaderViewController()
            }else if indexPath.row == 1 {
                controller = JYHaveHeaderView1Controller()
            }else if indexPath.row == 2 {
                controller = JYHaveHeaderView2Controller()
            }
        }
        
        controller.navigationItem.title = cellTitles[indexPath.section][indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
