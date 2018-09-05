//
//  MasterViewController.h
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "BoxActivityIndicatorView.h"

@class DetailViewController;
@class MovieSearchManager;

@interface MasterViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (weak, nonatomic) BoxActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) NSTimer* searchTimer;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *movies;
@property MovieSearchManager *manager;

@property BOOL enteredSegue;

@property (nonatomic) BOOL connectedToInternet;
@property (nonatomic) Reachability *internetReachability;

-(void) instantSearch;
-(void) resetSearchTimer;

@end

