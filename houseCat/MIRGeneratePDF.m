//
//  MIRGeneratePDF.m
//  houseCat
//
//  Created by kenl on 12/11/13.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRGeneratePDF.h"


@interface MIRGeneratePDF (Private)
	- (void) generatePdfWithFilePath: (NSString *)thefilePath;
	- (void)drawPageNumber:(NSInteger)pageNum;
//	- (void) drawBorder;
//	- (void) drawText;
//	- (void) drawLine;
//	- (void) drawHeader;
//	- (void) drawImage;
@end



@implementation MIRGeneratePDF

#pragma mark - PDF generation
- (NSString*) generatePDF: (NSArray*) objects
{
	// TODO: should consider localizing this (e.g. A4)
	pageSize = CGSizeMake(612, 792);
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4]; 
	[formatter setDateFormat:@"yyyyMMddHmmss"];
	NSDate* date = [[NSDate alloc] init];
	NSString* dateStr = [formatter stringFromDate:date];
	
	NSString* fileName = [[NSString alloc] initWithFormat:@"houseCat_%@.pdf", dateStr];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	// TODO: this file will need to be deleted at some point, when is it safe/advisable to do so?
	NSString *pdfFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	NSLog(@"pdfFilePath: %@", pdfFilePath );
	
	[self generatePdfWithFilePath:pdfFilePath];	
	return pdfFilePath;
}


- (void) generatePdfWithFilePath: (NSString *)thefilePath
{
	UIGraphicsBeginPDFContextToFile(thefilePath, CGRectZero, nil);
	
	NSInteger currentPage = 0;
	BOOL done = NO;
	do
	{
		// Mark the beginning of a new page.
		UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
		
		// Draw a page number at the bottom of each page.
		currentPage++;
		[self drawPageNumber:currentPage];
		
		//Draw a border for each page.
		//[self drawBorder];
		
		//		//Draw text fo our header.
		//		[self drawHeader];
		//		
		//		//Draw a line below the header.
		//		[self drawLine];
		//		
		//		//Draw some text for the page.
		//		[self drawText];
		//		
		//		//Draw an image
		//		[self drawImage];
		done = YES;
	}
	while (!done);
	
	// Close the PDF context and write the contents out.
	UIGraphicsEndPDFContext();
}


#pragma mark - Private Methods
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


//- (void) drawHeader
//{
//	CGContextRef    currentContext = UIGraphicsGetCurrentContext();
//	CGContextSetRGBFillColor(currentContext, 0.3, 0.7, 0.2, 1.0);
//	
//	NSString *textToDraw = @"Pdf Demo - iOSLearner.com";
//	
//	UIFont *font = [UIFont systemFontOfSize:24.0];
//	
//	CGSize stringSize = [textToDraw sizeWithFont:font constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) lineBreakMode:UILineBreakModeWordWrap];
//	
//	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
//	
//	[textToDraw drawInRect:renderingRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
//}


//- (void) drawText
//{
//	CGContextRef    currentContext = UIGraphicsGetCurrentContext();
//	CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
//	
//	NSString *textToDraw = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum.";
//	
//	UIFont *font = [UIFont systemFontOfSize:14.0];
//	
//	CGSize stringSize = [textToDraw sizeWithFont:font
//										constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset) 
//											 lineBreakMode:UILineBreakModeWordWrap];
//	
//	CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 50.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
//	
//	[textToDraw drawInRect:renderingRect 
//					  withFont:font
//				lineBreakMode:UILineBreakModeWordWrap
//					 alignment:UITextAlignmentLeft];
//	
//}


//- (void) drawLine
//{
//	CGContextRef    currentContext = UIGraphicsGetCurrentContext();
//	
//	CGContextSetLineWidth(currentContext, kLineWidth);
//	
//	CGContextSetStrokeColorWithColor(currentContext, [UIColor blueColor].CGColor);
//	
//	CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset, kMarginInset + kBorderInset + 40.0);
//	CGPoint endPoint = CGPointMake(pageSize.width - 2*kMarginInset -2*kBorderInset, kMarginInset + kBorderInset + 40.0);
//	
//	CGContextBeginPath(currentContext);
//	CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
//	CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
//	
//	CGContextClosePath(currentContext);    
//	CGContextDrawPath(currentContext, kCGPathFillStroke);
//}


//- (void) drawImage
//{
//	UIImage * demoImage = [UIImage imageNamed:@"demo.png"];
//	[demoImage drawInRect:CGRectMake( (pageSize.width - demoImage.size.width/2)/2, 350, demoImage.size.width/2, demoImage.size.height/2)];
//}



@end
