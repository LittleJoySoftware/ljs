#import "NString+IOS+SizeOf.h"
#import "Lumberjack.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

NS_INLINE BOOL ljs_layout_manager_available() {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
  return YES;
#else
  return NO;
#endif
}


@implementation NSString (NString_IOS_SizeOf)


- (CGSize) sizeOfStringWithFont:(UIFont *) aFont {
  return [self sizeOfStringWithFont:aFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (CGSize) sizeOfStringWithFont:(UIFont *) aFont constrainedToSize:(CGSize) aSize {
	return [self sizeOfStringWithFont:aFont constrainedToSize:aSize lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize) sizeOfStringWithFont:(UIFont *) aFont constrainedToSize:(CGSize) aSize lineBreakMode:(NSLineBreakMode) aLineBreakMode {
  if (ljs_layout_manager_available() == NO) {
    return [self sizeWithFont:aFont constrainedToSize:aSize lineBreakMode:aLineBreakMode];
  }
 
  NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
  NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:aSize];
  NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];
  [textStorage addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, self.length)];
  [textContainer setLineBreakMode:aLineBreakMode];
  [textContainer setLineFragmentPadding:0.0];
  (void)[layoutManager glyphRangeForTextContainer:textContainer];
  return [layoutManager usedRectForTextContainer:textContainer].size;
  
}

- (CGSize) sizeOfStringWithFont:(UIFont *) aFont
                    minFontSize:(CGFloat) aMinSize
                 actualFontSize:(CGFloat *) aActualFontSize
                       forWidth:(CGFloat) aWidth
                  lineBreakMode:(NSLineBreakMode) aLineBreakMode {
  if (ljs_layout_manager_available() == NO) {
    return [self sizeWithFont:aFont
                  minFontSize:aMinSize
               actualFontSize:aActualFontSize
                     forWidth:aWidth
                lineBreakMode:aLineBreakMode];
  }
  
  CGFloat currentFontSize = aFont.pointSize;
  CGSize targetSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  CGSize currentSize = CGSizeZero;
  
  CGFloat lineHeight = CGFLOAT_MAX;
  
  do {
    UIFont *currentFont = [aFont fontWithSize:currentFontSize];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:targetSize];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:currentFont range:NSMakeRange(0, self.length)];
    [textContainer setLineBreakMode:aLineBreakMode];
    [textContainer setLineFragmentPadding:0.0];
    (void)[layoutManager glyphRangeForTextContainer:textContainer];

    currentSize = [layoutManager usedRectForTextContainer:textContainer].size;
    if (lineHeight == CGFLOAT_MAX) {  lineHeight = currentSize.height; }

    currentFontSize -= 1.0f;
    if (currentFontSize < aMinSize) {  break; }
    
    DDLogDebug(@"size = %@", NSStringFromCGSize(currentSize));
  } while (currentSize.width > aWidth);
  *aActualFontSize = currentFontSize;
  return CGSizeMake(currentSize.width, lineHeight);
}




@end
