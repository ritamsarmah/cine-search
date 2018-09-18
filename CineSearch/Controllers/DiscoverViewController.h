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
@class MovieSearchManager;

@interface DiscoverViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, SwipeViewDelegate, SwipeViewDataSource> {
    NSTimer *carouselTimer;
    BOOL enteredSegue;
    
    NetworkStatus lastStatus;
    Reachability *internetReachability;
    
    NSArray *moviesArray;
    NSMutableDictionary *contentOffsetDictionary;
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet SwipeView *movieCarousel;
@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;
@property (weak, nonatomic) IBOutlet UITableView *movieTableView;

@property (weak, nonatomic) BoxActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UILabel *bannerLabel;

@property MovieSearchManager *manager;
@property NSMutableArray *nowPlayingMovies;
@property NSMutableArray *popularMovies;
@property NSMutableArray *recommendedMovies;
@property NSMutableArray *bannerMovies; // Movies for banner images
@property NSMutableArray *bannerImages; // Movies for banner images



- (void)setupImageSlideshow;
- (void)openBannerMovie:(NSInteger)index;
- (BOOL)isMovieInFavorites:(NSInteger)movieID;

@end
