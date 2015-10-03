//
//  AppDependencies.m
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "AppDependencies.h"
#import "MockTwitterDataManager.h"
#import "TwitterSearchInteractor.h"
#import "SearchResultPresenter.h"
#import "ViewController.h"

@interface AppDependencies() {
    SearchResultPresenter *presenter;
    MockTwitterDataManager *mockDataManager;
}

@end

@implementation AppDependencies

- (void)configureDependenciesFor:(AppDelegate *)appDelegate {
    
    // create/obtain objects
    ViewController *searchResultVC = (ViewController*)[appDelegate.window rootViewController];
    TwitterSearchInteractor *interactor = [TwitterSearchInteractor new];
    mockDataManager = [MockTwitterDataManager new];
    presenter = [SearchResultPresenter new];
    
    // configure dependencies
    interactor.twitterDataSource = mockDataManager;
    interactor.output = presenter;
    
    presenter.searchInput = interactor;
    presenter.searchResultsUI = searchResultVC;
    
    searchResultVC.eventHandler = presenter;
}

@end
