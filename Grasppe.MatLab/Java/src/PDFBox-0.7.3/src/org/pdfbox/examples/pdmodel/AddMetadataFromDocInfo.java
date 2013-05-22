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
import org.pdfbox.pdmodel.PDDocumentCatalog;
import org.pdfbox.pdmodel.PDDocumentInformation;
import org.pdfbox.pdmodel.common.PDMetadata;
import org.pdfbox.util.DateConverter;

import java.io.ByteArrayInputStream;
import java.util.Calendar;
import java.util.GregorianCalendar;

/**
 * This is an example on how to add metadata to a document.
 *
 * Usage: java org.pdfbox.examples.pdmodel.AddMetadataToDocument &lt;input-pdf&gt; &lt;output-pdf&gt;
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.3 $
 */
public class AddMetadataFromDocInfo
{
    private static final String PADDING = 
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          " +
        "                                                                                          ";
        
        
    
    private AddMetadataFromDocInfo()
    {
        //utility class
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
                if( document.isEncrypted() )
                {
                    System.err.println( "Error: Cannot add metadata to encrypted document." );
                    System.exit( 1 );
                }
                PDDocumentCatalog catalog = document.getDocumentCatalog();
                PDDocumentInformation info = document.getDocumentInformation();
                
                //Right now, PDFBox does not have any XMP library, so we will
                //just consruct the XML by hand.
                StringBuffer xmp= new StringBuffer();
                xmp.append(
                "<?xpacket begin='﻿' id='W5M0MpCehiHzreSzNTczkc9d'?>\n" + 
                "<?adobe-xap-filters esc=\"CRLF\"?>\n" + 
                "<x:xmpmeta>\n" + 
                "    <rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>\n" + 
                "        <rdf:Description rdf:about='' xmlns:pdf='http://ns.adobe.com/pdf/1.3/' " +
                                         "pdf:Keywords='" + fixNull( info.getKeywords() ) + "' " + 
                                         "pdf:Producer='" + fixNull( info.getProducer() ) + "'></rdf:Description>\n" + 
                "        <rdf:Description rdf:about='' xmlns:xap='http://ns.adobe.com/xap/1.0/' " + 
                                         "xap:ModifyDate='" + fixNull( info.getModificationDate() ) + "' " +
                                         "xap:CreateDate='" + fixNull( info.getCreationDate() ) + "' " + 
                                         "xap:CreatorTool='" + fixNull( info.getCreator() ) + "' " + 
                                         "xap:MetadataDate='" + fixNull( new GregorianCalendar() )+ "'>\n" + 
                "        </rdf:Description>\n" + 
                "        <rdf:Description rdf:about='' xmlns:dc='http://purl.org/dc/elements/1.1/' " + 
                                         "dc:format='application/pdf'>\n" + 
                "            <dc:title>\n" + 
                "                <rdf:Alt>\n" + 
                "                    <rdf:li xml:lang='x-default'>" + fixNull( info.getTitle() ) +"</rdf:li>\n" + 
                "                </rdf:Alt>\n" + 
                "            </dc:title>\n" + 
                "            <dc:creator>\n" + 
                "                <rdf:Seq>\n" + 
                "                    <rdf:li>PDFBox.org</rdf:li>\n" + 
                "                </rdf:Seq>\n" + 
                "            </dc:creator>\n" + 
                "            <dc:description>\n" + 
                "                <rdf:Alt>\n" + 
                "                    <rdf:li xml:lang='x-default'>" + fixNull( info.getSubject() ) +"</rdf:li>\n" + 
                "                </rdf:Alt>\n" + 
                "            </dc:description>\n" + 
                "        </rdf:Description>\n" + 
                "    </rdf:RDF>\n" + 
                "</x:xmpmeta>\n" );
                
                //xmp spec says we should put padding, so that the metadata can be appended to 
                //in place
                xmp.append( PADDING );
                xmp.append( PADDING );
                xmp.append( PADDING );
                xmp.append( "\n<?xpacket end='w'?>" );
                ByteArrayInputStream mdInput = new ByteArrayInputStream( xmp.toString().getBytes() );
                PDMetadata metadataStream = new PDMetadata(document, mdInput, false );
                catalog.setMetadata( metadataStream );
                
                
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
    
    private static String fixNull( String string )
    {
        return string == null ? "" : string;
    }
    
    private static String fixNull( Calendar cal )
    {
        return cal == null ? "" : DateConverter.toISO8601( cal );
    }

    /**
     * This will print the usage for this document.
     */
    private static void usage()
    {
        System.err.println( "Usage: java org.pdfbox.examples.pdmodel.AddMetadata <input-pdf> <output-pdf>" );
    }
}