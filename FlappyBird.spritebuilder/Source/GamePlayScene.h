//
//  GamePlayScene.h
//  FlappyBird
//
//  Created by Gerald on 2/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Character.h"

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrderHero
};

@interface GamePlayScene : CCNode <CCPhysicsCollisionDelegate>
{
    //Creates an instance of the game character.
    Character*     character;
    //References a node that simulates physics.
    CCPhysicsNode* physicsNode;
}

-(void) initialize;
-(void) addObstacle;
-(void) showScore;

@end