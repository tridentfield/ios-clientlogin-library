//
//  ClientLoginRequest.h
//
#import <Foundation/Foundation.h>

#define CLIENTLOGIN_URL @"https://www.google.com/accounts/ClientLogin"
#define PARAM_NAME_EMAIL @"Email"
#define PARAM_NAME_PASSWD @"Passwd"
#define PARAM_NAME_ACCOUNTTYPE @"accountType"
#define PARAM_NAME_SERVICE @"service"
#define PARAM_NAME_SOURCE @"source"

@protocol ClientLoginRequestDelegate;

@interface ClientLoginRequest : NSObject
{
    id<ClientLoginRequestDelegate> _delegate;
    NSMutableDictionary *_params;
    NSURLConnection *_connection;
    int _statusCode;
    NSMutableData *_responseData;
    NSMutableDictionary *_token;
}

@property (nonatomic, assign) id<ClientLoginRequestDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, assign) NSURLConnection *connection;
@property (nonatomic, assign, readonly) int statusCode;
@property (nonatomic, assign) NSMutableData *responseData;
@property (nonatomic, assign, readonly) NSMutableDictionary *token;

+ (ClientLoginRequest *) createWithEMail:(NSString *)email
                             Passwd:(NSString *)passwd
                             Source:(NSString *)source
                             Delegate:(id<ClientLoginRequestDelegate>) delegate;

- (void) login;
@end

@protocol ClientLoginRequestDelegate <NSObject>

@required
- (void) loginSuccess:(ClientLoginRequest *)request;
- (void) loginFailure:(ClientLoginRequest *)request;

@end
