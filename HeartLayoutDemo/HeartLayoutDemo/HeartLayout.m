//
//  HeartLayout.m
//  HeartLayoutDemo
//
//  Created by zhaimengyang on 8/29/16.
//  Copyright © 2016 zhaimengyang. All rights reserved.
//

#import "HeartLayout.h"

@interface HeartLayout ()

@property (assign, nonatomic) NSInteger numberOfItems;
@property (assign, nonatomic) CGPoint centerPoint;
@property (assign, nonatomic) CGFloat radius;

@property (assign, nonatomic) CGFloat rotation;
@property (assign, nonatomic) CGFloat currentRotation;
@property (assign, nonatomic) CGFloat scale;

@property (strong, nonatomic) NSMutableArray *insertedIndexPaths;
@property (strong, nonatomic) NSMutableArray *deletedIndexPaths;

@property (assign, nonatomic) BOOL otherSide;
@property (assign, nonatomic) BOOL temp1_Or_temp2;

@end

@implementation HeartLayout

- (instancetype)init {
    if (self = [super init]) {
        _insertedIndexPaths = [NSMutableArray array];
        _deletedIndexPaths = [NSMutableArray array];
        
        _rotation = 0.0;
        _currentRotation = 0.0;
        _scale = 1.0;
    }
    
    return self;
}

- (void)scaleTo:(CGFloat)factor {
    _scale = factor;
    [self invalidateLayout];
}

- (void)rotateTo:(CGFloat)theta {
    _rotation += theta;
    _currentRotation = 0.0;
    [self invalidateLayout];
}

- (void)rotateBy:(CGFloat)theta {
    _currentRotation = theta;
    [self invalidateLayout];
}

- (NSArray *)xCalculate:(CGFloat)y {
    NSLog(@"%f", sqrt(4.0));
    
    CGFloat item1 = 110 * 110 * y * y;
    CGFloat item2 = (y - 110 * y) * (y - 110 * y) * (-1);
    CGFloat item3 = (y * y - 110 * y - 0.5 * 110 * 110) * (y * y - 110 * y - 0.5 * 110 * 110);
    CGFloat item_right_plus = sqrt(item1 + item2 + item3);
    CGFloat item_right_minus = -1 * item_right_plus;
    
    CGFloat item1_L = y * y;
    CGFloat item2_L = (-1) * 110 * y;
    CGFloat item3_L = (-1) * 0.5 * 110 * 110;
    CGFloat item_left = item1_L + item2_L + item3_L;
    
    CGFloat item_p = item_right_plus - item_left;
    CGFloat item_m = item_right_minus - item_left;
    
    CGFloat x1 = -1;
    CGFloat x2 = -1;
    if (item_p >= 0) {
        x1 = sqrt(item_p);
    }
    if (item_m >= 0) {
        x2 = sqrt(item_m);
    }
    
    return @[@(x1), @(x2)];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    CGSize size = self.collectionView.bounds.size;
    self.numberOfItems = [self.collectionView numberOfItemsInSection:0];
    self.centerPoint = CGPointMake(size.width / 2.0, size.height / 2.0);
    self.radius = MIN(size.width, size.height) / 3.0;
}

- (CGSize)collectionViewContentSize {
    return self.collectionView.bounds.size;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger index = 0; index < self.numberOfItems; index++) {
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]]];
    }
    
    return attributes;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    attributes.size = self.itemSize;
    
    CGFloat max = 2 * 110;
    CGFloat min = -0.25 * 110;
    CGFloat margin = 0;
    if (indexPath.item > 0 && indexPath.item < 100) {
        margin = 0.999;
    } else if (indexPath.item >= 100) {
        margin = 0.001;
    }
    CGFloat y = (max - min) * (margin + indexPath.item) / self.numberOfItems + min;
    
    CGFloat x;
    CGFloat x1, x2, x3, x4;
    
    NSArray *xArray = [self xCalculate:y];
    CGFloat tempX1 = [(NSNumber *)xArray.firstObject floatValue];
    CGFloat tempX2 = [(NSNumber *)xArray.lastObject floatValue];
    if (tempX1 == -1) {
        x3 = tempX2;
        x4 = -1 * tempX2;
        x = self.otherSide ? x3 : x4;
    } else if (tempX2 == -1){
        x1 = tempX1;
        x2 = -1 * tempX1;
        x = self.otherSide ? x1 : x2;
    } else {
        x1 = tempX1;
        x2 = -1 * tempX1;
        x3 = tempX2;
        x4 = -1 * tempX2;
        x = self.temp1_Or_temp2 ? (self.otherSide ? x1 : x2) : (self.otherSide ? x3 : x4);
    }
    
    self.otherSide = !self.otherSide;
    self.temp1_Or_temp2 = !self.temp1_Or_temp2;
    
    CGFloat xPosition = x + self.centerPoint.x;
    CGFloat yPosition = y + self.centerPoint.y - 100;
    
    attributes.center = CGPointMake(xPosition, yPosition);
    
    return attributes;
}

#pragma mark - Animated updates

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        switch (updateItem.updateAction) {
            case UICollectionUpdateActionInsert:
                [self.insertedIndexPaths removeAllObjects];
                [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
                break;
            case UICollectionUpdateActionDelete:
                [self.deletedIndexPaths removeAllObjects];
                [self.deletedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
                break;
                
            default:
                break;
        }
    }
}

- (UICollectionViewLayoutAttributes *)insertionAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    attributes.alpha = 0;
    attributes.center = self.centerPoint;
    attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    return attributes;
}

- (UICollectionViewLayoutAttributes *)deletionAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    attributes.alpha = 0;
    attributes.center = self.centerPoint;
    attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    return attributes;
}

- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    NSLog(@"/*************/\nitemIndexPath.item = %ld\n/*************/", (long)itemIndexPath.item);
    return [self.insertedIndexPaths containsObject:itemIndexPath] ? [self insertionAttributesForItemAtIndexPath:itemIndexPath] : [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
}

- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self.deletedIndexPaths containsObject:itemIndexPath] ? [self deletionAttributesForItemAtIndexPath:itemIndexPath] : [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger item = 0; item < self.numberOfItems; item++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:item inSection:0]];
    }
    
    for (NSIndexPath *indexPath in indexPaths) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        CGAffineTransform __block t;
        [UIView animateWithDuration:0.1 animations:^{
            cell.transform = CGAffineTransformMakeScale(0.8, 0.8);
            cell.transform = CGAffineTransformMakeRotation(M_PI);
            t = cell.transform;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                cell.transform = CGAffineTransformMakeScale(1.2, 1.2);
                cell.transform = CGAffineTransformRotate(t, 2 * M_PI);
            } completion:^(BOOL finished) {
                cell.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

@end
