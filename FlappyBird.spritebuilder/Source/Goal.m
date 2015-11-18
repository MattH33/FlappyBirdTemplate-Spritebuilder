//
//  Goal.m
//  FlappyBird
//
//  Created by Matt H on 2015-11-16.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "Goal.h"

@implementation Goal

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"goal";
  self.physicsBody.sensor = YES;
}

@end
