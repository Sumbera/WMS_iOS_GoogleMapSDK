//
//  XQueryComponents.m
//  MapKitPro
//
//  Created by Stanislav Sumbera on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// by 'BadPirate' from http://stackoverflow.com/questions/3997976/parse-nsurl-query-property

#import "XQueryComponents.h"

// ****** NSSTRING extension ******
@implementation NSString (XQueryComponents)
//-----------------------------------------------------------------------------------
- (NSString *)stringByDecodingURLFormat
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}
//-----------------------------------------------------------------------------------
- (NSString *)stringByEncodingURLFormat
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}
//-----------------------------------------------------------------------------------
- (NSMutableDictionary *)dictionaryFromQueryComponents
{
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    for(NSString *keyValuePairString in [self componentsSeparatedByString:@"&"])
    {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2){
            continue; // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        }
        NSString *key = [[keyValuePairArray objectAtIndex:0] stringByDecodingURLFormat];
        NSString *value = [[keyValuePairArray objectAtIndex:1] stringByDecodingURLFormat];
      
        [queryComponents setObject:value forKey:key];
    }
        
        return queryComponents;
}
@end


// ****** NSURL extension ******
@implementation NSURL (XQueryComponents)
//-----------------------------------------------------------------------------------
- (NSMutableDictionary *)queryComponents {
    return [[self query] dictionaryFromQueryComponents];
}

//-----------------------------------------------------------------------------------
- (NSMutableDictionary *)fragmentComponents {
    return [[self fragment] dictionaryFromQueryComponents];
}
//-----------------------------------------------------------------------------------
-(NSURL *)urlByRemovingFragment {
    NSString *urlString = [self absoluteString];
    // Find that last component in the string from the end to make sure to get the last one
    NSRange fragmentRange = [urlString rangeOfString:@"#" options:NSBackwardsSearch];
    if (fragmentRange.location != NSNotFound) {
        // Chop the fragment.
        NSString* newURLString = [urlString substringToIndex:fragmentRange.location];
        return [NSURL URLWithString:newURLString];
    } else {
        return self;
    }
}


//-----------------------------------------------------------------------------------
-(NSURL *)urlByRemovingQueryParams {
    NSString *urlString = [self absoluteString];
    // Find that last component in the string from the end to make sure to get the last one
    NSRange fragmentRange = [urlString rangeOfString:@"?" options:NSBackwardsSearch];
    if (fragmentRange.location != NSNotFound) {
        // Chop the fragment.
        NSString* newURLString = [urlString substringToIndex:fragmentRange.location];
        return [NSURL URLWithString:newURLString];
    } else {
        return self;
    }
}

@end
// ****** NSDICTIONARY extension ******
@implementation NSDictionary (XQueryComponents)
//-----------------------------------------------------------------------------------
- (NSString *)stringFromQueryComponents
{
    NSString *result = nil;
    for(__strong NSString *key in [self allKeys])
    {
        key = [key stringByEncodingURLFormat];
        NSArray *allValues = [self objectForKey:key];
        if([allValues isKindOfClass:[NSArray class]])
            for(__strong NSString *value in allValues)
            {
                value = [[value description] stringByEncodingURLFormat];
                if(!result)
                    result = [NSString stringWithFormat:@"%@=%@",key,value];
                else 
                    result = [result stringByAppendingFormat:@"&%@=%@",key,value];
            }
        else {
            NSString *value = [[allValues description] stringByEncodingURLFormat];
            if(!result)
                result = [NSString stringWithFormat:@"%@=%@",key,value];
            else 
                result = [result stringByAppendingFormat:@"&%@=%@",key,value];
        }
    }
    return result;
}
@end
