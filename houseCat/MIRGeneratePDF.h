//
//  MIRGeneratePDF.h
//  houseCat
//
//  Created by kenl on 12/11/13.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBorderInset            20.0
#define kBorderWidth            1.0
#define kMarginInset            10.0


@interface MIRGeneratePDF : NSObject
{
	CGSize pageSize;
}

- (NSString*) generatePDF: (NSArray*) objects;

@end
