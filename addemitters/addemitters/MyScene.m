//
//  MyScene.m
//  AddEmitters
//
//  Created by Deep Sidhpura on 7/2/14.
//  Copyright (c) 2014 Deep Sidhpura. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene{
    
    SKSpriteNode *ship;
    SKEmitterNode *jetEngine;
    BOOL touching;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        touching=NO;
        //add bg
        SKSpriteNode *bg=[SKSpriteNode spriteNodeWithImageNamed:@"nightsky"];
        bg.position=CGPointMake(size.width/2, size.height/2);
        [self addChild:bg];
        
        //add spaceship
        
        ship=[SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        ship.position=CGPointMake(size.width/2, size.height/2);
        ship.scale=0.3;
        ship.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:ship.size];
        [self addChild:ship];
        
        //add emitter
        jetEngine=[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"EngineParticle" ofType:@"sks"]];
        
        jetEngine.numParticlesToEmit=1;
        jetEngine.position=CGPointMake(0, -180);
        
        [ship addChild:jetEngine];
        
        //edges of scene
        
        self.physicsBody=[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        //reduce gravity
        self.physicsWorld.gravity=CGVectorMake(0, -1);
        
        SKEmitterNode *myParticle=[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"]];
        myParticle.position=CGPointMake(size.height/2, size.width/2);
        [self addChild:myParticle];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touching=YES;
    jetEngine.numParticlesToEmit=0;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    touching=NO;
    jetEngine.numParticlesToEmit=100;
}

-(void)update:(CFTimeInterval)currentTime {
    
    //apply upward force
    if (touching) {
        [ship.physicsBody applyForce:CGVectorMake(0, 150)];
    }
    
}

@end
