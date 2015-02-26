//
//  ViewController.m
//  Spot On Game
//
//  Created by T.J. Agne on 2/26/15.
//  Copyright (c) 2015 T.J. Agne. All rights reserved.
//

#import "ViewController.h"
static const int BALL_RADIUS = 40;


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    srandom(time(0));
    spots = [[NSMutableArray alloc] init];
    lives = [[NSMutableArray alloc] init];
    
    // init the spot images
    touchedImage = [UIImage imageNamed:@"17DiceIcon.png"];
    untouchedImage = [UIImage imageNamed:@"NotSelected.png"];
    
    [self resetGame];
}

// remove old objects and begin new game
-(void)resetGame {
    [spots removeAllObjects];
    drawTime = 5.0;
    spotsTouched = 0;
    score = 0;
    [self.scoreLabel setText:@"Score: 0"];
    gameOver = NO;
    
    // add 3 lives
    for(int i=0; i<3; i++) {
        UIImageView *life = [[UIImageView alloc] initWithImage:touchedImage];
        
        // position the views next to each other at the bottom left
        //        CGRect frame = CGRectMake(10+40*i, 420, 30, 30);
        CGRect frame = CGRectMake(10+40*i, self.view.bounds.size.height-3*BALL_RADIUS, 30, 30);
        life.frame = frame;
        [lives addObject:life];
        [self.view addSubview:life];
    }
    
    // add 3 new spots, each added after a 1 second delay
    [self addNewSpot];
    [self performSelector:@selector(addNewSpot) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(addNewSpot) withObject:nil afterDelay:2.0];
}

-(void)addNewSpot {
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height;
    
    // pick random coordinates inside the view to place a spot
    float x = random() % (int)(viewWidth - 2 * BALL_RADIUS);
    float y = random() % (int)(viewHeight - 2 * BALL_RADIUS);
    
    // create a new spot
    UIImageView *spot = [[UIImageView alloc] initWithImage:untouchedImage];
    [spots addObject:spot];
    [self.view addSubview:spot];
    
    // set the frame of the spot to the random coordinates
    [spot setFrame:CGRectMake(x, y, BALL_RADIUS * 2, BALL_RADIUS * 2)];
    
    [self performSelector:@selector(beginSpotAnimation:) withObject:spot afterDelay:0.01];
}

-(void)beginSpotAnimation:(UIImageView *)spot {
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height;
    
    // pick random coordinates inside the view to place a spot
    float x = random() % (int)(viewWidth - 2 * BALL_RADIUS);
    float y = random() % (int)(viewHeight - 2 * BALL_RADIUS);
    
    // begin animation block
    [UIView beginAnimations:nil context:(__bridge void *)(spot)];
    [UIView setAnimationDelegate:self];
    
    // call the given method of the delegate when the animation ends
    [UIView setAnimationDidStopSelector:@selector(finishedAnimation:finished:context:)];
    [UIView setAnimationDuration:drawTime];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    // set the ending location of the spot
    [spot setFrame:CGRectMake(x+BALL_RADIUS, y+BALL_RADIUS, 0, 0)];
    [UIView commitAnimations];      // end animation block
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL hitSpot = NO;
    
    for (UITouch *touch in touches) { // we really only have one on the simulator
        CGPoint point = [touch locationInView:self.view];
        
        // loop backwards through spots in case any are overlapping a touch would kill
        //   the one in front
        for (int i = spots.count-1; i>=0 && !hitSpot; i--) {
            UIImageView *spot = [spots objectAtIndex:i];
            
            // get current location of spot which is not where it is
            // because it is animating, current location is where it will be
            // to get current frame need to access core animation layer
            CGRect frame = [[spot.layer presentationLayer] frame];
            
            // find center of spot
            CGPoint center = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
            
            // find distance between spot's center and touch
            float distance = pow(center.x-point.x, 2) + pow(center.y-point.y, 2);
            distance = sqrt(distance);
            
            // check if touch is within spot frame
            if (distance <= frame.size.width/2) {
                spot.image = touchedImage; // change image to touched spot image
                [self touchedSpot:spot];
                hitSpot = YES;
            }
        } // end for spot
    } // end for touch
    
    if (!hitSpot) {
        //        [missPlayer play]; // ^^^ to add sound
        score -= 20;    // ^^^ to add level: score -= 20 * self.level
        if (score < 0) {
            score = 0;
        }
        [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", score]];
    } // if hitSpot
}

-(void)touchedSpot:(UIImageView *)spot {
    spotsTouched++;
    score += 10;
    // hitPlayer.currentTime = 0; // ^^^
    // [hitPlayer play]; // ^^^
    
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", score]];
    
    // ^^^ whole big if for ++ level
    
    // stop current animation and start a new one at the same spot
    CGRect frame = [[spot.layer presentationLayer] frame];
    spot.frame = frame;
    [spot setNeedsDisplay]; // redraw the spot
    
    // give the spot time to redraw by delaying the end animation
    [self performSelector:@selector(beginSpotEndAnimation:) withObject:spot afterDelay:0.01];
}

-(void)beginSpotEndAnimation:(UIImageView *)spot {
    [UIView beginAnimations:@"end" context:(__bridge void *)(spot)];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationDelegate:self];
    
    // set completion method call
    [UIView setAnimationDidStopSelector:@selector(finishedAnimation:finished:context:)];
    
    // make spot stay in same place and disappear
    CGRect frame = spot.frame;
    frame.origin.x += frame.size.width/2;
    frame.origin.y += frame.size.height/2;
    frame.size.width = 0;
    frame.size.height = 0;
    [spot setFrame:frame];
    [spot setAlpha:0.0];
    [UIView commitAnimations];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
