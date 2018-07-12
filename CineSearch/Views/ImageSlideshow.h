//
//  ImageSlideshow.h
//  CineSearch
//
//  Created by SARMAH, RITAM on 7/12/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageSlideshow : UIScrollView <UIScrollViewDelegate>

@property (nonatomic) NSMutableArray *images;
@property (nonatomic) NSTimer *scrollTimer;
@property (nonatomic) UIViewController *interactionViewController;


@property int currentPosition;
@property NSTimeInterval timeInterval;
@property CGFloat width;

// Private Access
@property (nonatomic, readwrite) BOOL isAutoScrolling;
@property (nonatomic, readwrite) CGFloat maxWidth;

- (void)configureImages:(NSMutableArray *)images withSelector:(SEL)selector;
- (void)nextImage;

@end
