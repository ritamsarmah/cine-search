//
//  MovieTableViewCell.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/9/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MovieTableViewCell.h"

@implementation MovieTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.ratingView.layer.cornerRadius = 5;
    self.ratingView.layer.masksToBounds = YES;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)favoritePressed:(UIButton *)sender {
    [UIView animateWithDuration:0.3/2.5 animations:^{
        sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        if (self.favoriteButton.tintColor != [UIColor whiteColor]) {
            [self.favoriteButton setTintColor:[UIColor whiteColor]];
            [self.favoriteButton setImage:[UIImage imageNamed:@"HeartHollow"] forState:UIControlStateNormal];
        } else {
            [self.favoriteButton setTintColor:[UIColor colorWithRed:1.00 green:0.32 blue:0.30 alpha:1.0]];
            [self.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2.5 animations:^{
            sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2.5 animations:^{
                sender.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

@end
