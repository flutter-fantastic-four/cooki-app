import 'dart:developer';
import 'dart:io';

import 'package:cooki/core/utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cooki/core/utils/login_debug_helper.dart';

abstract class OAuthSignInDataSource<T> {
  Future<T?> signIn();
  Future<void> signOut();
}

class GoogleOAuthDataSourceImpl
    implements OAuthSignInDataSource<GoogleSignInAuthentication> {
  final GoogleSignIn _googleSignIn;

  GoogleOAuthDataSourceImpl(this._googleSignIn);

  @override
  Future<GoogleSignInAuthentication?> signIn() async {
    try {
      LoginDebugHelper.logLoginAttempt('Google', 'Starting');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        LoginDebugHelper.logLoginAttempt('Google', 'Cancelled by user');
        return null;
      }
      final auth = await googleUser.authentication;
      LoginDebugHelper.logLoginAttempt('Google', 'Success');
      return auth;
    } catch (e) {
      LoginDebugHelper.logLoginAttempt('Google', 'Failed', e.toString());
      return null;
    }
  }

  @override
  Future<void> signOut() => _googleSignIn.signOut();
}

class AppleOAuthDataSourceImpl
    implements OAuthSignInDataSource<AuthorizationCredentialAppleID> {
  @override
  Future<AuthorizationCredentialAppleID?> signIn() async {
    try {
      // For Android, we need to provide web authentication options
      if (Platform.isAndroid) {
        String redirectURL = dotenv.env['APPLE_REDIRECT_URI'].toString();
        String? clientID = dotenv.env['APPLE_CLIENT_ID'];

        if (clientID == null || redirectURL.isEmpty) {
          log('Apple Sign-In not properly configured for Android');
          return null;
        }

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.fullName,
            AppleIDAuthorizationScopes.email,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: clientID,
            redirectUri: Uri.parse(redirectURL),
          ),
        );
        return appleCredential;
      } else {
        // For iOS, native authentication
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.fullName,
            AppleIDAuthorizationScopes.email,
          ],
        );
        return appleCredential;
      }
    } catch (e) {
      log('Apple Sign-In failed: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    log('Apple Sign In sign out completed.');
    return Future.value();
  }
}

class KakaoOAuthDataSourceImpl implements OAuthSignInDataSource<String> {
  final UserApi _kakaoUserApi;

  KakaoOAuthDataSourceImpl(this._kakaoUserApi);

  @override
  Future<String?> signIn() async {
    try {
      LoginDebugHelper.logLoginAttempt('Kakao', 'Starting');

      if (await isKakaoTalkInstalled()) {
        try {
          final kakaoUser = await _kakaoUserApi.loginWithKakaoTalk();
          log('카카오톡으로 로그인 성공');
          LoginDebugHelper.logLoginAttempt('Kakao', 'Success via KakaoTalk');
          return kakaoUser.accessToken;
        } catch (error, stack) {
          logError(error, stack);

          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            LoginDebugHelper.logLoginAttempt('Kakao', 'Cancelled by user');
            return null;
          }
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            final kakaoUser = await _kakaoUserApi.loginWithKakaoAccount();
            log('카카오계정으로 로그인 성공');
            LoginDebugHelper.logLoginAttempt(
              'Kakao',
              'Success via KakaoAccount',
            );
            return kakaoUser.accessToken;
          } catch (error) {
            logError(error, stack);
            LoginDebugHelper.logLoginAttempt(
              'Kakao',
              'Failed',
              error.toString(),
            );
            return null;
          }
        }
      } else {
        try {
          final kakaoUser = await _kakaoUserApi.loginWithKakaoAccount();
          log('카카오계정으로 로그인 성공');
          LoginDebugHelper.logLoginAttempt('Kakao', 'Success via KakaoAccount');
          return kakaoUser.accessToken;
        } catch (error, stack) {
          logError(error, stack);
          LoginDebugHelper.logLoginAttempt('Kakao', 'Failed', error.toString());
          return null;
        }
      }
    } catch (e) {
      LoginDebugHelper.logLoginAttempt('Kakao', 'Failed', e.toString());
      return null;
    }
  }

  @override
  Future<void> signOut() => _kakaoUserApi.logout();

  // Future<bool> hasToken() async {
  //   if (await AuthApi.instance.hasToken()) {
  //     try {
  //       AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
  //       print('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');

  //       return true;
  //     } catch (error) {
  //       if (error is KakaoException && error.isInvalidTokenError()) {
  //         print('토큰 만료 $error');
  //       } else {
  //         print('토큰 정보 조회 실패 $error');
  //       }
  //       return false;
  //     }
  //   } else {
  //     print('발급된 토큰 없음');
  //     return false;
  //   }
  // }
}
