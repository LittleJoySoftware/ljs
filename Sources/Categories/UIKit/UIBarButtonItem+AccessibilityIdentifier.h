#import <Foundation/Foundation.h>

/**
 UIBarButtonItem on UIBarButtonItem_AccessibilityIdentifier category.
 
 NOT WORKING
 
 bar button items get converted to UINavigationBar items which are a private
 class in iOS SDK.  they are subclasses of UIButton, so they _do_ have 
 accessibilityIdentifiers.
 
 AFAICT - the bar button item is destroyed when the navigation button is
 created.
 */
@interface UIBarButtonItem (UIBarButtonItem_AccessibilityIdentifier) 

@property (nonatomic, copy) NSString *accessibilityIdentifier;

@end
