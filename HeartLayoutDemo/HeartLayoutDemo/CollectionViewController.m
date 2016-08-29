//
//  CollectionViewController.m
//  HeartLayoutDemo
//
//  Created by zhaimengyang on 8/29/16.
//  Copyright © 2016 zhaimengyang. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "HeartLayout.h"

@interface CollectionViewController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) NSInteger count;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.count = 0;
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.backgroundColor = [UIColor greenColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(delete)];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    pinchGesture.delegate = self;
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotate:)];
    rotationGesture.delegate = self;
    [self.collectionView addGestureRecognizer:pinchGesture];
    [self.collectionView addGestureRecognizer:rotationGesture];
}

- (void)add {
    NSInteger itemNum = 0;
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];
    if (selectedItems.count) {
        itemNum = [(NSIndexPath *)selectedItems.firstObject item] + 1;
    }
    NSIndexPath *itemPath = [NSIndexPath indexPathForItem:itemNum inSection:0];
    
    self.count++;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[itemPath]];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
        [self.collectionView selectItemAtIndexPath:itemPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }];
}

- (void)delete {
    if (!self.count) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"niania" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"oo" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSInteger itemNum = 0;
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];
    if (selectedItems.count) {
        itemNum = [(NSIndexPath *)selectedItems.firstObject item];
    }
    NSIndexPath *itemPath = [NSIndexPath indexPathForItem:itemNum inSection:0];
    
    self.count--;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[itemPath]];
    } completion:^(BOOL finished) {
        if (self.count) {
            [self.collectionView reloadData];
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:MAX(0, itemNum - 1) inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }];
}

#pragma mark - gestures

- (void)pinch:(UIPinchGestureRecognizer *)recognizer {
    HeartLayout *layout = (HeartLayout *)self.collectionView.collectionViewLayout;
    [layout scaleTo:recognizer.scale];
}

- (void)rotate:(UIRotationGestureRecognizer *)recognizer {
    HeartLayout *layout = (HeartLayout *)self.collectionView.collectionViewLayout;
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [layout rotateTo:recognizer.rotation];
    } else {
        [layout rotateBy:recognizer.rotation];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageName = [NSString stringWithFormat:@"%ld", indexPath.row % 4];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.imageName && ![cell.imageName isEqualToString:@"4"]) {
        cell.imageName = @"4";
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.imageName = [NSString stringWithFormat:@"%ld", indexPath.row % 4];
}

@end