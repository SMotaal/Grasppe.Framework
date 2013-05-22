/**
 * Copyright (c) 2004-2005, www.pdfbox.org
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
package org.pdfbox.pdmodel.fdf;

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Writer;

import org.pdfbox.cos.COSDictionary;
import org.pdfbox.cos.COSDocument;
import org.pdfbox.cos.COSName;

import org.pdfbox.exceptions.COSVisitorException;

import org.pdfbox.pdfparser.PDFParser;

import org.pdfbox.pdfwriter.COSWriter;

import org.pdfbox.util.XMLUtil;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * This is the in-memory representation of the FDF document.  You need to call
 * close() on this object when you are done using it!!
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.6 $
 */
public class FDFDocument
{
    private COSDocument document;

    /**
     * Constructor, creates a new FDF document.
     *
     * @throws IOException If there is an error creating this document.
     */
    public FDFDocument() throws IOException
    {
        document = new COSDocument();
        document.setHeaderString( "%FDF-1.2" );

        //First we need a trailer
        document.setTrailer( new COSDictionary() );

        //Next we need the root dictionary.
        FDFCatalog catalog = new FDFCatalog();
        setCatalog( catalog );
    }

    /**
     * Constructor that uses an existing document.  The COSDocument that
     * is passed in must be valid.
     *
     * @param doc The COSDocument that this document wraps.
     */
    public FDFDocument( COSDocument doc )
    {
        document = doc;
    }
    
    /**
     * This will create an FDF document from an XFDF XML document.
     * 
     * @param doc The XML document that contains the XFDF data.
     * @throws IOException If there is an error reading from the dom.
     */
    public FDFDocument( Document doc ) throws IOException
    {
        this();
        Element xfdf = doc.getDocumentElement();
        if( !xfdf.getNodeName().equals( "xfdf" ) )
        {
            throw new IOException( "Error while importing xfdf document, " + 
                "root should be 'xfdf' and not '" + xfdf.getNodeName() + "'" );
        }
        FDFCatalog cat = new FDFCatalog( xfdf );
        setCatalog( cat );
    }
    
    /**
     * This will write this element as an XML document.
     * 
     * @param output The stream to write the xml to.
     * 
     * @throws IOException If there is an error writing the XML.
     */
    public void writeXML( Writer output ) throws IOException
    {
        output.write( "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" );
        output.write( "<xfdf xmlns=\"http://ns.adobe.com/xfdf/\" xml:space=\"preserve\">\n" );
            
        getCatalog().writeXML( output );
    
        output.write( "</xfdf>\n" );
    }
    
    

    /**
     * This will get the low level document.
     *
     * @return The document that this layer sits on top of.
     */
    public COSDocument getDocument()
    {
        return document;
    }

    /**
     * This will get the FDF Catalog.  This is guaranteed to not return null.
     *
     * @return The documents /Root dictionary
     */
    public FDFCatalog getCatalog()
    {
        FDFCatalog retval = null;
        COSDictionary trailer = document.getTrailer();
        COSDictionary root = (COSDictionary)trailer.getDictionaryObject( COSName.ROOT );
        if( root == null )
        {
            retval = new FDFCatalog();
            setCatalog( retval );
        }
        else
        {
            retval = new FDFCatalog( root );
        }
        return retval;
    }

    /**
     * This will set the FDF catalog for this FDF document.
     *
     * @param cat The FDF catalog.
     */
    public void setCatalog( FDFCatalog cat )
    {
        COSDictionary trailer = document.getTrailer();
        trailer.setItem( COSName.ROOT, cat );
    }

    /**
     * This will load a document from a file.
     *
     * @param filename The name of the file to load.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static FDFDocument load( String filename ) throws IOException
    {
        return load( new BufferedInputStream( new FileInputStream( filename ) ) );
    }

    /**
     * This will load a document from a file.
     *
     * @param file The name of the file to load.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static FDFDocument load( File file ) throws IOException
    {
        return load( new BufferedInputStream( new FileInputStream( file ) ) );
    }

    /**
     * This will load a document from an input stream.
     *
     * @param input The stream that contains the document.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static FDFDocument load( InputStream input ) throws IOException
    {
        PDFParser parser = new PDFParser( input );
        parser.parse();
        return parser.getFDFDocument();
    }
    
    /**
     * This will load a document from a file.
     *
     * @param filename The name of the file to load.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static FDFDocument loadXFDF( String filename ) throws IOException
    {
        return loadXFDF( new BufferedInputStream( new FileInputStream( filename ) ) );
    }

    /**
     * This will load a document from a file.
     *
     * @param file The name of the file to load.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static FDFDocument loadXFDF( File file ) throws IOException
    {
        return loadXFDF( new BufferedInputStream( new FileInputStream( file ) ) );
    }

    /**
     * This will load a document from an input stream.
     *
     * @param input The stream that contains the document.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static FDFDocument loadXFDF( InputStream input ) throws IOException
    {
        Document doc = XMLUtil.parse( input );
        return new FDFDocument( doc );
    }
    
    /**
     * This will save this document to the filesystem.
     *
     * @param fileName The file to save as.
     *
     * @throws IOException If there is an error saving the document.
     * @throws COSVisitorException If an error occurs while generating the data.
     */
    public void save( File fileName ) throws IOException, COSVisitorException
    {
        save( new FileOutputStream( fileName ) );
    }

    /**
     * This will save this document to the filesystem.
     *
     * @param fileName The file to save as.
     *
     * @throws IOException If there is an error saving the document.
     * @throws COSVisitorException If an error occurs while generating the data.
     */
    public void save( String fileName ) throws IOException, COSVisitorException
    {
        save( new FileOutputStream( fileName ) );
    }

    /**
     * This will save the document to an output stream.
     *
     * @param output The stream to write to.
     *
     * @throws IOException If there is an error writing the document.
     * @throws COSVisitorException If an error occurs while generating the data.
     */
    public void save( OutputStream output ) throws IOException, COSVisitorException
    {
        COSWriter writer = null;
        try
        {
            writer = new COSWriter( output );
            writer.write( document );
            writer.close();
        }
        finally
        {
            if( writer != null )
            {
                writer.close();
            }
        }
    }
    
    /**
     * This will save this document to the filesystem.
     *
     * @param fileName The file to save as.
     *
     * @throws IOException If there is an error saving the document.
     * @throws COSVisitorException If an error occurs while generating the data.
     */
    public void saveXFDF( File fileName ) throws IOException, COSVisitorException
    {
        saveXFDF( new BufferedWriter( new FileWriter( fileName ) ) );
    }

    /**
     * This will save this document to the filesystem.
     *
     * @param fileName The file to save as.
     *
     * @throws IOException If there is an error saving the document.
     * @throws COSVisitorException If an error occurs while generating the data.
     */
    public void saveXFDF( String fileName ) throws IOException, COSVisitorException
    {
        saveXFDF( new BufferedWriter( new FileWriter( fileName ) ) );
    }

    /**
     * This will save the document to an output stream and close the stream.
     *
     * @param output The stream to write to.
     *
     * @throws IOException If there is an error writing the document.
     * @throws COSVisitorException If an error occurs while generating the data.
     */
    public void saveXFDF( Writer output ) throws IOException, COSVisitorException
    {
        try
        {
            writeXML( output );
        }
        finally
        {
            if( output != null )
            {
                output.close();
            }
        }
    }

    /**
     * This will close the underlying COSDocument object.
     *
     * @throws IOException If there is an error releasing resources.
     */
    public void close() throws IOException
    {
        document.close();
    }
}