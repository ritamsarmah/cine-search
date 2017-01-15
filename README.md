# Movie Search
Keep up with the latest movies using Movie Search for iPhone. Uses The Movie Database API for searching and discovering movies.

## Getting Started
1. Install Xcode.
2. Clone this repository.
3. Install dependencies using [CocoaPods](https://github.com/CocoaPods/CocoaPods).
4. Create an account with [tMDB](https://www.themoviedb.org/account/signup?language=en) and apply for an API key.
5. Create files in MovieSearch.xcworkspace holding your key:
    ```objc
    // Constants.h
    extern NSString *const key;

    // Constants.m
    NSString *const key = @"your-key-here";
    ```
6. Build and run.

## Dependencies 
- [Realm](https://github.com/realm/realm-cocoa)

## Known Issues & Bugs
- Discover tab is incomplete
- Crashes when there is no internet connection
