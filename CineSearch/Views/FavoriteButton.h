//
//  FavoriteButton.h
//  CineSearch
//
//  Created by SARMAH, RITAM on 9/5/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteButton : UIButton

@property UIColor *fillColor;

- (void)setFavorite:(BOOL)isFavorite animated:(BOOL)isAnimated;
- (BOOL)toggleWithAnimation:(BOOL)animated;

@end
