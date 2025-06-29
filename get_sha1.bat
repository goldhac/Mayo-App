@echo off
"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "c:\Users\goldn\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android > sha1_result.txt 2> sha1_error.txt
echo SHA-1 certificate information has been saved to sha1_result.txt (if successful) or errors in sha1_error.txt