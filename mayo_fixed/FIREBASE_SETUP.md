# Firebase Setup Guide

## Firestore Rules Deployment

The app now includes Firestore security rules that need to be deployed to your Firebase project. These rules ensure that users can only access their own data, including mood entries.

### Steps to Deploy Firestore Rules

1. **Install Firebase CLI** (if not already installed)
   ```
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```
   firebase login
   ```

3. **Initialize Firebase in your project** (if not already done)
   ```
   cd "c:\Users\goldn\Documents\Mayo App\mayo_fixed"
   firebase init
   ```
   - Select Firestore when prompted for which Firebase features to set up
   - Select your project (mayo-60118)
   - When asked about the Firestore rules file, use the existing `firestore.rules` file

4. **Deploy the rules**
   ```
   firebase deploy --only firestore:rules
   ```

## Alternative: Deploy Rules via Firebase Console

If you prefer using the Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (mayo-60118)
3. Navigate to Firestore Database in the left sidebar
4. Click on the "Rules" tab
5. Copy and paste the contents of the `firestore.rules` file
6. Click "Publish"

## Firestore Rules Explanation

The rules in `firestore.rules` provide the following permissions:

1. **Users Collection**:
   - Users can read and write only their own user document
   - Users can read and write only their own mood entries

2. **Sessions Collection**:
   - Users can read and write sessions where they are either the user or partner
   - Users can create sessions where they are the user

3. **CoupleManagement Collection**:
   - Users can read and write couple data where they are either user1 or user2
   - Users can create couple data where they are either user1 or user2

These rules ensure proper data isolation and security for all app features, including the mood tracker functionality.