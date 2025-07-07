import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class SocialAuthService {
  // Google Sign In configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Google Sign In
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResponse(
          success: false,
          message: 'Google sign in was cancelled',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Send to backend for verification and user creation/login
      final response = await ApiService.post(
        '/auth/google',
        {
          'idToken': googleAuth.idToken,
          'accessToken': googleAuth.accessToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
        },
        includeAuth: false,
      );

      if (response['success']) {
        return AuthResponse(
          success: true,
          message: response['message'],
          user: User.fromJson(response['user']),
          token: response['token'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: response['message'] ?? 'Google sign in failed',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Google sign in error: ${e.toString()}',
      );
    }
  }

  // Facebook Sign In
  Future<AuthResponse> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        
        // Get user data from Facebook
        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture.width(200)",
        );

        // Send to backend for verification and user creation/login
        final response = await ApiService.post(
          '/auth/facebook',
          {
            'accessToken': accessToken.tokenString,
            'email': userData['email'],
            'name': userData['name'],
            'photoUrl': userData['picture']['data']['url'],
            'facebookId': userData['id'],
          },
          includeAuth: false,
        );

        if (response['success']) {
          return AuthResponse(
            success: true,
            message: response['message'],
            user: User.fromJson(response['user']),
            token: response['token'],
          );
        } else {
          return AuthResponse(
            success: false,
            message: response['message'] ?? 'Facebook sign in failed',
          );
        }
      } else {
        return AuthResponse(
          success: false,
          message: 'Facebook sign in was cancelled or failed',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Facebook sign in error: ${e.toString()}',
      );
    }
  }

  // Apple Sign In
  Future<AuthResponse> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: nonce,
      );

      // Send to backend for verification and user creation/login
      final response = await ApiService.post(
        '/auth/apple',
        {
          'identityToken': credential.identityToken,
          'authorizationCode': credential.authorizationCode,
          'email': credential.email,
          'givenName': credential.givenName,
          'familyName': credential.familyName,
          'userIdentifier': credential.userIdentifier,
          'rawNonce': rawNonce,
        },
        includeAuth: false,
      );

      if (response['success']) {
        return AuthResponse(
          success: true,
          message: response['message'],
          user: User.fromJson(response['user']),
          token: response['token'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: response['message'] ?? 'Apple sign in failed',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Apple sign in error: ${e.toString()}',
      );
    }
  }

  // Sign out from all social providers
  Future<void> signOutFromSocialProviders() async {
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      // Apple doesn't require explicit sign out
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out from social providers: $e');
      }
    }
  }

  // Helper methods for Apple Sign In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}