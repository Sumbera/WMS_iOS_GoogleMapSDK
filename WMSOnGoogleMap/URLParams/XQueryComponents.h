//
//  XQueryComponents.h
//  MapKitPro
//
//  Created by Stanislav Sumbera on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XQueryComponents)
- (NSString *)stringByDecodingURLFormat;
- (NSString *)stringByEncodingURLFormat;
- (NSMutableDictionary *)dictionaryFromQueryComponents;
@end

@interface NSURL (XQueryComponents)
- (NSMutableDictionary *)queryComponents;
- (NSMutableDictionary *)fragmentComponents;
-(NSURL *)urlByRemovingFragment;
-(NSURL *)urlByRemovingQueryParams;
@end

@interface NSDictionary (XQueryComponents)
- (NSString *)stringFromQueryComponents;
@end