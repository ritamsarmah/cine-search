//
//  ImageSlideshow.m
//  CineSearch
//
//  Created by SARMAH, RITAM on 7/12/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

#import "ImageSlideshow.h"

@implementation ImageSlideshow

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _isAutoScrolling = NO;
        self.delegate = self;
    }
    
    return self;
}

- (void)configureImages:(NSMutableArray *)images withSelector:(SEL)selector {
    self.currentPosition = 0;
    int tagNumber = 0;

    // Duplicates for circular slideshow
    self.images = images;
    UIImage *lastImage = images.lastObject;
    [_images addObject:images.firstObject];
    [_images insertObject:lastImage atIndex:0];
    
    self.maxWidth = self.width * (self.images.count - 1);

    for (UIImage *image in self.images) {
        // Populate scrollView with imageViews containing images
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.currentPosition, 0, self.width, self.frame.size.height)];
        
        imageView.image = image;
        imageView.tag = tagNumber;
        tagNumber++;
        self.currentPosition += self.width;
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.interactionViewController action:selector];
        [imageView addGestureRecognizer:tapRecognizer];
        [self addSubview:imageView];
    }
    
    self.contentSize = CGSizeMake(self.currentPosition, self.frame.size.height);
    self.contentOffset = CGPointMake(self.width, 0);
    
    self.currentPosition = self.width * 2;
    
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
    }
    
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
}

- (void)nextImage {
    self.isAutoScrolling = YES;
    if (self.currentPosition == self.maxWidth) {
        [self setContentOffset:CGPointMake(0, 0) animated:NO];
        [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setContentOffset:CGPointMake(self.width, 0) animated:NO];
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.contentOffset = CGPointMake(self.currentPosition, 0);
        } completion:nil];
    }
    self.isAutoScrolling = NO;
    self.currentPosition += self.width;
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == self.maxWidth && !self.isAutoScrolling) {
        [scrollView setContentOffset:CGPointMake(self.width, 0) animated:NO];
    } else if (scrollView.contentOffset.x == 0 && !self.isAutoScrolling) {
        [scrollView setContentOffset:CGPointMake(self.maxWidth - self.width, 0) animated:NO];
    } else {
        self.currentPosition = scrollView.contentOffset.x;
    }
}

@end
