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
}

-(void)update:(CCTime)delta
{
    // put update code here
}

//Method that defines what happens when a user taps the screen.
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    //This makes the character flap when the screen is touched.
    [character flap];
}

@end
