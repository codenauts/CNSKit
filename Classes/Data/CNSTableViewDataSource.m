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

#import "CNSTableViewDataSource.h"

@implementation CNSTableViewDataSource

#pragma mark -
#pragma mark Initialization

- (id)init {
  if ((self = [super init])) {
    [self createCellTags];
  }
  return self;
}

#pragma mark -
#pragma mark UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.cellTags count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 	return [[self.cellTags objectAtIndex:section] count];
}

#pragma mark -
#pragma mark Helper Methods

- (void)addTagsToCellTags:(NSInteger *)tags length:(NSInteger)length {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSInteger index = 0; index < length; index++) {
		[array addObject:[NSNumber numberWithInt:tags[index]]];
	}
	
	[self.cellTags addObject:array];
	[array release];
}

- (UITableViewCell *)createCellWithStyle:(UITableViewCellStyle)style tableView:(UITableView *)tableView identifier:(NSString *)identifier {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
  }
  return cell;
}

- (void)createCellTags {
	self.cellTags = [[NSMutableArray alloc] initWithCapacity:0];
}

- (NSInteger)tagForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[[self.cellTags objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] intValue];
}

- (NSString *)titleForTag:(NSInteger)tag localizationPrefix:(NSString *)prefix {
  return NSLocalizedString(([NSString stringWithFormat:@"%@CellText%d", prefix, tag]), nil); 
}

#pragma mark -
#pragma mark Memory Management Methods

- (void)dealloc {
	self.cellTags = nil;
	[super dealloc];
}

@end
