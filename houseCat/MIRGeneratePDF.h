//
//  MIRGeneratePDF.h
//  houseCat
//
//  Created by kenl on 12/11/13.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBorderInset 20.0f
#define kBorderWidth 1.0f
#define kMarginInset 10.0f
#define kBottomMargin 40.0f
// TODO: currently 8.5x11, this will need to be a variable that can be localized (e.g. A4).
#define kPageWidth 612
#define kPageHeight 792

//Line drawing
#define kLineWidth              1.0


@interface MIRGeneratePDF : NSObject
{
	// this isn't an object type so it can't be a property:
	CGSize pageSize;
}

@property (strong, nonatomic) NSArray* itemArray;
@property (strong, nonatomic) NSString* headerText;

- (NSString*)generatePDF: (NSArray*)items headerText:(NSString*)resultsString;

@end
