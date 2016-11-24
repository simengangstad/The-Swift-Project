//
//  BreakOutView.swift
//  BreakOut
//
//  Created by Simen Gangstad on 19.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

struct Rect {
    var rows: Int
    var columns: Int
}

class Brick: UIView {}

class BreakOutView: NamedBezierPathsView, UICollisionBehaviorDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        brickCount = Rect(rows: 5, columns: 4)
        amountOfBalls = _amountOfBalls
        
        paddle = UIView()
        paddle.backgroundColor = paddleColour
        brickBehavior.addItem(paddle)
        collider.addItem(paddle)
        addSubview(paddle)
    }
    
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        return animator
    }()
    
    private lazy var collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.collisionDelegate = self
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    
    
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
        
        if let brick = item1 as? Brick {
            removeBrick(brick: brick)
        }
        
        if let brick = item2 as? Brick {
            removeBrick(brick: brick)
        }
    }
    
    private func removeBrick(brick: UIView) {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            brick.backgroundColor = UIColor.red
            
        }, completion: { [unowned self] (bool: Bool) in
        
            brick.removeFromSuperview()
            self.collider.removeItem(brick)
            self.brickBehavior.removeItem(brick)
        })
    }
    
    private let brickBehavior: UIDynamicItemBehavior = {
        let dib = UIDynamicItemBehavior()
        dib.allowsRotation = false
        dib.density = 10000.0
        dib.elasticity = 1.0
        dib.resistance = 1.0
        dib.friction = 1.0
        return dib
    }()
    
    public var brickSpacing: CGFloat = 5
    public var brickColour: UIColor = UIColor.blue
    
    private var bricks = [[Brick?]]()
    
    private static let BrickIdentifier: String = "brick"
    
    public var brickCount: Rect = Rect(rows: 5, columns: 4) {

        willSet {
            if !bricks.isEmpty {
                for row in 0..<brickCount.rows {
                    for column in 0..<brickCount.columns {
                        if let brick = bricks[row][column] {
                            brick.removeFromSuperview()
                            brickBehavior.removeItem(brick)
                            collider.removeItem(brick)
                        }
                    }
                }
            }
        }
        
        didSet {
            bricks = [[Brick]]()
            
            for _ in 0..<brickCount.rows {
                var tmp = [Brick]()
                for _ in 0..<brickCount.columns {
                    let brick = Brick()
                    brick.accessibilityIdentifier = BreakOutView.BrickIdentifier
                    brick.backgroundColor = brickColour
                    tmp.append(brick)
                    brickBehavior.addItem(brick)
                    collider.addItem(brick)
                    addSubview(brick)
                }
                bricks.append(tmp)
            }
            
            setNeedsLayout()
        }
    }
    
    func updateFramesOfBricks() {
        for row in 0..<brickCount.rows {
            for column in 0..<brickCount.columns {
                if let brick = bricks[row][column] {
                    brick.frame = CGRect(origin: positionOfBrick(forRow: row, andColumn: column), size: CGSize(width: widthOfBrick, height: heightOfBrick))
                }
            }
        }
    }
    
    
    private var paddle: UIView!
    
    public var paddleColour: UIColor = UIColor.green
    
    private var lastPaddleOrigin: CGPoint!
    private var lastViewSize: CGSize?
    
    func movedPaddle(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
        
        let dx = recognizer.translation(in: self)
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        var x = paddle.frame.origin.x + dx.x
        
        if x < bounds.origin.x + brickSpacing {
            x = brickSpacing
        }
        else if x + paddleSize.width + brickSpacing > bounds.size.width {
            x = bounds.size.width - paddleSize.width - brickSpacing
        }
        
        paddle.frame.origin = CGPoint(x: x, y: paddle.frame.origin.y)
        
        animator.updateItem(usingCurrentState: paddle)
            
        default: break
        }
    }
    
    public var ballColour: UIColor = UIColor.red
    
    private var _amountOfBalls = 1
    
    public var amountOfBalls: Int? {
        didSet {
            
            if balls.count < amountOfBalls! {
                while balls.count < amountOfBalls! {
                    let ball = newBall
                    balls.append(ball)
                    addSubview(ball)
                    ballBehaviour.add(item: ball)
                    collider.addItem(ball)
                }
            }
            else {
                while balls.count > amountOfBalls! {
                    let last = balls.removeLast()!
                    last.removeFromSuperview()
                    ballBehaviour.remove(item: last)
                    collider.removeItem(last)
                }
            }
            
            setNeedsLayout()
        }
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            
            let tapPosition = recognizer.location(in: self)
            for ball in balls {
                var vectorToBall = CGVector(dx: (ball?.frame.origin.x)! - tapPosition.x, dy: (ball?.frame.origin.y)! - tapPosition.y)
                let sizeOfVector = sqrt(pow(vectorToBall.dx, 2) + pow(vectorToBall.dy, 2))
                vectorToBall.dx /= sizeOfVector
                vectorToBall.dy /= sizeOfVector
                
                ballBehaviour.pushBehavior.pushDirection = vectorToBall
        }
            
        default: break
        }
    }

    public var animating = false {
        didSet {
            if animating {
                animator.addBehavior(collider)
                animator.addBehavior(ballBehaviour)
                animator.addBehavior(brickBehavior)
            }
            else {
                animator.removeBehavior(collider)
                animator.removeBehavior(ballBehaviour)
                animator.removeBehavior(brickBehavior)
            }
        }
    }
    
    private lazy var ballBehaviour = BallBehaviour()
    
    private var balls = [UIView?]()
    
    public let ballRadius: CGFloat = 20
    
    private var newBall: UIView {
        let ball = UIView()
        ball.backgroundColor = ballColour
        return ball
    }
    
    struct Paths {
        static let Paddle = 99
    }
    
    private var paddleSize: CGSize {
        return CGSize(width: widthOfBrick, height: heightOfBrick / 2.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        if paddle.frame.origin == CGPoint(x: 0.0, y: 0.0) {
            
            let origin = CGPoint(x: bounds.width / 2.0 - widthOfBrick / 2.0, y: bounds.height - heightOfBrick / 2.0 - brickSpacing)
            paddle.frame = CGRect(origin: origin, size: paddleSize)
            lastViewSize = bounds.size
        }
        else {
            
            let scale = (paddle.frame.origin.x == 0.0 ? 1.0 : paddle.frame.origin.x) / (lastViewSize?.width ?? 1.0)
            let origin = CGPoint(x: bounds.width * scale, y: bounds.height - brickSpacing - heightOfBrick / 2.0)
            paddle.frame = CGRect(origin: origin, size: paddleSize)
            lastViewSize = bounds.size
        }
        
        for ball in balls {
            let position = CGPoint(x: bounds.width / 2.0 - ballRadius / 2.0, y: bounds.height - heightOfBrick / 2.0 - brickSpacing - 2 * heightOfBrick)
            ball?.frame.origin = position
            ball?.frame.size = CGSize(width: ballRadius, height: ballRadius)
        }
        
        /*let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: bounds.height))
        path.addLine(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: bounds.width, y: 0.0))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        
        bezierPaths["boundary"] = path
        collider.removeBoundary(withIdentifier: "boundary" as NSCopying)
        collider.addBoundary(withIdentifier: "boundary" as NSCopying, for: path)
        */
        updateFramesOfBricks()
    }
    
    private func positionOfBrick(forRow row: Int, andColumn column: Int) -> CGPoint {
        
        return CGPoint(x: CGFloat(row) * widthOfBrick + brickSpacing * CGFloat(row + 1),
                       y: CGFloat(column) * heightOfBrick + brickSpacing * CGFloat(column + 1))
    }
    
    private var widthOfBrick: CGFloat {
        return (bounds.width - brickSpacing * CGFloat(brickCount.rows + 1)) / CGFloat(brickCount.rows)
    }
    
    private var heightOfBrick: CGFloat {
        return (bounds.height / 2.0 - brickSpacing * CGFloat(brickCount.columns + 1)) / CGFloat(brickCount.columns)
    }
}
