//
//  MIRGeneratePDF.h
//  houseCat
//
//  Created by kenl on 12/11/13.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBorderInset 20.0
#define kBorderWidth 1.0
#define kMarginInset 10.0
// TODO: currently 8.5x11, this will need to be a variable that can be localized (e.g. A4).
#define kPageWidth 612
#define kPageHeight 792

//Line drawing
#define kLineWidth              1.0


@interface MIRGeneratePDF : NSObject
{
	CGSize pageSize;
}

@property (strong, nonatomic) NSArray* itemArray;
@property (strong, nonatomic) NSString* headerText;

- (NSString*)generatePDF: (NSArray*)items headerText:(NSString*)resultsString;

@end
