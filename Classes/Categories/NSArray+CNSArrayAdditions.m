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

#import "NSArray+CNSArrayAdditions.h"

@implementation NSArray (CNSArrayAdditions)

// Thanks to Mike Ash and his blog Friday Q&A
// http://www.mikeash.com/pyblog/friday-qa-2009-08-14-practical-blocks.html

- (NSArray *)map:(id (^)(id obj))block {
  NSMutableArray *new = [NSMutableArray array];
  for(id obj in self) {
    id newObj = block(obj);
    [new addObject: newObj ? newObj : [NSNull null]];
  }
  return new;
}

// Thanks to Mike Ash and his blog Friday Q&A
// http://www.mikeash.com/pyblog/friday-qa-2009-08-14-practical-blocks.html

- (NSArray *)select: (BOOL (^)(id obj))block {
  NSMutableArray *new = [NSMutableArray array];
  for(id obj in self)
    if(block(obj))
      [new addObject: obj];
  return new;
}

@end

