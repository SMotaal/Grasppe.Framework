switch(Sys.info()[['sysname']],
       Windows= {library("rJava")
                 .jinit()
                .jaddClassPath("C:/waterloo/Waterloo_Java_Library/GraphExplorer/dist/GraphExplorer.jar")
       },
       Linux  = {library("rJava")
                 .jinit()},
       Darwin = {print("")
                  print("Note: Waterloo Graphics will work in JGR on the Mac OS but may not work properly in other R environments")
                 print("")
				.jinit(paramaters="-Dapple.awt.graphics.UseQuartz=\"true\"")
                 .jaddClassPath("/Volumes/BOOTCAMP/waterloo/Waterloo_Java_Library/GraphExplorer/dist/GraphExplorer.jar")
                 }
       )
wb=.jnew("kcl.waterloo.explorer.GraphExplorer")
.jcall(wb,,"run")
