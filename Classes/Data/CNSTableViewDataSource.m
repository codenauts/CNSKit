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

@synthesize cellTags;

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
 	return [[[self.cellTags objectAtIndex:section] valueForKey:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [self titleForSectionAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self createCellWithStyle:UITableViewCellStyleDefault tableView:tableView identifier:@"DefaultDataSourceCell"];
}

#pragma mark -
#pragma mark Helper Methods

- (void)addSectionWithoutTitleCellTags:(NSInteger *)tags length:(NSInteger)length {
  [self addSectionWithTitle:nil sectionTag:-1 cellTags:tags length:length];
}

- (void)addSectionWithTitle:(NSString *)title sectionTag:(NSInteger)sectionTag cellTags:(NSInteger *)tags length:(NSInteger)length {
  NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSInteger index = 0; index < length; index++) {
		[array addObject:[NSNumber numberWithInt:tags[index]]];
	}

	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
	[dictionary setValue:array forKey:@"rows"];
	[dictionary setValue:title forKey:@"title"];
  if (sectionTag > -1) {
    [dictionary setValue:[NSNumber numberWithInt:sectionTag] forKey:@"sectionTag"];
  }
  [self.cellTags addObject:dictionary];
}

- (void)addSectionWithTitle:(NSString *)title sectionTag:(NSInteger)sectionTag uniqueCellTag:(NSInteger)uniqueCellTag count:(NSInteger)count {
  NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSInteger index = 0; index < count; index++) {
		[array addObject:[NSNumber numberWithInt:uniqueCellTag]];
	}
  
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
	[dictionary setValue:array forKey:@"rows"];
	[dictionary setValue:title forKey:@"title"];
  if (sectionTag > -1) {
    [dictionary setValue:[NSNumber numberWithInt:sectionTag] forKey:@"sectionTag"];
  }
  [self.cellTags addObject:dictionary];
}

- (UITableViewCell *)createCellWithStyle:(UITableViewCellStyle)style tableView:(UITableView *)tableView identifier:(NSString *)identifier {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
  }
  return cell;
}

- (void)createCellTags {
	self.cellTags = [[NSMutableArray alloc] initWithCapacity:0];
}

- (UITableViewCell *)loadCellFromNibWithIdentifier:(NSString *)identifier tableView:(UITableView *)tableView {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		NSArray *loadedNib = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
		cell = [loadedNib objectAtIndex:0];
	}
	return cell;
}

- (NSInteger)tagForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[[[self.cellTags objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex:indexPath.row] intValue];
}

- (NSString *)titleForTag:(NSInteger)tag localizationPrefix:(NSString *)prefix {
  return NSLocalizedString(([NSString stringWithFormat:@"%@CellText%d", prefix, tag]), nil); 
}

- (NSString *)titleForSectionAtIndex:(NSInteger)index {
  if ((self.cellTags) && ([self.cellTags count] > index)) {
    return [[self.cellTags objectAtIndex:index] valueForKey:@"title"];
  }
  else {
    return nil;
  }
}

- (NSInteger)tagForSectionAtIndex:(NSInteger)index {
  if ([self.cellTags count] > index) {
    return [[[self.cellTags objectAtIndex:index] valueForKey:@"sectionTag"] intValue];
  }
  else {
    return -1;
  }
}

- (NSInteger)indexForSectionTag:(NSInteger)tag {
  NSInteger index = 0;
  for (NSDictionary *section in self.cellTags) {
    if ([[section valueForKey:@"sectionTag"] intValue] == tag) {
      return index;
    }
    index++;
  }
  return -1;
}

- (NSInteger)rowForTag:(NSInteger)tag inSection:(NSInteger)section {
  NSNumber *tagNumber = [NSNumber numberWithInt:tag];
  return [[[self.cellTags objectAtIndex:section] valueForKey:@"rows"] indexOfObject:tagNumber];
}

#pragma mark -
#pragma mark Memory Management Methods

- (void)dealloc {
	self.cellTags = nil;
}

@end
