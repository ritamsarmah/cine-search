//
//  MovieTableViewCell.m
//  CineSearch
//
//  Created by Ritam Sarmah on 11/9/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MovieTableViewCell.h"
#import "MovieSingleton.h"
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

- (IBAction)favoritePressed:(UIButton *)sender {
    RLMRealm *realm = RLMRealm.defaultRealm;
    if (self.favoriteButton.tintColor != [UIColor whiteColor]) {
        // Animate to empty heart
        [UIView animateWithDuration:0.3/2.5 animations:^{
            sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            [self.favoriteButton setTintColor:[UIColor whiteColor]];
            [self.favoriteButton setImage:[UIImage imageNamed:@"HeartHollow"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2.5 animations:^{
                sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2.5 animations:^{
                    sender.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
        
        // Remove from favorites list
        MovieID *movieToDelete = [MovieID objectForPrimaryKey:@(self.movieID.movieID)];
        
        [realm beginWriteTransaction];
        [realm deleteObject:movieToDelete];
        [realm commitWriteTransaction];
        
    } else {
        // Animate to red filled heart
        [UIView animateWithDuration:0.3/2.5 animations:^{
            sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            [self.favoriteButton setTintColor:[UIColor colorWithRed:1.00 green:0.32 blue:0.30 alpha:1.0]];
            [self.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2.5 animations:^{
                sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2.5 animations:^{
                    sender.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
        
        // Add to favorites list
        [realm beginWriteTransaction];
        [MovieID createInRealm:realm withValue:@{@"movieID": @(self.movieID.movieID)}];
        [realm commitWriteTransaction];
        
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
