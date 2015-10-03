//
//  AppDependencies.m
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "AppDependencies.h"
#import "TwitterSearchInteractor.h"
#import "SearchResultPresenter.h"
#import "ViewController.h"
#import "TwitterURLSource.h"
#import "TwitterDataManager.h"
#import "MockTwitterDataManager.h"

@interface AppDependencies() {
    SearchResultPresenter *presenter;
    id<TwitterDataSource> twitterDataManager;
}

@end

@implementation AppDependencies

- (void)configureDependenciesFor:(AppDelegate *)appDelegate {

    // create/obtain objects
#ifdef MOCK_DATA
    twitterDataManager = [MockTwitterDataManager new];
#else
    twitterDataManager = [TwitterDataManager new];
    twitterDataManager.twitterURLBuilder = [TwitterURLSource new];
#endif
    
    ViewController *searchResultVC = (ViewController*)[appDelegate.window rootViewController];
    TwitterSearchInteractor *interactor = [TwitterSearchInteractor new];
    presenter = [SearchResultPresenter new];
    
    // configure dependencies
    interactor.twitterDataSource = twitterDataManager;
    interactor.output = presenter;
    
    presenter.searchInput = interactor;
    presenter.searchResultsUI = searchResultVC;
    
    searchResultVC.eventHandler = presenter;
}

@end
