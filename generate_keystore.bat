@echo off
echo Generating new debug.keystore file...

"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v -keystore c:\Users\goldn\.android\debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US" > keystore_output.txt 2>&1

echo.
echo Debug keystore generated. Now getting SHA-1 fingerprint...
echo.

"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore c:\Users\goldn\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android >> keystore_output.txt 2>&1

echo.
echo Output saved to keystore_output.txt
echo.
type keystore_output.txt