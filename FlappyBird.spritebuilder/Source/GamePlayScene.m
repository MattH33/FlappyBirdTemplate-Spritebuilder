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
//This will be run every frame.
//delta is the time that has elapsed since the last time it was run. This is usually once every second, but can be bigger if the game slows down
{
    // Increment the time since the last obstacle was added
    timeSinceObstacle += delta; // delta is approximately 1/60th of a second
    
    // Check to see if two seconds have passed
    if (timeSinceObstacle > 2.0f)
    {
        // Add a new obstacle
        [self addObstacle];
        
        // Then reset the timer.
        timeSinceObstacle = 0.0f;
    }
}

//Method that defines what happens when a user taps the screen.
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    //This makes the character flap when the screen is touched.
    [character flap];
}

@end
