//
//  CollectionViewCell.m
//  HeartLayoutDemo
//
//  Created by zhaimengyang on 8/29/16.
//  Copyright © 2016 zhaimengyang. All rights reserved.
//

#import "CollectionViewCell.h"

@interface CollectionViewCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:self.imageView];
    }
    
    return self;
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    
    self.imageView.image = [UIImage imageNamed:imageName];
}

@end