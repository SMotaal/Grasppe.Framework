/**
 * Copyright (c) 2004, www.pdfbox.org
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of pdfbox; nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * http://www.pdfbox.org
 *
 */
package org.pdfbox.examples.pdmodel;

import java.awt.Color;
import java.io.IOException;

import org.pdfbox.exceptions.COSVisitorException;

import org.pdfbox.pdmodel.PDDocument;
import org.pdfbox.pdmodel.PDPage;

import org.pdfbox.pdmodel.edit.PDPageContentStream;

/**
 * This is an example that creates a simple document.
 *
 * The example is taken from the pdf file format specification.
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.2 $
 */
public class ShowColorBoxes
{
    /**
     * Constructor.
     */
    public ShowColorBoxes()
    {
        super();
    }

    /**
     * create the second sample document from the PDF file format specification.
     *
     * @param file The file to write the PDF to.
     *
     * @throws IOException If there is an error writing the data.
     * @throws COSVisitorException If there is an error writing the PDF.
     */
    public void doIt( String file) throws IOException, COSVisitorException
    {
        // the document
        PDDocument doc = null;
        try
        {
            doc = new PDDocument();
            
            PDPage page = new PDPage();
            doc.addPage( page );
            
            PDPageContentStream contentStream = new PDPageContentStream(doc, page);
            //first fill the entire background with cyan
            contentStream.setNonStrokingColor( Color.CYAN );
            contentStream.fillRect( 0,0, page.findMediaBox().getWidth(), page.findMediaBox().getHeight() );
            
            //then draw a red box in the lower left hand corner
            contentStream.setNonStrokingColor( Color.RED );
            contentStream.fillRect( 10, 10, 100, 100 );
            
            contentStream.close();
            doc.save( file );
        }
        finally
        {
            if( doc != null )
            {
                doc.close();
            }
        }
    }

    /**
     * This will create a hello world PDF document.
     * <br />
     * see usage() for commandline
     *
     * @param args Command line arguments.
     */
    public static void main(String[] args)
    {
        ShowColorBoxes app = new ShowColorBoxes();
        try
        {
            if( args.length != 1 )
            {
                app.usage();
            }
            else
            {
                app.doIt( args[0] );
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    /**
     * This will print out a message telling how to use this example.
     */
    private void usage()
    {
        System.err.println( "usage: " + this.getClass().getName() + " <output-file>" );
    }
}