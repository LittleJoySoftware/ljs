// Copyright 2011 Little Joy Software. All rights reserved.
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

#import "LjsButton.h"
#import "Lumberjack.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int __unused ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int __unused ddLogLevel = LOG_LEVEL_WARN;
#endif


@interface LjsButton ()

@property (nonatomic, strong) UIImage *isOnImage;
@property (nonatomic, strong) UIImage *isOffImage;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIColor *highColor;
@property (nonatomic, strong) UIColor *lowColor;

- (void) setImageForState;

@end


@implementation LjsButton

@synthesize highColor = _highColor;
@synthesize lowColor = _lowColor;

- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self != nil) {
    [self awakeFromNib];
  }
  return self;
}

- (void)awakeFromNib {
  // Initialize the gradient layer
  CAGradientLayer *aGradientLayer = [[CAGradientLayer alloc] init];
  self.gradientLayer = aGradientLayer;
  
  CGRect myBounds = self.bounds;
  CGSize mySize = myBounds.size;
  
  // Set its bounds to be the same of its parent
  [aGradientLayer setBounds:myBounds];
  // Center the layer inside the parent layer
  [aGradientLayer setPosition:CGPointMake(mySize.width/2,
                                          mySize.height/2)];
  
  // Insert the layer at position zero to make sure the 
  // text of the button is not obscured
  CALayer *myLayer = self.layer;
  [myLayer insertSublayer:aGradientLayer atIndex:0];
  
  // Set the layer's corner radius
  [myLayer setCornerRadius:8.0f];
  // Turn on masking
  [myLayer setMasksToBounds:YES];
  // Display a border around the button 
  [myLayer setBorderWidth:2.0];
  
  
  self.showsTouchWhenHighlighted = YES;
  self.isOn = NO;
  self.isOnImage = nil;
  self.isOffImage = nil;
}

- (void)drawRect:(CGRect)rect {
  UIColor *hc = self.highColor;
  UIColor *lc = self.lowColor;
  if (hc && lc) {
    NSArray *colors = @[(id)[hc CGColor], (id)[lc CGColor]];
    [self.gradientLayer setColors:colors];
  }
  [super drawRect:rect];
}

- (void) setHighColor:(UIColor *) aColor {
  // Set the high color and repaint
  _highColor = aColor;
  [[self layer] setNeedsDisplay];
}

- (void) setLowColor:(UIColor * ) aColor {
  // Set the low color and repaint
  _lowColor = aColor;
  [[self layer] setNeedsDisplay];
}

- (void) setHighColor:(UIColor *) aHighColor
             lowColor:(UIColor *) aKowColor {
  _highColor = aHighColor;
  _lowColor = aKowColor;
  [[self layer] setNeedsDisplay];
}

- (void) setBorderColor:(UIColor *) aColor
            borderWidth:(CGFloat) aWidth
           cornerRadius:(CGFloat) aRadius {
  self.layer.borderColor = aColor.CGColor;
  self.layer.borderWidth = aWidth;
  self.layer.cornerRadius = aRadius;
  [[self layer] setNeedsDisplay];
}

- (void) resetBounds {
  self.gradientLayer.bounds = self.bounds;
  CGFloat width = self.bounds.size.width/2;
  CGFloat height = self.bounds.size.height/2;
  [self.gradientLayer setPosition:CGPointMake(width, height)];
}


- (void) setNormalAndHiglightedTitleWithFont:(UIFont *) aFont
                                       color:(UIColor *) aColor
                                       title:(NSString *) aTitle {
  self.titleLabel.font = aFont;
  [self setTitle:aTitle forState:UIControlStateNormal];
  [self setTitle:aTitle forState:UIControlStateHighlighted];
  [self setTitleColor:aColor forState:UIControlStateNormal];
  [self setTitleColor:aColor forState:UIControlStateHighlighted];
}

- (void) setIsOnImage:(UIImage *)aIsOnImage 
           isOffImage:(UIImage *)aIsOffImage {
  self.isOnImage = aIsOnImage;
  self.isOffImage = aIsOffImage;
}

- (void) setImageForState {
  if (self.isOnImage == nil || self.isOffImage == nil) {
    return;
  }
  UIImage *image;
  if (self.isOn == YES) {
    image = self.isOnImage;
  } else {
    image = self.isOffImage;
  }
  [self setImage:image forState:UIControlStateNormal];
}

- (void) setState:(BOOL) aIsOn {
  self.isOn = aIsOn;
  [self setImageForState];
}

- (void) toggle {
  self.isOn = !self.isOn;
  [self setImageForState];
}

@end
