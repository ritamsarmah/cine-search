//
//  FavoritesViewController.h
//  CineSearch
//
//  Created by Ritam Sarmah on 12/21/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieSearchManager.h"
#import "BoxActivityIndicatorView.h"

@class DetailViewController;

@interface FavoritesViewController : UITableViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) BoxActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property NSMutableDictionary *moviesForID;
@property MovieSearchManager *manager;
@property BOOL enteredSegue;
@property BOOL finishedDownloadingMovies;

@end
