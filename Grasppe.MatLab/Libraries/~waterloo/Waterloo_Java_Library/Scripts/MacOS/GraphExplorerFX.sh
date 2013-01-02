SCRIPT=$0
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:"/Users/ML/javafx-sdk2.2.0-beta/rt/lib"
java -jar  -Dapple.awt.graphics.UseQuartz="true" -Djavafx.location=/Users/ML/Documents/javafx-sdk2.2.0-beta/rt/lib -Xdock:name="GraphExplorerFX" "$SCRIPT/../../../GraphExplorerFX/dist/GraphExplorerFX.jar"