//
//  MyScene.m
//  MyGame
//
//  Created by Deep Sidhpura on 7/7/14.
//  Copyright (c) 2014 Deep Sidhpura. All rights reserved.
//

#import "MyScene.h"



@implementation MyScene {
    
    SKSpriteNode *ship;
    SKEmitterNode *flames;
    SKEmitterNode *smoke;
    SKAction *movingMeteors;
    SKNode *_moving;
    SKNode *meteorGroup;
    BOOL canRestart;
    BOOL touching;
    
}

static const uint32_t shipCatagory=1 << 0;
static const uint32_t meteorCatagory=1 << 1;
static const uint32_t worldCatagory=1 << 2;


-(void) didBeginContact:(SKPhysicsContact *)contact{
    
    
    
    SKPhysicsBody *notTheShip;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {  //We know the ball has least value
        notTheShip=contact.bodyB;
    }
    else{
        notTheShip=contact.bodyA;
    }
    
    if (notTheShip.categoryBitMask == meteorCatagory) {
       
        _moving.speed=0;
        canRestart=YES;
        ship.physicsBody.collisionBitMask=worldCatagory;
        if (smoke) {
            [smoke removeFromParent];
        }
        
            smoke=[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"]];
            smoke.position=CGPointMake(-130, -30);
            [ship addChild:smoke];
        
    
    }
   
    
}

-(void) resetScene {
 
    ship.position=CGPointMake(100, self.frame.size.height/2);
    ship.speed=1;
    
    ship.physicsBody.collisionBitMask=meteorCatagory | worldCatagory ;
    
    canRestart=NO;
    
    [meteorGroup removeAllChildren];
    [smoke removeFromParent];
    NSLog(@"Removed");
    
    _moving.speed=1;
    
    
}




-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.physicsBody=[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask=worldCatagory;
        self.physicsBody.collisionBitMask=shipCatagory;
        
        self.physicsWorld.gravity=CGVectorMake(0, -1);
        touching=NO;
        
        _moving=[SKNode node];
        [self addChild:_moving];
        
        meteorGroup=[SKNode node];
        [_moving addChild:meteorGroup];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        ship.scale=0.12;
        ship.position=CGPointMake(100, size.height/2);
        
        
        ship.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:ship.size];
        ship.physicsBody.allowsRotation=NO;
        
        ship.physicsBody.categoryBitMask=shipCatagory;
        ship.physicsBody.collisionBitMask=meteorCatagory | worldCatagory;
        ship.physicsBody.contactTestBitMask=meteorCatagory | worldCatagory;
        
        flames=[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Flames" ofType:@"sks"]];
        flames.position=CGPointMake(-190,0);
        flames.numParticlesToEmit=1;
    
        
        [ship addChild:flames];
        
        [self addChild:ship];
        
        //Setting up the background.
        
        SKTexture *spaceTexture=[SKTexture textureWithImageNamed:@"Galaxy"];
        spaceTexture.filteringMode=SKTextureFilteringNearest;

            //adding actions.
        SKAction *moveSpace=[SKAction moveByX:-spaceTexture.size.width *2 y:0 duration:10];
        SKAction *resetSpace=[SKAction moveByX:spaceTexture.size.width *2 y:0 duration:0];
        SKAction *repeatAction=[SKAction repeatActionForever:[SKAction sequence:@[moveSpace,resetSpace]]];
        
        
        for (int i=0; i < 7 ; i++) {
            
            SKSpriteNode *space=[SKSpriteNode spriteNodeWithTexture:spaceTexture];
            space.position=CGPointMake(i*space.size.width,size.height/2);
            space.zPosition=-20;
            [space runAction:repeatAction];
            [_moving addChild:space];
            
            
        }
            //adding meteors
        
        
        SKAction *moveMeteor=[SKAction moveByX:-(self.frame.size.width + 500) y:0 duration:3];
        SKAction *removeMeteor=[SKAction removeFromParent];
        movingMeteors=[SKAction sequence:@[moveMeteor ,removeMeteor]];
        
        
      
        
        SKAction *spawn=[SKAction performSelector:@selector(meteorGeneration) onTarget:self];
        SKAction *delay=[SKAction waitForDuration:1.0];
        SKAction *spawnThenDelay=[SKAction sequence:@[spawn,delay]];
        SKAction *spawnForever=[SKAction repeatActionForever:spawnThenDelay];
        [self runAction:spawnForever];

        
        //Notifying abt contact
        self.physicsWorld.contactDelegate=self;
    }
    return self;
}

-(void) meteorGeneration{
    
    
    
  SKEmitterNode *meteorFlames=[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MeteorFlames" ofType:@"sks"]];
    
    meteorFlames.numParticlesToEmit=0;
    meteorFlames.position=CGPointMake(650, 0);
    
    CGFloat y= arc4random() % (NSInteger)(self.frame.size.height-100);
    
    SKSpriteNode *meteor=[SKSpriteNode spriteNodeWithImageNamed:@"Meteor"];
    meteor.position=CGPointMake(self.frame.size.width + meteor.size.width , y + 50);
    meteor.scale=0.04;
    meteor.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:meteor.size.width / 2];
    
    meteor.physicsBody.categoryBitMask=meteorCatagory;
    meteor.physicsBody.contactTestBitMask=shipCatagory;
    
    
    
    meteor.physicsBody.dynamic=NO;
    [meteor runAction:movingMeteors];
    [meteor addChild:meteorFlames];
    
    [meteorGroup addChild:meteor];
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    touching=YES;
    flames.numParticlesToEmit=0;  //unlimited particles
    
    if (canRestart) {
        [self resetScene];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    touching=NO;
    flames.numParticlesToEmit=100;
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (touching && _moving.speed > 0) {
        
        [ship.physicsBody applyForce:CGVectorMake(0, 27)];
    }
}

@end
