//
//  FavoritesViewController.m
//  CineSearch
//
//  Created by Ritam Sarmah on 12/21/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "FavoritesViewController.h"
#import "DetailViewController.h"
#import "MovieTableViewCell.h"
#import "MovieID.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Realm/Realm.h>


static NSString * const CellIdentifier = @"MovieCell";
static NSString * const kTableName = @"table";

@interface FavoritesViewController ()

@property (nonatomic, strong) RLMResults *array;
@property (nonatomic, strong) RLMNotificationToken *notificationToken;

@end

@implementation FavoritesViewController

#pragma mark - View Lifecycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.activityIndicator.center = CGPointMake(self.view.bounds.size.width / 2,  self.view.bounds.size.height / 3);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if (self.enteredSegue && self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.enteredSegue) {
        self.enteredSegue = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Favorites";
    
    BoxActivityIndicatorView *activityIndicator = [[BoxActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    activityIndicator.disablesInteraction = NO;
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
    [self.activityIndicator startAnimating];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.array = [[MovieID allObjects] sortedResultsUsingKeyPath:@"movieID" ascending:YES];
    self.manager = [[MovieSearchManager alloc] init];
    self.moviesForID = [[NSMutableDictionary alloc] init];
    self.enteredSegue = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.finishedDownloadingMovies = NO;
    if (self.array.count != 0) {
        for (MovieID *movieID in self.array) {
            if (!self.moviesForID[@(movieID.movieID)]) {
                [self.manager.database getMovieForID:movieID completion:^(Movie *movie) {
                    [self.moviesForID setObject:movie forKey:@([movie.idNumber integerValue])];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.array.count == self.moviesForID.count) {
                            [self.activityIndicator stopAnimating];
                            self.finishedDownloadingMovies = YES;
                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                    });
                }];
            }
        }
    } else {
        [self.activityIndicator stopAnimating];
        self.finishedDownloadingMovies = YES;
    }
    
    // Set realm notification block
    __weak typeof(self) weakSelf = self;
    self.notificationToken = [self.array addNotificationBlock:^(RLMResults<MovieID *> *results, RLMCollectionChange *changes, NSError *error) {
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }
        
        UITableView *tableView = weakSelf.tableView;
        // Initial run of the query will pass nil for the change information
        if (!changes) {
            [tableView reloadData];
            return;
        }
        
        // Download newly favorited movies if needed
        for (MovieID *movieID in results) {
            if ([weakSelf.moviesForID objectForKey:@(movieID.movieID)] == nil) {
                [weakSelf.manager.database getMovieForID:movieID completion:^(Movie *movie) {
                    [weakSelf.moviesForID setObject:movie forKey:@([movie.idNumber integerValue])];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [tableView reloadData];
                    });
                }];
            }
        }
        
        // Query results have changed, so apply them to the UITableView
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[changes deletionsInSection:0]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView insertRowsAtIndexPaths:[changes insertionsInSection:0]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadRowsAtIndexPaths:[changes modificationsInSection:0]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }];
}

- (void)dealloc {
    [self.notificationToken invalidate];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Waits for movie data to be downloaded before populating tableview
    if (self.finishedDownloadingMovies) return self.array.count;
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieTableViewCell *cell = (MovieTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MovieID *key = self.array[indexPath.row];
    cell.movieID = key;
    cell.tag = indexPath.row;
    
    // Set favorites icon
    [cell.favoriteButton setFavorite:YES animated:NO];
    
    Movie *movie = self.moviesForID[@(key.movieID)];
    if (movie != nil) {
        cell.titleLabel.text = movie.title;
        cell.releaseLabel.text = movie.releaseDate ?: @"TBA";
        cell.ratingLabel.text = [NSString stringWithFormat:@"%0.1f", [movie.rating doubleValue]];
        
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
    }
    
    return cell;
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.enteredSegue = YES;
    if ([[segue identifier] isEqualToString:@"showFavoriteMovie"]) {
        MovieTableViewCell *cell = (MovieTableViewCell *)sender;
        DetailViewController *controller = segue.destinationViewController;
        [controller setMovie:self.moviesForID[@(cell.movieID.movieID)]];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end

