
import SpriteKit

import AVKit

import AVFoundation




class GameScene: SKScene, SKPhysicsContactDelegate {
    

    var scrollNode:SKNode!
    var wallNode: SKNode!
    var bird: SKSpriteNode!
    var item: SKSpriteNode!
    
    
    
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let itemCategory: UInt32 = 1 << 4
    
    
    
    var score = 0
    var ItemScore = 0
    
    let userDefaults:UserDefaults = UserDefaults.standard
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var scoreItemLabelNode:SKLabelNode!
    var bestItemScoreLabelNode:SKLabelNode!
    
    
    var soundPlayer: AVAudioPlayer!
    
    var musicPlayer: AVAudioPlayer!


    
 
    
    
    
    
    
    
    
    
    

    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)    // ←追加
        physicsWorld.contactDelegate = self
        
        


        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
            
        wallNode = SKNode()
        scrollNode.addChild(wallNode)

        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setItem()
        
        setupScoreLabel()
        
        setupItemScoreLabel()
    }

    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest

        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2

        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5)

        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)

        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))

        // groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)

            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )

            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理演算を設定する
            
            
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            sprite.physicsBody?.isDynamic = false
            
            
            

            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }

    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest

        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2

        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20)

        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)

        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))

        // スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする

            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )

            // スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
        
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    
    func setupWall() {
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y:0, duration:4)
        
        
        //自身を取り除くアクション作成
        let removeWall = SKAction.removeFromParent()
        
        
        // 2 つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //鳥が通り抜ける隙間の長さを鳥のサイズの３倍とする
        let slit_length = birdSize.height * 3
        //隙間位置の上下の振れ幅を鳥のサイズの３倍とする。１
        let random_y_range = birdSize.height * 3
        
        //下の壁のY幅下限位置（中央位置から下芳香の最大揺れ幅で下の壁を表示する位置を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        
        
        let createWallAnimation = SKAction.run ({
            //壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50
            
                //0 ~ random_y = CGFloat.random(in: 0..<random_y_range)
            let random_y = CGFloat.random(in: 0..<random_y_range)
            
            // Y軸の下限にランダムな値を足して。、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            
            under.physicsBody?.isDynamic = false
            
            
            wall.addChild(under)
            
            //上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            
            
            upper.physicsBody?.isDynamic = false
            
            
            wall.addChild(upper)
            
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2 , y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            
            wall.addChild(scoreNode)
            
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
            
            
            
        })
        
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
    }
    
    func setupBird() {
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        bird.physicsBody?.allowsRotation = false
        
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | itemCategory
        
        
        bird.run(flap)
        
        addChild(bird)
    }
    
    
    func setItem() {
        let itemTextureA = SKTexture(imageNamed:"abcdefghijkl")
        itemTextureA.filteringMode = .nearest

        let texturesAnimation = SKAction.animate(with: [itemTextureA], timePerFrame: 0.2)
        
        item = SKSpriteNode(texture: itemTextureA)

        item.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)

        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + itemTextureA.size().width)

        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)
        let birdSize = SKTexture(imageNamed: "bird_a").size()

        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        let random_y_range = self.frame.size.height
        
        let slit_length = birdSize.height * 3

        
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - itemTextureA.size().height / 2 - random_y_range / 2


        
        
        
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.zPosition = -50 // 雲より手前、地面より奥

            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y

            let under = SKSpriteNode(texture: itemTextureA)
//            under.position = CGPoint(x: 0, y: under_wall_y + 3)
            under.position = CGPoint(x: 0, y: under_wall_y)

            wall.position = CGPoint(x: self.frame.size.width + itemTextureA.size().width / 2, y: under_wall_y)
            

            
            

//            under.physicsBody?.categoryBitMask = self.itemCategory    // ←追加
            

            


            
            
//            let scoreNode = SKNode()
//            wall.position =  CGPoint(x: 0 , y: under_wall_y )
            under.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: itemTextureA.size().width, height: itemTextureA.size().height))
            
//            scoreNode.position = CGPoint(x: under.size.width + birdSize.width / 2 , y: self.frame.height / 2)
//            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: under.size.width, height: self.frame.size.height))
            under.physicsBody?.isDynamic = false
            under.physicsBody?.categoryBitMask = self.itemCategory
            under.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(under)

            
            




            // 上側の壁を作成
//            let upper = SKSpriteNode(texture: itemTextureA)
//            upper.position = CGPoint(x: 0, y: under_wall_y + itemTextureA.size().height + slit_length)
//
//            wall.addChild(upper)

            wall.run(wallAnimation)

            self.wallNode.addChild(wall)
        })

        
        
        let waitAnimation = SKAction.wait(forDuration: 2)

        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        

        wallNode.run(repeatForeverAnimation)


//        addChild(item)
    }
    
    
    

    
    func didBegin(_ contact: SKPhysicsContact) {
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            
            
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
//            }else if(contact.bodyA.categoryBitMask & itemCategory) == itemCategory ||
//                    (contact.bodyB.categoryBitMask & itemCategory) == itemCategory
//                {
//
//                print("ScoreUp")
//                    score += 1
//                    scoreLabelNode.text = "Score:\(score)"
//
//
//
//            }
                
            }
                
            }else if(contact.bodyA.categoryBitMask & itemCategory) == itemCategory ||
              (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
                var firstBody, secondBody: SKPhysicsBody




                print("ItemScoreUp")
                
                
                ItemScore += 1
                scoreItemLabelNode.text = "Item Score:\(ItemScore)"
                
                

                
                //音楽ファイルをbackmusic.mp3とした場合

                
//                if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//                    firstBody = contact.bodyA
//                    secondBody = contact.bodyB
//                } else {
//                    firstBody = contact.bodyB
//                    secondBody = contact.bodyA
//                }
                
                
                if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory {
                    contact.bodyA.node?.removeFromParent()
                }
                if (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
                    contact.bodyB.node?.removeFromParent()

                    
                }
    




                var itembestScore = userDefaults.integer(forKey: "Item BEST")

                if ItemScore > itembestScore {
                    itembestScore = ItemScore
                    bestItemScoreLabelNode.text = "Item Best Score:\(itembestScore)"
                    userDefaults.set(itembestScore, forKey: "Item BEST")
                    userDefaults.synchronize()
                    
                    
                    


            }


            
            //音楽ファイルをbackmusic.mp3とした場合
            let music = SKAction.playSoundFileNamed("bgm2.mp3",waitForCompletion: true)
//                let repeatMusic = SKAction.repeat(music, count: 10000)
                self.run(music)
                
            
            
            
        }else{
            print("GameOver")
            
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion: {
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        score = 0
        ItemScore = 0
        scoreLabelNode.text = "Score:\(score)"
        scoreItemLabelNode.text = "Item Score:\(ItemScore)"

        
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        
        wallNode.removeAllChildren()
        
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
        if scrollNode.speed > 0 {
        
        bird.physicsBody?.velocity = CGVector.zero
        
        
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy :15))
        
        } else if bird.speed == 0 {
            restart()
        }
    }
        
    func setupScoreLabel() {
        
        
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        
    }
    
    
    func setupItemScoreLabel() {
        
        
        ItemScore = 0
        scoreItemLabelNode = SKLabelNode()
        scoreItemLabelNode.fontColor = UIColor.black
        scoreItemLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 680)
        scoreItemLabelNode.zPosition = 100
        scoreItemLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreItemLabelNode.text = "ItemScore:\(ItemScore)"
        self.addChild(scoreItemLabelNode)
        
        bestItemScoreLabelNode = SKLabelNode()
        bestItemScoreLabelNode.fontColor = UIColor.black
        bestItemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 720)
        bestItemScoreLabelNode.zPosition = 100
        bestItemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let ItembestScore = userDefaults.integer(forKey: "Item BEST")
        bestItemScoreLabelNode.text = "Item Best Score:\(ItembestScore)"
        self.addChild(bestItemScoreLabelNode)
        
        
    }
    
    
    open func playSoundEffect(named fileName: String) {
         if let url = Bundle.main.url(forResource: fileName, withExtension: "") {
             soundPlayer = try? AVAudioPlayer(contentsOf: url)
             soundPlayer.stop()
             soundPlayer.numberOfLoops = 0
             soundPlayer.prepareToPlay()
             soundPlayer.play()
         }
     }
    
    
    open func playMusic(_ fileName: String, withExtension type: String = "") {
        if let url = Bundle.main.url(forResource: fileName, withExtension: type) {
            musicPlayer = try? AVAudioPlayer(contentsOf: url)
            musicPlayer.numberOfLoops = -1
            musicPlayer.prepareToPlay()
            musicPlayer.play()
        }
    }
    
}

