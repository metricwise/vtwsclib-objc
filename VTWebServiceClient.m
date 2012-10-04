//
//  WebServiceClient.m
//  Window&DoorMeasurementNew
//
//  Created by Adam Heinz on 9/25/12.
//
//

#import <CommonCrypto/CommonDigest.h>

#import "NSDictionary+URLEncoding.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "VTWebServiceClient.h"

@implementation VTWebServiceClient

@synthesize sessionName;

-(id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for VTWebServiceClient"
                                 userInfo:nil];
}

-(id)initWithURL:(NSURL *)url
{
    if (self=[super init])
    {
        serverURL = url;
    }
    return self;
}

- (NSDictionary *)doChallenge:(NSString *)userName
{
    NSDictionary *getDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"getchallenge", @"operation",
                             userName, @"username",
                             nil];
    return [self doGet:getDict];
}

- (NSDictionary *)doCreate:(NSString *)elementType elementDict:(NSDictionary *)elementDict
{
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"create", @"operation", 
                              sessionName, @"sessionName", 
                              elementType, @"elementType", 
                              [self writeJSON:elementDict], @"element",
                              nil];
    if ([elementType isEqual:@"Documents"]) {
        NSString *fileName = [elementDict objectForKey:@"filename"];
        NSData *fileData = [NSData dataWithContentsOfFile:fileName];
        return [self doPostFile:postDict fileData:fileData];
    } else {
        return [self doPost:postDict];
    }
}

- (NSDictionary *)doGet:(NSDictionary *)getDict
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@\?%@", [serverURL absoluteString], [getDict urlEncodedString]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    return [self parseResponse:responseData];
}

- (NSDictionary *)doLogin:(NSString *)userName accessKey:(NSString *)accessKey
{
    NSDictionary *challengeDict = [self doChallenge:userName];
    NSString *token = [[challengeDict objectForKey:@"result"] objectForKey:@"token"];
    NSString *md5Hash = [self md5:[token stringByAppendingString:accessKey]];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"login", @"operation",
                              userName, @"username",
                              md5Hash, @"accessKey",
                              nil];
    NSDictionary *loginDict = [self doPost:postDict];
    sessionName = [[loginDict objectForKey:@"result"] objectForKey:@"sessionName"];
    return loginDict;
}

- (NSDictionary *)doPost:(NSDictionary *)postDict
{
    NSString *postString = [postDict urlEncodedString];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:serverURL];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[urlRequest setHTTPBody:postData];
	[urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    return [self parseResponse:responseData];
}

- (NSDictionary *)doPostFile:(NSDictionary *)postDict fileData:(NSData *)fileData
{
	NSString *boundary = @"quaixai2eezoo5nut0yo9aenuikab7Ko";
    NSMutableData *postData = [NSMutableData dataWithCapacity:[fileData length] + 1024];
    [postData appendData:[[NSString stringWithFormat:@"--%@\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    for (NSString *keyString in postDict) {
        NSString *valueString = [postDict objectForKey:keyString];
        [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\n\n%@\n", keyString, valueString] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[NSString stringWithFormat:@"--%@\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filename\"; filename=\"%@\"\n\n", @"image.png"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:fileData];
    [postData appendData:[[NSString stringWithFormat:@"\n--%@--\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:serverURL];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[urlRequest setHTTPBody:postData];
	[urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"content-type"];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    return [self parseResponse:responseData];
}

- (NSDictionary *)doQuery:(NSString *)query
{
    return nil;
}

- (NSString *) md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

- (NSDictionary *) parseResponse:(NSData *)responseData {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *responseDict = [jsonParser objectWithData:responseData];
    if (![[responseDict objectForKey:@"success"] isEqual:[NSNumber numberWithInt:1]]) {
        NSLog(@"%@", responseDict);
//        NSDictionary *errorDict = [responseDict objectForKey:@"error"];
//        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[errorDict objectForKey:@"message"] userInfo:errorDict];
    }
    return responseDict;
}

- (NSString *) writeJSON:(id)value {
    SBJsonWriter *jsonWriter = [SBJsonWriter new];
    return [jsonWriter stringWithObject:value];
}

@end
