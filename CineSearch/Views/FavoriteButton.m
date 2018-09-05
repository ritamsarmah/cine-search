//
//  FavoriteButton.m
//  CineSearch
//
//  Created by SARMAH, RITAM on 9/5/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

#import "FavoriteButton.h"

@implementation FavoriteButton {
    BOOL isFavorite;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    if (self = [super init]) {
        [self resetAppearance];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self resetAppearance];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self resetAppearance];
    }
    return self;
}

- (void)resetAppearance {
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.fillColor = [UIColor colorWithRed:1.00 green:0.32 blue:0.30 alpha:1.0];
    [self setFavorite:YES animated: NO];
}

- (void)setFavorite:(BOOL)isFavorite animated:(BOOL)isAnimated {
    if (isAnimated) {
        [UIView animateWithDuration:0.3/2.5 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            isFavorite ? [self favorite] : [self unfavorite];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2.5 animations:^{
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2.5 animations:^{
                    self.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
    } else {
        isFavorite ? [self favorite] : [self unfavorite];
    }
}

- (BOOL)toggleWithAnimation:(BOOL)animated {
    isFavorite = !isFavorite;
    [self setFavorite:isFavorite animated:animated];
    return isFavorite;
}

- (void)favorite {
    [self setTintColor:self.fillColor];
    [self setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
    isFavorite = YES;
}

- (void)unfavorite {
    [self setTintColor:[UIColor whiteColor]];
    [self setImage:[UIImage imageNamed:@"HeartHollow"] forState:UIControlStateNormal];
    isFavorite = NO;
}

@end
