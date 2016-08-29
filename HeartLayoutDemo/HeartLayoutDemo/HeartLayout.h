//
//  HeartLayout.h
//  HeartLayoutDemo
//
//  Created by zhaimengyang on 8/29/16.
//  Copyright © 2016 zhaimengyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartLayout : UICollectionViewFlowLayout

- (void)scaleTo:(CGFloat)factor;

- (void)rotateTo:(CGFloat)theta;
- (void)rotateBy:(CGFloat)theta;

@end
