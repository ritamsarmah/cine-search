//
//  DiscoverViewController.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 12/22/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "DiscoverViewController.h"

@interface DiscoverViewController () {
    int x;
    int max;
}

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [MovieSingleton sharedManager];
    self.imageScrollView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:4];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        for (Movie *movie in self.moviesNowPlaying) {
            NSURL *url = [NSURL URLWithString:movie.backdropURL];
            NSData *data = [[NSData alloc] initWithContentsOfURL: url];
            if (data != nil) {
                [images addObject:[UIImage imageWithData:data]];
            }
            if (images.count == 4) {
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            x = 0;
            max = [[UIScreen mainScreen] bounds].size.width * (images.count-1);
            
            self.imageScrollView.pagingEnabled = YES;
            for (id image in images) {
                UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(x, 0, [[UIScreen mainScreen] bounds].size.width, self.imageScrollView.frame.size.height)];
                imageView.image = image;
                x = x+[[UIScreen mainScreen] bounds].size.width;
                [self.imageScrollView addSubview:imageView];
            }
            
            self.imageScrollView.contentSize=CGSizeMake(x, self.imageScrollView.frame.size.height);
            self.imageScrollView.contentOffset=CGPointMake(0, 0);
            
            x = [[UIScreen mainScreen] bounds].size.width;
            
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.7 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
            self.scrollTimer = timer;
        });
    });
}

-(void)nextImage {
    [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.imageScrollView.contentOffset = CGPointMake(x, 0);
    } completion:nil];
    if (x >= max) {
        x = 0;
    } else {
        x += [[UIScreen mainScreen] bounds].size.width;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    x = scrollView.contentOffset.x;
}

@end
