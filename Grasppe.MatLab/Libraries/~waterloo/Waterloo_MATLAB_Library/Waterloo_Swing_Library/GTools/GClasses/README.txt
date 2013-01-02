The Waterloo Swing Library is part of a larger suite - Project Waterloo.
To allow this snapshot to be upgraded easily, ensure they are in a parent folder named "waterloo". Place this folder (with subfolders) on your MATLAB path and it's ready to run. 

For a demo of the features, just type waterloodemo() at the MATLAB prompt.

Some files in this library have dependencies on the following
components/functions from Project Waterloo. These are included in the MATLAB FEX distribution of Waterloo Swing Library. If your copy does not include these, you can get one that does from
http://www.mathworks.com/matlabcentral/fileexchange/authors/23816. 
Dependencies:
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

MATLAB FEX does not allow Java jar files to be included in posts, but SwingX can be downloaded from
http://swingx.java.net/
Just add the jar file(s) to your MATLAB classpath using javaaddpath 
(N.B. This is done for you if using the full Project Waterloo or
sigTOOL distributions).

Note the the LookAndFeel class is included here only to prevent broken links when MATLAB parses some of the other classes. LookAndFeel is not intended for use.

ML
08.2011
