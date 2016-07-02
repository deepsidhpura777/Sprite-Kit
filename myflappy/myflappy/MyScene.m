//
//  MyScene.m
//  MyFlappy
//
//  Created by Deep Sidhpura on 7/3/14.
//  Copyright (c) 2014 Deep Sidhpura. All rights reserved.
//

#import "MyScene.h"


@interface MyScene () <SKPhysicsContactDelegate> {
    
    SKSpriteNode * _bird;
    SKColor *_skyColor;
    SKTexture *_pipeTexture1;
    SKTexture *_pipeTexture2;
    SKAction *_moveAndRemovePipes;
    SKNode *_pipes;
    SKNode *_moving;
    BOOL _canRestart;
    SKLabelNode *_scoreLabelnode;
    NSInteger _score;
}

@end

@implementation MyScene

static NSInteger const kVerticalPipeGap=100;

static const uint32_t birdCatagory=1 << 0;
static const uint32_t worldCatagory=1 << 1;
static const uint32_t pipeCatagory=1 << 2;
static const uint32_t scoreCatagory=1<<3;



-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    if (_moving.speed > 0) {
        
        if ((contact.bodyA.categoryBitMask & scoreCatagory)==scoreCatagory || (contact.bodyB.categoryBitMask & scoreCatagory)==scoreCatagory) {
            _score++;
            _scoreLabelnode.text=[NSString stringWithFormat:@"%d",_score];
            
        }
        else{
        _moving.speed=0;
        _bird.physicsBody.collisionBitMask=worldCatagory;
        [_bird runAction:[SKAction rotateByAngle:M_PI * _bird.position.y *0.01 duration:_bird.position.y * 0.03] completion:^{
            _bird.speed=0;
        } ];
    
    //Flash Background if contact is detected.
            [self removeActionForKey:@"flash"];
            [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
                self.backgroundColor=[SKColor redColor];
                }] , [SKAction waitForDuration:0.05] ,[SKAction runBlock:^{
        self.backgroundColor=_skyColor;
                }],[SKAction waitForDuration:0.05]]] count:4],[SKAction runBlock:^{
                    _canRestart=YES;
                }]]] withKey:@"flash"];
    
        }
    }
}

-(void) resetScene{
    
    _bird.position=CGPointMake(self.frame.size.width /4, CGRectGetMidY(self.frame));
    _bird.physicsBody.velocity=CGVectorMake(0, 0);
    _bird.physicsBody.collisionBitMask=worldCatagory | pipeCatagory;
    _bird.speed=1.0;
    _bird.zRotation=0.0;
    
    _score=0;
    _scoreLabelnode.text=[NSString stringWithFormat:@"%d",_score];
    
    [_pipes removeAllChildren];
    
    _canRestart=NO;
    
    _moving.speed=1;


}



-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        _score=0;
        _scoreLabelnode=[SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
        _scoreLabelnode.position=CGPointMake(CGRectGetMidX(self.frame), 3*self.frame.size.height / 4);
        _scoreLabelnode.zPosition=100;
        _scoreLabelnode.text=[NSString stringWithFormat:@"%d",_score];
        [self addChild:_scoreLabelnode];
        
        
        self.physicsWorld.gravity=CGVectorMake(0.0, -3.0);
        self.physicsWorld.contactDelegate=self;
        
        _moving=[SKNode node];
        [self addChild:_moving];
        
        _pipes=[SKNode node];
        [_moving addChild:_pipes];
        
        //Background set
        
        _skyColor=[SKColor colorWithRed:113/255 green:197 blue:207.0/255.0 alpha:1.0];
        [self setBackgroundColor:_skyColor];
        
        
        //Bird Specs
        
        SKTexture *birdTexture1=[SKTexture textureWithImageNamed:@"Bird1"];
        birdTexture1.filteringMode=SKTextureFilteringNearest;
        
        SKTexture *birdTexture2=[SKTexture textureWithImageNamed:@"Bird2"];
        birdTexture2.filteringMode=SKTextureFilteringNearest;
        
        SKAction *flap=[SKAction repeatActionForever:[SKAction animateWithTextures:@[birdTexture1,birdTexture2] timePerFrame:0.2]];
        
        _bird=[SKSpriteNode spriteNodeWithTexture:birdTexture1];
        [_bird setScale:2.0];
        _bird.position=CGPointMake(self.frame.size.width /4, CGRectGetMidY(self.frame));
        
        //create a bird physics body.
        
        _bird.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height/2];
        _bird.physicsBody.dynamic=YES;
        _bird.physicsBody.allowsRotation=NO;
        
        //collision specs
        _bird.physicsBody.categoryBitMask=birdCatagory;
        _bird.physicsBody.collisionBitMask=worldCatagory | pipeCatagory;
        _bird.physicsBody.contactTestBitMask=worldCatagory | pipeCatagory;
        [self addChild:_bird];
        
        
            
        
        [_bird runAction:flap];
        
        //create ground
        
        SKTexture *groundtexture=[SKTexture textureWithImageNamed:@"Ground"];
        groundtexture.filteringMode=SKTextureFilteringNearest;
        
            //animating ground movement.
        
        SKAction *moveGroundSprite=[SKAction moveByX:-groundtexture.size.width*2 y:0 duration:0.02 * groundtexture.size.width*2];
        SKAction *resetGroundSprite=[SKAction moveByX:groundtexture.size.width*2 y:0 duration:0]; //This has to happen immediately
        SKAction *repeatGroundAction=[SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite,resetGroundSprite]]];
        
        
          for (int i=0; i < self.frame.size.width / (groundtexture.size.width)*2; ++i) {
            SKSpriteNode *sprite=[SKSpriteNode spriteNodeWithTexture:groundtexture];
            [sprite setScale:2.0];
            sprite.position=CGPointMake(i*sprite.size.width,sprite.size.height /2);
             // NSLog(@"Sprite height:%f and Width:%f",sprite.size.height,sprite.size.width);
            [sprite runAction:repeatGroundAction];
            [_moving addChild:sprite];
          }
        
            //creating a ground physics body.
        SKNode *dummy=[SKNode node];
        dummy.position=CGPointMake(0, groundtexture.size.height);  //texture height is half of sprite height.
        dummy.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, groundtexture.size.height * 2)];
       // NSLog(@"Ground Texture height:%f and Width:%f",groundtexture.size.height,groundtexture.size.width);
        dummy.physicsBody.dynamic=NO;
        
        dummy.physicsBody.categoryBitMask=worldCatagory;
        [self addChild:dummy];
        
        
        //Create SkyLine
        
        SKTexture *skyLineTexture=[SKTexture textureWithImageNamed:@"Skyline"];
        skyLineTexture.filteringMode=SKTextureFilteringNearest;
        
        SKAction *moveSkySprite=[SKAction moveByX:-skyLineTexture.size.width*2 y:0 duration:0.1 * skyLineTexture.size.width*2];
        SKAction *resetSkySprite=[SKAction moveByX:skyLineTexture.size.width*2 y:0 duration:0];
        SKAction *repeatSkyAction=[SKAction repeatActionForever:[SKAction sequence:@[moveSkySprite,resetSkySprite]]];
        
        for (int i=0; i < self.frame.size.width / (skyLineTexture.size.width)*2; ++i) {
            SKSpriteNode *sprite=[SKSpriteNode spriteNodeWithTexture:skyLineTexture];
            [sprite setScale:2.0];
            sprite.zPosition=-20;
            sprite.position=CGPointMake(i*sprite.size.width,sprite.size.height /2 + groundtexture.size.height *2);
            [sprite runAction:repeatSkyAction];
            NSLog(@"In for:%d",i);
            [_moving addChild:sprite];
        }
        
        //Create pipes
        
        _pipeTexture1=[SKTexture textureWithImageNamed:@"Pipe1"];
        _pipeTexture1.filteringMode=SKTextureFilteringNearest;
        _pipeTexture2=[SKTexture textureWithImageNamed:@"Pipe2"];
        _pipeTexture2.filteringMode=SKTextureFilteringNearest;
        
        CGFloat distanceToMove=self.frame.size.width + 2*_pipeTexture1.size.width;
        SKAction *movePipes=[SKAction moveByX:-distanceToMove y:0 duration:0.01 * distanceToMove];
        SKAction * removePipes = [SKAction removeFromParent];
        _moveAndRemovePipes=[SKAction sequence:@[movePipes,removePipes]];
        
           //calling spawnPipes method using our scene as the selector.
        SKAction *spawn=[SKAction performSelector:@selector(spawnPipes) onTarget:self];
        SKAction *delay=[SKAction waitForDuration:2.0];
        SKAction *spawnThenDelay=[SKAction sequence:@[spawn,delay]];
        SKAction *spawnForever=[SKAction repeatActionForever:spawnThenDelay];
        [self runAction:spawnForever];
        
        }
        
        
        
      
    
    return self;
}


-(void) spawnPipes{
    SKNode* pipePair=[SKNode node];
    pipePair.position=CGPointMake(self.frame.size.width + _pipeTexture1.size.width *2, 0);
    pipePair.zPosition=-10;
    
    CGFloat y=arc4random() % (NSInteger) (self.frame.size.height / 3);  //choosing pipes randomly between 0 to 1/3rd of the screen.
    
    SKSpriteNode *pipe1=[SKSpriteNode spriteNodeWithTexture:_pipeTexture1];
    [pipe1 setScale:2.0];
    pipe1.position=CGPointMake(0, y);
    pipe1.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.dynamic=NO;
    
    pipe1.physicsBody.categoryBitMask=pipeCatagory;
    pipe1.physicsBody.contactTestBitMask=birdCatagory;
    
    [pipePair addChild:pipe1]; // adding the pipe to the pipePair outside the screen.
    
    
    SKSpriteNode *pipe2=[SKSpriteNode spriteNodeWithTexture:_pipeTexture2];
    [pipe2 setScale:2.0];
    pipe2.position=CGPointMake(0, y + pipe1.size.height + kVerticalPipeGap);
    pipe2.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.dynamic=NO;
    
    pipe2.physicsBody.categoryBitMask=pipeCatagory;
    pipe2.physicsBody.contactTestBitMask=birdCatagory;
    
    [pipePair addChild:pipe2]; // adding the pipe to the pipePair outside the screen.
    
       // adding a contact node for the score
    
    SKNode *contactNode=[SKNode node];
    contactNode.position=CGPointMake(pipe1.size.width+_bird.size.width, CGRectGetMidY(self.frame));
    contactNode.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(pipe2.size.width, self.frame.size.height)];
    contactNode.physicsBody.dynamic=NO;
    contactNode.physicsBody.categoryBitMask=scoreCatagory;
    contactNode.physicsBody.contactTestBitMask=birdCatagory;
    
    [pipePair addChild:contactNode];
    
    [pipePair runAction:_moveAndRemovePipes];
    
     [_pipes addChild:pipePair];
    
    
    
    
}

-(CGFloat) clamp:(CGFloat) min :(CGFloat) max : (CGFloat) value{
    
    if (value > max) {
        return  max;
    }
    else if (value < min)
        return  min;
    else
        return  value;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if (_moving.speed > 0) {
        _bird.physicsBody.velocity=CGVectorMake(0, 0);
        [_bird.physicsBody applyImpulse:CGVectorMake(0, 5)];
    }
    else if (_canRestart)
        [self resetScene];
   
    
   }

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (_moving.speed > 0) {
        _bird.zRotation=[self clamp:-1 :0.5 :_bird.physicsBody.velocity.dy *(_bird.physicsBody.velocity.dy < 0 ? 0.003 :0.001)];
    }
}

@end
