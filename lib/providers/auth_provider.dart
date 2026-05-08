// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  String get userRole => _user?.role ?? '';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((fbUser) async {
      if (fbUser != null) {
        debugPrint('🔐 Auth state: ${fbUser.email} | uid: ${fbUser.uid}');
        await _fetchUser(fbUser.uid);
      } else {
        debugPrint('🔐 Auth state: logged out');
        _user = null;
      }
      _isInitializing = false;
      notifyListeners();
    });
  }

  // Firestore থেকে user data আনো
  Future<void> _fetchUser(String uid) async {
    try {
      debugPrint('📡 Fetching user from Firestore: $uid');

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      debugPrint('📦 Document exists: ${doc.exists}');

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        debugPrint('📦 Data: $data');
        _user = UserModel.fromMap(data);
        debugPrint('✅ User loaded: ${_user!.fullName} | Role: ${_user!.role}');
      } else {
        debugPrint('❌ No Firestore document for uid: $uid');
        _user = null;
      }
    } catch (e) {
      debugPrint('❌ fetchUser error: $e');
      _user = null;
    }
  }

  // ── SIGN UP ──────────────────────────────────────
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? restaurantName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      debugPrint('📝 Starting signup: $email | role: $role');

      // Step 1: Firebase Auth
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user!.uid;
      debugPrint('✅ Firebase Auth created: $uid');

      await cred.user!.updateDisplayName(fullName.trim());

      // Step 2: Firestore এ save করো
      final userData = {
        'uid': uid,
        'fullName': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role,
        'addresses': [],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      debugPrint('📝 Saving to Firestore: $userData');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      debugPrint('✅ Saved to Firestore successfully!');

      // Step 3: Verify সেভ হয়েছে কিনা
      final verify = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!verify.exists) {
        debugPrint('❌ VERIFY FAILED: Document not found after save!');
        _errorMessage = 'Failed to save account data. Try again.';
        notifyListeners();
        return false;
      }

      debugPrint('✅ VERIFIED: Document exists in Firestore!');

      // Step 4: Restaurant তৈরি করো (owner হলে)
      if (role == 'restaurant_owner' &&
          restaurantName != null &&
          restaurantName.trim().isNotEmpty) {
        final restData = {
          'ownerId': uid,
          'name': restaurantName.trim(),
          'description': '',
          'imageUrl': '',
          'coverImageUrl': '',
          'address': '',
          'latitude': 23.8103,
          'longitude': 90.4125,
          'categories': [],
          'rating': 0.0,
          'totalRatings': 0,
          'deliveryTime': 30,
          'deliveryFee': 30.0,
          'minimumOrder': 150.0,
          'openingTime': '09:00',
          'closingTime': '22:00',
          'isOpen': true,
          'isApproved': false,
          'isFeatured': false,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('restaurants')
            .add(restData);

        debugPrint('✅ Restaurant created: $restaurantName');
      }

      // Step 5: Local user set
      _user = UserModel(
        uid: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      debugPrint('✅ SignUp complete! Role: $role');
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuth error: ${e.code} - ${e.message}');
      _errorMessage = _mapError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ SignUp error: $e');
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── SIGN IN ──────────────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      debugPrint('🔑 Signing in: $email');

      // Step 1: Firebase Auth
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user!.uid;
      debugPrint('✅ Firebase Auth OK: $uid');

      // Step 2: Firestore থেকে user data আনো
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      debugPrint('📦 Firestore doc exists: ${doc.exists}');

      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromMap(doc.data()!);
        debugPrint('✅ Login success! Role: ${_user!.role}');
        notifyListeners();
        return true;
      } else {
        // Firestore এ doc নেই — sign out করো
        debugPrint('❌ No Firestore doc found after login');
        await FirebaseAuth.instance.signOut();
        _errorMessage =
        'Account data missing. Please sign up again.';
        _user = null;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Auth error: ${e.code}');
      _errorMessage = _mapError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _errorMessage = 'Login failed. Try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── SIGN OUT ─────────────────────────────────────
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account with this email.';
      case 'wrong-password':
        return 'Wrong password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'Email already registered. Please login.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment.';
      default:
        return 'Authentication failed. Try again.';
    }
  }
}