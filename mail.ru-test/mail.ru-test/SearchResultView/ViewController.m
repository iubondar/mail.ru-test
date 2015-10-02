//
//  ViewController.m
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "ViewController.h"
#import "SearchResultCell.h"

static NSString * const kSearchResultCellIdentifier = @"SearchResultCell";

@interface ViewController () <UISearchBarDelegate, UITableViewDataSource>

@end

@implementation ViewController

@synthesize searchResultDataSource;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // TODO: Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // TODO: map to datasource
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchResultCellIdentifier];
    
    // TODO: set data for cell
    
    return cell;
}

@end
