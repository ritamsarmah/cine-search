//
//  DiscoverViewController.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "DiscoverViewController.h"
#import "MovieSingleton.h"
#import "DetailViewController.h"
#import "MovieID.h"
#import <Realm/Realm.h>
#import "AFTableViewCell.h"

@interface DiscoverViewController () {
    int x;
    int max;
    BOOL isAutoScrolling;
}

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation DiscoverViewController

- (void)loadView {
    [super loadView];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:activityIndicator];
    self.loadingMovies = activityIndicator;
    
    const NSInteger numberOfTableViewRows = 1;
    const NSInteger numberOfCollectionViewCells = 10;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++) {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            
            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];
            
            [colorArray addObject:color];
        }
        
        [mutableArray addObject:colorArray];
    }
    
    self.colorArray = [NSArray arrayWithArray:mutableArray];
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.loadingMovies.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Discover";
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [MovieSingleton sharedManager];
    self.bannerMovies = [NSMutableArray arrayWithCapacity:4];
    self.imageScrollView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.loadingMovies startAnimating];
    isAutoScrolling = NO;
    
    self.movieTableView.rowHeight = 120;
    self.movieTableView.backgroundColor = [UIColor clearColor];
    
    self.detailViewController = [(DetailViewController *)[DetailViewController alloc] init];
    
    [self.manager.database getNowPlaying:^(NSMutableArray *movies) {
        if (self.moviesNowPlaying != movies) {
            if (movies.count != 0) {
                [self.imageCache removeAllObjects];
                self.moviesNowPlaying = movies;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupImageScrollView];
                    // TODO: Include reload method call for scroll view of "in theatres", etc...
                    // [self.loadingMovies stopAnimating]; TODO: Reimplement
                });
            }
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupImageScrollView {
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:6];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        for (Movie *movie in self.moviesNowPlaying) {
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
                // Duplicate first and last images for circular scrollview
                [images addObject:images[0]];
                [images insertObject:images[3] atIndex:0];
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            x = 0;
            int tagNumber = 0;
            max = [[UIScreen mainScreen] bounds].size.width * (images.count-1);
            
            self.imageScrollView.pagingEnabled = YES;
            for (UIImage *image in images) {
                
                // Popular scrollview with imageViews containing backdrops
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 0, [[UIScreen mainScreen] bounds].size.width, self.imageScrollView.frame.size.height)];
                
                imageView.image = image;
                imageView.tag = tagNumber;
                tagNumber++;
                x += [[UIScreen mainScreen] bounds].size.width;
                
                imageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMovie:)];
                [imageView addGestureRecognizer:tapRecognizer];
                
                self.imageScrollView.hidden = YES;
                [self.imageScrollView addSubview:imageView];
                [self.loadingMovies stopAnimating];
                [UIView transitionWithView:self.imageScrollView
                                  duration:0.3
                 
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    self.imageScrollView.hidden = NO;
                                }
                                completion:nil];
            }
            
            self.imageScrollView.contentSize=CGSizeMake(x, self.imageScrollView.frame.size.height);
            self.imageScrollView.contentOffset=CGPointMake([[UIScreen mainScreen] bounds].size.width, 0);
            
            x = ([[UIScreen mainScreen] bounds].size.width * 2);
            
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.7 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
            self.scrollTimer = timer;
        });
    });
}

-(void)nextImage {
    isAutoScrolling = YES;
    if (x == max) {
        [self.imageScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.imageScrollView setContentOffset:CGPointMake([[UIScreen mainScreen] bounds].size.width, 0) animated:NO];
        } completion:nil];
        
    } else {
        [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.imageScrollView.contentOffset = CGPointMake(x, 0);
        } completion:nil];
    }
    isAutoScrolling = NO;
    x += [[UIScreen mainScreen] bounds].size.width;
}

-(void)openMovie:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"showDiscoverDetail" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDiscoverDetail"]) {
        UITapGestureRecognizer *recognizer = (UITapGestureRecognizer *)sender;
        UIImageView *imageView = (UIImageView *)recognizer.view;
        Movie *movie = self.bannerMovies[imageView.tag-1];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setMovie:movie];
        
        if ([self isMovieInFavorites:[movie.idNumber integerValue]]) {
            controller.isFavorite = YES;
        } else {
            controller.isFavorite = NO;
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        
        CGFloat horizontalOffset = scrollView.contentOffset.x;
        
        AFIndexedCollectionView *collectionView = (AFIndexedCollectionView *)scrollView;
        NSInteger index = collectionView.indexPath.row;
        self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
        
    } else if ([scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
    else {
        if (scrollView.contentOffset.x == max && !isAutoScrolling) {
            [scrollView setContentOffset:CGPointMake([[UIScreen mainScreen] bounds].size.width, 0) animated:NO];
        }
        else if (scrollView.contentOffset.x == 0 && !isAutoScrolling) {
            [scrollView setContentOffset:CGPointMake((max-[[UIScreen mainScreen] bounds].size.width),0) animated:NO];
        } else {
            x = scrollView.contentOffset.x;
        }
    }
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

// CollectionView + TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.colorArray.count;
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
            sectionName = NSLocalizedString(@"In Theatres", @"In Theatres");
            break;
        case 1:
            sectionName = NSLocalizedString(@"New & Trending", @"New & Trending");
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
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    NSInteger index = cell.collectionView.indexPath.row;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *collectionViewArray = self.colorArray[[(AFIndexedCollectionView *)collectionView indexPath].row];
    return collectionViewArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSArray *collectionViewArray = self.colorArray[[(AFIndexedCollectionView *)collectionView indexPath].row];
    cell.backgroundColor = collectionViewArray[indexPath.item];
    
    return cell;
}

@end
