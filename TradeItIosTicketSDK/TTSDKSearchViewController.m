//
//  TTSDKSearchViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/15/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKSearchViewController.h"
#import "TradeItSymbolLookupRequest.h"
#import "TradeItSymbolLookupCompany.h"
#import "TradeItSymbolLookupResult.h"
#import "TradeItMarketDataService.h"
#import "TTSDKTicketController.h"

@interface TTSDKSearchViewController() {
    TTSDKTicketController * globalController;
    TradeItMarketDataService * marketService;
}

@property NSArray * symbolSearchResults;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property TradeItSymbolLookupRequest * searchRequest;

@end

@implementation TTSDKSearchViewController

- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView setAnimationsEnabled:NO];
    [[UIDevice currentDevice] setValue:@1 forKey:@"orientation"];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView setAnimationsEnabled:YES];
}

-(void) viewDidLoad {
    self.symbolSearchResults = [[NSArray alloc] init];

    globalController = [TTSDKTicketController globalController];

    marketService = [[TradeItMarketDataService alloc] initWithSession: globalController.currentSession];

    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];

    self.searchRequest = [[TradeItSymbolLookupRequest alloc] init];

    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.symbolSearchResults.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Company" forIndexPath:indexPath];

    TradeItSymbolLookupCompany * company = (TradeItSymbolLookupCompany *)[self.symbolSearchResults objectAtIndex:indexPath.row];

    cell.textLabel.text = company.symbol;
    cell.detailTextLabel.text = company.name;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TradeItSymbolLookupCompany * selectedCompany = (TradeItSymbolLookupCompany *)[self.symbolSearchResults objectAtIndex:indexPath.row];

    globalController.position = nil;
    globalController.position = [[TTSDKPosition alloc] init];
    globalController.position.symbol = selectedCompany.symbol;
    globalController.position.companyName = selectedCompany.name;

    if (globalController.currentSession.previewRequest) {
        globalController.currentSession.previewRequest.orderSymbol = selectedCompany.symbol;
    }

    [globalController.position getPositionData:^(TradeItResult * result) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar.text isEqualToString:@""]) {
        [self setResultsToLoading];
        TradeItSymbolLookupRequest * lookupRequest = [[TradeItSymbolLookupRequest alloc] initWithQuery:searchBar.text];

        [marketService symbolLookup:lookupRequest withCompletionBlock:^(TradeItResult * res) {
            [self setResultsToLoaded];
            if ([res isKindOfClass:TradeItSymbolLookupResult.class]) {
                TradeItSymbolLookupResult * result = (TradeItSymbolLookupResult *)res;
                [self resultsDidReturn:result.results];
            }
        }];
    } else {
        [self resultsDidReturn:[[NSArray alloc] init]];
    }
}

-(void)resultsDidReturn:(NSArray *)results {
    self.symbolSearchResults = results;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)setResultsToLoading {
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.frame = CGRectMake(loadingIndicator.bounds.size.width, loadingIndicator.bounds.size.height, 20, 20);
    
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    
    [loadingView addSubview:loadingIndicator];
    
    self.tableView.backgroundView = loadingView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)setResultsToLoaded {
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}



@end