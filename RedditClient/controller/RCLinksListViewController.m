//
//  ViewController.m
//  RedditClient
//
//  Created by Orest Savchak on 8/5/16.
//  Copyright © 2016 Orest Savchak. All rights reserved.
//

#import "RCLinksListViewController.h"
#import "RCLinksTableViewCell.h"
#import "RCLinksModel.h"
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>
#import <SVPullToRefresh/UIScrollView+SVInfiniteScrolling.h>

@interface RCLinksListViewController ()<UITableViewDataSource, UITextFieldDelegate, RCLinksModelDelegate>

@property (strong, nonatomic) RCLinksModel *model;

@property (strong, nonatomic) NSArray<RSLink *> *links;

@property (weak, nonatomic) IBOutlet UITableView *linksTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation RCLinksListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.model.delegate = self;
    [self addTableViewLoadingListeners];
    [self addObserversForKeyboardHandling];
}

- (void)addTableViewLoadingListeners {
    __weak RCLinksListViewController *weakSelf = self;
    [self.linksTableView addPullToRefreshWithActionHandler:^{
        [weakSelf.linksTableView showsPullToRefresh];
        [weakSelf didPulledToRefresh];
    }];
    [self.linksTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.linksTableView showsInfiniteScrolling];
        [weakSelf didInfiniteScolled];
    }];
}

//Careful, copy-paste!
- (void)addObserversForKeyboardHandling {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        id _obj = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect _keyboardFrame = CGRectNull;
        if ([_obj respondsToSelector:@selector(getValue:)]) [_obj getValue:&_keyboardFrame];
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_linksTableView setContentInset:UIEdgeInsetsMake(0.f, 0.f, _keyboardFrame.size.height, 0.f)];
        } completion:nil];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_linksTableView setContentInset:UIEdgeInsetsZero];
        } completion:nil];
    }];
}

- (RCLinksModel *)model {
    if (!_model) {
        _model = [RCLinksModel new];
    }
    return _model;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _activityIndicator.center = self.view.center;
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:_activityIndicator];
    }
    return _activityIndicator;
}

- (IBAction)didClickSearch:(UIButton *)sender {
    [self search];
}

- (void)showLoading {
    [self.activityIndicator startAnimating];
}

- (void)hideLoading {
    [self.activityIndicator stopAnimating];
}

- (void)didPulledToRefresh {
    [self.model updateTopItems];
}

- (void)didInfiniteScolled {
    [self.model updateBottomItems];
}

- (void)search {
    [self showLoading];
    [self clearTable];
    [self.model searchForQuery:self.searchTextField.text];
}

- (void)clearTable {
    self.links = nil;
    [self.linksTableView reloadData];
}

#pragma mark RCLinksModelDelegate implementation

- (void)linksModel:(RCLinksModel *)model didLinksUpdate:(NSArray<RSLink *> *)links onTop:(BOOL)onTop {
    if (onTop) {
        [self.linksTableView.pullToRefreshView stopAnimating];
    } else {
        [self.linksTableView.infiniteScrollingView stopAnimating];
    }
    [self hideLoading];
    
    NSIndexPath *startAtPosition = onTop ? [NSIndexPath indexPathForRow:0 inSection:0] : [self.linksTableView.indexPathsForVisibleRows.lastObject copy];
    self.links = [links copy];
    [self.linksTableView reloadData];
    if (self.links.count) {
        [self.linksTableView scrollToRowAtIndexPath:startAtPosition
                                   atScrollPosition:UITableViewScrollPositionBottom
                                           animated:NO];
    }
}

- (void)linksModel:(RCLinksModel *)model didFailedToLoadWithError:(NSError *)error {
    [self.linksTableView.pullToRefreshView stopAnimating];
    [self.linksTableView.infiniteScrollingView stopAnimating];
}

#pragma mark UITextFieldDelegate implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.searchTextField) {
        [self search];
        return YES;
    }
    return NO;
}

#pragma mark UITableViewDataSource implementation

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCLinksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"linksCell"];
    [cell updateWithDataObject:[self.links objectAtIndex:[indexPath row]]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.links.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end
