//
//  MainScene.m
//  FlappyBird
//
//  Created by Matt H on 2015-11-16.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"

//Sets up a parallax effect that will be used on the moving background.
@interface CGPointObject : NSObject
{
    CGPoint _ratio;
    CGPoint _offset;
    CCNode *__unsafe_unretained _child; // weak ref
}
@property (nonatomic,readwrite) CGPoint ratio;
@property (nonatomic,readwrite) CGPoint offset;
@property (nonatomic,readwrite,unsafe_unretained) CCNode *child;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end

@implementation MainScene {
    
    //Creates variables to define the parallax ratios of the bushes and clouds.
    CGPoint _cloudParallaxRatio;
    CGPoint _bushParallaxRatio;
    CCNode *_parallaxContainer;
    CCParallaxNode *_parallaxBackground;
    
    //Connects the ground, cloud, and bush objects created in Spritebuilder to code variables.
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    CCNode *_cloud1;
    CCNode *_cloud2;
    NSArray *_clouds;
    CCNode *_bush1;
    CCNode *_bush2;
    NSArray *_bushes;
    
    NSTimeInterval _sinceTouch;
    
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_nameLabel;
    
    int points;
}


- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    
    //Places the identical grounds, clouds, and bushes into their own arrays, to be used as loops.
    _grounds = @[_ground1, _ground2];
    _clouds = @[_cloud1, _cloud2];
    _bushes = @[_bush1, _bush2];
    
    //Makes the bushes and clouds children of the CCParallaxNode.
    _parallaxBackground = [CCParallaxNode node];
    [_parallaxContainer addChild:_parallaxBackground];
    
    //The bush parallax ratio is larger than the cloud, because the clouds would be further away.
    _bushParallaxRatio = ccp(0.9, 1);
    _cloudParallaxRatio = ccp(0.5, 1);
    
    //Sets the bushes up when the scene loads
    for (CCNode *bush in _bushes) {
        CGPoint offset = bush.position;
        [self removeChild:bush];
        [_parallaxBackground addChild:bush z:0 parallaxRatio:_bushParallaxRatio positionOffset:offset];
    }
    
    //Sets the clouds up when the scene loads.
    for (CCNode *cloud in _clouds) {
        CGPoint offset = cloud.position;
        [self removeChild:cloud];
        [_parallaxBackground addChild:cloud z:0 parallaxRatio:_cloudParallaxRatio positionOffset:offset];
    }
    
    for (CCNode *ground in _grounds) {
        
        //Sets the ground's collision type.
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    
    //Sets this class as delegate
    physicsNode.collisionDelegate = self;
    
    _obstacles = [NSMutableArray array];
    points = 0;
    _scoreLabel.visible = true;
    
    [super initialize];
}

#pragma mark - Touch Handling

//Defines how touch events are handled.
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        [character.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
        
        @try
        {
            [super touchBegan:touch withEvent:event];
        }
        @catch(NSException* ex)
        {
            
        }
    }
}

#pragma mark - Game Actions

//Defines the gameOver method, which is called when the character collides with another object. This makes the restart button appear, stops the camera scrolling, makes the screen shake, and stops the character.
- (void)gameOver {
    if (!_gameOver) {
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        
        character.physicsBody.velocity = ccp(0.0f, character.physicsBody.velocity.y);
        character.rotation = 90.f;
        character.physicsBody.allowsRotation = FALSE;
        [character stopAllActions];
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        
        [self runAction:bounce];
    }
}

//Defines the restart method, which resets the scene.
- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

#pragma mark - Obstacle Spawning

//Defines the method that adds obstacles to the scene.
- (void)addObstacle {
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    CGPoint screenPosition = [self convertToWorldSpace:ccp(380, 0)];
    CGPoint worldPosition = [physicsNode convertToNodeSpace:screenPosition];
    obstacle.position = worldPosition;
    [obstacle setupRandomPosition];
    obstacle.zOrder = DrawingOrderPipes;
    [physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

#pragma mark - Update

//Defines the method that shows how many pipes the player has passed.
- (void)showScore
{
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    _scoreLabel.visible = true;
}

- (void)update:(CCTime)delta
{
    //Defines the tilt and descent of the character when a user hasn't tapped the screen.
    _sinceTouch += delta;
    
    character.rotation = clampf(character.rotation, -30.f, 90.f);
    
    if (character.physicsBody.allowsRotation) {
        float angularVelocity = clampf(character.physicsBody.angularVelocity, -2.f, 1.f);
        character.physicsBody.angularVelocity = angularVelocity;
    }
    
    if ((_sinceTouch > 0.5f)) {
        [character.physicsBody applyAngularImpulse:-40000.f*delta];
    }
    
    physicsNode.position = ccp(physicsNode.position.x - (character.physicsBody.velocity.x * delta), physicsNode.position.y);
    
    //Loops the ground.
    for (CCNode *ground in _grounds) {
        //Get the world position of the ground
        CGPoint groundWorldPosition = [physicsNode convertToWorldSpace:ground.position];
        //Get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        //If the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
        

    }
    
    //Handles what happens to obstacles that aren't visible on the screen.
    NSMutableArray *offScreenObstacles = nil;
    
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
    }
    
    if (!_gameOver)
    {
        @try
        {
            character.physicsBody.velocity = ccp(80.f, clampf(character.physicsBody.velocity.y, -MAXFLOAT, 200.f));
            
            [super update:delta];
        }
        @catch(NSException* ex)
        {
            
        }
    }
    
    _parallaxBackground.position = ccp(_parallaxBackground.position.x - (character.physicsBody.velocity.x * delta), _parallaxBackground.position.y);
    
    //Loops the bushes and gives them a parallax effect.
    for (CCNode *bush in _bushes) {
        //Gets the world position of the bush.
        CGPoint bushWorldPosition = [_parallaxBackground convertToWorldSpace:bush.position];
        //Gets the screen position of the bush.
        CGPoint bushScreenPosition = [self convertToNodeSpace:bushWorldPosition];
        
        //If the left corner is one complete width off the screen, move it to the right.
        if (bushScreenPosition.x <= (-1 * bush.contentSize.width)) {
            for (CGPointObject *child in _parallaxBackground.parallaxArray) {
                if (child.child == bush) {
                    child.offset = ccp(child.offset.x + 2*bush.contentSize.width, child.offset.y);
                }
            }
        }
    }
    
    //Loops the clouds and gives them a parallax effect.
    for (CCNode *cloud in _clouds) {
        //Gets the world position of the cloud
        CGPoint cloudWorldPosition = [_parallaxBackground convertToWorldSpace:cloud.position];
        //Gets the screen position of the cloud
        CGPoint cloudScreenPosition = [self convertToNodeSpace:cloudWorldPosition];
        
        //If the left corner is one complete width off the screen, move it to the right.
        if (cloudScreenPosition.x <= (-1 * cloud.contentSize.width)) {
            for (CGPointObject *child in _parallaxBackground.parallaxArray) {
                if (child.child == cloud) {
                    child.offset = ccp(child.offset.x + 2*cloud.contentSize.width, child.offset.y);
                }
            }
        }
    }
}

//If the character collides with an object, game over is called.
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair character:(CCSprite*)character level:(CCNode*)level {
    [self gameOver];
    return TRUE;
}

//If the character passes through an obstacle, increase their points by 1.
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)character goal:(CCNode *)goal {
    [goal removeFromParent];
    points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    return TRUE;
}

@end
