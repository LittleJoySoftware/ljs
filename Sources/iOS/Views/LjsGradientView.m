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

#import "LjsGradientView.h"
#import "Lumberjack.h"
#import "NSArray+LjsAdditions.h"
#import "LjsReasons.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int __unused ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int __unused ddLogLevel = LOG_LEVEL_WARN;
#endif



@interface LjsGradientView ()

@property (nonatomic, strong) UIColor *highColor;
@property (nonatomic, strong) UIColor *middleColor;
@property (nonatomic, strong) UIColor *lowColor;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;


@end

@implementation LjsGradientView


#pragma mark Memory Management


- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self != nil) {
    [self awakeFromNib];
    self.highColor = nil;
    self.lowColor = nil;
    self.middleColor = nil;
  }
  return self;
}

- (id) initWithFrame:(CGRect)frame
              colors:(NSArray *) aHighMiddleLowColors {
  LjsReasons *reasons = [LjsReasons new];
  [reasons ifCollection:aHighMiddleLowColors doesNotHaveCount:3 addReasonWithVarName:@"array of colors"];
  if ([reasons hasReasons]) {
    DDLogError([reasons explanation:@"could not create view" consequence:@"nil"]);
    return nil;
  }

  self = [self initWithFrame:frame];
  if (self != nil) {
    self.highColor = [aHighMiddleLowColors nth:0];
    self.middleColor = [aHighMiddleLowColors nth:1];
    self.lowColor = [aHighMiddleLowColors nth:2];
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
  
  [myLayer setCornerRadius:6.0f];
  [myLayer setMasksToBounds:YES];
  [myLayer setBorderWidth:0.0];
}

- (void)drawRect:(CGRect)rect {
  UIColor *hc = self.highColor;
  UIColor *mc = self.middleColor;
  UIColor *lc = self.lowColor;
  
  if (hc && mc && lc) {
    NSArray *colors = @[(id)[hc CGColor], (id)[mc CGColor], (id)[lc CGColor]];
    [self.gradientLayer setColors:colors];
  }
  [super drawRect:rect];
}


@end
