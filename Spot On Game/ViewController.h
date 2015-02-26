//
//  ViewController.h
//  Spot On Game
//
//  Created by T.J. Agne on 2/26/15.
//  Copyright (c) 2015 T.J. Agne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    NSMutableArray *spots;
    NSMutableArray *lives;
    int spotsTouched;
    int score;
    float drawTime;     // duration that each spot remains on the screen
    BOOL gameOver;
    UIImage *touchedImage;
    UIImage *untouchedImage;
}

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

- (void) resetGame;
- (void) addNewSpot;

// create a new spot, determine if finished spot was touched, decreases remaining lives
- (void) finishedAnimation:(NSString *)animationId finished:(BOOL)finished context:(void *)context;
// increase score when spot is touched
- (void) touchedSpot:(UIImageView *)spot;

@end

