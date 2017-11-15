//
//  CDViOSScanner.h
//  Dealr, Inc.
//

#import <Foundation/Foundation.h>

#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>


@class UIViewController;


@interface CDViOSScanner : CDVPlugin {
    
    UIView* parentView;
    
    NSString *_callback;
    
    NSArray *_barCodeResults;
    
    NSArray *_barCodeTypes;
    
}

- (void) cordovaGetBC:(CDVInvokedUrlCommand *)command;

@end
