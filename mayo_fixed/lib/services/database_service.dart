import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// DatabaseService class handles all Firestore database operations
/// This service manages Users, Sessions, and CoupleManagement collections
class DatabaseService {
  // Private constructor to implement singleton pattern
  DatabaseService._privateConstructor();
  
  // Static instance of DatabaseService (singleton)
  static final DatabaseService _instance = DatabaseService._privateConstructor();
  
  // Factory constructor that returns the singleton instance
  factory DatabaseService() => _instance;
  
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _sessionsCollection => _firestore.collection('sessions');
  CollectionReference get _coupleManagementCollection => _firestore.collection('coupleManagement');
  CollectionReference get _partnerCodesCollection => _firestore.collection('partnerCodes');

  /// Create user document in Firestore
  /// 
  /// Parameters:
  /// - [user]: FirebaseAuth user object
  /// - [name]: User's display name
  /// - [nickname]: User's preferred nickname
  /// - [profilePicture]: URL to user's profile picture (optional)
  /// - [partnerCode]: Partner code for linking (optional)
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status and message
  Future<DatabaseResult> createUserDocument({
    required User user,
    required String name,
    required String nickname,
    String? profilePicture,
    String? partnerCode,
  }) async {
    try {
      // Check if document already exists
      final existingDoc = await _usersCollection.doc(user.uid).get();
      if (existingDoc.exists) {
        if (kDebugMode) {
          print('User document already exists for: ${user.uid}');
        }
        return DatabaseResult(
          success: true,
          message: 'User document already exists',
        );
      }

      // Create user data
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'nickname': nickname,
        'profilePicture': profilePicture,
        'role': 'individual', // Default role
        'partnerId': null, // No partner initially
        'profileSetupComplete': profilePicture != null && profilePicture.isNotEmpty,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Create user document
      await _usersCollection.doc(user.uid).set(userData);

      // Generate partner code after user creation
      await generatePartnerCode(user.uid);

      // Handle partner linking if code provided
      if (partnerCode != null && partnerCode.isNotEmpty) {
        final linkResult = await linkWithPartner(user.uid, partnerCode);
        if (!linkResult.success) {
          if (kDebugMode) {
            print('Partner linking failed: ${linkResult.message}');
          }
        }
      }
      
      if (kDebugMode) {
        print('User document created successfully: ${user.uid}');
      }
      
      return DatabaseResult(
        success: true,
        message: 'User document created successfully',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user document: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to create user document: $e',
      );
    }
  }

  /// Generate a unique 5-character partner code for user
  /// 
  /// Parameters:
  /// - [userId]: User's ID
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status, message, and partner code
  Future<DatabaseResult> generatePartnerCode(String userId) async {
    try {
      // Check if user exists
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        return DatabaseResult(
          success: false,
          message: 'User not found',
        );
      }

      // Check if user already has partner code
      final existingCodeDoc = await _partnerCodesCollection.doc(userId).get();
      if (existingCodeDoc.exists) {
        final codeData = existingCodeDoc.data() as Map<String, dynamic>;
        return DatabaseResult(
          success: true,
          message: 'Partner code already exists',
          data: {'partnerCode': codeData['code'], 'userId': userId},
        );
      }

      // Generate unique code
      String partnerCode;
      bool isUnique = false;
      int attempts = 0;
      const maxAttempts = 10;

      do {
        partnerCode = _generateRandomCode();
        
        // Check if code is unique
        final codeQuery = await _partnerCodesCollection
            .where('code', isEqualTo: partnerCode)
            .limit(1)
            .get();
        
        isUnique = codeQuery.docs.isEmpty;
        attempts++;
      } while (!isUnique && attempts < maxAttempts);

      if (!isUnique) {
        return DatabaseResult(
          success: false,
          message: 'Failed to generate unique partner code',
        );
      }

      // Store code in partnerCodes collection
      await _partnerCodesCollection.doc(userId).set({
        'code': partnerCode,
        'userId': userId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return DatabaseResult(
        success: true,
        message: 'Partner code generated successfully',
        data: {'partnerCode': partnerCode, 'userId': userId},
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error generating partner code: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to generate partner code: $e',
      );
    }
  }

  /// Generate a random 5-character alphanumeric code
  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Link current user with partner using partner code
  /// 
  /// Parameters:
  /// - [userId]: Current user's ID
  /// - [partnerCode]: Partner's 5-character code
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status and message
  Future<DatabaseResult> linkWithPartner(String userId, String partnerCode) async {
    try {
      // Find partner by code
      final codeQuery = await _partnerCodesCollection
          .where('code', isEqualTo: partnerCode.toUpperCase())
          .limit(1)
          .get();

      if (codeQuery.docs.isEmpty) {
        return DatabaseResult(
          success: false,
          message: 'Invalid partner code',
        );
      }

      final partnerCodeDoc = codeQuery.docs.first;
      final partnerCodeData = partnerCodeDoc.data() as Map<String, dynamic>;
      final partnerUserId = partnerCodeData['userId'] as String;

      // Prevent linking with yourself
      if (partnerUserId == userId) {
        return DatabaseResult(
          success: false,
          message: 'You cannot link with yourself',
        );
      }

      // Check if current user already has a partner
      final currentUserDoc = await _usersCollection.doc(userId).get();
      if (!currentUserDoc.exists) {
        return DatabaseResult(
          success: false,
          message: 'Current user not found',
        );
      }

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      if (currentUserData['partnerId'] != null) {
        return DatabaseResult(
          success: false,
          message: 'You already have a partner',
        );
      }

      // Check if partner already has a partner
      final partnerUserDoc = await _usersCollection.doc(partnerUserId).get();
      if (!partnerUserDoc.exists) {
        return DatabaseResult(
          success: false,
          message: 'Partner user not found',
        );
      }

      final partnerUserData = partnerUserDoc.data() as Map<String, dynamic>;
      if (partnerUserData['partnerId'] != null) {
        return DatabaseResult(
          success: false,
          message: 'This user already has a partner',
        );
      }

      // Create couple management document
      final coupleResult = await _createCoupleLink(userId, partnerUserId);
      if (!coupleResult.success) {
        return coupleResult;
      }

      // Update both users with partner information
      await _usersCollection.doc(userId).update({
        'partnerId': partnerUserId,
        'role': 'couple',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _usersCollection.doc(partnerUserId).update({
        'partnerId': userId,
        'role': 'couple',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return DatabaseResult(
        success: true,
        message: 'Successfully linked with partner',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error linking with partner: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to link with partner: $e',
      );
    }
  }

  /// Create a couple management document
  /// 
  /// Parameters:
  /// - [userId1]: First partner's user ID
  /// - [userId2]: Second partner's user ID
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status and message
  Future<DatabaseResult> _createCoupleLink(String userId1, String userId2) async {
    try {
      final coupleData = {
        'coupleId': '${userId1}_$userId2',
        'userId1': userId1,
        'userId2': userId2,
        'linkStatus': 'linked',
        'sessionHistory': [],
        'sessionCount': 0,
        'relationshipStatus': 'dating',
        'lastSessionDate': null,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _coupleManagementCollection.doc('${userId1}_$userId2').set(coupleData);
      
      return DatabaseResult(
        success: true,
        message: 'Couple link created successfully',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error creating couple link: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to create couple link: $e',
      );
    }
  }

  /// Get user's partner code
  /// 
  /// Parameters:
  /// - [userId]: User's ID
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status, message, and partner code
  Future<DatabaseResult> getUserPartnerCode(String userId) async {
    try {
      final codeDoc = await _partnerCodesCollection.doc(userId).get();
      
      if (!codeDoc.exists) {
        // Generate code if it doesn't exist
        return await generatePartnerCode(userId);
      }

      final codeData = codeDoc.data() as Map<String, dynamic>;
      return DatabaseResult(
        success: true,
        message: 'Partner code retrieved successfully',
        data: {'partnerCode': codeData['code'], 'userId': userId},
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error getting partner code: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to get partner code: $e',
      );
    }
  }

  /// Unlink current user from their partner
  /// 
  /// Parameters:
  /// - [userId]: Current user's ID
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status and message
  Future<DatabaseResult> unlinkPartner(String userId) async {
    try {
      // Get current user data
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        return DatabaseResult(
          success: false,
          message: 'User not found',
        );
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final partnerId = userData['partnerId'] as String?;

      if (partnerId == null) {
        return DatabaseResult(
          success: false,
          message: 'No partner to unlink',
        );
      }

      // Update current user to remove partner
      await _usersCollection.doc(userId).update({
        'partnerId': null,
        'role': 'individual',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update partner to remove current user
      await _usersCollection.doc(partnerId).update({
        'partnerId': null,
        'role': 'individual',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Delete couple management document (try both possible IDs)
      final coupleId1 = '${userId}_$partnerId';
      final coupleId2 = '${partnerId}_$userId';
      
      try {
        final doc1 = await _coupleManagementCollection.doc(coupleId1).get();
        if (doc1.exists) {
          await _coupleManagementCollection.doc(coupleId1).delete();
        } else {
          final doc2 = await _coupleManagementCollection.doc(coupleId2).get();
          if (doc2.exists) {
            await _coupleManagementCollection.doc(coupleId2).delete();
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting couple management document: $e');
        }
      }

      return DatabaseResult(
        success: true,
        message: 'Successfully unlinked from partner',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error unlinking partner: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to unlink partner: $e',
      );
    }
  }

  /// Update user profile picture
  /// 
  /// Parameters:
  /// - [userId]: User's ID
  /// - [profilePicture]: URL to the new profile picture
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status and message
  Future<DatabaseResult> updateUserProfilePicture(String userId, String profilePicture) async {
    try {
      await _usersCollection.doc(userId).update({
        'profilePicture': profilePicture,
        'profileSetupComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return DatabaseResult(
        success: true,
        message: 'Profile picture updated successfully',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile picture: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to update profile picture: $e',
      );
    }
  }

  /// Update user nickname
  /// 
  /// Parameters:
  /// - [userId]: User's ID
  /// - [nickname]: New nickname for the user
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status and message
  Future<DatabaseResult> updateUserNickname({required String userId, required String nickname}) async {
    try {
      await _usersCollection.doc(userId).update({
        'nickname': nickname,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return DatabaseResult(
        success: true,
        message: 'Nickname updated successfully',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error updating nickname: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to update nickname: $e',
      );
    }
  }

  /// Update user profile setup status
  /// 
  /// Parameters:
  /// - [userId]: User's ID
  /// - [isComplete]: Whether profile setup is complete
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status and message
  Future<DatabaseResult> updateUserProfileSetupStatus({required String userId, required bool isComplete}) async {
    try {
      await _usersCollection.doc(userId).update({
        'profileSetupComplete': isComplete,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return DatabaseResult(
        success: true,
        message: 'Profile setup status updated successfully',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile setup status: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to update profile setup status: $e',
      );
    }
  }

  /// Get user data
  /// 
  /// Parameters:
  /// - [userId]: User's ID
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status, message, and user data
  Future<DatabaseResult> getUserData(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      
      if (!doc.exists) {
        return DatabaseResult(
          success: false,
          message: 'User not found',
        );
      }
      
      return DatabaseResult(
        success: true,
        message: 'User data retrieved successfully',
        data: doc.data(),
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to get user data: $e',
      );
    }
  }

  /// Migrate existing user documents to new partner code system
  Future<DatabaseResult> migrateUserDocuments() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return DatabaseResult(
          success: false,
          message: 'No authenticated user found',
        );
      }
      
      // Check if user document exists
      final userDoc = await _usersCollection.doc(user.uid).get();
      if (!userDoc.exists) {
        return DatabaseResult(
          success: false,
          message: 'User document not found',
        );
      }

      // Generate partner code if it doesn't exist
      final codeDoc = await _partnerCodesCollection.doc(user.uid).get();
      if (!codeDoc.exists) {
        await generatePartnerCode(user.uid);
      }
      
      return DatabaseResult(
        success: true,
        message: 'User document migrated successfully',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error migrating user document: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to migrate user document: $e',
      );
    }
  }

  /// Get user sessions
  /// 
  /// Parameters:
  /// - [userId]: User's ID
  /// - [limit]: Maximum number of sessions to retrieve
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status, message, and sessions data
  Future<DatabaseResult> getUserSessions(String userId, {int limit = 10}) async {
    try {
      final sessionsQuery = await _sessionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('sessionStart', descending: true)
          .limit(limit)
          .get();
      
      final sessions = sessionsQuery.docs.map((doc) => {
        'sessionId': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      return DatabaseResult(
        success: true,
        message: 'Sessions retrieved successfully',
        data: {'sessions': sessions},
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user sessions: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to get user sessions: $e',
      );
    }
  }

  /// Create a new session
  /// 
  /// Parameters:
  /// - [userId]: User's ID who started the session
  /// - [sessionType]: Type of session ('individual' or 'couple')
  /// - [partnerId]: Partner's ID (required for couple sessions)
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status, message, and session ID
  Future<DatabaseResult> createSession({
    required String userId,
    required String sessionType,
    String? partnerId,
  }) async {
    try {
      final sessionData = {
        'userId': userId,
        'sessionType': sessionType,
        'partnerId': partnerId,
        'sessionStart': FieldValue.serverTimestamp(),
        'sessionEnd': null,
        'duration': null,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _sessionsCollection.add(sessionData);
      
      return DatabaseResult(
        success: true,
        message: 'Session created successfully',
        data: {'sessionId': docRef.id},
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error creating session: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to create session: $e',
      );
    }
  }

  /// End a session
  /// 
  /// Parameters:
  /// - [sessionId]: Session's ID
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status and message
  Future<DatabaseResult> endSession(String sessionId) async {
    try {
      await _sessionsCollection.doc(sessionId).update({
        'sessionEnd': FieldValue.serverTimestamp(),
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return DatabaseResult(
        success: true,
        message: 'Session ended successfully',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error ending session: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to end session: $e',
      );
    }
  }

  /// Save mood entry
  /// 
  /// Parameters:
  /// - [userId]: User's ID
  /// - [mood]: Mood value (1-10)
  /// - [notes]: Optional notes about the mood
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status and message
  Future<DatabaseResult> saveMoodEntry({
    required String userId,
    required int mood,
    String? notes,
  }) async {
    try {
      final moodData = {
        'mood': mood,
        'notes': notes,
        'timestamp': FieldValue.serverTimestamp(),
      };
      
      await _usersCollection
          .doc(userId)
          .collection('moodEntries')
          .add(moodData);
      
      return DatabaseResult(
        success: true,
        message: 'Mood entry saved successfully',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error saving mood entry: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to save mood entry: $e',
      );
    }
  }

  /// Get recent mood entries
  /// 
  /// Parameters:
  /// - [userId]: User's ID
  /// - [limit]: Maximum number of entries to retrieve
  /// 
  /// Returns:
  /// - [DatabaseResult]: Contains success status, message, and mood data
  Future<DatabaseResult> getMoodEntries(String userId, {int limit = 30}) async {
    try {
      final moodQuery = await _usersCollection
          .doc(userId)
          .collection('moodEntries')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      final moods = moodQuery.docs.map((doc) => {
        'entryId': doc.id,
        ...doc.data(),
      }).toList();
      
      return DatabaseResult(
        success: true,
        message: 'Mood entries retrieved successfully',
        data: {'moods': moods},
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error getting mood entries: $e');
      }
      
      return DatabaseResult(
        success: false,
        message: 'Failed to get mood entries: $e',
      );
    }
  }
}

/// Result class for database operations
class DatabaseResult {
  final bool success;
  final String message;
  final dynamic data;

  DatabaseResult({
    required this.success,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return 'DatabaseResult(success: $success, message: $message, data: $data)';
  }
}