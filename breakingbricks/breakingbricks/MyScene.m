//
//  MyScene.m
//  BreakingBricks
//
//  Created by Deep Sidhpura on 7/1/14.
//  Copyright (c) 2014 Deep Sidhpura. All rights reserved.
//

#import "MyScene.h"
#import "EndScene.h"

@interface MyScene ()

@property(nonatomic,strong) SKSpriteNode *paddle;

@end

static const uint32_t ballCatagory=1;  // 2 power 0 ie 0th position
static const uint32_t brickCatagory=2; // 2 power 1 ie 1st position
static const uint32_t paddleCatagory=4; // 2 power 2 ie 2
static const uint32_t edgeCatagory=8;
static const uint32_t bottomEdgeCatagory=16;


/*
 Alternatively  use bitwise operators
 static const uint32_t ballCatagory=0x1;
 static const uint32_t ballCatagory=0x1 << 1;
 */


@implementation MyScene

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    /*if (contact.bodyA.categoryBitMask == brickCatagory) {
        NSLog(@" bodyA is a brick");
        [contact.bodyA.node removeFromParent];
    }
    if (contact.bodyB.categoryBitMask == brickCatagory) {
        NSLog(@" bodyB is a brick");
        [contact.bodyB.node removeFromParent];
    }*/
    
    SKPhysicsBody *notTheBall;  //we are getting that particular physics body and if its node is a brick, we are removing it.
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {  //We know the ball has least value
        notTheBall=contact.bodyB;
    }
    else{
        notTheBall=contact.bodyA;
    }
    
    if (notTheBall.categoryBitMask == brickCatagory) {
      // SKAction *playSFX=[SKAction playSoundFileNamed:@"brickhit.caf" waitForCompletion:NO];
       //[self runAction:playSFX];
        [notTheBall.node removeFromParent];
    }
    if(notTheBall.categoryBitMask==paddleCatagory){
        //SKAction *playSFX=[SKAction playSoundFileNamed:@"blip.caf" waitForCompletion:NO];//this means its a paddle.
        //[self runAction:playSFX];
    }
    
    if (notTheBall.categoryBitMask==bottomEdgeCatagory) {
        
        NSLog(@"intersected");
        EndScene *end=[EndScene sceneWithSize:self.size];
        [self.view presentScene:end transition:[SKTransition doorsCloseHorizontalWithDuration:1]];
    }
    
    
    
}


- (void)addBall:(CGSize)size {
    //create a new sprite node from an image
    SKSpriteNode *ball=[SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    //add sprite node to scene
    
    CGPoint myPoint=CGPointMake(size.width/2, size.height/2);
    ball.position=myPoint;
    
    //add a physics body to ball
    
    ball.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
    ball.physicsBody.friction=0;  //prevents the angle after collision from getting stuck
    ball.physicsBody.linearDamping=0; //energy it loses while moving through empty space
    ball.physicsBody.restitution=1; //Bounciness of the ball
    ball.physicsBody.categoryBitMask=ballCatagory;
    
    ball.physicsBody.contactTestBitMask=brickCatagory | paddleCatagory | bottomEdgeCatagory; // it will notify on contact with brick or paddle
    
    SKTextureAtlas *atlas=[SKTextureAtlas atlasNamed:@"orb"];
    NSArray *orbImageNames=[atlas textureNames];
    
    NSArray *sortedNames=[orbImageNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableArray *orbTextures=[NSMutableArray array];
    
    for (NSString *filename in sortedNames) {
        SKTexture *texture=[atlas textureNamed:filename];
        [orbTextures addObject:texture];
    }
    
    SKAction *glow=[SKAction animateWithTextures:orbTextures timePerFrame:0.1];
    SKAction *keepGlowing=[SKAction repeatActionForever:glow];
    [ball runAction:keepGlowing];
    
    
    [self addChild:ball];
    CGVector vector=CGVectorMake(7, 7);
    [ball.physicsBody applyImpulse:vector];
}

-(void) addPlayer:(CGSize)size{
    
    // create paddle sprite
    self.paddle=[SKSpriteNode spriteNodeWithImageNamed:@"paddle"];
    self.paddle.position=CGPointMake(size.width/2, 100);
    self.paddle.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:self.paddle.frame.size];
    self.paddle.physicsBody.dynamic=NO;
    self.paddle.physicsBody.categoryBitMask=paddleCatagory;
    
    
    //add to the scene
    [self addChild:self.paddle];
    
}

-(void) addBricks:(CGSize)size{
    
    for (int i=0; i < 4; i++) {
        SKSpriteNode *brick=[SKSpriteNode spriteNodeWithImageNamed:@"brick"];
        brick.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
        brick.physicsBody.dynamic=NO;
        brick.physicsBody.categoryBitMask=brickCatagory;
        
        int xPos=size.width /5 *(i+1);
        int yPos=size.height - 50;
        brick.position=CGPointMake(xPos, yPos);
        [self addChild:brick];
    }
}


-(void) addBottomEdge:(CGSize)size{  //We need a physics body but no particular node to add. therefore we choose an invisible node.
    SKNode *bottomEdge=[SKNode node];
    bottomEdge.physicsBody=[SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0,1) toPoint:CGPointMake(size.width,1)];
    bottomEdge.physicsBody.categoryBitMask=bottomEdgeCatagory;
    [self addChild:bottomEdge];
    
}




-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        CGPoint location=[touch locationInNode:self];
        CGPoint newPosition=CGPointMake(location.x, 100);
        
        //stop the paddle from going too far
        if(newPosition.x < self.paddle.size.width /2)
            newPosition.x=self.paddle.size.width/2;
        if(newPosition.x >self.size.width - (self.paddle.size.width / 2))
            newPosition.x=self.size.width - (self.paddle.size.width /2);
        self.paddle.position=newPosition;
    }
    
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor=[SKColor whiteColor];
        
        //adding a physics body to the scene
        
        self.physicsBody=[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask=edgeCatagory;
        
        self.physicsWorld.gravity=CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate=self; // notifying the physics world abt the delegate
        
        
        [self addBall:size];
        [self addPlayer:size];
        [self addBricks:size];
        [self addBottomEdge:size];
      
    }
    return self;
}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
