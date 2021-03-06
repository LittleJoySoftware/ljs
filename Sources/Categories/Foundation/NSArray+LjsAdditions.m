#import "Lumberjack.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int __unused ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int __unused ddLogLevel = LOG_LEVEL_WARN;
#endif


@implementation NSArray (NSArray_LjsAdditions)

- (BOOL) not_empty {
  return [self count] != 0;
}

- (BOOL) has_objects {
  return [self count] != 0;
}


#pragma mark - Lisp

- (id) nth:(NSUInteger) index {
  NSUInteger count = [self count];
  if (index >= count) {
    return nil;
  } else {
    return self[index];
  }
}

- (id) s_nth:(NSInteger) aIndex {
  return (aIndex < 0) ? nil : [self nth:(NSUInteger)aIndex];
}

- (id) first {
  return [self nth:0];
}

- (id) second {
  return [self nth:1];
}

- (id) last {
  return [self lastObject];
}

- (NSArray *) rest {
  NSUInteger count = [self count];
  if (count < 2) {
    return nil;
  } else {
    return [self subarrayWithRange:NSMakeRange(1, count - 1)];
  }
}

- (NSArray *) reverse {
  return [[self reverseObjectEnumerator] allObjects];
}

- (NSArray *) append:(id) object {
  if (object == nil) {
    return [NSArray arrayWithArray:self];
  }
  
  if ([object isKindOfClass:[NSArray class]]) {
    NSArray *other = (NSArray *) object;
    return [self arrayByAddingObjectsFromArray:other];
  } else {
    return [self arrayByAddingObject:object];
  }
}

#pragma mark - Sorting

- (NSArray *) sortedArrayUsingDescriptor:(NSSortDescriptor *) aSorter {
  NSArray *array = @[aSorter];
  return [self sortedArrayUsingDescriptors:array];
}

#pragma mark - Mapping

- (NSArray *) mapcar:(id (^)(id obj)) aBlock {
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
  for (id obj in self) {
    [result addObject:aBlock(obj)];
  }
  return [NSArray arrayWithArray:result];
}

- (NSArray *) mapc:(void (^)(id obj, NSUInteger idx, BOOL *stop)) aBlock  {
  return [self mapc:aBlock concurrent:NO];
}

- (NSArray *) mapc:(void (^)(id obj, NSUInteger idx, BOOL *stop)) aBlock concurrent:(BOOL) aConcurrent {
  if (aConcurrent == YES) {
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent
                           usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                             aBlock(obj, idx, stop);
                           }];
  } else {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      aBlock(obj, idx, stop);
    }];
  }
  return self;
}

#pragma mark - Filtering

- (NSArray *) filteredArrayUsingPassingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
  NSIndexSet * filteredIndexes = [self indexesOfObjectsPassingTest:predicate];
  return [self objectsAtIndexes:filteredIndexes];
}

- (NSArray *) arrayByRemovingObjectsInArray:(NSArray *) aArray {
  if ([aArray not_empty] == NO) {
    return [NSArray arrayWithArray:self];
  }
  NSPredicate *predicate;
  predicate = [NSPredicate predicateWithBlock:^(id obj, NSDictionary *bindings) {
    //DDLogDebug(@"evaluating: %@", obj);
    BOOL result = [aArray containsObject:obj] == NO;
    return result;
  }];
  return [self filteredArrayUsingPredicate:predicate];
}

#pragma mark - Strings <==> Enumerations

- (NSString *) stringWithEnum:(NSUInteger) enumVal {
  NSString *result = nil;
  if (enumVal < [self count]) {
    result = self[enumVal];
  }
  return result;
}

- (NSUInteger) enumFromString:(NSString *) strVal default:(NSUInteger) def {
  NSUInteger n = [self indexOfObject:strVal];
  if(n == NSNotFound) n = def;
  return n;
}

- (NSUInteger) enumFromString:(NSString *) strVal {
  return [self enumFromString:strVal default:NSNotFound];
}

#pragma mark - validation

- (BOOL) containsObjects:(id) aObjects {
  if ([self has_objects] == NO) { return NO; }
  
  if (aObjects == nil) { return NO; }
  
  if ([aObjects conformsToProtocol:@protocol(NSFastEnumeration)] == NO) {  return NO; }
  
  for (id obj in aObjects) { if ([self containsObject:obj] == NO) { return NO; } }
  
  return YES;
}

- (BOOL) containsObjects:(id) aObjects allowsOthers:(BOOL) aAllowsOthers {
  BOOL hasAll = [self containsObjects:aObjects];
  if (hasAll == NO) { return NO; }
  
  if (aAllowsOthers == YES) { return hasAll; }
  
  if ([aObjects respondsToSelector:@selector(count)] == NO) { return NO; }
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-selector-match"
  NSUInteger objectCount = [aObjects count];
#pragma clang diagnostic pop
  return objectCount == [self count];
}


@end
