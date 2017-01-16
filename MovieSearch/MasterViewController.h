//
//  MasterViewController.h
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class MovieSingleton;

@interface MasterViewController : UITableViewController<UISearchBarDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) UIView *loadingView;
@property (weak, nonatomic) UIActivityIndicatorView *loadingMovies;
@property (weak, nonatomic) NSTimer* searchTimer;

@property NSMutableArray *movies;
@property MovieSingleton *manager;

-(void) instantSearch;
-(void) resetSearchTimer;

@end

