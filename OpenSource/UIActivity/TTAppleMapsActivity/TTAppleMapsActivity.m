//
//  TTAppleMapsActivity.h
//
//  Created by Tobias Tiemerding on 12/25/12.
//  Copyright (c) 2012-2013 Tobias Tiemerding
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TTAppleMapsActivity.h"

@implementation TTAppleMapsActivity

- (NSString *)activityType
{
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle
{
	return @"Open in Apple Maps";//NSLocalizedString(@"Open in Apple Maps", @"Open in Apple Maps");
}

- (UIImage *)_activityImage
{
	return [UIImage imageNamed:@"uiactivity_applemap"];
}
//- (UIImage *)activityImage
//{
//	return [UIImage imageNamed:@"TTAppleMapsActivity"];
//}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	if(self.latitude && self.longitude)
        return YES;
	
	return NO;
}

- (void)performActivity
{
   // Construct url string
    NSMutableString *appleMapsURLString = [NSMutableString stringWithString:@"http://maps.apple.com/maps?"];
	NSMutableArray *components = [NSMutableArray array];
    
    if (self.building) {
        [components addObject:[NSString stringWithFormat:@"%@=%@, Waterloo, Canada", @"q", self.building]];
    }
    
	if (self.latitude && self.longitude)
		[components addObject:[NSString stringWithFormat:@"%@=%@,%@", @"ll", [self.latitude stringValue], [self.longitude stringValue]]];
    
	if (self.zoomLevel > 0)
		[components addObject:[NSString stringWithFormat:@"%@=%@", @"z", [NSString stringWithFormat:@"%lu", (unsigned long)self.zoomLevel]]];
	
	if (self.mapMode)
		[components addObject:[NSString stringWithFormat:@"%@=%@", @"t", self.mapMode]];
	
	NSString *componentsString = [components componentsJoinedByString:@"&"];
    if (componentsString.length > 0)
        [appleMapsURLString appendFormat:@"%@", componentsString];
	
	NSURL *appleMapsURL = [NSURL URLWithString:[appleMapsURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL:appleMapsURL]) {
        NSLog(@"apple map: %@", appleMapsURL);
        [[UIApplication sharedApplication] openURL:appleMapsURL];
        [self activityDidFinish:YES];
    }
    
    [self activityDidFinish:NO];
}

@end

