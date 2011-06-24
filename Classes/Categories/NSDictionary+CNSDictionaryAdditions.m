// Copyright 2011 Codenauts UG. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSDictionary+CNSDictionaryAdditions.h"


@implementation NSDictionary (CNSDictionaryAdditions)

// Thanks for inspiration to Mike Ash and his blog Friday Q&A
// http://www.mikeash.com/pyblog/friday-qa-2009-08-14-practical-blocks.html

- (NSDictionary *)mapValues:(id (^)(id value))block {
  NSMutableDictionary *new = [NSMutableDictionary dictionary];
  [self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    id newObj = block(value);
    [new setValue:newObj ? newObj : [NSNull null] forKey:key];
  }];
  return new;
}

- (NSArray *)keysAndValuesJoinedByString:(NSString *)string {
  NSMutableArray *paramsArray = [[NSMutableArray alloc] init];
  [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [paramsArray addObject:[NSString stringWithFormat:@"%@%@%@",key,string,obj]];
  }];
  return paramsArray;
}

@end
