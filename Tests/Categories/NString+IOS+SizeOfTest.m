#import "LjsTestCase.h"
#import "NString+IOS+SizeOf.h"
#import "LjsLabelAttributes.h"


static NSString *const kLoremIpsum_20_words = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc lacinia, tortor ut varius convallis, eros leo fermentum lectus, et fermentum.";

static NSString *const kLoremImpsum_20_bytes = @"Donec sit amet libero vitae sed.";



@interface NString_IOS_SizeOfTest : LjsTestCase {}

- (UIFont *) fontForTests;
@end



@implementation NString_IOS_SizeOfTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void) setUpClass {
  [super setUpClass];
  // Run at start of all tests in the class
}

- (void) tearDownClass {
  // Run at end of all tests in the class
  [super tearDownClass];
}

- (void) setUp {
  [super setUp];
  // Run before each test method
}

- (void) tearDown {
  // Run after each test method
  [super tearDown];
}

- (UIFont *) fontForTests {
  static UIFont *shared_font = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // "HelveticaNeue" is an option...
    static NSString *const fontName = @"HelveticaNeue";
    shared_font = [UIFont fontWithName:fontName size:18];
  });
  return shared_font;
}

- (void) test_size_of_basic {
  NSString *str = @"foobar";
  UIFont *font = [self fontForTests];
  CGSize catSize = [str sizeOfStringWithFont:font];
  
  GHAssertEqualsWithAccuracy((CGFloat)catSize.width, (CGFloat)52, 1.0, @"width should be equal");
  GHAssertEqualsWithAccuracy((CGFloat)catSize.height, (CGFloat)22, 2.0, @"height should be equal");

}

- (void) test_size_of_constrained {
  CGSize constraint = CGSizeMake(80, 44);
  NSString *str = kLoremImpsum_20_bytes;
  UIFont *font = [self fontForTests];
  CGSize catSize = [str sizeOfStringWithFont:font constrainedToSize:constraint];
  
  
  GHAssertEqualsWithAccuracy((CGFloat)catSize.width, (CGFloat)80.0, 3.0, @"width should be equal");
  GHAssertEqualsWithAccuracy((CGFloat)catSize.height, (CGFloat)42, 4.0, @"height should be equal");

}

- (void) test_size_of_constraint_discovered {
  CGSize constraint = CGSizeMake(80, 44);
  NSString *str = kLoremImpsum_20_bytes;
  UIFont *font = [self fontForTests];
  CGFloat discovered = 0.0;
  CGSize catSize = [str sizeOfStringWithFont:font
                                 minFontSize:5
                              actualFontSize:&discovered
                                    forWidth:constraint.width
                               lineBreakMode:NSLineBreakByTruncatingTail];
  
  
  // i don't like the look of this one
  GHAssertEqualsWithAccuracy((CGFloat)catSize.width, (CGFloat)70.0, 10.0, @"width should be equal");
  GHAssertEqualsWithAccuracy((CGFloat)catSize.height, (CGFloat)21.5, 2.0, @"height should be equal");
  GHAssertEqualsWithAccuracy((CGFloat)discovered, (CGFloat)5.5, 0.5, @"font size should be equal");
  
}

@end
