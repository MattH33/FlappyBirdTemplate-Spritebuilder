//
//  Character.m
//  FlappyBird
//
//  Created by Gerald on 2/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Character.h"
#import "GamePlayScene.h"

@implementation Character

- (void)didLoadFromCCB
{
    //Positions the character within the scene and sets up the collision type for the character when it hits another physics object.
    self.position = ccp(115, 250);
    self.zOrder = DrawingOrderHero;
    self.physicsBody.collisionType = @"character";
}

//Defines the flap method. This will make the character move upwards by a set amount.
- (void)flap
{
    [self.physicsBody applyImpulse:ccp(0, 400.f)];
}

@end
