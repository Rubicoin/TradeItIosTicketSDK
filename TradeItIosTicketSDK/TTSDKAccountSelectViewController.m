//
//  TTSDKPortfolioViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 12/16/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import "TTSDKAccountSelectViewController.h"
#import "TTSDKAccountSelectTableViewCell.h"
#import "TTSDKTradeViewController.h"
#import "TTSDKBrokerSelectViewController.h"
#import "TTSDKPortfolioService.h"
#import "TTSDKPortfolioAccount.h"

@interface TTSDKAccountSelectViewController () {
    TTSDKPortfolioService * portfolioService;
    NSArray * accountResults;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *editBrokersButton;

@end

@implementation TTSDKAccountSelectViewController


-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView setAnimationsEnabled:NO];
    [[UIDevice currentDevice] setValue:@1 forKey:@"orientation"];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView setAnimationsEnabled:YES];
}

-(void) viewDidLoad {
    [super viewDidLoad];

    [self.editBrokersButton setTitleColor:self.styles.activeColor forState:UIControlStateNormal];

    accountResults = [[NSArray alloc] init];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.tableView.backgroundColor = self.styles.pageBackgroundColor;
    portfolioService = [[TTSDKPortfolioService alloc] initWithAccounts: self.ticket.linkedAccounts];

    if (self.ticket.currentSession.isAuthenticated) {
        [self loadAccounts];
    } else {
        [self.ticket.currentSession authenticateFromViewController:self withCompletionBlock:^(TradeItResult * res) {
            [self performSelectorOnMainThread:@selector(loadAccounts) withObject:nil waitUntilDone:NO];
        }];
    }

    [self.tableView reloadData];
}

-(void) loadAccounts {
    [portfolioService getSummaryForAccounts:^(void) {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

-(void) checkAuth {
    if (self.ticket.currentSession.isAuthenticated) {
        [self loadAccounts];
    }
}

-(IBAction) editBrokersPressed:(id)sender {
    [self performSegueWithIdentifier:@"AccountSelectToAccountLink" sender:self];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return portfolioService.accounts.count;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isModal) {
        TTSDKPortfolioAccount * account = [portfolioService.accounts objectAtIndex: indexPath.row];
        NSDictionary * selectedAccount = [account accountData];

        if (![account.userId isEqualToString:self.ticket.currentSession.login.userId]) {
            [self.ticket selectCurrentSession:[self.ticket retrieveSessionByAccount: selectedAccount] andAccount:selectedAccount];
        } else {
            [self.ticket selectCurrentAccount: selectedAccount];
        }
        
        TTSDKTradeViewController * tradeVC = (TTSDKTradeViewController *)[self.navigationController.viewControllers objectAtIndex:0];
        [self.navigationController popToViewController:tradeVC animated: YES];
    } else {
        [self.tableView reloadData];
    }
}

- (IBAction)closePressed:(id)sender {
    [self.ticket returnToParentApp];
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    UIButton * addAccount = [[UIButton alloc] initWithFrame:CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y, footerView.frame.size.width, 30.0f)];
    addAccount.titleEdgeInsets = UIEdgeInsetsMake(0, 43.0, 0, 0);
    [addAccount setTitle:@"Add Account" forState:UIControlStateNormal];
    [addAccount setTitleColor:self.styles.activeColor forState:UIControlStateNormal];
    [addAccount.titleLabel setFont: [UIFont systemFontOfSize:15.0f]];
    addAccount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [addAccount setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer * addAccountTap = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(addAccountPressed:)];
    [addAccount addGestureRecognizer:addAccountTap];
    
    footerView.backgroundColor = self.styles.pageBackgroundColor;
    
    [footerView addSubview:addAccount];
    
    return footerView;
}

-(IBAction) addAccountPressed:(id)sender {
    [self performSegueWithIdentifier:@"AccountSelectToBrokerSelect" sender:self];
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * accountIdentifier = @"AccountSelectIdentifier";
    TTSDKAccountSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountIdentifier];
    if (cell == nil) {
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"TradeItIosTicketSDK" ofType:@"bundle"];
        NSBundle * resourceBundle = [NSBundle bundleWithPath:bundlePath];

        [tableView registerNib:[UINib nibWithNibName:@"TTSDKAccountSelectCell" bundle:resourceBundle] forCellReuseIdentifier:accountIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:accountIdentifier];

        cell.backgroundColor = self.styles.pageBackgroundColor;
    }

    TTSDKPortfolioAccount * account = [portfolioService.accounts objectAtIndex: indexPath.row];
    [cell configureCellWithAccount: account];

    return cell;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AccountSelectToBrokerSelect"]) {
        UINavigationController * dest = (UINavigationController *)[segue destinationViewController];

        UIStoryboard * ticket = [UIStoryboard storyboardWithName:@"Ticket" bundle: [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"TradeItIosTicketSDK" ofType:@"bundle"]]];

        TTSDKBrokerSelectViewController * brokerSelectController = [ticket instantiateViewControllerWithIdentifier:@"BROKER_SELECT"];
        brokerSelectController.isModal = YES;

        [dest pushViewController:brokerSelectController animated:NO];
    }
}


@end
