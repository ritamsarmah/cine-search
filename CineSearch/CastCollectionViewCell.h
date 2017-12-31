//
//  CastCollectionViewCell.h
//  CineSearch
//
//  Created by Ritam Sarmah on 12/31/17.
//  Copyright © 2017 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CastCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end
