//
//  DiscoverViewController.m
//  CineSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "DiscoverViewController.h"
#import "MovieSearchManager.h"
#import "DetailViewController.h"
#import "MovieID.h"
#import "AFTableViewCell.h"

#import <Realm/Realm.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DiscoverViewController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.activityIndicator.center = CGPointMake(self.view.bounds.size.width / 2,  self.view.bounds.size.height / 2);
    CGFloat newHeight = self.view.frame.size.width * (60.0/107.0);
    [self.movieCarousel setBounds:CGRectMake(0, 0, self.movieCarousel.frame.size.width, newHeight)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if (enteredSegue && self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    
    // Reset carousel if carousel visible
    if (!self.movieCarousel.isHidden) {
        [self resetTimer];
        [self.movieCarousel reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (enteredSegue) {
        enteredSegue = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Discover";
    
    self.manager = [MovieSearchManager sharedManager];
    self.bannerMovies = [NSMutableArray arrayWithCapacity:4];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    enteredSegue = NO;
    
    BoxActivityIndicatorView *activityIndicator = [[BoxActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    activityIndicator.disablesInteraction = NO;
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
    
    // Configure iCarousel
    [self.movieCarousel setHidden:YES];
    self.movieCarousel.dataSource = self;
    self.movieCarousel.delegate = self;
    self.movieCarousel.wrapEnabled = YES;
    
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
    
    internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    [self updateInterfaceWithReachability:internetReachability];
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
    if (reachability == internetReachability) {
        [self configureInterfaceWithReachability:reachability];
    }
}

- (void)configureInterfaceWithReachability:(Reachability *)reachability {
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    switch (netStatus) {
        case NotReachable: {
            self.connectionLabel.hidden = NO;
            self.movieCarousel.hidden = YES;
            self.movieTableView.hidden = YES;
            [self.activityIndicator stopAnimating];
            break;
        }
        case ReachableViaWWAN:
        case ReachableViaWiFi: {
            switch (lastStatus) {
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
    lastStatus = netStatus;
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
        [self.manager.database getRecommendedForID:randomID completion:^(NSMutableArray *movies) {
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
        
        // Configure carousel with movie banners
        self.bannerImages = images;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetTimer];
            [self.movieCarousel reloadData];
            [UIView transitionWithView:self.view
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self.movieCarousel setHidden:NO];
                                [self.movieTableView setHidden:NO];
                            }
                            completion:nil];
            [self.activityIndicator stopAnimating];
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
    
    moviesArray = [NSArray arrayWithArray:mutableArray];
    contentOffsetDictionary = [NSMutableDictionary dictionary];
    [self.movieTableView reloadData];
}

- (void)openBannerMovie:(NSInteger)index {
    Movie *selectedMovie = self.bannerMovies[index];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.4
                                                      target:self.activityIndicator
                                                    selector:@selector(startAnimating)
                                                    userInfo:nil
                                                     repeats:NO];
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
    [self.manager.database getMovieForID:[selectedMovie getMovieID] completion:^(Movie *movie) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [timer invalidate];
            [self.activityIndicator stopAnimating];
            [self performSegueWithIdentifier:@"showBannerDetail" sender:movie];
        });
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    enteredSegue = YES;
    [carouselTimer invalidate];
    Movie *movie = (Movie *)sender;
    DetailViewController *controller = segue.destinationViewController;
    [controller setMovie:movie];
    controller.isFavorite = [self isMovieInFavorites:[movie.idNumber integerValue]];
    [UIApplication.sharedApplication endIgnoringInteractionEvents];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        
        CGFloat horizontalOffset = scrollView.contentOffset.x;
        
        AFIndexedCollectionView *collectionView = (AFIndexedCollectionView *)scrollView;
        NSInteger index = collectionView.section;
        contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
        
    } else if ([scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
}

- (BOOL)isMovieInFavorites:(NSInteger)movieID {
    RLMResults *favorites = [MovieID allObjects];
    
    for (MovieID *realmMovieID in favorites) {
        if (realmMovieID.value == movieID) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return moviesArray.count;
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
    
    CGFloat horizontalOffset = [contentOffsetDictionary[[@(index) stringValue]] floatValue];
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
    
    NSArray *collectionViewArray = moviesArray[[(AFIndexedCollectionView *)collectionView section]];
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
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
    [self.manager.database getMovieForID:[cell.movie getMovieID] completion:^(Movie *movie) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [timer invalidate];
            [self.activityIndicator stopAnimating];
            [self performSegueWithIdentifier:@"showMovieDetail" sender:movie];
        });
    }];
}

#pragma mark - SwipeView

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return self.bannerImages.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UIImage *image = [self.bannerImages objectAtIndex:index];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame: CGRectMake(0, 0, self.movieCarousel.frame.size.width, self.movieCarousel.frame.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return imageView;
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index {
    [self openBannerMovie:index];
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView {
    [self resetTimer];
}

- (void)autoScroll {
    NSInteger nextIndex = (self.movieCarousel.currentPage + 1) % self.movieCarousel.numberOfItems;
    [self.movieCarousel scrollToItemAtIndex:nextIndex duration:0.7];
}

- (void)resetTimer {
    [carouselTimer invalidate];
    carouselTimer = [NSTimer scheduledTimerWithTimeInterval:5.5 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
}

#pragma mark - Gesture Recognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end
