//
//  BattleViewController.swift
//  TechMon
//
//  Created by 井戸海里 on 2020/09/15.
//  Copyright © 2020 IdoUmi. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    //プレイヤーの関連付けするパーツ
    @IBOutlet var playerNameLabel:UILabel!
    @IBOutlet var playerImageView:UIImageView!
    @IBOutlet var playerHPLabel:UILabel!
    @IBOutlet var playerMPLabel:UILabel!
    @IBOutlet var playerTPLabel:UILabel!
    //敵の関連付けするパーツ
    @IBOutlet var enemyNameLabel:UILabel!
    @IBOutlet var enemyImageView:UIImageView!
    @IBOutlet var enemyHPLabel:UILabel!
    @IBOutlet var enemyMPLabel:UILabel!
    
    //音楽再生で使う便利クラス
    let techMonManeger = TechMonManager.shared
    //キャラクターのステータス
    //var playerHP = 100
    //var playerMP = 0
    //var enemyHP = 200
    //var enemyMP = 0
    
    var player: Character!
    var enemy: Character!
    
    //ゲーム用タイマー
    var gameTimer : Timer!
    //プレイヤーが攻撃できるかどうか
    var isPlayerAttackAvailable :Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //キャラクターの読み込み
        player = techMonManeger.player
        enemy = techMonManeger.enemy
        
        //プレイヤーのステータスを反映
        playerNameLabel.text = "勇者"
        playerImageView.image = UIImage(named: "yusya.png")
        //playerHPLabel.text = "\(player.maxHP) / \(player.maxHP)"
        //playerMPLabel.text = "\(player.maxMP) / \(player.maxMP)"
        
        //敵のステータスを反映
        enemyNameLabel.text = "龍"
        enemyImageView.image = UIImage(named: "monster.png")
        //enemyHPLabel.text = "\(enemy.maxHP) / \(enemy.maxHP)"
        //enemyMPLabel.text = "\(enemy.maxMP) / \(enemy.maxMP)"

        //ゲームタイマーを作る
        gameTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateGame),
            userInfo: nil,
            repeats: true)
        //ゲームタイマー開始
        gameTimer.fire()
        // Do any additional setup after loading the view.
    }
    
    func updateUI(){
        
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        techMonManeger.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        techMonManeger.stopBGM()
    }
    //0.1秒ごとにゲームの状態を更新する
    @objc func updateGame(){
        //プレイヤーのステータスを更新
        player.currentMP += 1
        //MPが20を超えたら攻撃できるようにする、21を超えない
        if player.currentMP >= 20{
            
            isPlayerAttackAvailable = true
            player.currentMP = 20
        }else {
            isPlayerAttackAvailable = false
        }
        //敵のステータスを更新
        enemy.currentMP += 1
        //敵はMPが35までいったら自動で攻撃する
        if enemy.currentMP >= 35{
            
            enemyAttack()
            enemy.currentMP = 0
        }
        
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
    }
    //敵の攻撃
    func enemyAttack(){
        
        techMonManeger.damageAnimation(imageView: playerImageView)
        techMonManeger.playSE(fileName: "SE_attack")
        
        player.currentHP -= 20
        
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        
        if player.currentHP <= 0 {
            
            finishBattle(vanishImageView : playerImageView,isPlayerWin:false)
            
        }
        
    }
    
    func judgeBattle(){
        
        if player.currentHP <= 0 {
            
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }else if enemy.currentHP <= 0{
            
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    //勝敗が決定した時の処理
    func finishBattle(vanishImageView:UIImageView,isPlayerWin:Bool){
        //BGMやタイマーを止めておく
        techMonManeger.vanishAnimation(imageView: vanishImageView)
        techMonManeger.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        //勝敗結果で音楽をメッセージを変える
        var finishMessage :String = ""
        if isPlayerWin{
            
            techMonManeger.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！"
        }else{
            
            techMonManeger.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北"
        }
        //アラートを作成する
        let alert = UIAlertController(
            title: "バトル終了",
            message: finishMessage,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"OK",style: .default,handler: {_ in
            //OKボタンを押したら消える
            self.dismiss(animated: true, completion: nil)
            
        }))
        //アラートを表示
        present(alert,animated: true,completion: nil)
        
    }
    //攻撃のメソッド
    @IBAction func attackActton(){
        
        if isPlayerAttackAvailable {
            
            techMonManeger.damageAnimation(imageView: enemyImageView)
            techMonManeger.playSE(fileName: "SE_attack")
            
            enemy.currentHP -= player.attackPoint
            
            enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP {
                
                player.currentTP = player.maxTP
                
                
            }
            player.currentMP = 0
            
            updateUI()
        }
        
        judgeBattle()
        
    }
    
    @IBAction func tameruAction(){
        
        if isPlayerAttackAvailable{
            
            techMonManeger.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP {
                
                player.currentTP = player.maxTP
                
                playerTPLabel.text = "\(player.currentTP) / \(player.maxTP) "
            }
            player.currentMP = 0
            
            updateUI()
        }
    }
    @IBAction func fireAction(){
        
        if isPlayerAttackAvailable && player.currentTP >= 40 {
            
            techMonManeger.damageAnimation(imageView: enemyImageView)
            techMonManeger.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            if player.currentTP <= 0 {
                
                player.currentTP = 0
                
                
            player.currentMP = 0
            
        }
            updateUI()
                       
                       judgeBattle()
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
}
