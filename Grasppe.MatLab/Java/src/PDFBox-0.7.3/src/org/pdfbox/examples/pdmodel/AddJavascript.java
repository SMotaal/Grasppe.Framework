/**
 * Copyright (c) 2005, www.pdfbox.org
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

import org.pdfbox.pdmodel.PDDocument;
import org.pdfbox.pdmodel.interactive.action.type.PDActionJavaScript;

import java.io.IOException;

/**
 * This is an example of how to set some javascript in the document.
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.3 $
 */
public class AddJavascript
{
    private AddJavascript()
    {
        //static class, should not be instantiated.
    }
    
    /**
     * This will print the documents data.
     *
     * @param args The command line arguments.
     *
     * @throws Exception If there is an error parsing the document.
     */
    public static void main( String[] args ) throws Exception
    {
        if( args.length != 2 )
        {
            usage();
        }
        else
        {
            PDDocument document = null;
            try
            {
                document = PDDocument.load( args[0] );
                PDActionJavaScript javascript = new PDActionJavaScript( 
                    "app.alert( {cMsg: 'PDFBox rocks!', nIcon: 3, nType: 0, cTitle: 'PDFBox Javascript example' } );");
                document.getDocumentCatalog().setOpenAction( javascript );
                if( document.isEncrypted() )
                {
                    throw new IOException( "Encrypted documents are not supported for this example" );
                }
                document.save( args[1] );
            }
            finally
            {
                if( document != null )
                {
                    document.close();
                }
            }
        }
    }

    /**
     * This will print the usage for this document.
     */
    private static void usage()
    {
        System.err.println( "Usage: java org.pdfbox.examples.pdmodel.AddJavascript <input-pdf> <output-pdf>" );
    }
}