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

#import "CNSConnectionHelper.h"
#import "CNSLogHelper.h"
#import "NSString+CNSStringAdditions.h"

@interface CNSConnectionHelper ()
  
@property (retain, readwrite) NSError *lastError;

- (void)releaseConnection;

@end

@implementation CNSConnectionHelper

@synthesize data;
@synthesize identifier;
@synthesize statusCode;
@synthesize lastError;

#pragma mark -
#pragma mark Initialization

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate selector:(SEL)aSelector identifier:(NSString *)anIdentifier {
  if ((self = [super init])) {
    delegate = aDelegate;
    selector = aSelector;
    
    data = [[NSMutableData alloc] init];
    identifier = anIdentifier;
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];  
  }
  return self;
}

- (id)initWithURL:(NSURL *)url delegate:(id)aDelegate selector:(SEL)aSelector {
	return [self initWithURL:url identifier:@"" delegate:aDelegate selector:aSelector];
}

- (id)initWithURL:(NSURL *)url identifier:(NSString *)anIdentifier delegate:(id)aDelegate selector:(SEL)aSelector {
  if ((self = [super init])) {
    delegate = aDelegate;
    selector = aSelector;
		identifier = [anIdentifier copy];
    
    data = [[NSMutableData alloc] init];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; 
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];  
  }
  return self;
}

#pragma mark - Helper 

- (void)cancel {
  [connection cancel];
}

#pragma mark -
#pragma mark Memory Management Methods

- (void)releaseConnection {
  delegate = nil;  
  connection = nil;
}

- (void)dealloc {
  data = nil;
	
  [self releaseConnection];  
}

#pragma mark -
#pragma mark Connection Delegate Methods

- (BOOL)connection:(NSURLConnection *)aConnection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space {
  return [[space authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
  }
}  

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
	[data setLength:0];
  if ([response respondsToSelector:@selector(statusCode)]) {
    statusCode = [((NSHTTPURLResponse *)response) statusCode];
  }  
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)receivedData {
	[data appendData:receivedData];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([delegate respondsToSelector:@selector(connectionDidFail:)]) {
    [delegate performSelector:@selector(connectionDidFail:) withObject:self];
  }

  [self releaseConnection];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
  self.lastError = error;
  if ([delegate respondsToSelector:@selector(connectionDidFail:)]) {
    [delegate performSelector:@selector(connectionDidFail:) withObject:self];
  }
  
  [self releaseConnection];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if ([delegate respondsToSelector:selector]) {
    [delegate performSelectorInBackground:selector withObject:self];
  }
  
  [self releaseConnection];
}

@end
