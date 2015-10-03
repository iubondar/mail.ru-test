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
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ViewController

@synthesize searchResultDataSource, eventHandler;

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

#pragma mark - TwitterSearchResultsUI

- (void)showNewTweets {
    [self reloadTable];
}

- (void)startEditSearchString {
    [self.searchBar becomeFirstResponder];
}

#pragma mark Private

- (void)reloadTable {
    [self.searchResultsTable reloadData];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // TODO: height by content
    return 50;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResultDataSource totalTweetsCount];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchResultCellIdentifier];
    [cell setTweetUIData:[self.searchResultDataSource tweetUIDataForRow:indexPath.row]];
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.eventHandler queryStringHasBeenChangedByUser:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.eventHandler queryStringHasBeenChangedByUser:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self.eventHandler queryStringHasBeenChangedByUser:searchBar.text];
}

@end
