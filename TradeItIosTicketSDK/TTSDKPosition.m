//
//  TTSDKPosition.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/14/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKPosition.h"
#import "TradeItMarketDataService.h"
#import "TTSDKTicketController.h"
#import "TradeItQuoteResult.h"

@interface TTSDKPosition() {
}

@end

@implementation TTSDKPosition

-(void) getPositionData:(void (^)(TradeItResult *)) completionBlock {
    TTSDKTicketController * globalController = [TTSDKTicketController globalController];

    if (globalController.currentSession) {
        TTSDKTicketSession * session = globalController.currentSession;
        TradeItMarketDataService * marketService = [[TradeItMarketDataService alloc] initWithSession: session];
        TradeItQuoteRequest * request = [[TradeItQuoteRequest alloc] initWithSymbol: self.symbol];

        [marketService getQuote:request withCompletionBlock:^(TradeItResult * res) {
            if ([res isKindOfClass:TradeItQuoteResult.class]) {
                TradeItQuoteResult * result = (TradeItQuoteResult *)res;

                self.symbol = result.symbol;
                self.lastPrice = result.lastPrice;
                self.change = result.change;
                self.changePct = result.pctChange;

                completionBlock(res);
            } else {
                completionBlock(nil);
            }
        }];
    }
}

-(BOOL) isDataPopulated {
    BOOL populated = YES;

    if (!self.lastPrice) {
        populated = NO;
    }

    if (!self.quantity && ![self.quantity isEqualToNumber:@0]) {
        populated = NO;
    }

    return populated;
}

@end