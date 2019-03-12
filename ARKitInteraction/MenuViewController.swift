//
//  MenuViewController.swift
//  ARKitInteraction
//
//  Created by Jenny Ferina on 3/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import AudioToolbox

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func newRoutePressed(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
    }
    
    @IBAction func loadRoutePressed(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
    }
    
    @IBAction func learnMorePressed(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
    }
    

    @IBAction func settingsPressed(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
