//
//  MasterViewController.h
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@class DetailViewController;
@class MovieSingleton;

@interface MasterViewController : UITableViewController<UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) UIView *loadingView;
@property (weak, nonatomic) UIActivityIndicatorView *loadingMovies;
@property (weak, nonatomic) NSTimer* searchTimer;

@property NSMutableArray *movies;
@property MovieSingleton *manager;

@property (nonatomic) BOOL connectedToInternet;
@property (nonatomic) Reachability *internetReachability;

-(void) instantSearch;
-(void) resetSearchTimer;

@end

