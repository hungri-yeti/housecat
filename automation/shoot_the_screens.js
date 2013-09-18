// Copyright (c) 2012 Jonathan Penn (http://cocoamanifest.net/)

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


// Pull in the special function, captureLocalizedScreenshot(), that names files
// according to device, language, and orientation
#import "capture.js"

// Now, we simply drive the application! For more information, check out my
// resources on UI Automation at http://cocoamanifest.net/features
var target = UIATarget.localTarget();
var app = target.frontMostApp();
var language = target.frontMostApp().preferencesValueForKey("AppleLanguages")[0];
var window = target.frontMostApp().mainWindow();



// main screen (Rooms View Controller)
captureLocalizedScreenshot("main");

// Add Room View Controller
var navBar = app.navigationBar();
var addButton = navBar.rightButton();
addButton.tap();
target.delay(1.0);

// var keyboardButtons = app.keyboard().buttons();
// var changeKeyboardButton = keyboardButtons[1];

// for some reason the kb is taking a while to respond:
target.delay(2.0);
captureLocalizedScreenshot("addRoom_before");
if( language == 'en' )
{
	app.keyboard().typeString("Kitchen");
}
// ru support pending
// else if ( language == 'ru' )
// {
// 	// kb always defaults to standard english, so tap once to switch to ru.
// 	// NOTE: this will break if there are more than two keyboards.
// 	changeKeyboardButton.tap();
// 	target.delay(1.0);
// 
// 	captureLocalizedScreenshot("addRoom_before");
// 
// 	app.keyboard().typeString("Кухня");
// }
target.delay(2.0);
captureLocalizedScreenshot("addRoom_after");

// we're still in the modal 'add room' scene, cancel out:
//window.logElementTree();
var navBar = app.navigationBar();
var cancelButton = navBar.leftButton();
cancelButton.tap();



// Change Room View Controller
// window.logElementTree();
var roomsTable = window.tableViews()[0];
var roomCell = roomsTable.cells()[1];
roomCell.tap();
target.delay(1.0);
captureLocalizedScreenshot("editRoom");
cancelButton.tap();
target.delay(1.0);



// Delete Room: this doesn't work.
// UIALogger.logMessage("pre-flick");
// target.delay(4.0)
// swipe to left to expose Delete button. None of these seem to work:
//cell.flickInsideWithOptions({startOffset:{x:0.5, y:0.5}, endOffset:{x:0.2, y:0.7}});
// target.flickFromTo({x:160, y:200}, {x:10, y:207});
//cell.dragInsideWithOptions({startOffset:{x:0.5, y:0.5}, endOffset:{x:0.0, y:0.0}, duration:0.1});
// cell.dragInsideWithOptions({startOffset:{x: 0.6, y: 0.5}, endOffset:{x: 0.1, y: 0.1}, duration: 0.25});
// The table does not react to any of the above commands.
//cell.tap();	// tap gets the correct cell, so I know that's working as expected and cell is
//	pointing to what I expect it to.
//var deleteSwitch = cell.switches()[0]; // switch isn't exposed so this doesn't work
//deleteSwitch.tap();
// UIALogger.logMessage("post-flick");
// target.delay(4.0);
// captureLocalizedScreenshot("deleteRoom");
// cancel the delete:
//cell.tap();
//target.delay(1.0);
// straight from Instruments script:
// target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Master Bedroom"].scrollToVisible();
// target.delay(2.0);
// captureLocalizedScreenshot("deleteRoom");
// target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Master Bedroom"].tap();
// target.delay(2.0);
// captureLocalizedScreenshot("deletedRoom");
// even though the above was verbatim, it still doesn't work.



// Items View Controller
// window.logElementTree();
// roomsTable.logElementTree();
// roomCell.logElementTree();
// tap the accessory for the second cell. These coords are specific to iPhone 5 screen dimension.
// Note that the coords are relative to the entire screen, not the cell itself.
roomCell.tapWithOptions({tapOffset:{x:0.859375, y:0.235915}});
target.delay(2.0);
captureLocalizedScreenshot("itemsList");



// Items Detail View Controller
var itemsTable = window.tableViews()[0];
var itemCell = itemsTable.cells()[0];
itemCell.tap();
target.delay(2.0);
captureLocalizedScreenshot("itemDetail");



// Photos View Controller
var scrollView = window.elements()[1];
var photoButton = scrollView.buttons()[0];
photoButton.tap();
target.delay(2.0);
captureLocalizedScreenshot("itemPhotos");



// Photo Detail View Controller
var collectionView = window.elements()[1];
collectionView.logElementTree();
collectionView.tapWithOptions({tapOffset:{x:0.17, y:0.22}});
target.delay(2.0);
captureLocalizedScreenshot("itemPhoto");



// Loss Report List View Controller
// first go back to the main screen:
backButton = navBar.leftButton();
backButton.tap();
backButton = navBar.leftButton();
backButton.tap();
backButton = navBar.leftButton();
backButton.tap();
backButton = navBar.leftButton();
backButton.tap();
// then start the claim:
var toolbar = window.toolbar();
var barButtons = toolbar.buttons();
var claimButton = barButtons[1];
claimButton.tap();
target.delay(1.0);
captureLocalizedScreenshot("claim01");
// select the items that we'll be using for the claim form:
itemsTable = window.tableViews()[0];
var itemCell0 = itemsTable.cells()[0];
var itemCell1 = itemsTable.cells()[1];
itemCell0.tap();
itemCell1.tap()
target.delay(1.0);
captureLocalizedScreenshot("claim02");



// Loss Report Info Request
// first get the empty claim form:
var claimInfoButton = navBar.rightButton();
claimInfoButton.tap();
target.delay(1.0);
captureLocalizedScreenshot("claim03a");

// then add policy number:
//window.logElementTree();
textField = window.elements()[3];
textField.tap();
target.delay(4.0);
captureLocalizedScreenshot("claim03b");	// is this screen necessary?
if( language == 'en' )
{
	app.keyboard().typeString("123ABC456DEF");
}
target.delay(4.0);
captureLocalizedScreenshot("claim04");

var saveButton = navBar.rightButton();
saveButton.tap();
target.delay(1.0);
captureLocalizedScreenshot("claim05");

