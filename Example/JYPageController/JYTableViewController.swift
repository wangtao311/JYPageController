//
//  JYTableViewController.swift
//  JYPageController_Example
//
//  Created by wang tao on 2022/9/9.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class JYTableViewController: UITableViewController {
    
    deinit {
        NSLog("JYTableViewController 销毁了")
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
        imageView.frame = CGRect(x: 15, y: 20, width: 80, height: 80)
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        
        
        let titleLbael = UILabel()
        titleLbael.text = "title"
        titleLbael.font = UIFont.systemFont(ofSize: 16)
        titleLbael.frame = CGRect(x: 120, y: 20, width: 100, height: 25)
        contentView.addSubview(titleLbael)
        
        let detailLbael = UILabel()
        detailLbael.font = UIFont.systemFont(ofSize: 13)
        detailLbael.text = "Pass the selected object to the new view controller."
        detailLbael.frame = CGRect(x: 120, y: 70, width: 200, height: 25)
        detailLbael.textColor = .lightGray
        contentView.addSubview(detailLbael)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
