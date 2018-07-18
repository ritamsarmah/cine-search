//
//  ImageSlideshow.h
//  CineSearch
//
//  Created by SARMAH, RITAM on 7/12/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageSlideshow : UIScrollView <UIScrollViewDelegate>

/* Public Access */
@property (nonatomic) NSMutableArray *images;
@property (nonatomic) UIViewController *interactionViewController;
@property int currentPosition;
@property NSTimeInterval timeInterval;
@property NSTimeInterval transitionInterval;

/* Private Access */
@property (nonatomic) NSTimer *scrollTimer;
@property (nonatomic, readwrite) BOOL isAutoScrolling;
@property (nonatomic, readwrite) CGFloat maxWidth;

- (void)configureImages:(NSMutableArray *)images withSelector:(SEL)selector;
- (void)nextImage;

@end
