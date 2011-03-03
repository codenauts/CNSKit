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

#import "CNSUser.h"
#import "CNSPasswordStore.h"

@implementation CNSUser

// Constructor
- (id)init {
  if (self = [super init]) {
    email = nil;
		passwordStore = [[CNSPasswordStore alloc] init];
  }
  return self;
}

// Returns as singleton instance of User
+ (CNSUser *)sharedUser {
  static CNSUser *sharedUser = nil;
  if (!sharedUser) {
    sharedUser = [[CNSUser alloc] init];
  }
  return sharedUser;
}

// Return email
- (NSString *)email {
  if (email == nil) {
    email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
  }
  return email;
}

// Set email
- (void)setEmail:(NSString *)newEmail {
  [newEmail retain];
  [email release];
  email = newEmail;
  
  [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"UserEmail"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

// Return password from store
- (NSString *)getStoredPassword {
	return [passwordStore getPasswordForUsername:self.email];
}

// Set password at store
- (void)setStoredPassword:(NSString *)newPassword {
	[passwordStore setPassword:newPassword forUsername:self.email];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

// Set password store
- (void)setPasswordStore:(CNSPasswordStore *)aPasswordStore {
	[aPasswordStore retain];
	[passwordStore retain];
	passwordStore = aPasswordStore;
}

// Dealloc
- (void) dealloc {
  self.email = nil;
	[passwordStore release];
	[super dealloc];
}

@end
