//
//  EndScene.m
//  BreakingBricks
//
//  Created by Deep Sidhpura on 7/2/14.
//  Copyright (c) 2014 Deep Sidhpura. All rights reserved.
//

#import "EndScene.h"
#import "MyScene.h"

@implementation EndScene


-(instancetype)initWithSize:(CGSize)size{
    
    if (self =[super initWithSize:size]) {
        
        
        //Add end sound later on.
        
        //create message
        
        self.backgroundColor=[SKColor blackColor];
        
        SKLabelNode *label=[SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        label.text=@"YOU LOSE";
        label.fontColor=[SKColor whiteColor];
        label.fontSize=40;
        label.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:label];
        
        //second label
        SKLabelNode *tryAgain=[SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        tryAgain.text=@"tap to play";
        tryAgain.fontColor=[SKColor whiteColor];
        tryAgain.fontSize=24;
        tryAgain.position=CGPointMake(CGRectGetMidX(self.frame), -50);
        
        SKAction *moveLabel=[SKAction moveToY:CGRectGetMidY(self.frame) -40 duration:2];
        
        [tryAgain runAction:moveLabel];
        
        [self addChild:tryAgain];
        
        
    }
    return self;
    
    
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    MyScene *firstScene=[MyScene sceneWithSize:self.size];
    [self.view presentScene:firstScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.5]];
}



@end
