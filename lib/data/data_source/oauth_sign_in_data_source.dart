import 'dart:developer';

import 'package:cooki/core/utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

abstract class OAuthSignInDataSource<T> {
  Future<T?> signIn();
  Future<void> signOut();
}

class GoogleOAuthDataSourceImpl implements OAuthSignInDataSource<GoogleSignInAuthentication> {
  final GoogleSignIn _googleSignIn;

  GoogleOAuthDataSourceImpl(this._googleSignIn);

  @override
  Future<GoogleSignInAuthentication?> signIn() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    return googleUser.authentication;
  }

  @override
  Future<void> signOut() => _googleSignIn.signOut();
}

class KakaoOAuthDataSourceImpl implements OAuthSignInDataSource<String> {
  final UserApi _kakaoUserApi;

  KakaoOAuthDataSourceImpl(this._kakaoUserApi);

  @override
  Future<String?> signIn() async {
    if (await isKakaoTalkInstalled()) {
      try {
        final kakaoUser = await _kakaoUserApi.loginWithKakaoTalk();
        log('카카오톡으로 로그인 성공');
        return kakaoUser.accessToken;
      } catch (error, stack) {
        logError(error, stack);

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return null;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          final kakaoUser = await _kakaoUserApi.loginWithKakaoAccount();
          log('카카오계정으로 로그인 성공');
          return kakaoUser.accessToken;
        } catch (error) {
          logError(error, stack);

          return null;
        }
      }
    } else {
      try {
        final kakaoUser = await _kakaoUserApi.loginWithKakaoAccount();
        log('카카오계정으로 로그인 성공');
        return kakaoUser.accessToken;
      } catch (error, stack) {
        logError(error, stack);

        return null;
      }
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
