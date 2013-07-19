#import <UIKit/UIKit.h>

/**
 UIView on UILabel_LjsAdditions category.
 */
@interface UILabel (UILabel_LjsAdditions)

+ (UILabel *) labelWithFrame:(CGRect) frame
                        text:(NSString *) aText
                        font:(UIFont *) aFont
                   alignment:(NSTextAlignment) aAlignment
                   textColor:(UIColor *) aTextColor
            highlightedColor:(UIColor *) aHighlightedColor
             backgroundColor:(UIColor *) aBackgroundColor
               lineBreakMode:(NSLineBreakMode) aLineBreakMode
               numberOfLines:(NSUInteger) aNumberOfLines;

+ (UILabel *) labelWithText:(NSString *) aText
                       font:(UIFont *) aFont
                  alignment:(NSTextAlignment) aAlignment
                  textColor:(UIColor *) aTextColor
           highlightedColor:(UIColor *) aHighlightedColor
            backgroundColor:(UIColor *) aBackgroundColor
              lineBreakMode:(NSLineBreakMode) aLineBreakMode
              numberOfLines:(NSUInteger) aNumberOfLines
                    originX:(CGFloat) originX
   centeredToRectWithHeight:(CGFloat) aHeight
                      width:(CGFloat) aWidth;


@end
