//
//  DiscoverViewController.h
//  CineSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class MovieSingleton;

@interface DiscoverViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) UIActivityIndicatorView *loadingMovies;
@property (weak, nonatomic) UILabel *bannerLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;
@property (weak, nonatomic) IBOutlet UITableView *movieTableView;

@property NSTimer *scrollTimer;
@property MovieSingleton *manager;
@property NSMutableArray *nowPlayingMovies;
@property NSMutableArray *popularMovies;
@property NSMutableArray *recommendedMovies;
@property NSMutableArray *bannerMovies; // Movies for banner images

@property BOOL enteredSegue;

- (void)setupImageScrollView;
- (void)nextImage;
- (void)openMovie:(UITapGestureRecognizer *)sender;
- (BOOL)isMovieInFavorites:(NSInteger)movieID;

@end
