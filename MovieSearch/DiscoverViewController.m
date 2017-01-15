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

@interface DiscoverViewController () {
    int x;
    int max;
    BOOL isAutoScrolling;
}

@end

@implementation DiscoverViewController

- (void)loadView {
    [super loadView];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:activityIndicator];
    self.loadingMovies = activityIndicator;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.loadingMovies.center = self.view.center;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [MovieSingleton sharedManager];
    self.imageScrollView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.loadingMovies startAnimating];
    isAutoScrolling = NO;
    
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
    UIImageView *imageView = (UIImageView *)sender.view;
    NSLog(@"%lu", imageView.tag);
    Movie *movie = self.bannerMovies[imageView.tag];
    DetailViewController *controller = (DetailViewController *)[self detailViewController];
    [controller setMovie:movie];
    [self showDetailViewController:controller sender:self];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == max && !isAutoScrolling) {
        [scrollView setContentOffset:CGPointMake([[UIScreen mainScreen] bounds].size.width, 0) animated:NO];
    }
    else if (scrollView.contentOffset.x == 0 && !isAutoScrolling) {
        [scrollView setContentOffset:CGPointMake((max-[[UIScreen mainScreen] bounds].size.width),0) animated:NO];
    } else {
        x = scrollView.contentOffset.x;
    }
}

@end
