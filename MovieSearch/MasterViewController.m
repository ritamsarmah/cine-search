//
//  MasterViewController.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "MasterViewController.h"
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
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.searchBar.delegate = self;
    _database = [[MovieSearch alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMovie"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Movie *movie = self.movies[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setMovie:movie];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Search Bar

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.loadingMovies startAnimating];
    self.loadingView.hidden = false;
    [_database search:searchBar.text completion:^(NSMutableArray *movies) {
        if (movies.count != 0) {
            self.movies = movies;
            NSLog(@"%lu", self.movies.count);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSRange range = NSMakeRange(0, 1);
                NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.loadingMovies stopAnimating];
                self.loadingView.hidden = true;
            });
        } else {
            // TODO: Display alert message for no movies found
        }
        
    }];
    [searchBar endEditing:true];
    NSLog(@"Searching for %@", searchBar.text);
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
    
    // Display movie in the table cell
    Movie *movie = [_movies objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = movie.title;
    
    if ([movie.releaseDate isEqualToString:@""]) {
        cell.releaseLabel.text = @"Unknown release date";
    } else {
        cell.releaseLabel.text = movie.releaseDate;
    }
    
    cell.ratingLabel.text = [movie.rating stringValue];
    
    // TODO: Change number to star rating design
    
    // Download image from URL
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

            } else {
                cell.posterImageView.image = [UIImage imageNamed:@"BlankMoviePoster"];
            }
            [cell.loadingPoster stopAnimating];
        });
    });
    
    return cell;
}

@end
