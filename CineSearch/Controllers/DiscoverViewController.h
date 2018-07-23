//
//  DiscoverViewController.h
//  CineSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxActivityIndicatorView.h"
#import "Reachability.h"

#import <SwipeView/SwipeView.h>

@class DetailViewController;
@class MovieSingleton;

@interface DiscoverViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, SwipeViewDelegate, SwipeViewDataSource>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet SwipeView *movieCarousel;
@property (weak, nonatomic) BoxActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UILabel *bannerLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;
@property (weak, nonatomic) IBOutlet UITableView *movieTableView;

@property MovieSingleton *manager;
@property NSMutableArray *nowPlayingMovies;
@property NSMutableArray *popularMovies;
@property NSMutableArray *recommendedMovies;
@property NSMutableArray *bannerMovies; // Movies for banner images
@property NSMutableArray *bannerImages; // Movies for banner images

@property NSArray *moviesArray;
@property NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic) Reachability *internetReachability;

@property BOOL enteredSegue;
@property NetworkStatus lastStatus;

- (void)setupImageSlideshow;
- (void)openBannerMovie:(NSInteger)index;
- (BOOL)isMovieInFavorites:(NSInteger)movieID;

@end
