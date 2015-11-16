//
//  ViewController.swift
//  2048firtest
//
//  Created by RenPeng on 15/10/9.
//  Copyright © 2015年 RenPeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let game = GameController(dimension: 4, threshold: 2048)
//        self.presentViewController(game, animated: true, completion: nil)
    }
    @IBAction func startGameButtonTapped(sender : UIButton) {
        let game = GameController(dimension: 4, threshold: 2048)
        self.presentViewController(game, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

