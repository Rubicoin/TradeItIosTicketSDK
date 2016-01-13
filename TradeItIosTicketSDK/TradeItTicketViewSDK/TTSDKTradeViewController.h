 //
//  TTSDKTradeViewController.h
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 7/29/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//
#import "TTSDKBaseTradeViewController.h"
#import "TTSDKOrderTypeSelectionViewController.h"
#import "TTSDKTradeItTicket.h"


@interface TTSDKTradeViewController : TTSDKBaseTradeViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property TradeItResult * lastResult;
@property TradeItStockOrEtfTradeReviewResult * reviewResult;
@property TradeItStockOrEtfTradeSuccessResult * successResult;

@end