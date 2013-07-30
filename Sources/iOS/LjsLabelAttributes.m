// Copyright 2012 Little Joy Software. All rights reserved.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Neither the name of the Little Joy Software nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY LITTLE JOY SOFTWARE ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LITTLE JOY SOFTWARE BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LjsLabelAttributes.h"
#import "Lumberjack.h"
#import "LjsCategories.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation LjsLabelAttributes

- (id) initWithString:(NSString *) aString
                 font:(UIFont *) aFont
           labelWidth:(CGFloat) aLabelWidth {
  self = [super init];
  if (self != nil) {
    DDLogDebug(@"string = %@", aString);
    self.linebreakMode = NSLineBreakByWordWrapping;
    self.font = aFont;
    CGSize oneLineSize = ljs_textsize(aString, aFont);
    DDLogDebug(@"one line size = %.2f", oneLineSize.height);
    self.lineHeight = oneLineSize.height;
    
    CGSize max = CGSizeMake(aLabelWidth, CGFLOAT_MAX);
    CGSize labelSize = ljs_multiline_textsize(aString, aFont, max, NSLineBreakByWordWrapping);
    DDLogDebug(@"label size = %@", NSStringFromCGSize(labelSize));
    self.labelHeight = labelSize.height;
    self.numberOfLines = (NSUInteger) self.labelHeight / self.lineHeight;
    self.string = aString;
    self.labelWidth = aLabelWidth;
  }
  return self;
}

- (id) initWithString:(NSString *) aString
                 font:(UIFont *) aFont
           labelWidth:(CGFloat) aLabelWidth
        linebreakMode:(NSLineBreakMode)aLinebreakMode
          minFontSize:(CGFloat)aMinFontSize {
  self = [super init];
  if (self != nil) {
    
    CGFloat discovered = 0;
    
    //CGSize max = CGSizeMake(aLabelWidth, CGFLOAT_MAX);
    //CGSize size = ljs_multiline_textsize(aString, aFont, max, aLinebreakMode);

    CGSize size = [aString sizeWithFont:aFont
                            minFontSize:aMinFontSize
                         actualFontSize:&discovered
                               forWidth:aLabelWidth
                          lineBreakMode:aLinebreakMode];
  
    

    /**** LOOKS LIKE A BUG ******
    self.lineHeight = size.height;
     ****************************/
    
    self.font = [UIFont fontWithName:aFont.fontName size:discovered];
    CGSize oneLine = [aString sizeWithFont:self.font];
    self.lineHeight = oneLine.height;
    
    self.linebreakMode = aLinebreakMode;
    self.labelHeight = size.height;
    self.labelWidth = size.width;
    self.numberOfLines = (NSUInteger) self.labelHeight / self.lineHeight;
    self.string = aString;
    self.labelWidth = aLabelWidth;

  }
  return self;
}

- (void) applyAttributesToLabel:(UILabel *) aLabel
      shouldApplyWidthAndHeight:(BOOL) aShouldApplyWidthAndHeight {
  aLabel.font = self.font;
  aLabel.text = self.string;
  aLabel.lineBreakMode = self.linebreakMode;
  aLabel.numberOfLines = self.numberOfLines;
  if (aShouldApplyWidthAndHeight == YES) {
    [aLabel setHeightWithHeight:self.labelHeight];
    [aLabel setWidthWithWidth:self.labelWidth];
  }
}


- (UILabel *) labelWithFrame:(CGRect) aFrame
                   alignment:(NSTextAlignment) aAlignemnt
                    textColor:(UIColor *) aTextColor
              highlightColor:(UIColor *) aHighlightColor
             backgroundColor:(UIColor *) aBackgroundColor {
  return [UILabel labelWithFrame:aFrame
                            text:self.string
                            font:self.font
                       alignment:aAlignemnt
                       textColor:aTextColor
                highlightedColor:aHighlightColor
                 backgroundColor:aBackgroundColor
                   lineBreakMode:self.linebreakMode
                   numberOfLines:self.numberOfLines];
 
}



- (NSString *) description {
  return [NSString stringWithFormat:@"#<LjsLabelAttributes line: %.2f height: %.2f lines: %d width: %.2f>",
          self.lineHeight, self.labelHeight, self.numberOfLines, self.labelWidth];
}

//text label = {{10, 8}, {153, 22}}
//details label = {{10, 30}, {282, 18}}
+ (CGSize) sizeOfDetailsCellTitleLabel {
  return CGSizeMake(153, 22);
}

+ (CGSize) sizeOfDetailsCellDetailsLabel {
  return CGSizeMake(282, 18);
}

+ (CGFloat) heightOfDetailsCellTitleLabel {
  return [LjsLabelAttributes sizeOfDetailsCellTitleLabel].height;
}

+ (CGFloat) widthOfDetailsCellTitleLabel {
  return [LjsLabelAttributes sizeOfDetailsCellTitleLabel].width;
}

+ (CGFloat) heightOfDetailsCellDetailsLabel {
  return [LjsLabelAttributes sizeOfDetailsCellDetailsLabel].width;
}

+ (CGFloat) widthOfDetailsCellDetailsLabel {
  return [LjsLabelAttributes sizeOfDetailsCellDetailsLabel].width;
}

+ (CGRect) frameForDetailsCellTitleLabelWithX:(CGFloat) aX {
  CGSize size = [LjsLabelAttributes sizeOfDetailsCellTitleLabel];
  CGFloat w = MIN(size.width + aX, 316);
  CGFloat h = size.height;
  return CGRectMake(aX, 8, w, h);
}

+ (CGRect) frameForDetailsCellDetailsLabelWithX:(CGFloat) aX {
  CGSize size = [LjsLabelAttributes sizeOfDetailsCellDetailsLabel];
  CGFloat w = MIN(size.width + aX, 316);
  CGFloat h = size.height;
  return CGRectMake(aX, 30, w, h);
}

@end










