//
//  ViewController.swift
//  HelloWorld
//
//  Created by 朱力 on 2017/8/9.
//  Copyright © 2017年 朱力. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var data: [SnippetData] = [SnippetData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createNewSnippet(_ sender: Any) {
        let newSnippet = SnippetData()
        data.append(newSnippet)
    }

}

