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

#import "CNSPasswordStore.h"
#import "CNSKeychainUtils.h"
#import "CNSLogHelper.h"

@implementation CNSPasswordStore

// Get password from Keychain for service and username
- (NSString *)getPasswordForUsername:(NSString *)username {
	NSError *error;
	NSString *password = [CNSKeychainUtils getPasswordForUsername:username serviceName:[[[NSBundle mainBundle] infoDictionary] valueForKey:kCFBundleIdentifierKey] error:&error];
	if ([error code] != 0) {
		CNSLog(@"Error occured while retrieving password: %@", [error userInfo]);
	}
	return password;
}

// Set password from Keychain for service and username
- (void)setPassword:(NSString *)password forUsername:(NSString *)username {
	NSError *error;
	if (![CNSKeychainUtils storeUsername:username andPassword:password serviceName:[[[NSBundle mainBundle] infoDictionary] valueForKey:kCFBundleIdentifierKey] updateExisting:true error:&error]) {
		CNSLog(@"Error occured while storing password: %@", [error userInfo]);
	}
}

@end
