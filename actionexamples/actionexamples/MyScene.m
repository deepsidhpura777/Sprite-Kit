//
//  MyScene.m
//  ActionExamples
//
//  Created by Deep Sidhpura on 7/2/14.
//  Copyright (c) 2014 Deep Sidhpura. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.29 green:0.75 blue:0.99 alpha:1.0];
        
        //create a platform. just a colored sprite
        SKSpriteNode *platform=[SKSpriteNode spriteNodeWithColor:[SKColor brownColor] size:CGSizeMake(100, 20)];
        platform.position=CGPointMake(50, 100);
        [self addChild:platform];
        
        //create first action
        SKAction *move=[SKAction moveByX:(size.width - platform.size.width) y:0 duration:2];
        //need a node to run it.
        //some actions are not reversible through reverse action method
        SKAction *moveBack=[move reversedAction];
        
        SKAction *wait=[SKAction waitForDuration:1.5];
        
        SKAction *backAndForth=[SKAction sequence:@[move,wait,moveBack,wait]];
        
        SKAction *repeater=[SKAction repeatActionForever:backAndForth];
        
        [platform runAction:repeater];
        
        
       
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    }

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
