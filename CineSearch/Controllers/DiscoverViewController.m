//
//  DiscoverViewController.m
//  CineSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "DiscoverViewController.h"
#import "MovieSingleton.h"
#import "DetailViewController.h"
#import "MovieID.h"
#import "AFTableViewCell.h"

#import <Realm/Realm.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DiscoverViewController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.activityIndicator.center = CGPointMake(self.view.bounds.size.width / 2,  self.view.bounds.size.height / 2);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Discover";
    if (self.enteredSegue && self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }

    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.enteredSegue = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.manager = [MovieSingleton sharedManager];
    self.bannerMovies = [NSMutableArray arrayWithCapacity:4];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;

    BoxActivityIndicatorView *activityIndicator = [[BoxActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    activityIndicator.disablesInteraction = NO;
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;

    // Configure imageSlideshow parameters
    [self.imageSlideshow setHidden:YES];
//    self.imageSlideshow.width = self.imageSlideshow.frame.size.width; // [[UIScreen mainScreen] bounds].size.width;
    self.imageSlideshow.timeInterval = 5.7;
    self.imageSlideshow.pagingEnabled = YES;
    self.imageSlideshow.interactionViewController = self;
    
    [self.movieTableView setHidden:YES];
    self.movieTableView.rowHeight = 155; // CollectionViewCell Height + 20 for padding
    self.movieTableView.backgroundColor = [UIColor clearColor];

    // Set up of connection status label
    self.connectionLabel.hidden = YES;

    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method
     reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

/*
 * Called by Reachability whenever status changes.
 */
#pragma mark - Reachability
- (void) reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    if (reachability == self.internetReachability) {
        [self configureInterfaceWithReachability:reachability];
    }
}

- (void)configureInterfaceWithReachability:(Reachability *)reachability {
    NetworkStatus netStatus = [reachability currentReachabilityStatus];

    switch (netStatus) {
        case NotReachable: {
            self.connectionLabel.hidden = NO;
            self.imageSlideshow.hidden = YES;
            self.movieTableView.hidden = YES;
            [self.activityIndicator stopAnimating];
            break;
        }
        case ReachableViaWWAN:
        case ReachableViaWiFi: {
            switch (self.lastStatus) {
                case ReachableViaWWAN:
                case ReachableViaWiFi:
                    break;
                default: {
                    self.connectionLabel.hidden = YES;
                    [self.activityIndicator startAnimating];
                    [self retrieveMovieData];
                    break;
                }
            }
        }
    }
    self.lastStatus = netStatus;
}

#pragma mark - UI/Movie methods
- (void)retrieveMovieData {
    dispatch_group_t movieCollectionGroup = dispatch_group_create();

    // Populate nowPlayingMovies array
    dispatch_group_enter(movieCollectionGroup);
    [self.manager.database getNowPlaying:^(NSMutableArray *movies) {
        if (movies.count != 0) {
            self.nowPlayingMovies = movies;
        }
        dispatch_group_leave(movieCollectionGroup);
    }];

    // Populate popularMovies array
    dispatch_group_enter(movieCollectionGroup);
    [self.manager.database getPopular:^(NSMutableArray *movies) {
        if (movies.count != 0) {
            self.popularMovies = movies;
        }
        dispatch_group_leave(movieCollectionGroup);
    }];

    // Get random ID for recommendation
    RLMResults *favorites = [MovieID allObjects];
    if (favorites.count != 0) {
        int randIndex = arc4random_uniform((int)favorites.count);
        MovieID *randomID = favorites[randIndex];

        // Populate recommendedMovies array
        dispatch_group_enter(movieCollectionGroup);
        [self.manager.database getRecommendedForID:randomID.movieID completion:^(NSMutableArray *movies) {
            if (movies.count != 0) {
                self.recommendedMovies = movies;
            }
            dispatch_group_leave(movieCollectionGroup);
        }];
    }

    dispatch_group_notify(movieCollectionGroup, dispatch_get_main_queue(),^{
        [self setupImageSlideshow];
        [self setupMoviesTableView];
    });
}

- (void)setupImageSlideshow {
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:6];

    dispatch_async(dispatch_get_global_queue(0,0), ^{
        for (Movie *movie in self.nowPlayingMovies) {
            NSURL *url = [NSURL URLWithString:movie.backdropURL];
            NSData *data = [[NSData alloc] initWithContentsOfURL: url];
            if (data != nil) {

                // Create backdrop image
                UIImage *backdrop = [UIImage imageWithData:data];
                NSString *title = movie.title;

                NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                paragraphStyle.alignment = NSTextAlignmentLeft;

                NSShadow *shadow = [[NSShadow alloc] init];
                shadow.shadowColor = [UIColor blackColor];
                shadow.shadowBlurRadius = 6;
                shadow.shadowOffset = CGSizeMake(0.0, 0.0);

                UIFont *font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:32];

                NSDictionary *attributes = @{ NSFontAttributeName: font,
                                              NSParagraphStyleAttributeName: paragraphStyle,
                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                              NSShadowAttributeName: shadow };

                UIGraphicsBeginImageContext(backdrop.size);
                CGRect rect = CGRectMake(0, 0, backdrop.size.width, backdrop.size.height);
                [backdrop drawInRect:rect];
                [title drawInRect:CGRectMake(20, backdrop.size.height*(7.0/9.0), backdrop.size.width*(8.0/9.0), backdrop.size.height) withAttributes:attributes];
                UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                [self.bannerMovies addObject:movie];
                [images addObject:result];
            }
            if (images.count == 4) {
                break;
            }
        }

        // Configure imageSlideshow with movie banners
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageSlideshow configureImages:images withSelector:@selector(openBannerMovie:)];
            [self.activityIndicator stopAnimating];
            [UIView transitionWithView:self.view
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self.imageSlideshow setHidden:NO];
                                [self.movieTableView setHidden:NO];
                            }
                            completion:nil];
        });
    });
}

// Setup of movie table view data
- (void)setupMoviesTableView {
    const NSInteger numberOfSections = 3;
    const NSInteger numberOfCollectionViewCells = 10;

    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfSections];

    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSMutableArray *movieArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];

        switch (section) {
            case 0:
                movieArray = self.nowPlayingMovies;
                break;
            case 1:
                movieArray = self.popularMovies;
                break;
            case 2:
                movieArray = self.recommendedMovies;
                break;
            default:
                break;
        }

        if (movieArray != nil) {
            [mutableArray addObject:movieArray];
        }
    }

    self.moviesArray = [NSArray arrayWithArray:mutableArray];
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
    [self.movieTableView reloadData];
}

- (void)openBannerMovie:(UITapGestureRecognizer *)sender {
    UITapGestureRecognizer *recognizer = (UITapGestureRecognizer *)sender;
    UIImageView *imageView = (UIImageView *)recognizer.view;
    Movie *selectedMovie = self.bannerMovies[imageView.tag-1];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.4
                                                      target:self.activityIndicator
                                                    selector:@selector(startAnimating)
                                                    userInfo:nil
                                                     repeats:NO];
    [self.manager.database getMovieForID:selectedMovie.idNumber.integerValue completion:^(Movie *movie) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [timer invalidate];
            [self.activityIndicator stopAnimating];
            [self performSegueWithIdentifier:@"showBannerDetail" sender:movie];
        });
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.enteredSegue = YES;
    Movie *movie = (Movie *)sender;
    DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
    [controller setMovie:movie];
    controller.isFavorite = [self isMovieInFavorites:[movie.idNumber integerValue]];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {

        CGFloat horizontalOffset = scrollView.contentOffset.x;

        AFIndexedCollectionView *collectionView = (AFIndexedCollectionView *)scrollView;
        NSInteger index = collectionView.section;
        self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);

    } else if ([scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
//    else {
//        if (scrollView.contentOffset.x == max && !isAutoScrolling) {
//            [scrollView setContentOffset:CGPointMake([[UIScreen mainScreen] bounds].size.width, 0) animated:NO];
//        }
//        else if (scrollView.contentOffset.x == 0 && !isAutoScrolling) {
//            [scrollView setContentOffset:CGPointMake((max-[[UIScreen mainScreen] bounds].size.width),0) animated:NO];
//        } else {
//            x = scrollView.contentOffset.x;
//        }
//    }
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.moviesArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";

    AFTableViewCell *cell = (AFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;

    header.textLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:20];
    header.textLabel.text = [header.textLabel.text capitalizedString];
    header.textLabel.textColor = [UIColor whiteColor];
    header.backgroundView.backgroundColor = [UIColor clearColor];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 0:
            sectionName = NSLocalizedString(@"In Theaters", @"In Theaters");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Trending Now", @"Trending Now");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Recommended For You", @"Recommended For You");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(AFTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setCollectionViewDataSourceDelegate:self section:indexPath.section];
    NSInteger index = cell.collectionView.section;

    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    [cell.collectionView registerClass:[AFCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCellIdentifier"];
}

#pragma mark - Collection View

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AFCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];

    // Create imageView for background
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BlankMoviePoster"]];
    imageView.frame = cell.bounds;
    imageView.clipsToBounds = YES;
    imageView.contentScaleFactor = UIViewContentModeScaleAspectFit;

    NSArray *collectionViewArray = self.moviesArray[[(AFIndexedCollectionView *)collectionView section]];
    Movie *movie = collectionViewArray[indexPath.item];
    NSURL *posterURL = [NSURL URLWithString:movie.posterURL];

    // Download poster image
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:posterURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            if (cacheType == SDImageCacheTypeNone) {
                [UIView transitionWithView:imageView
                                  duration:0.2
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    imageView.image = image;
                                } completion:nil];
            } else {
                imageView.image = image;
            }
        }
    }];

    cell.backgroundView = imageView;
    cell.movie = movie;

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AFCollectionViewCell *cell = (AFCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    // If database load is taking too long, activityIndicator will show
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.4
                                                      target:self.activityIndicator
                                                    selector:@selector(startAnimating)
                                                    userInfo:nil
                                                     repeats:NO];
    [self.manager.database getMovieForID:cell.movie.idNumber.integerValue completion:^(Movie *movie) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [timer invalidate];
            [self.activityIndicator stopAnimating];
            [self performSegueWithIdentifier:@"showMovieDetail" sender:movie];
        });
    }];
}

#pragma mark - Gesture Recognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end