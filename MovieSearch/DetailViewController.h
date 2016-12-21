//
//  DetailViewController.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieSearch.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Movie *movie;
@property (weak, nonatomic) NSURL *trailerURL;
@property MovieSearch *database;

@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backdropImageView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;
@property (weak, nonatomic) IBOutlet UIButton *trailerButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)back:(UIButton *)sender;
- (IBAction)favoriteClicked:(UIButton *)sender;
- (IBAction)openTrailer:(UIButton *)sender;


@end

