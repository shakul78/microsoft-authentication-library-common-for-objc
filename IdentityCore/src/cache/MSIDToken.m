// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MSIDToken.h"
#import "MSIDUserInformation.h"
#import "MSIDAADTokenResponse.h"
#import "MSIDClientInfo.h"
#import "MSIDTelemetryEventStrings.h"

//in seconds, ensures catching of clock differences between the server and the device
static uint64_t s_expirationBuffer = 300;

@implementation MSIDToken

- (instancetype)initWithJSONDictionary:(NSDictionary *)json error:(NSError **)error
{    
    if (!(self = [super initWithJSONDictionary:json error:error]))
    {
        return nil;
    }
    
    // We don't use _json variable.
    _json = nil;
    
    _idToken = json[MSID_OAUTH2_ID_TOKEN];
    _familyId = json[MSID_FAMILY_ID];
    _resource = json[MSID_OAUTH2_RESOURCE];
    _clientId = json[MSID_OAUTH2_CLIENT_ID];
    
    if (!json[MSID_OAUTH2_AUTHORITY] && json[MSID_OAUTH2_ENVIRONMENT])
    {
        NSString *authority = [NSString stringWithFormat:@"https://%@/common", json[MSID_OAUTH2_ENVIRONMENT]];
        _authority = [[NSURL alloc] initWithString:authority];
    }
    else
    {
        _authority = json[MSID_OAUTH2_AUTHORITY] ? [[NSURL alloc] initWithString:json[MSID_OAUTH2_AUTHORITY]] : nil;
    }
    
    _scopes = [self scopesFromString:json[MSID_OAUTH2_SCOPE]];
    
    NSError *err;
    _clientInfo = [[MSIDClientInfo alloc] initWithRawClientInfo:json[MSID_OAUTH2_CLIENT_INFO] error:&err];
    if (err)
    {
        MSID_LOG_ERROR(nil, @"Client info is corrupted.");
        MSID_LOG_ERROR_PII(nil, @"Client info is corrupted, error: %@", err);
    }
    
    _expiresOn = json[MSID_OAUTH2_EXPIRES_ON] ? [NSDate dateWithTimeIntervalSince1970:[json[MSID_OAUTH2_EXPIRES_ON] doubleValue]] : nil;
    _additionalServerInfo = json[MSID_OAUTH2_ADDITIONAL_SERVER_INFO];
    
    if (json[MSID_OAUTH2_REFRESH_TOKEN])
    {
        _token = json[MSID_OAUTH2_REFRESH_TOKEN];
        _tokenType = MSIDTokenTypeRefreshToken;
    }
    else
    {
        _token = json[MSID_OAUTH2_ACCESS_TOKEN];
        _tokenType = MSIDTokenTypeAccessToken;
    }
    
    return self;
}

- (NSDictionary *)jsonDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setValue:self.idToken forKey:MSID_OAUTH2_ID_TOKEN];
    [dictionary setValue:self.familyId forKey:MSID_FAMILY_ID];
    [dictionary setValue:self.resource forKey:MSID_OAUTH2_RESOURCE];
    [dictionary setValue:self.clientId forKey:MSID_OAUTH2_CLIENT_ID];
    [dictionary setValue:self.authority.absoluteString forKey:MSID_OAUTH2_AUTHORITY];
    [dictionary setValue:self.authority.msidHostWithPortIfNecessary forKey:MSID_OAUTH2_ENVIRONMENT];
    [dictionary setValue:[self scopesToString:self.scopes] forKey:MSID_OAUTH2_SCOPE];
    [dictionary setValue:_clientInfo.rawClientInfo forKey:MSID_OAUTH2_CLIENT_INFO];
    if (self.expiresOn)
    {
        dictionary[MSID_OAUTH2_EXPIRES_ON] = [NSString stringWithFormat:@"%qu", (uint64_t)[self.expiresOn timeIntervalSince1970]];
    }
    [dictionary setValue:self.additionalServerInfo forKey:MSID_OAUTH2_ADDITIONAL_SERVER_INFO];
    
    if (self.tokenType == MSIDTokenTypeRefreshToken)
    {
        [dictionary setValue:self.token forKey:MSID_OAUTH2_REFRESH_TOKEN];
    }
    else
    {
        [dictionary setValue:self.token forKey:MSID_OAUTH2_ACCESS_TOKEN];
    }
    
    return dictionary;
}

- (BOOL)isExpired;
{
    NSDate *nowPlusBuffer = [NSDate dateWithTimeIntervalSinceNow:s_expirationBuffer];
    return [self.expiresOn compare:nowPlusBuffer] == NSOrderedAscending;
}

- (BOOL)isEqualToToken:(MSIDToken *)token
{
    if (!token)
    {
        return NO;
    }
    
    BOOL result = YES;
    result &= (!self.token && !token.token) || [self.token isEqualToString:token.token];
    result &= (!self.idToken && !token.idToken) || [self.idToken isEqualToString:token.idToken];
    result &= (!self.expiresOn && !token.expiresOn) || [self.expiresOn isEqualToDate:token.expiresOn];
    result &= (!self.familyId && !token.familyId) || [self.familyId isEqualToString:token.familyId];
    result &= (!self.clientInfo && !token.clientInfo) || [self.clientInfo.rawClientInfo isEqualToString:token.clientInfo.rawClientInfo];
    result &= (!self.additionalServerInfo && !token.additionalServerInfo) || [self.additionalServerInfo isEqualToDictionary:token.additionalServerInfo];
    result &= self.tokenType == token.tokenType;
    result &= (!self.resource && !token.resource) || [self.resource isEqualToString:token.resource];
    result &= (!self.authority && !token.authority) || [self.authority.absoluteString isEqualToString:token.authority.absoluteString];
    result &= (!self.clientId && !token.clientId) || [self.clientId isEqualToString:token.clientId];
    result &= (!self.scopes && !token.scopes) || [self.scopes isEqualToOrderedSet:token.scopes];
    
    return result;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (![object isKindOfClass:MSIDToken.class])
    {
        return NO;
    }
    
    return [self isEqualToToken:(MSIDToken *)object];
}

- (NSUInteger)hash
{
    NSUInteger hash = self.token.hash;
    hash ^= self.idToken.hash;
    hash ^= self.expiresOn.hash;
    hash ^= self.familyId.hash;
    hash ^= self.clientInfo.hash;
    hash ^= self.additionalServerInfo.hash;
    hash ^= self.tokenType;
    hash ^= self.resource.hash;
    hash ^= self.authority.hash;
    hash ^= self.clientId.hash;
    hash ^= self.scopes.hash;
    
    return hash;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    _familyId = [coder decodeObjectOfClass:[NSString class] forKey:@"familyId"];
    _expiresOn = [coder decodeObjectOfClass:[NSDate class] forKey:@"expiresOn"];
    
    NSString *accessToken = [coder decodeObjectOfClass:[NSString class] forKey:@"accessToken"];
    NSString *refreshToken = [coder decodeObjectOfClass:[NSString class] forKey:@"refreshToken"];
    
    if (refreshToken)
    {
        _token = refreshToken;
        _tokenType = MSIDTokenTypeRefreshToken;
    }
    else
    {
        _token = accessToken;
        _tokenType = MSIDTokenTypeAccessToken;
    }
    
    _additionalServerInfo = [coder decodeObjectOfClass:[NSDictionary class] forKey:@"additionalServer"];
    
    NSString *rawClientInfo = [coder decodeObjectOfClass:[NSString class] forKey:@"clientInfo"];
    
    NSError *error = nil;
    _clientInfo = [[MSIDClientInfo alloc] initWithRawClientInfo:rawClientInfo error:&error];
    
    if (error)
    {
        MSID_LOG_WARN(nil, @"Couln't initialize client info when deserializing token");
    }
    
    _idToken = [[coder decodeObjectOfClass:[MSIDUserInformation class] forKey:@"userInformation"] rawIdToken];
    _resource = [coder decodeObjectOfClass:[NSString class] forKey:@"resource"];

    NSString *authorityString = [coder decodeObjectOfClass:[NSString class] forKey:@"authority"];
    _authority = [NSURL URLWithString:authorityString];
    
    _clientId = [coder decodeObjectOfClass:[NSString class] forKey:@"clientId"];
    _scopes = [coder decodeObjectOfClass:[NSOrderedSet class] forKey:@"scopes"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.familyId forKey:@"familyId"];
    [coder encodeObject:self.expiresOn forKey:@"expiresOn"];
    
    if (self.tokenType == MSIDTokenTypeRefreshToken)
    {
        [coder encodeObject:self.token forKey:@"refreshToken"];
    }
    else
    {
        [coder encodeObject:self.token forKey:@"accessToken"];
    }
    // Backward compatibility with ADAL.
    [coder encodeObject:@"Bearer" forKey:@"accessTokenType"];
    
    [coder encodeObject:self.clientInfo.rawClientInfo forKey:@"clientInfo"];
    [coder encodeObject:self.additionalServerInfo forKey:@"additionalServer"];
    
    MSIDUserInformation *userInformation = [MSIDUserInformation new];
    userInformation.rawIdToken = self.idToken;
    [coder encodeObject:userInformation forKey:@"userInformation"];
    
    [coder encodeObject:self.resource forKey:@"resource"];
    [coder encodeObject:self.authority.absoluteString forKey:@"authority"];
    [coder encodeObject:self.clientId forKey:@"clientId"];
    [coder encodeObject:self.scopes forKey:@"scopes"];
}

#pragma mark - Init

- (instancetype)initWithTokenResponse:(MSIDTokenResponse *)response
                              request:(MSIDTokenRequest *)request
                            tokenType:(MSIDTokenType)tokenType
{
    if (!response
        || !request)
    {
        return nil;
    }
    
    if (!(self = [super init]))
    {
        return nil;
    }
    
    [self fillFromRequest:request];
    [self fillFromResponse:response tokenType:tokenType];
    [self fillExpiryFromResponse:response];
    [self fillAdditionalServerInfoFromResponse:response];
    
    return self;
}

#pragma mark - Private

- (NSMutableOrderedSet<NSString *> *)scopesFromString:(NSString *)scopesString
{
    if (!scopesString)
    {
        return nil;
    }
    
    NSMutableOrderedSet<NSString *> *scope = [NSMutableOrderedSet<NSString *> new];
    NSArray *parts = [scopesString componentsSeparatedByString:@" "];
    for (NSString *part in parts)
    {
        if (![NSString msidIsStringNilOrBlank:part])
        {
            [scope addObject:part.msidTrimmedString.lowercaseString];
        }
    }
    
    return scope;
}

- (NSString *)scopesToString:(NSOrderedSet<NSString *> *)scopes
{
    return [scopes.array componentsJoinedByString:@" "];
}


#pragma mark - Fill item

- (void)fillFromRequest:(MSIDTokenRequest *)tokenRequest
{
    _authority = tokenRequest.authority;
    _clientId = tokenRequest.clientId;
}

- (void)fillFromResponse:(MSIDTokenResponse *)tokenResponse
               tokenType:(MSIDTokenType)tokenType
{
    _tokenType = tokenType;
    _idToken = tokenResponse.idToken;
    
    NSString *resource = nil;
    NSString *familyId = nil;
    
    if ([tokenResponse isKindOfClass:[MSIDAADTokenResponse class]])
    {
        MSIDAADTokenResponse *aadTokenResponse = (MSIDAADTokenResponse *)tokenResponse;
        resource = aadTokenResponse.resource;
        familyId = aadTokenResponse.familyId;
        _clientInfo = aadTokenResponse.clientInfo;
    }
    
    switch (tokenType)
    {
        case MSIDTokenTypeAccessToken:
        {
            _resource = resource;
            _token = tokenResponse.accessToken;
            _scopes = [tokenResponse.scope scopeSet];
            
            break;
        }
        case MSIDTokenTypeRefreshToken:
        {
            _token = tokenResponse.refreshToken;
            _familyId = familyId;
            break;
        }
        case MSIDTokenTypeAdfsUserToken:
        {
            _resource = resource;
            _token = tokenResponse.refreshToken;
            break;
        }
        default:
            break;
    }
}

- (void)fillExpiryFromResponse:(MSIDTokenResponse *)tokenResponse
{
    NSDate *expiryDate = tokenResponse.expiryDate;
    
    if (!expiryDate)
    {
        MSID_LOG_WARN(nil, @"The server did not return the expiration time for the access token.");
        expiryDate = [NSDate dateWithTimeIntervalSinceNow:3600.0]; //Assume 1hr expiration
    }
    else
    {
        _expiresOn = expiryDate;
    }
}

- (void)fillAdditionalServerInfoFromResponse:(MSIDTokenResponse *)tokenResponse
{
    NSMutableDictionary *serverInfo = [NSMutableDictionary dictionary];
    
    if ([tokenResponse isKindOfClass:[MSIDAADTokenResponse class]])
    {
        MSIDAADTokenResponse *aadTokenResponse = (MSIDAADTokenResponse *)tokenResponse;
        [serverInfo setObject:aadTokenResponse.extendedExpiresIn forKey:@"ext_expires_on"];
        [serverInfo setObject:aadTokenResponse.speInfo forKey:MSID_TELEMETRY_KEY_SPE_INFO];
    }
    
    _additionalServerInfo = serverInfo;
}

@end
