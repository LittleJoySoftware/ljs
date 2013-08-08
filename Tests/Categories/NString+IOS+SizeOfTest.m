#import "LjsTestCase.h"
#import "NString+IOS+SizeOf.h"
#import "LjsLabelAttributes.h"


static NSString *const kLoremIpsum_20_words = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc lacinia, tortor ut varius convallis, eros leo fermentum lectus, et fermentum.";

static NSString *const kLoremImpsum_20_bytes = @"Donec sit amet libero vitae sed.";



@interface NString_IOS_SizeOfTest : LjsTestCase {}
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


- (void) test_size_of_basic {
  NSString *str = @"foobar";
  UIFont *font = [UIFont systemFontOfSize:18];
  CGSize catSize = [str sizeOfStringWithFont:font];
  CGSize attrSize = ljs_textsize(str, font);
  //      size of str = {52, 21.473999}
  // attr size of str = {53, 22}
  GHTestLog(@"category size of str = %@", NSStringFromCGSize(catSize));
  GHTestLog(@"    attr size of str = %@", NSStringFromCGSize(attrSize));
  
}

- (void) test_size_of_constrained {
  CGSize constraint = CGSizeMake(80, 44);
  NSString *str = kLoremImpsum_20_bytes;
  UIFont *font = [UIFont systemFontOfSize:18];
  CGSize catSize = [str sizeOfStringWithFont:font constrainedToSize:constraint];
  CGSize attrSize = ljs_multiline_textsize(str, font, constraint, NSLineBreakByWordWrapping);
  
  CGFloat discovered = 0;
  CGSize scaledSize = [str sizeWithFont:font
                      minFontSize:4
                   actualFontSize:&discovered
                         forWidth:constraint.width
                    lineBreakMode:NSLineBreakByWordWrapping];

  
  GHTestLog(@"category size of str = %@", NSStringFromCGSize(catSize));
  GHTestLog(@"    attr size of str = %@", NSStringFromCGSize(attrSize));
  GHTestLog(@"  scaled size of str = %@ ==> '%.2f'", NSStringFromCGSize(scaledSize), discovered);
  
}


- (void) test_size_of_foo {
  CGSize constraint = CGSizeMake(80, 44);
  NSString *str = kLoremImpsum_20_bytes;
  UIFont *font = [UIFont systemFontOfSize:18];
  CGFloat discovered0 = 0;
  CGSize catSize = [str sizeOfStringWithFont:font minFontSize:4
                              actualFontSize:&discovered0
                                    forWidth:80
                               lineBreakMode:NSLineBreakByWordWrapping];
  
  //CGSize attrSize = ljs_multiline_textsize(str, font, constraint, NSLineBreakByWordWrapping);
  
  CGFloat discovered1 = 0;
  CGSize scaledSize = [str sizeWithFont:font
                            minFontSize:4
                         actualFontSize:&discovered1
                               forWidth:constraint.width
                          lineBreakMode:NSLineBreakByWordWrapping];
  
  
  GHTestLog(@"category size of str = %@ ==> '%.2f'", NSStringFromCGSize(catSize), discovered0);
  GHTestLog(@"  scaled size of str = %@ ==> '%.2f'", NSStringFromCGSize(scaledSize), discovered1);
  
}




@end
