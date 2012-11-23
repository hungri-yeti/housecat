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
	[formatter setDateFormat:@"yyyyMMddHmmss"];
	NSDate* date = [[NSDate alloc] init];
	NSString* dateStr = [formatter stringFromDate:date];
	
	NSString* fileName = [[NSString alloc] initWithFormat:@"houseCat_%@.pdf", dateStr];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pdfFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
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
	NSString* textToDraw = [[NSString alloc] initWithFormat:@"Serial Number: %@", item.serialNumber];
	
	UIFont *font = [UIFont systemFontOfSize:14.0];
	CGSize stringSize = [textToDraw sizeWithFont:font
										constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) 
											 lineBreakMode:NSLineBreakByWordWrapping];
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 100.0, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	[textToDraw drawInRect:renderingRect 
					  withFont:font
				lineBreakMode:NSLineBreakByWordWrapping
					 alignment:NSTextAlignmentLeft];
}


- (void) drawPurchaseCost:(Items*)item
{	
	NSString *numberStr = [NSNumberFormatter localizedStringFromNumber:item.cost
																			 numberStyle:NSNumberFormatterCurrencyStyle];

	NSString* textToDraw = [[NSString alloc] initWithFormat:@"Cost: %@", numberStr];
	
	UIFont *font = [UIFont systemFontOfSize:14.0];
	CGSize stringSize = [textToDraw sizeWithFont:font
										constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) 
											 lineBreakMode:NSLineBreakByWordWrapping];
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset + 200, kBorderInset + kMarginInset + 75.0, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	[textToDraw drawInRect:renderingRect 
					  withFont:font
				lineBreakMode:NSLineBreakByWordWrapping
					 alignment:NSTextAlignmentLeft];
}


- (void) drawPurchaseDate:(Items*)item
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString* dateText = [dateFormatter stringFromDate:item.purchaseDate];
	NSString* textToDraw = [[NSString alloc] initWithFormat:@"Purchased: %@", dateText ];

	UIFont *font = [UIFont systemFontOfSize:14.0];
	CGSize stringSize = [textToDraw sizeWithFont:font
										constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) 
											 lineBreakMode:NSLineBreakByWordWrapping];
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 75.0, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	[textToDraw drawInRect:renderingRect 
					  withFont:font
				lineBreakMode:NSLineBreakByWordWrapping
					 alignment:NSTextAlignmentLeft];
}


- (void) drawItemName:(Items*)item
{
	// If I ever want to fiddle with the text color:
	//CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
	
	//NSString *textToDraw = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum.";
	NSString* textToDraw = item.name;
	
	UIFont *font = [UIFont systemFontOfSize:14.0];
	
	CGSize stringSize = [textToDraw sizeWithFont:font
										constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) 
											 lineBreakMode:NSLineBreakByWordWrapping];
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 50.0, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	[textToDraw drawInRect:renderingRect 
					  withFont:font
				lineBreakMode:NSLineBreakByWordWrapping
					 alignment:NSTextAlignmentLeft];
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
	NSString* pageNumberString = [NSString stringWithFormat:@"Page %d", pageNumber];
	UIFont* theFont = [UIFont systemFontOfSize:12];
	
	CGSize pageNumberStringSize = [pageNumberString sizeWithFont:theFont
															 constrainedToSize:pageSize
																  lineBreakMode:NSLineBreakByWordWrapping];
	
	CGRect stringRenderingRect = CGRectMake(kBorderInset,
														 pageSize.height - 40.0,
														 pageSize.width - 2*kBorderInset,
														 pageNumberStringSize.height);
	
	[pageNumberString drawInRect:stringRenderingRect withFont:theFont 
						lineBreakMode:NSLineBreakByWordWrapping 
							 alignment:NSTextAlignmentCenter];
}


- (void) drawHeaderWithText: (NSString*)textToDraw
{
	UIFont *font = [UIFont systemFontOfSize:18.0];
	
	CGSize stringSize = [textToDraw sizeWithFont:font 
										constrainedToSize:CGSizeMake
								(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) 
											 lineBreakMode:NSLineBreakByWordWrapping];
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	[textToDraw drawInRect:renderingRect withFont:font 
				lineBreakMode:NSLineBreakByWordWrapping 
					 alignment:NSTextAlignmentLeft];
	
}


- (void) drawHeader
{
	NSString *textToDraw = @"houseCat";
	
	UIFont *font = [UIFont systemFontOfSize:24.0];
	
	CGSize stringSize = [textToDraw sizeWithFont:font 
										constrainedToSize:CGSizeMake
								(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) 
											 lineBreakMode:NSLineBreakByWordWrapping];
	
	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, 
												 pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
	
	[textToDraw drawInRect:renderingRect withFont:font 
				lineBreakMode:NSLineBreakByWordWrapping 
					 alignment:NSTextAlignmentLeft];
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
