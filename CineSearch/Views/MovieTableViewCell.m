//
//  MovieTableViewCell.m
//  CineSearch
//
//  Created by Ritam Sarmah on 11/9/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MovieTableViewCell.h"
#import "MovieSearchManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MovieTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.ratingView.layer.cornerRadius = 5;
    self.ratingView.layer.masksToBounds = YES;
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.00 green:0.72 blue:1.00 alpha:1.0];
    self.selectedBackgroundView = selectedBackgroundView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        self.ratingView.hidden = NO;
        self.ratingView.backgroundColor = [UIColor colorWithRed:0.04 green:0.05 blue:0.06 alpha:1.0];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.ratingView.hidden = NO;
        self.ratingView.backgroundColor = [UIColor colorWithRed:0.04 green:0.05 blue:0.06 alpha:1.0];
    }
}

- (IBAction)favoritePressed:(FavoriteButton *)sender {
    RLMRealm *realm = RLMRealm.defaultRealm;
    if ([sender toggleWithAnimation:YES]) {
        // Add to favorites list
        [realm transactionWithBlock:^{
            [MovieID createInRealm:realm withValue:@{@"movieID": @(self.movieID.movieID)}];
        }];
    } else {
        // Remove from favorites list
        // Remove from favorites list
        MovieID *movieToDelete = [MovieID objectForPrimaryKey:@(self.movieID.movieID)];
        [realm transactionWithBlock:^{
            [realm deleteObject:movieToDelete];
        }];
    }
}

- (BOOL)isMovieInFavorites:(NSInteger)movieID {
    RLMResults *favorites = [MovieID allObjects];
    
    for (MovieID *realmMovieID in favorites) {
        if (realmMovieID.movieID == movieID) {
            return YES;
        }
    }
    return NO;
}

@end
