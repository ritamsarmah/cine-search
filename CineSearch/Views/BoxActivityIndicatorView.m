//
//  BoxActivityIndicatorView.m
//  CineSearch
//
//  Created by Ritam Sarmah on 3/31/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

#import "BoxActivityIndicatorView.h"

@implementation BoxActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:10];
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
        self.hidesWhenStopped = YES;
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return self;
}

- (void)startAnimating {
    [super startAnimating];
    if (_disablesInteraction) {
        [UIApplication.sharedApplication beginIgnoringInteractionEvents];
    }
}

- (void)stopAnimating {
    [super stopAnimating];
    if (_disablesInteraction && UIApplication.sharedApplication.isIgnoringInteractionEvents) {
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
    }
}

@end
