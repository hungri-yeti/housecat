//
//  MIRGeneratePDF.m
//  houseCat
//
//  Created by kenl on 12/11/13.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRGeneratePDF.h"
#import "Items.h"
#import "Images.h"


@interface MIRGeneratePDF (Private)
	- (void) generatePdfWithFilePath: (NSString *)thefilePath itemsArray:(NSArray*)items;
	- (void)drawPageNumber:(NSInteger)pageNum;
	- (void) drawLine;
	- (void) drawHeader;
	- (void) drawHeaderWithText:(NSString*)textToDraw;
	- (void) drawItemName:(Items*)item;
	- (void) drawPurchaseDate:(Items*)item;
	- (void) drawPurchaseCost:(Items*)item;
	- (void) drawSerialNumber:(Items*)item;
	- (void) drawImages:(Items*)item;
//	- (void) drawBorder;
//	- (void) drawText;
//	- (void) drawImage;
@end


@implementation MIRGeneratePDF


#pragma mark - PDF generation
- (NSString*)generatePDF: (NSArray*)items headerText:(NSString*)resultsString
{
	self.itemArray = items;
	self.headerText = resultsString;
	
	pageSize = CGSizeMake(kPageWidth, kPageHeight);
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	// TODO: does this need to be localized?
	[formatter setDateFormat:@"yyyyMMddHmmss"];
	NSDate* date = [[NSDate alloc] init];
	NSString* dateStr = [formatter stringFromDate:date];
	
	NSString* fileName = [[NSString alloc] initWithFormat:@"houseCat_%@.pdf", dateStr];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString* pdfFilePath = [NSString stringWithFormat:@"%@/pdf/%@", documentsDirectory, fileName];
	
	[self generatePdfWithFilePath:pdfFilePath itemsArray:items];
	return pdfFilePath;	
}


- (void) generatePdfWithFilePath: (NSString *)thefilePath itemsArray:(NSArray*)items
{
	UIGraphicsBeginPDFContextToFile(thefilePath, CGRectZero, nil);
	
	NSInteger currentPage = 0;
	BOOL done = NO;
	do
	{
		for (Items* item in items)
		{
			// Mark the beginning of a new page.
			UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
			
			// Draw a page number at the bottom of each page.
			currentPage++;
			[self drawPageNumber:currentPage];
			
			//Draw a border for each page.
			//[self drawBorder];
			
			//Draw text for our header.
			[self drawHeaderWithText:self.headerText];
			
			//Draw a line below the header.
			[self drawLine];
			
			// fill in the fields:
			[self drawItemName:item];
			[self drawPurchaseDate:item];
			[self drawPurchaseCost:item];
			[self drawSerialNumber:item];
			// draw the first two images (or fewer if not found)
			[self drawImages:item];
		}
		done = YES;
	}
	while (!done);
	
	// Close the PDF context and write the contents out.
	UIGraphicsEndPDFContext();
}



#pragma mark - Private Methods


// ----------------------------------------------------------------------------------------------------------------
//  draw the first two images to the PDF. There may be 0, 1, 2, or more images. Since the image NSSet isn't
// ordered, this isn't the most efficient function. However, the quantity of images for each item will
//	probably be low so it shouldn't be a real-world issue.
// ----------------------------------------------------------------------------------------------------------------
- (void) drawImages:(Items*)item
{
	// two images placed side-by-side, portrait orientation, margin on the outside, gutter between.
	// Based on pageSize = CGSizeMake(612, 792); // 8.5 x 11
	
	NSEnumerator *e = [item.images objectEnumerator];
	Images* image;
	while (image = [e nextObject])
	{
		if( 0 == [image.sortOrder intValue])
		{
			// left img:
			UIImage* img1 = [UIImage imageWithContentsOfFile:image.imagePath];
			[img1 drawInRect:CGRectMake( kBorderInset + kMarginInset, 150, 
												 (pageSize.width/2)-(3*kBorderInset), 
												 (pageSize.height/2)-(2*kBorderInset))
			 ];
		}
		if( 1 == [image.sortOrder intValue])
		{
			// right img:
			UIImage* img2 = [UIImage imageWithContentsOfFile:image.imagePath];
			[img2 drawInRect:CGRectMake( kBorderInset + kMarginInset + (pageSize.width/2), 
												 150, 
												 (pageSize.width/2)-(3*kBorderInset), 
												 (pageSize.height/2)-(2*kBorderInset) )
			 ];
		}
	}
}


- (void) drawSerialNumber:(Items*)item
{
	NSString* textToDraw = [[NSString alloc] initWithFormat:
									NSLocalizedString(@"Serial Number: %@", @"Loss Report serial number"), 
									item.serialNumber];
	
	UIFont *font = [UIFont systemFontOfSize:14.0];
	CGSize constraint = CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, 
											 pageSize.height - 2*kBorderInset - 2*kMarginInset);
	NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
	[atts setObject:font forKey:NSFontAttributeName];
	CGRect contentRect = [textToDraw boundingRectWithSize: constraint
																options: NSStringDrawingUsesLineFragmentOrigin
															attributes: atts
																context: nil];
	CGSize stringSize = contentRect.size;
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 100.0, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);

	NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
	[style setLineBreakMode:NSLineBreakByWordWrapping];
	[style setAlignment:NSTextAlignmentLeft];
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
	[attr setObject:font forKey:NSFontAttributeName];
	[textToDraw drawInRect:renderingRect withAttributes:attr];
}


- (void) drawPurchaseCost:(Items*)item
{	
	NSString *numberStr = [NSNumberFormatter localizedStringFromNumber:item.cost
																			 numberStyle:NSNumberFormatterCurrencyStyle];

	NSString* textToDraw = [[NSString alloc] initWithFormat:
									NSLocalizedString(@"Cost: %@", @"Loss Report cost"), 
									numberStr];
	
	UIFont *font = [UIFont systemFontOfSize:14.0];
	CGSize constraint = CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, 
											 pageSize.height - 2*kBorderInset - 2*kMarginInset);
	NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
	[atts setObject:font forKey:NSFontAttributeName];
	CGRect contentRect = [textToDraw boundingRectWithSize: constraint
																 options: NSStringDrawingUsesLineFragmentOrigin
															 attributes: atts
																 context: nil];
	CGSize stringSize = contentRect.size;
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset + 200, kBorderInset + kMarginInset + 75.0, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
	[style setLineBreakMode:NSLineBreakByWordWrapping];
	[style setAlignment:NSTextAlignmentLeft];
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
	[attr setObject:font forKey:NSFontAttributeName];
	[textToDraw drawInRect:renderingRect withAttributes:attr];
}


- (void) drawPurchaseDate:(Items*)item
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString* dateText = [dateFormatter stringFromDate:item.purchaseDate];
	NSString* textToDraw = [[NSString alloc] initWithFormat:
									NSLocalizedString(@"Purchased: %@", @"Loss Report purchased date"), 
									dateText ];

	UIFont *font = [UIFont systemFontOfSize:14.0];
	CGSize constraint = CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, 
											 pageSize.height - 2*kBorderInset - 2*kMarginInset);
	NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
	[atts setObject:font forKey:NSFontAttributeName];
	CGRect contentRect = [textToDraw boundingRectWithSize: constraint
																 options: NSStringDrawingUsesLineFragmentOrigin
															 attributes: atts
																 context: nil];
	CGSize stringSize = contentRect.size;
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 75.0, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
	[style setLineBreakMode:NSLineBreakByWordWrapping];
	[style setAlignment:NSTextAlignmentLeft];
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
	[attr setObject:font forKey:NSFontAttributeName];
	[textToDraw drawInRect:renderingRect withAttributes:attr];

}


- (void) drawItemName:(Items*)item
{
	// If I ever want to fiddle with the text color:
	//CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
	
	NSString* textToDraw = item.name;
	
	UIFont *font = [UIFont systemFontOfSize:14.0];
	
	CGSize constraint = CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, 
											 pageSize.height - 2*kBorderInset - 2*kMarginInset);
	NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
	[atts setObject:font forKey:NSFontAttributeName];
	CGRect contentRect = [textToDraw boundingRectWithSize: constraint
																 options: NSStringDrawingUsesLineFragmentOrigin
															 attributes: atts
																 context: nil];
	CGSize stringSize = contentRect.size;
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 50.0, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
	[style setLineBreakMode:NSLineBreakByWordWrapping];
	[style setAlignment:NSTextAlignmentLeft];
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
	[attr setObject:font forKey:NSFontAttributeName];
	[textToDraw drawInRect:renderingRect withAttributes:attr];

}


//- (void) drawBorder
//{
//	CGContextRef    currentContext = UIGraphicsGetCurrentContext();
//	UIColor *borderColor = [UIColor brownColor];
//	
//	CGRect rectFrame = CGRectMake(kBorderInset, kBorderInset, pageSize.width-kBorderInset*2, pageSize.height-kBorderInset*2);
//	
//	CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
//	CGContextSetLineWidth(currentContext, kBorderWidth);
//	CGContextStrokeRect(currentContext, rectFrame);
//}


- (void)drawPageNumber:(NSInteger)pageNumber
{
	NSString* textToDraw = [NSString stringWithFormat:
											NSLocalizedString(@"Page %d", @"Loss Report page number"),
											pageNumber];
	UIFont* font = [UIFont systemFontOfSize:12];
	
	CGSize constraint = CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, 
											 pageSize.height - 2*kBorderInset - 2*kMarginInset);
	NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
	[atts setObject:font forKey:NSFontAttributeName];
	CGRect contentRect = [textToDraw boundingRectWithSize: constraint
																 options: NSStringDrawingUsesLineFragmentOrigin
															 attributes: atts
																 context: nil];
	CGSize stringSize = contentRect.size;
	
	CGRect renderingRect = CGRectMake(kBorderInset,
														 pageSize.height - kBottomMargin,
														 pageSize.width - 2*kBorderInset,
														 stringSize.height);
	
	NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
	[style setLineBreakMode:NSLineBreakByWordWrapping];
	[style setAlignment:NSTextAlignmentLeft];
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
	[attr setObject:font forKey:NSFontAttributeName];
	[textToDraw drawInRect:renderingRect withAttributes:attr];
}


- (void) drawHeaderWithText: (NSString*)textToDraw
{
	UIFont *font = [UIFont systemFontOfSize:18.0];
	
	CGSize constraint = CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, 
											 pageSize.height - 2*kBorderInset - 2*kMarginInset);
	NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
	[atts setObject:font forKey:NSFontAttributeName];
	CGRect contentRect = [textToDraw boundingRectWithSize: constraint
																 options: NSStringDrawingUsesLineFragmentOrigin
															 attributes: atts
																 context: nil];
	CGSize stringSize = contentRect.size;

	
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
		
	NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
	[style setLineBreakMode:NSLineBreakByWordWrapping];
	[style setAlignment:NSTextAlignmentLeft];
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
	[attr setObject:font forKey:NSFontAttributeName];
	[textToDraw drawInRect:renderingRect withAttributes:attr];

}


- (void) drawHeader
{
	NSString *textToDraw = NSLocalizedString(@"houseCat", @"Loss Report header app name");
	
	UIFont *font = [UIFont systemFontOfSize:24.0];
	
	CGSize constraint = CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, 
											 pageSize.height - 2*kBorderInset - 2*kMarginInset);
	NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
	[atts setObject:font forKey:NSFontAttributeName];
	CGRect contentRect = [textToDraw boundingRectWithSize: constraint
																 options: NSStringDrawingUsesLineFragmentOrigin
															 attributes: atts
																 context: nil];
	CGSize stringSize = contentRect.size;

	
	
	
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
	[style setLineBreakMode:NSLineBreakByWordWrapping];
	[style setAlignment:NSTextAlignmentLeft];
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
	[attr setObject:font forKey:NSFontAttributeName];
	[textToDraw drawInRect:renderingRect withAttributes:attr];


}


- (void) drawLine
{
	CGContextRef    currentContext = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(currentContext, kLineWidth);
	
	CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset, kMarginInset + kBorderInset + 40.0);
	CGPoint endPoint = CGPointMake(pageSize.width - 2*kMarginInset -2*kBorderInset, kMarginInset + kBorderInset + 40.0);
	
	CGContextBeginPath(currentContext);
	CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
	CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
	
	CGContextClosePath(currentContext);    
	CGContextDrawPath(currentContext, kCGPathFillStroke);
}


@end
