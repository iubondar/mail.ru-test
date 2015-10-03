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
static CGFloat const kCellSeparatorHeight = 1;

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

- (BOOL)isLandscapeOrientation {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

- (BOOL)isDeviceIPad {
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static SearchResultCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.searchResultsTable dequeueReusableCellWithIdentifier:kSearchResultCellIdentifier];
    });
    
    [sizingCell setTweetUIData:[self.searchResultDataSource tweetUIDataForRow:indexPath.row]];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.searchResultsTable.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height + kCellSeparatorHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLandscapeOrientation] || [self isDeviceIPad]) {
        return 55;
    } else {
        return 71;
    }
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
