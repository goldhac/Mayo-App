@echo off
cd c:\Users\goldn\Documents\Mayo App\mayo\android
echo Running Gradle task to get SHA-1 certificate...
if exist gradlew.bat (
  gradlew.bat signingReport > ..\sha1_gradle_result.txt 2> ..\sha1_gradle_error.txt
) else (
  echo gradlew.bat not found, trying gradle command...
  gradle signingReport > ..\sha1_gradle_result.txt 2> ..\sha1_gradle_error.txt
)
echo Done. Check sha1_gradle_result.txt or sha1_gradle_error.txt for results.