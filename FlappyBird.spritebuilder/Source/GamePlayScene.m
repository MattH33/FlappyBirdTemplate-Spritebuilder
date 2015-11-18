//
//  GamePlayScene.m
//  FlappyBird
//
//  Created by Matt H on 2015-11-16.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "GamePlayScene.h"
#import "Character.h"
#import "Obstacle.h"

@implementation GamePlayScene

- (void)initialize
{
    //Loads a new Character named "Character" from the CCB file(SpriteBuilder file).
    character = (Character*)[CCBReader load:@"Character"];
    
    //Adds the character as a child of physicsNode, so physics will be applied to it.
    [physicsNode addChild:character];
    
    //Makes an obstacle appear.
    [self addObstacle];
    timeSinceObstacle = 0.0f;
}

-(void)update:(CCTime)delta
//This will be run every frame. "delta" is the time that has elapsed since the last time it was run. This is usually once every second, but it can be more if the game slows down.
{
    //Increment the time since the last obstacle was added.
    timeSinceObstacle += delta;
    
    //Checks to see if two seconds have passed
    if (timeSinceObstacle > 2.0f)
    {
        //If it's been 2 seconds, add another obstacle.
        [self addObstacle];
        
        //Reset the timer so this process can run again.
        timeSinceObstacle = 0.0f;
    }
}

//Method that defines what happens when a user taps the screen.
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    //This makes the character flap when the screen is touched.
    [character flap];
}

@end
