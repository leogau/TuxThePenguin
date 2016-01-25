//
//  GameViewController.swift
//  Tux the Penguin
//
//  Created by Leo Gau on 1/14/16.
//  Copyright (c) 2016 Leo Gau. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    var musicPlayer = AVAudioPlayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let menuScene = MenuScene()
        let skView = self.view as! SKView
        
        menuScene.size = view.bounds.size
        skView.presentScene(menuScene)
        
        let musicUrl = NSBundle.mainBundle().URLForResource("Sound/BackgroundMusic", withExtension: "m4a")
        if let url = musicUrl {
            do {
                musicPlayer = try AVAudioPlayer(contentsOfURL: url)
                musicPlayer.numberOfLoops = -1
                musicPlayer.prepareToPlay()
                musicPlayer.play()
            } catch {
                print("something went wrong with the audio")
            }
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
