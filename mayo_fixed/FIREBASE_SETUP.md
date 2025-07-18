# Firebase Setup Guide
## Firebase Rules Deployment


The app now includes Firestore and Storage security rules that need to be deployed to your Firebase project. These rules ensure that users can only access their own data, including mood entries and profile pictures.

### Steps to Deploy Firebase Rules

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
   - Select Firestore and Storage when prompted for which Firebase features to set up
   - Select your project (mayo-60118)
   - When asked about the Firestore rules file, use the existing `firestore.rules` file
   - When asked about the Storage rules file, use the existing `storage.rules` file

4. **Deploy Firestore Rules**
   ```
   firebase deploy --only firestore:rules
   ```

5. **Deploy Storage Rules**
   ```
   firebase deploy --only storage:rules
   ```

## Alternative: Deploy Rules via Firebase Console

If you prefer using the Firebase Console:

### For Firestore Rules:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (mayo-60118)
3. Navigate to Firestore Database in the left sidebar
4. Click on the "Rules" tab
5. Copy and paste the contents of the `firestore.rules` file
6. Click "Publish"

### For Storage Rules:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (mayo-60118)
3. Navigate to Storage in the left sidebar
4. Click on the "Rules" tab
5. Copy and paste the contents of the `storage.rules` file
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

## Storage Rules Explanation

The rules in `storage.rules` provide the following permissions:

1. **Profile Pictures**:
   - Any authenticated user can read profile pictures
   - Users can only write (upload) their own profile pictures
   - The file path must match the pattern `/profile_pictures/{userId}_{timestamp}.jpg`

2. **Default Rule**:
   - All other access is denied by default

These rules ensure that users can only upload their own profile pictures while allowing all authenticated users to view profile pictures.