#import "Lumberjack.h"
#import "NSString+IOSSizeOf.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int __unused ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int __unused ddLogLevel = LOG_LEVEL_WARN;
#endif


@implementation UILabel (UILabel_LjsAdditions)

+ (UILabel *) labelWithFrame:(CGRect) frame
                        text:(NSString *) aText
                        font:(UIFont *) aFont
                   alignment:(NSTextAlignment) aAlignment
                   textColor:(UIColor *) aTextColor
            highlightedColor:(UIColor *) aHighlightedColor
             backgroundColor:(UIColor *) aBackgroundColor
               lineBreakMode:(NSLineBreakMode) aLineBreakMode
               numberOfLines:(NSUInteger) aNumberOfLines {
  UILabel *label = [[UILabel alloc] initWithFrame:frame];
  label.text = aText;
  label.font = aFont;
  label.textAlignment = aAlignment;
  label.textColor = aTextColor;
  label.highlightedTextColor = aHighlightedColor;
  label.backgroundColor = aBackgroundColor == nil ? [UIColor clearColor] : aBackgroundColor;
  label.lineBreakMode = aLineBreakMode;
  label.numberOfLines = (NSInteger)aNumberOfLines;
  return label;
}


+ (UILabel *) labelWithText:(NSString *) aText
                       font:(UIFont *) aFont
                  alignment:(NSTextAlignment) aAlignment
                  textColor:(UIColor *) aTextColor
           highlightedColor:(UIColor *) aHighlightedColor
            backgroundColor:(UIColor *) aBackgroundColor
              lineBreakMode:(NSLineBreakMode) aLineBreakMode
              numberOfLines:(NSUInteger) aNumberOfLines
                    originX:(CGFloat) aOriginX
   centeredToRectWithHeight:(CGFloat) aHeight
                      width:(CGFloat) aWidth {
  CGSize size = [aText sizeOfStringWithFont:aFont];
  CGFloat y = (aHeight/2) - (size.height / 2);
  CGRect frame = CGRectMake(aOriginX, y, aWidth, size.height);
  return [UILabel labelWithFrame:frame
                            text:aText
                            font:aFont
                       alignment:aAlignment
                       textColor:aTextColor
                highlightedColor:aHighlightedColor
                 backgroundColor:aBackgroundColor
                   lineBreakMode:aLineBreakMode
                   numberOfLines:aNumberOfLines];
}


@end
