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
}

-(void)update:(CCTime)delta
{
    // put update code here
}

// put new methods here
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    // this will get called every time the player touches the screen
    [character flap];
}

@end
