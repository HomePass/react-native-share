#import <MessageUI/MessageUI.h>
#import "RNShare.h"
#import "RCTConvert.h"
#import <HomepassCommon/RCTUtils.h>

@import Social;

@implementation RNShare

RCT_EXPORT_MODULE()

#pragma mark - RN Methods

RCT_EXPORT_METHOD(open:(NSDictionary *)options :(RCTResponseSenderBlock)callback)
{
    // Your implementation here
    NSString *shareText = [RCTConvert NSString:options[@"text"]];
    NSString *shareUrl = [RCTConvert NSString:options[@"url"]];
    NSURL *actualUrl = [NSURL URLWithString:shareUrl];

    [self showActivityControllerWithItems:@[ shareText, shareUrl, actualUrl ]];
}

RCT_EXPORT_METHOD(file:(NSDictionary *)options :(RCTResponseSenderBlock)callback)
{
    // Your implementation here
    NSString *fileName = [RCTConvert NSString:options[@"fileName"]];
    NSString *fileExt = [RCTConvert NSString:options[@"fileExt"]];
    NSString *fileUrlPath = [RCTConvert NSString:options[@"fileUrl"]];
    NSURL *fileUrl = [NSURL URLWithString:fileUrlPath];

    NSURL *tmpFileURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, fileExt]];
    NSError *tmpError = nil;
    [[NSFileManager defaultManager] copyItemAtURL:fileUrl toURL:tmpFileURL error:&tmpError];

    [self showActivityControllerWithItems:@[ tmpFileURL ]];
}

RCT_EXPORT_METHOD(facebook:(NSDictionary *)options :(RCTResponseSenderBlock)callback)
{
    // Your implementation here
    NSString *shareText = [RCTConvert NSString:options[@"text"]];
    NSString *shareUrl = [RCTConvert NSString:options[@"url"]];
    NSURL *actualUrl = [NSURL URLWithString:shareUrl];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *root = [[[RCTSharedApplication() delegate] window] rootViewController];

        while (root.presentedViewController != nil) {
            root = root.presentedViewController;
        }

        SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [viewController setInitialText:shareText];

        if (actualUrl) {
            [viewController addURL:actualUrl];
        }

        [root presentViewController:viewController animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(twitter:(NSDictionary *)options :(RCTResponseSenderBlock)callback)
{
    // Your implementation here
    NSString *shareText = [RCTConvert NSString:options[@"text"]];
    NSString *shareUrl = [RCTConvert NSString:options[@"url"]];
    NSURL *actualUrl = [NSURL URLWithString:shareUrl];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *root = [[[RCTSharedApplication() delegate] window] rootViewController];

        while (root.presentedViewController != nil) {
            root = root.presentedViewController;
        }

        SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [viewController setInitialText:shareText];

        if (actualUrl) {
            [viewController addURL:actualUrl];
        }

        [root presentViewController:viewController animated:YES completion:nil];
    });
}

#pragma mark - Native Methods

- (void)showActivityControllerWithItems:(NSArray *)items {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];

        UIViewController *root = [[[RCTSharedApplication() delegate] window] rootViewController];

        while (root.presentedViewController != nil) {
            root = root.presentedViewController;
        }

        //if iPhone
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [root presentViewController:activityVC animated:YES completion:nil];
        }
        //if iPad
        else {
            // Change Rect to position Popover
            UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
            [popup presentPopoverFromRect:CGRectMake(root.view.frame.size.width/2, root.view.frame.size.height/4, 0, 0)inView:root.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    });
}

@end
