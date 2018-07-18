//
//  DetailViewController.h
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MovieSingleton;
@class Movie;

@interface DetailViewController : UIViewController <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) Movie *movie;
@property (nonatomic) NSArray *castArray;
@property (nonatomic) NSMutableDictionary *castImageDict;
@property (weak, nonatomic) NSURL *trailerURL;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) BOOL castImagesFromWeb;
@property MovieSingleton *manager;

@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;
@property (weak, nonatomic) IBOutlet UIButton *trailerButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIView *actionBackgroundView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *posterLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *backdropImageView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *castCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *castCollectionViewHeight;

- (IBAction)back:(UIButton *)sender;
- (IBAction)favoritePressed:(UIButton *)sender;
- (IBAction)openTrailer:(UIButton *)sender;

@end

