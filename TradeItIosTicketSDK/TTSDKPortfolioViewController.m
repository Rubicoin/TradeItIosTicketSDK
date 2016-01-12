//
//  TTSDKPortfolioViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/5/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKPortfolioViewController.h"
#import "TTSDKUtils.h"
#import "TTSDKPortfolioHoldingTableViewCell.h"
#import "TTSDKPortfolioAccountsTableViewCell.h"

@interface TTSDKPortfolioViewController ()

@property (weak, nonatomic) IBOutlet UIButton *editBrokersButton;
@property (weak, nonatomic) IBOutlet UIButton *doneEditingBrokersButton;
@property TTSDKUtils * utils;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property NSArray * testAccounts;
@property NSArray * testHoldings;
@property (weak, nonatomic) IBOutlet UITableView *accountsTable;
@property (weak, nonatomic) IBOutlet UITableView *holdingsTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *holdingsHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountsHeightConstraint;

@property NSInteger selectedIndex;

@end

@implementation TTSDKPortfolioViewController

- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) viewDidLoad {
    self.scrollView.scrollEnabled = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.bounces = YES;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [self.scrollView.subviews firstObject].frame.size.height);
    [self.scrollView needsUpdateConstraints];

    self.testAccounts = [NSArray arrayWithObjects:
                         [NSDictionary dictionaryWithObjectsAndKeys:@"Fidelity", @"acctName", @"+18,940 (6.24%)", @"totalValue", @"$40,416", @"buyingPower", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"Fidelity", @"acctName", @"+2,214 (3.16%)", @"totalValue", @"$2,105", @"buyingPower", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"Etrade", @"acctName", @"-129 (2.08%)", @"totalValue", @"$305", @"buyingPower", nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:@"Robinhood", @"acctName", @"+679 (8.02%)", @"totalValue", @"$1,536", @"buyingPower", nil],
                         nil];

    self.testHoldings = [NSArray arrayWithObjects:
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          @"AAPL", @"symbol",
                          @"$4,988.04", @"cost",
                          @"+1,346 (1.23%)", @"change",
                          @"223.43", @"bid",
                          @"224.34", @"ask",
                          @"$7,023.87", @"totalValue",
                          @"1.36%", @"dailyReturn",
                          @"-4.32%", @"totalReturn",
                          nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          @"GE", @"symbol",
                          @"$628.63", @"cost",
                          @"+282 (3.1%)", @"change",
                          @"52.43", @"bid",
                          @"51.21", @"ask",
                          @"$735.07", @"totalValue",
                          @"-8.1%", @"dailyReturn",
                          @"4.29%", @"totalReturn",
                          nil],
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          @"BET", @"symbol",
                          @"$45.54", @"cost",
                          @"-1,823 (0.1%)", @"change",
                          @"119.03", @"bid",
                          @"120.74", @"ask",
                          @"$5,988.07", @"totalValue",
                          @"3.52%", @"dailyReturn",
                          @"-1.89%", @"totalReturn",
                          nil],
                         nil];

    self.selectedIndex = -1;

    [self.holdingsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    tableView.alwaysBounceVertical = NO;
    tableView.scrollEnabled = NO;
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isHoldingsTable:tableView]) {
        return self.testHoldings.count;
    } else {
        return self.testAccounts.count;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndex == indexPath.row) {
        // User taps expanded row
        self.selectedIndex = -1;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (self.selectedIndex != -1) {
        // User taps different row
        NSIndexPath * prevPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        self.selectedIndex = indexPath.row;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        // User taps new row with none expanded
        self.selectedIndex = indexPath.row;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

    [self resizeUIComponents];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isHoldingsTable:tableView]) {
        if (self.selectedIndex == indexPath.row) {
            return 140.0f;
        } else {
            return 60.0f;
        }
    } else {
        return 44.0f;
    }
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [self resizeUIComponents];
    }
}

-(void) resizeUIComponents {
    self.holdingsHeightConstraint.constant = self.holdingsTable.contentSize.height;
    self.accountsHeightConstraint.constant = self.accountsTable.contentSize.height;

    CGRect contentRect = CGRectZero;

    for (UIView * view in [[self.scrollView.subviews firstObject] subviews]) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }

    [self.scrollView setContentSize: contentRect.size];
    [self.scrollView setNeedsLayout];
    [self.scrollView setNeedsUpdateConstraints];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellIdentifier;
    NSString * nibIdentifier;

    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"TradeItIosTicketSDK" ofType:@"bundle"];
    NSBundle * resourceBundle = [NSBundle bundleWithPath:bundlePath];

    if ([self isHoldingsTable:tableView]) {
        cellIdentifier = @"PortfolioHoldingIdentifier";
        nibIdentifier = @"TTSDKPortfolioHoldingCell";
        TTSDKPortfolioHoldingTableViewCell * cell = (TTSDKPortfolioHoldingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:nibIdentifier bundle:resourceBundle] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }

        [cell configureCellWithData:[self.testHoldings objectAtIndex:indexPath.row]];

        if (indexPath.row == 0) {
            [cell hideSeparator];
        } else {
            [cell showSeparator];
        }

        cell.clipsToBounds = YES;
        return cell;
    } else {
        cellIdentifier = @"PortfolioAccountIdentifier";
        nibIdentifier = @"TTSDKPortfolioAccountCell";
        TTSDKPortfolioAccountsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:nibIdentifier bundle:resourceBundle] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }

        [cell configureCellWithData:[self.testAccounts objectAtIndex:indexPath.row]];

        return cell;
    }
}

-(BOOL) isHoldingsTable:(UITableView *)tableView {
    // the accounts table tag is 0 and the holdings table tag is 1
    return tableView.tag == 1;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
