//
//  MasterViewController.m
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MasterViewController.h"
#import "MovieTableViewCell.h"
#import "MovieSingleton.h"
#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Realm/Realm.h>


@implementation MasterViewController

- (void)loadView {
    [super loadView];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    CGRect size = CGRectMake(0, 0, 70, 70);
    UIView *view = [[UIView alloc] initWithFrame:size];
    view.backgroundColor = [UIColor darkGrayColor];
    view.alpha = 0.7;
    view.hidden = YES;
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    [self.view addSubview:view];
    [self.view addSubview:activityIndicator];
    
    self.loadingView = view;
    self.loadingMovies = activityIndicator;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.loadingView.center = self.view.center;
    self.loadingMovies.center = self.view.center;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [MovieSingleton sharedManager];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.searchBar.delegate = self;
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method
     reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark - Reachability
- (void) reachabilityChanged:(NSNotification *)note {
    self.connectedToInternet = NO;
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    if (reachability == self.internetReachability) {
        [self checkReachabilityStatus:reachability];
    }
}

- (void)checkReachabilityStatus:(Reachability *)reachability {
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    switch (netStatus) {
        case NotReachable: {
            self.connectedToInternet = NO;
        }
        case ReachableViaWWAN:
        case ReachableViaWiFi: {
            self.connectedToInternet = YES;
        }
    }
}

- (void)displayConnectionAlert {
    [self.loadingMovies stopAnimating];
    self.loadingView.hidden = YES;
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Unable to retrieve movies"
                                message:@"Please check your internet connection and try again."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                
                                handler:^(UIAlertAction * action) {
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:true completion:nil];
    [self.tableView setUserInteractionEnabled:YES];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.enteredSegue = YES;
    if ([[segue identifier] isEqualToString:@"showMovie"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Movie *movie = self.movies[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setMovie:movie];
        
        if ([self isMovieInFavorites:[movie.idNumber integerValue]]) {
            controller.isFavorite = YES;
        } else {
            controller.isFavorite = NO;
        }
        
        [self.searchBar endEditing:YES];
    }
}

#pragma mark - Search Bar

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if (self.connectedToInternet) {
        [self.searchTimer invalidate];
        [self.loadingMovies startAnimating];
        self.loadingView.hidden = NO;
        [searchBar endEditing:YES];
        [self.tableView setUserInteractionEnabled:NO];
        [self.manager.database search:searchBar.text completion:^(NSMutableArray *movies) {
            if (movies == nil) {
                [self displayConnectionAlert];
            }
            else if (self.movies != movies) {
                if (movies.count != 0) {
                    self.movies = movies;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSRange range = NSMakeRange(0, 1);
                        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self.loadingMovies stopAnimating];
                        [self.tableView setUserInteractionEnabled:YES];
                        self.loadingView.hidden = YES;
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loadingMovies stopAnimating];
                        self.loadingView.hidden = YES;
                        UIAlertController *alert = [UIAlertController
                                                    alertControllerWithTitle:@"Movie not found"
                                                    message:@"No movies matched your search"
                                                    preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"OK"
                                                    style:UIAlertActionStyleDefault
                                                    
                                                    handler:^(UIAlertAction * action) {
                                                    }];
                        
                        [alert addAction:yesButton];
                        
                        [self presentViewController:alert animated:YES completion:nil];
                        [self.tableView setUserInteractionEnabled:YES];
                    });
                }
            }
        }];
    } else {
        [self displayConnectionAlert];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}


-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([self.searchTimer isValid]) {
        self.searchTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.5f];
    } else {
        [self resetSearchTimer];
    }
}

-(void)resetSearchTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                      target:self
                                                    selector:@selector(instantSearch)
                                                    userInfo:nil
                                                     repeats:NO];
    self.searchTimer = timer;
}

- (void)instantSearch {
    if (self.connectedToInternet) {
        [self.manager.database search:self.searchBar.text completion:^(NSMutableArray *movies) {
            if (self.movies != movies) {
                if (movies.count != 0) {
                    self.movies = movies;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSRange range = NSMakeRange(0, 1);
                        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                    });
                }
            }
        }];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MovieCell";
    
    MovieTableViewCell *cell = (MovieTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Set movieID for cell
    Movie *movie = [_movies objectAtIndex:indexPath.row];
    cell.movieID = [[MovieID alloc] initWithID:[movie.idNumber intValue]];
    
    // Set labels based on movie data
    cell.titleLabel.text = movie.title;
    cell.releaseLabel.text = movie.releaseDate ?: @"TBA";
    cell.ratingLabel.text = [NSString stringWithFormat:@"%0.1f", [movie.rating doubleValue]];
    
    // Set favorites icon
    if ([cell isMovieInFavorites:[movie.idNumber integerValue]]) {
        [cell.favoriteButton setTintColor:[UIColor colorWithRed:1.00 green:0.32 blue:0.30 alpha:1.0]];
        [cell.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
    } else {
        [cell.favoriteButton setTintColor:[UIColor whiteColor]];
        [cell.favoriteButton setImage:[UIImage imageNamed:@"HeartHollow"] forState:UIControlStateNormal];
    }
    
    // Download poster image
    cell.posterImageView.image = [UIImage imageNamed:@"BlankMoviePoster"];
    NSURL *url = [[NSURL alloc] initWithString:movie.posterURL];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager loadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            cell.posterImageView.image = image;
        }
    }];
    
    return cell;
}

- (BOOL)isMovieInFavorites:(NSInteger)movieID {
    RLMResults *favorites = [MovieID allObjects];
    
    for (MovieID *realmMovieID in favorites) {
        if (realmMovieID.movieID == movieID) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end
