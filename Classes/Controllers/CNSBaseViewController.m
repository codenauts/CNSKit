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

#import "CNSBaseViewController.h"

@interface CNSBaseViewController (Private)

  - (void)simulateMemoryWarning;

@end

@implementation CNSBaseViewController

#pragma mark -
#pragma mark UIViewController Methods

- (void)viewDidUnload {
  [super viewDidUnload];
  [self releaseView];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  #if TARGET_IPHONE_SIMULATOR
    #ifdef DEBUG
      // If we are running in the simulator and it's the DEBUG target
      // then simulate a memory warning. Note that the DEBUG flag isn't
      // defined by default. To define it add this Preprocessor Macro for
      // the Debug target: DEBUG=1
      [self simulateMemoryWarning];
    #endif
  #endif
}

- (void)didReceiveMemoryWarning {
  [self releaseView];
  [super didReceiveMemoryWarning];
}

#pragma mark - Debugging Helper

// Idea taken from iDev Recipes
// Blog-Post: http://idevrecipes.com/2011/05/04/debugging-magic-auto-simulate-memory-warnings/
// Gist: https://gist.github.com/956403

- (void)simulateMemoryWarning {
  #if TARGET_IPHONE_SIMULATOR
    #ifdef DEBUG
  SEL memoryWarningSel = @selector(_performMemoryWarning);
  if ([[UIApplication sharedApplication] respondsToSelector:memoryWarningSel]) {
    [[UIApplication sharedApplication] performSelector:memoryWarningSel];
  } else {
    NSLog(@"%@",@"Whoops UIApplication no loger responds to -_performMemoryWarning");
  }
    #endif
  #endif
}


#pragma mark -
#pragma mark Public Helper Methods

+ (CNS_APPLICATION_DELEGATE_CLASS *)applicationDelegate {
  return (CNS_APPLICATION_DELEGATE_CLASS *)[[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma mark Memory Management Methods

- (void)releaseView {
}

- (void)dealloc {
  [self releaseView];
  [super dealloc];
}

@end
