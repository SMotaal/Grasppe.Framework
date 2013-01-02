import java.util.prefs.Preferences
import java.io.File


/** Note that this assumes we are using the console corresponding to the final
*  entry in controllers
**/
def controllers=groovy.ui.Console.getConsoleControllers()
def console=controllers.get(controllers.size()-1)
def ldr=console.getShell().getClassLoader()


/*****************************************************
*
* Set the path to the Waterloo installation here based on the
* location of this script
*
******************************************************/
String fileSep=File.separator
String PathToWaterloo=console.currentFileChooserDir
PathToWaterloo=PathToWaterloo + fileSep + '..' + fileSep


File f1=new File(PathToWaterloo + '/Waterloo_Java_Library/GraphExplorer/dist/GraphExplorer.jar')
Preferences.userNodeForPackage(groovy.ui.Console).put('currentClasspathJarDir', f1.getPath())
ldr.addURL(f1.toURL());

