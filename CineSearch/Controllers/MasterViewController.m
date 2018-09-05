//
//  MasterViewController.m
//  CineSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MasterViewController.h"
#import "MovieTableViewCell.h"
#import "MovieSearchManager.h"
#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Realm/Realm.h>

@implementation MasterViewController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.activityIndicator.center = window.center;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [MovieSearchManager sharedManager];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    BoxActivityIndicatorView *activityIndicator = [[BoxActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    activityIndicator.disablesInteraction = NO;
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
    [self.activityIndicator stopAnimating];
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
    
    [self presentViewController:alert animated:YES completion:nil];
    [self.tableView setUserInteractionEnabled:YES];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.enteredSegue = YES;
    if ([[segue identifier] isEqualToString:@"showMovie"]) {
        Movie *movie = (Movie *)sender;
        DetailViewController *controller = segue.destinationViewController;
        [controller setMovie:movie];
        controller.isFavorite = [self isMovieInFavorites:[movie.idNumber integerValue]];
        [self.searchBar endEditing:YES];
    }
}

#pragma mark - Search Bar

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if (self.connectedToInternet) {
        [self.searchTimer invalidate];
        [self.activityIndicator startAnimating];
        [searchBar endEditing:YES];
        [self.tableView setUserInteractionEnabled:NO];
        [self.manager.database getMoviesForQuery:searchBar.text completion:^(NSMutableArray *movies) {
            if (movies == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self displayConnectionAlert];
                });
            }
            else if (self.movies != movies) {
                if (movies.count != 0) {
                    self.movies = movies;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSRange range = NSMakeRange(0, 1);
                        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self.activityIndicator stopAnimating];
                        [self.tableView setUserInteractionEnabled:YES];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
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
        [self.manager.database getMoviesForQuery:self.searchBar.text completion:^(NSMutableArray *movies) {
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
            if (cacheType == SDImageCacheTypeNone) {
                [UIView transitionWithView:cell.posterImageView
                                  duration:0.2
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    cell.posterImageView.image = image;
                                } completion:nil];
            } else {
                cell.posterImageView.image = image;
            }
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieTableViewCell *cell = (MovieTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    // If database load is taking too long, activityIndicator will show
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.4
                                                      target:self.activityIndicator
                                                    selector:@selector(startAnimating)
                                                    userInfo:nil
                                                     repeats:NO];
    [self.manager.database getMovieForID:cell.movieID.movieID completion:^(Movie *movie) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [timer invalidate];
            [self.activityIndicator stopAnimating];
            [self performSegueWithIdentifier:@"showMovie" sender:movie];
        });
    }];
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
