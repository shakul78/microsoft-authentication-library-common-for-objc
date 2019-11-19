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

NSString *const MSID_BROKER_RESUME_DICTIONARY_KEY  = @"adal-broker-resume-dictionary";
NSString *const MSID_BROKER_SYMMETRIC_KEY_TAG      = @"com.microsoft.adBrokerKey\0";
NSString *const MSID_BROKER_ADAL_SCHEME            = @"msauth";
NSString *const MSID_BROKER_MSAL_SCHEME            = @"msauthv2";
NSString *const MSID_BROKER_NONCE_SCHEME           = @"msauthv3";
NSString *const MSID_BROKER_APP_BUNDLE_ID          = @"com.microsoft.azureauthenticator";
NSString *const MSID_BROKER_APP_BUNDLE_ID_DF       = @"com.microsoft.azureauthenticator-df";
NSString *const MSID_BROKER_MAX_PROTOCOL_VERSION   = @"max_protocol_ver";
NSString *const MSID_BROKER_PROTOCOL_VERSION_KEY   = @"msg_protocol_ver";
NSInteger const MSID_BROKER_PROTOCOL_VERSION_2     = 2;
NSInteger const MSID_BROKER_PROTOCOL_VERSION_3     = 3;
NSInteger const MSID_BROKER_PROTOCOL_VERSION_4     = 4;
NSString *const MSID_BROKER_OPERATION_KEY          = @"operation";
NSString *const MSID_BROKER_KEY                    = @"broker_key";
NSString *const MSID_BROKER_CLIENT_VERSION_KEY     = @"client_version";
NSString *const MSID_BROKER_CLIENT_APP_VERSION_KEY = @"client_app_version";
NSString *const MSID_BROKER_CLIENT_APP_NAME_KEY    = @"client_app_name";
NSString *const MSID_BROKER_CORRELATION_ID_KEY     = @"correlation_id";
NSString *const MSID_BROKER_REQUEST_PARAMETERS_KEY = @"request_parameters";
NSString *const MSID_BROKER_LOGIN_HINT_KEY         = @"login_hint";
NSString *const MSID_BROKER_PROMPT_KEY             = @"prompt";
NSString *const MSID_BROKER_CLIENT_ID_KEY          = @"client_id";
NSString *const MSID_BROKER_EXTRA_OIDC_SCOPES_KEY  = @"extra_oidc_scopes";
NSString *const MSID_BROKER_EXTRA_CONSENT_SCOPES_KEY = @"extra_consent_scopes";
NSString *const MSID_BROKER_EXTRA_QUERY_PARAM_KEY  = @"extra_query_param";
NSString *const MSID_BROKER_INSTANCE_AWARE_KEY     = @"instance_aware";
NSString *const MSID_BROKER_INTUNE_ENROLLMENT_IDS_KEY = @"intune_enrollment_ids";
NSString *const MSID_BROKER_INTUNE_MAM_RESOURCE_KEY = @"intune_mam_resource";
NSString *const MSID_BROKER_CLIENT_CAPABILITIES_KEY = @"client_capabilities";
NSString *const MSID_BROKER_CLAIMS_KEY             = @"claims";
NSString *const MSID_BROKER_APPLICATION_TOKEN_TAG  = @"com.microsoft.adBrokerAppToken";
NSString *const MSID_ADAL_BROKER_MESSAGE_VERSION   = @"2";
NSString *const MSID_MSAL_BROKER_MESSAGE_VERSION   = @"3";
NSString *const MSID_AUTHENTICATOR_REDIRECT_URI    = @"urn:ietf:wg:oauth:2.0:oob";
