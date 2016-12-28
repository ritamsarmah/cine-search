//
//  MasterViewController.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MasterViewController.h"
#import "MovieTableViewCell.h"
#import "MovieSingleton.h"
#import "DetailViewController.h"

@implementation MasterViewController

- (void)loadView {
    [super loadView];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    CGRect size = CGRectMake(0, 0, 70, 70);
    UIView *view = [[UIView alloc] initWithFrame:size];
    view.backgroundColor = [UIColor darkGrayColor];
    view.alpha = 0.7;
    view.hidden = true;
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = true;
    
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
    self.navigationController.navigationBar.hidden = true;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.searchBar.delegate = self;
    self.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    _imageCache = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.imageCache removeAllObjects];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMovie"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Movie *movie = self.movies[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        [controller setMovie:movie];
        [self.searchBar endEditing:true];
    }
}

#pragma mark - Search Bar

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchTimer invalidate];
    [self.loadingMovies startAnimating];
    self.loadingView.hidden = false;
    [self.manager.database search:searchBar.text completion:^(NSMutableArray *movies) {
        if (self.movies != movies) {
            if (movies.count != 0) {
                [self.imageCache removeAllObjects];
                self.movies = movies;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSRange range = NSMakeRange(0, 1);
                    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.loadingMovies stopAnimating];
                    self.loadingView.hidden = true;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loadingMovies stopAnimating];
                    self.loadingView.hidden = true;
                    UIAlertController *alert = [UIAlertController
                                                alertControllerWithTitle:@"Unable to find movie"
                                                message:@"No movies matched your search"
                                                preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* yesButton = [UIAlertAction
                                                actionWithTitle:@"OK"
                                                style:UIAlertActionStyleDefault
                                                
                                                handler:^(UIAlertAction * action) {
                                                }];
                    
                    [alert addAction:yesButton];
                    
                    [self presentViewController:alert animated:true completion:nil];
                });
            }
        }
        
    }];
    [searchBar endEditing:true];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}


-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
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
    [self.manager.database search:self.searchBar.text completion:^(NSMutableArray *movies) {
        if (self.movies != movies) {
            if (movies.count != 0) {
                [self.imageCache removeAllObjects];
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
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:0.00 green:0.72 blue:1.00 alpha:1.0];
    [cell setSelectedBackgroundView:bgColorView];
    
    // Display movie in the table cell
    Movie *movie = [_movies objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = movie.title;
    cell.releaseLabel.text = movie.releaseDate ?: @"TBA";
    cell.ratingLabel.text = [NSString stringWithFormat:@"%0.1f", [movie.rating doubleValue]];
    
    // Check if image cached, else download from URL
    UIImage *posterImage = [self.imageCache objectForKey:movie.idNumber];
    if ([self.imageCache objectForKey:movie.idNumber] != nil) {
        [UIView transitionWithView:cell.posterImageView
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            cell.posterImageView.image = posterImage;
                        } completion:nil];
    } else {
        NSURL *url = [[NSURL alloc] initWithString:movie.posterURL];
        cell.posterImageView.image = nil;
        [cell.loadingPoster startAnimating];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData *data = [[NSData alloc] initWithContentsOfURL:url];
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
        });
    }
    
    return cell;
}

@end
