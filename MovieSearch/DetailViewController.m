//
//  DetailViewController.m
//  MovieSearch
//
//  Created by Ritam Sarmah on 11/2/16.
//  Copyright © 2016 Ritam Sarmah. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController


- (void)configureView {
    // Update the user interface for the detail item.
    self.movieTitleLabel.text = self.movie.title;
    self.releaseLabel.text = [NSString stringWithFormat:@"Release date: %@", self.movie.releaseDate];
    self.ratingLabel.text = [NSString stringWithFormat:@"%0.1f", [self.movie.rating doubleValue]];
    self.overviewLabel.text = self.movie.overview;

    // Download poster image from URL
    NSURL *posterURL = [[NSURL alloc] initWithString:self.movie.posterURL];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL:posterURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil) {
                UIImage *posterImage = [UIImage imageWithData:data];
                self.posterImageView.image = posterImage;
                
            } else {
                self.posterImageView.image = [UIImage imageNamed:@"BlankMoviePoster"];
            }
        });
    });
    
    // Download backdrop image from URL
    self.backdropImageView.image = [UIImage imageNamed:@"BlankBackdrop"];
    NSURL *backdropURL = [[NSURL alloc] initWithString:self.movie.backdropURL];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL:backdropURL];
        
        if (data != nil) {
            UIImage *backdropImage = [UIImage imageWithData:data];
            CIContext *context = [CIContext contextWithOptions:nil];
            CIImage *inputImage = [CIImage imageWithCGImage:backdropImage.CGImage];
            
            CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [filter setValue:inputImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
            CIImage *result = [filter valueForKey:kCIOutputImageKey];
            
            CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
            
            CALayer *maskLayer = [CALayer layer];
            maskLayer.frame = self.backdropImageView.bounds;
            maskLayer.shadowPath = CGPathCreateWithRect(CGRectInset(self.backdropImageView.bounds, 5, 5), nil);
            maskLayer.shadowOpacity = 1;
            maskLayer.shadowOffset = CGSizeZero;
            maskLayer.shadowColor = [UIColor whiteColor].CGColor;
            
            self.backdropImageView.layer.mask = maskLayer;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView transitionWithView:self.backdropImageView
                                  duration:0.4f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    self.backdropImageView.image = [UIImage imageWithCGImage:cgImage];
                                } completion:nil];
                
                [self setNeedsStatusBarAppearanceUpdate];

            });
        }
    });
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.trailerButton.layer.cornerRadius = 5;
    self.trailerButton.layer.masksToBounds = YES;
    self.favoriteButton.layer.cornerRadius = 5;
    self.favoriteButton.layer.masksToBounds = YES;
    self.ratingView.layer.cornerRadius = 5;
    self.ratingView.layer.masksToBounds = YES;
    [self.navigationController setNavigationBarHidden:YES];
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Managing the detail item

- (void)setMovie:(Movie *)newMovie {
    if (_movie != newMovie) {
        _movie = newMovie;
        
        // Update the view.
        [self configureView];
    }
}

- (IBAction)back:(UIButton *)sender {
    UINavigationController *navCon = [self.splitViewController.viewControllers objectAtIndex:0];
    [navCon popViewControllerAnimated: YES];
}

@end
