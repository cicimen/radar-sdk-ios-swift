//
//  ViewController.swift
//  Example
//
//  Created by Egemen Gulkilik on 21.10.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        

        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let numbers = [0]
            let _ = numbers[1]
        }
         */
    }
    
    @IBAction func crash(_ sender: Any) {
        let numbers = [0]
        let _ = numbers[1]
    }
    

}

