Waterloo Swing Library

The Waterloo Swing Library is part of a larger suite - Project Waterloo.
To allow this snapshot to be upgraded easily, ensure they are in a parent folder named "waterloo". Place this folder (with subfolders) on your MATLAB path and it's ready to run. 


----------------------- INSTALLATION-----------------------
To install, place the waterloo folder  on your MATLAB path.

In each MATLAB session, run "waterloo" at the MATLAB prompt. This sets up the MATLAB path and, where appropriate, the java class path.
[The full project is large so this stops your MATLAB path being extended, and searches slowed, when you do not need waterloo].

To use the library from your own code, just include a call to waterloo() in it to set up the path.
-----------------------------DEMO--------------------------
For a demo of the features, just type waterloodemo() at the MATLAB prompt.


COMPATIBILITY
The library is expected to grow and change but backwards compatibility will be maintained through the class methods. For best results, use those rather than accessing properties directly even if they are public.

Some files in this library have dependencies on the following
components/functions from Project Waterloo. 
    isMutipleCall
    jcontrol*
    MouseMotionHandler*
    MUtils*
	MUtilities*
	LookAndFeel*
* For smooth running, you should ensure that you have only one copy of these classes. If you have earlier versions installed separately, just delete them.
Note that MUtils and its subclasses have some dependencies on the kcl.jar file in Project Waterloo for some of their methods. However, none of these static methods are called by the Swing Library so this will not be a problem.

Two classes have dependencies on the SwingLabs SwingX extensions:
GTaskPaneContainer
GSideBar

SwingX can be downloaded from
http://swingx.java.net/
Just add the jar file(s) to your MATLAB classpath using javaaddpath 

Note the the LookAndFeel class is included here only to prevent broken links when MATLAB parses some of the other classes. LookAndFeel is not intended for use.

ML
09.2011
sigtool@kcl.ac.uk