//
//  StartScene.m
//  MyFlappy
//
//  Created by Deep Sidhpura on 7/7/14.
//  Copyright (c) 2014 Deep Sidhpura. All rights reserved.
//

#import "StartScene.h"
#import "MyScene.h"

@interface StartScene () <SKPhysicsContactDelegate> {
    
    SKSpriteNode * _bird;
    SKColor *_skyColor;
    
}

@end


@implementation StartScene

-(instancetype)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        //Background set
        
        _skyColor=[SKColor colorWithRed:113/255 green:197 blue:207.0/255.0 alpha:1.0];
        [self setBackgroundColor:_skyColor];
        
        //Bird Specs
        
        SKTexture *birdTexture1=[SKTexture textureWithImageNamed:@"Bird1"];
        birdTexture1.filteringMode=SKTextureFilteringNearest;
        
        _bird=[SKSpriteNode spriteNodeWithTexture:birdTexture1];
        [_bird setScale:2.0];
        _bird.position=CGPointMake(self.frame.size.width /4, CGRectGetMidY(self.frame));
        [self addChild:_bird];
        
        //Ground specs
        
        SKTexture *groundtexture=[SKTexture textureWithImageNamed:@"Ground"];
        groundtexture.filteringMode=SKTextureFilteringNearest;
        
        for (int i=0; i < self.frame.size.width / (groundtexture.size.width)*2; ++i) {
            SKSpriteNode *sprite=[SKSpriteNode spriteNodeWithTexture:groundtexture];
            [sprite setScale:2.0];
            sprite.position=CGPointMake(i*sprite.size.width,sprite.size.height /2);
            [self addChild:sprite];
        }
        
        //sky specs
        SKTexture *skyLineTexture=[SKTexture textureWithImageNamed:@"Skyline"];
        skyLineTexture.filteringMode=SKTextureFilteringNearest;
        
        for (int i=0; i < self.frame.size.width / (skyLineTexture.size.width)*2; ++i) {
            SKSpriteNode *sprite=[SKSpriteNode spriteNodeWithTexture:skyLineTexture];
            [sprite setScale:2.0];
            sprite.zPosition=-20;
            sprite.position=CGPointMake(i*sprite.size.width,sprite.size.height /2 + groundtexture.size.height *2);
            [self addChild:sprite];
        }
        
    }
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    MyScene *firstScene=[MyScene sceneWithSize:self.size];
    [self.view presentScene: firstScene]; 
}

@end
