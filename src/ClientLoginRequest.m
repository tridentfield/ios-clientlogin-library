//
//  ClientLoginRequest.m
//

#import "ClientLoginRequest.h"

static const NSString *serviceValue = @"ah";
static const NSString *accountTypeValue = @"HOSTED_OR_GOOGLE";
static const NSTimeInterval timeoutInterval = 60.0;

@implementation ClientLoginRequest

@synthesize delegate = _delegate;
@synthesize params = _params;
@synthesize connection = _connection;
@synthesize statusCode = _statusCode;
@synthesize responseData = _responseData;
@synthesize token = _token;

#pragma static methods
+ (ClientLoginRequest *)createWithEMail:(NSString *)email
                            Passwd:(NSString *)passwd
                            Source:(NSString *)source
                            Delegate:(id<ClientLoginRequestDelegate>) delegate
{
    ClientLoginRequest *request = [[[ClientLoginRequest alloc] init] autorelease];
    request.connection = nil;
    request.responseData = nil;
    request.params = [NSMutableDictionary dictionary];
    [request.params setObject:email forKey:PARAM_NAME_EMAIL];
    [request.params setObject:passwd forKey:PARAM_NAME_PASSWD];
    [request.params setObject:source forKey:PARAM_NAME_SOURCE];
    [request.params setObject:serviceValue forKey:PARAM_NAME_SERVICE];
    [request.params setObject:accountTypeValue forKey:PARAM_NAME_ACCOUNTTYPE];

    request.delegate = delegate;

    return request;
}

#pragma private methods
- (NSString *) createPostBody
{
    NSMutableArray *pairs = [NSMutableArray array];
    for(NSString *key in [_params keyEnumerator]) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@",
                key, [_params objectForKey:key]]];
    }
    return [pairs componentsJoinedByString:@"&"];
}

- (void) parseResponseData
{
    NSString *responseString = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] autorelease];
    NSArray *pairs = [responseString componentsSeparatedByString:@"\n"];
    NSString *pair;
    NSEnumerator *enumerator = [pairs objectEnumerator];
    _token = [NSMutableDictionary dictionary];
    while ((pair = ((NSString *)[enumerator nextObject]))) {
        if ([pair length] == 0) {
            continue;
        }
        NSArray *values = [pair componentsSeparatedByString:@"="];
        [_token setObject:[values objectAtIndex:1] forKey:[values objectAtIndex:0]];
    }
}

#pragma public methods
- (void)dealloc
{
    [_params release];
    [_connection cancel];
    [_connection release];
    [_responseData release];
    [_token release];
    [super dealloc];
}

- (void) login
{
    NSMutableURLRequest *request = [NSMutableURLRequest
            requestWithURL:[NSURL URLWithString:CLIENTLOGIN_URL]
            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
            timeoutInterval:timeoutInterval];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[self createPostBody] dataUsingEncoding:NSUTF8StringEncoding]];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}



#pragma NSURLConnection Delegate methods
- (void)connection:(NSURLConnection *)connection
            didReceiveResponse:(NSURLResponse *)response
{
    _statusCode = [((NSHTTPURLResponse *)response) statusCode];
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection
            didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
        willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self parseResponseData];

    if (_statusCode == 200) {
        [_delegate loginSuccess:self];
    } else {
        [_delegate loginFailure:self];
    }

    [_responseData release];
    _responseData = nil;
    [_connection release];
    _connection = nil;
}

- (void)connection:(NSURLConnection *)connection
            didFailWithError:(NSError *)error
{
    [_responseData release];
    _responseData = nil;
    [_connection release];
    _connection = nil;
}

@end
