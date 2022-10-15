//
//  JYTableViewController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/9/9.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JYPageController

class JYTableViewController: UITableViewController,JYPageChildContollerProtocol {
    
    deinit {
        NSLog("JYTableViewController dealloc")
    }
    
    func fetchChildControllScrollView() -> UIScrollView? {
        return tableView
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name("JYccrollViewDidScroll"), object: self, userInfo: ["offsetY":scrollView.contentOffset.y])
//        scrollView.contentOffset = .zero
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 120
        tableView.showsVerticalScrollIndicator = false
        tableView.register(JYTableViewCell.classForCoder(), forCellReuseIdentifier: "JYTableViewCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 26
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JYTableViewCell", for: indexPath)
        return cell
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





class JYTableViewCell: UITableViewCell {
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        let imageView = UIImageView(image: UIImage(named: "demo_list_icon"))
        imageView.frame = CGRect(x: 15, y: 10, width: 140, height: 100)
        contentView.addSubview(imageView)
        
        
        let titleLbael = UILabel()
        titleLbael.text = "title"
        titleLbael.frame = CGRect(x: 160, y: 10, width: 100, height: 25)
        contentView.addSubview(titleLbael)
        
        let detailLbael = UILabel()
        detailLbael.text = "Pass the selected object to the new view controller."
        detailLbael.frame = CGRect(x: 160, y: 80, width: 200, height: 25)
        detailLbael.textColor = .lightGray
        contentView.addSubview(detailLbael)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
