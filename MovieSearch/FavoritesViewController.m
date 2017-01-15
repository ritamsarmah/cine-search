//
//  FavoritesViewController.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/21/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "FavoritesViewController.h"
#import "DetailViewController.h"
#import "MovieTableViewCell.h"
#import "MovieID.h"
#import <Realm/Realm.h>

static NSString * const CellIdentifier = @"MovieCell";
static NSString * const kTableName = @"table";

@interface FavoritesViewController ()

@property (nonatomic, strong) RLMResults *array;
@property (nonatomic, strong) RLMNotificationToken *notification;

@end

@implementation FavoritesViewController

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.array = [[MovieID allObjects] sortedResultsUsingKeyPath:@"movieID" ascending:YES];
    self.manager = [[MovieSingleton alloc] init];
    self.imageCache = [[NSMutableDictionary alloc] init];
    
    // Set realm notification block
    __weak typeof(self) weakSelf = self;
    self.notification = [self.array addNotificationBlock:^(RLMResults *data, RLMCollectionChange *changes, NSError *error) {
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }
        
        UITableView *tv = weakSelf.tableView;
        // Initial run of the query will pass nil for the change information
        if (!changes) {
            [tv reloadData];
            return;
        }
        
        // changes is non-nil, so we just need to update the tableview
        [tv beginUpdates];
        [tv deleteRowsAtIndexPaths:[changes deletionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv insertRowsAtIndexPaths:[changes insertionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv reloadRowsAtIndexPaths:[changes modificationsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv endUpdates];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieTableViewCell *cell = (MovieTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:0.00 green:0.72 blue:1.00 alpha:1.0];
    [cell setSelectedBackgroundView:bgColorView];
    
    MovieID *object = self.array[indexPath.row];
    __block Movie *movie;
    cell.movieID = object;
    [self.manager.database getMovieForID:object.movieID completion:^(Movie *movieForObject) {
        movie = movieForObject;
    }];
    
    while (movie == nil) {} // Waits for completion block to set movie TODO: Rewrite this
    
    // Set labels based on movie data
    cell.titleLabel.text = movie.title;
    cell.releaseLabel.text = movie.releaseDate ?: @"TBA";
    cell.ratingLabel.text = [NSString stringWithFormat:@"%0.1f", [movie.rating doubleValue]];
    
    // Check if image cached, else download from URL
    cell.posterImageView.image = nil;
    UIImage *posterImage = [self.imageCache objectForKey:movie.idNumber];
    if (posterImage != nil) {
        [UIView transitionWithView:cell.posterImageView
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            cell.posterImageView.image = posterImage;
                        } completion:nil];
    } else {
        [cell.loadingPoster startAnimating];
        NSURL *url = [[NSURL alloc] initWithString:movie.posterURL];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data != nil) {
                    UIImage *posterImage = [UIImage imageWithData:data];
                    [UIView transitionWithView:cell.posterImageView
                                      duration:0.2f
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        cell.posterImageView.image = posterImage;
                                    } completion:nil];
                    self.imageCache[movie.idNumber] = posterImage;
                } else {
                    cell.posterImageView.image = [UIImage imageNamed:@"BlankMoviePoster"];
                }
                [cell.loadingPoster stopAnimating];
            });
        }];
        [task resume];
    }
    
    [cell.favoriteButton setTintColor:[UIColor colorWithRed:1.00 green:0.32 blue:0.30 alpha:1.0]];
    [cell.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
    
    return cell;
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Preparing for segue");
    if ([[segue identifier] isEqualToString:@"showFavoriteMovie"]) {
        MovieTableViewCell *cell = (MovieTableViewCell *)sender;
        __block Movie *movie;
        [self.manager.database getMovieForID:cell.movieID.movieID completion:^(Movie *movieForObject) {
            movie = movieForObject;
        }];
        
        self.navigationController.navigationBar.hidden = YES;
        
        while (movie == nil) {}
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setMovie:movie];
    }
}

@end

