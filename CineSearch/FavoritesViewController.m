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
@property (nonatomic, strong) RLMNotificationToken *notification;

@end

@implementation FavoritesViewController

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Favorites";
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if (self.enteredSegue && self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.enteredSegue = NO;
    } else {
         [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.navigationController.navigationBar.largeTitleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.array = [[MovieID allObjects] sortedResultsUsingKeyPath:@"movieID" ascending:YES];
    self.manager = [[MovieSingleton alloc] init];
    self.moviesForID = [[NSMutableDictionary alloc] init];
    self.enteredSegue = NO;
    
    for (MovieID *movieID in self.array) {
        if (!self.moviesForID[@(movieID.movieID)]) {
            [self.manager.database getMovieForID:movieID.movieID completion:^(Movie *movie) {
                [self.moviesForID setObject:movie forKey:@([movie.idNumber integerValue])];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }];
        }
    }
    
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
        
        for (MovieID *movieID in data) {
            if ([weakSelf.moviesForID objectForKey:@(movieID.movieID)] == nil) {
                [weakSelf.manager.database getMovieForID:movieID.movieID completion:^(Movie *movie) {
                    [weakSelf.moviesForID setObject:movie forKey:@([movie.idNumber integerValue])];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                }];
            }
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
    
    
    MovieID *key = self.array[indexPath.row];
    cell.movieID = key;
    cell.tag = indexPath.row;
    
    // Set favorites icon
    [cell.favoriteButton setTintColor:[UIColor colorWithRed:1.00 green:0.32 blue:0.30 alpha:1.0]];
    [cell.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
    
    if (self.moviesForID[@(key.movieID)] != nil) {
        Movie *movie = self.moviesForID[@(key.movieID)];
        cell.titleLabel.text = movie.title;
        cell.releaseLabel.text = movie.releaseDate ?: @"TBA";
        cell.ratingLabel.text = [NSString stringWithFormat:@"%0.1f", [movie.rating doubleValue]];
        
        // Download poster image
        cell.posterImageView.image = [UIImage imageNamed:@"BlankMoviePoster"];
        NSURL *url = [[NSURL alloc] initWithString:movie.posterURL];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager loadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                cell.posterImageView.image = image;
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
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setMovie:self.moviesForID[@(cell.movieID.movieID)]];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end

