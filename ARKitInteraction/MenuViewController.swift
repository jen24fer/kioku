//
//  MenuViewController.swift
//  ARKitInteraction
//
//  Created by Jenny Ferina on 3/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import AudioToolbox
import AVKit
import AVFoundation

class MenuViewController: UIViewController {

    var play = false
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //playAudio()
        // Do any additional setup after loading the view.
        
        guard let path = Bundle.main.path(forResource: "Spring beach1", ofType: "wav") else
        {
            fatalError("Could not find audio")
        }
        let fileURL = URL(fileURLWithPath: path)
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            guard let audioPlayer = audioPlayer else {return}
            audioPlayer.prepareToPlay()
            var audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            }
            //audioPlayer.delegate = self
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
            print("playing")
        } catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    func playVid()
    {
        guard let path = Bundle.main.path(forResource: "Background Slides", ofType: "m4v") else
        {
            fatalError("Could not find video")
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true)
        {
            player.play()
        }
    }
    
    func playAudio()
    {
 
//        do {
//            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
//        } catch let error as NSError {
//            print("audioSession error: \(error.localizedDescription)")
//        }
 
        
    }
    
    @IBAction func newRoutePressed(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
    }
    
    @IBAction func loadRoutePressed(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
    }
    
    @IBAction func learnMorePressed(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
        playVid()
    }
    

    @IBAction func settingsPressed(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1519)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.pause()
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
