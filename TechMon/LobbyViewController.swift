//
//  LobbyViewController.swift
//  TechMon
//
//  Created by 井戸海里 on 2020/09/15.
//  Copyright © 2020 IdoUmi. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {
    //名前とスタミナのラベル宣言
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var staminaLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    //スタミナの変数宣言
    var stamina : Int = 100
    var staminaTimaer : Timer!

    //アプリが起動した時に一度呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UIの設定
        nameLabel.text = "勇者"
        staminaLabel.text = "\(stamina)/100"
        //タイマーを作る
        staminaTimaer = Timer.scheduledTimer(
            timeInterval: 3,
            target: self,
            selector: #selector(updateStaminaValue),
            userInfo: nil,
            repeats: true)
        
        staminaTimaer.fire()

        // Do any additional setup after loading the view.
    }
    //ロビー画面が見えるようになる時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        techMonManager.playBGM(fileName : "lobby")
    }
    //ロビー画面が見えなくなる時に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        techMonManager.stopBGM()
    }
    //冒険に行くボタンを押した時にする処理
    @IBAction func toBattle(){
        //スタミナが50以上あれば消費しに戦闘画面へ
        if stamina > 50 {
            
            stamina -= 50
            staminaLabel.text = "\(stamina)/100"
            performSegue(withIdentifier: "toBattle", sender: nil)
            //それ以外ならアラートを出す
        }else{
            
            let alert = UIAlertController(
                title:"バトルに行けません",
                message:"スタミナをためてください",
                preferredStyle: .alert)
            //ボタンをつくる
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            //アラートを表示する
            present(alert,animated: true,completion: nil)
        }
        
    }
    //スタミナの回復メソッド
    @objc func updateStaminaValue(){
        
        if stamina < 100{
            
            stamina += 1
            staminaLabel.text = "\(stamina)/100"
        }
        
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
