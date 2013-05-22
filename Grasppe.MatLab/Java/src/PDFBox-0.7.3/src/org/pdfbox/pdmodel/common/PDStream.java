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
package org.pdfbox.pdmodel.common;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.pdfbox.cos.COSArray;
import org.pdfbox.cos.COSBase;
import org.pdfbox.cos.COSDictionary;
import org.pdfbox.cos.COSName;
import org.pdfbox.cos.COSStream;

import org.pdfbox.filter.Filter;
import org.pdfbox.filter.FilterManager;

import org.pdfbox.pdmodel.PDDocument;

import org.pdfbox.pdmodel.common.filespecification.PDFileSpecification;

/**
 * A PDStream represents a stream in a PDF document.  Streams are tied to a single
 * PDF document.
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.16 $
 */
public class PDStream implements COSObjectable
{
    private COSStream stream;
    
    /**
     * This will create a new PDStream object.
     */
    protected PDStream()
    {
        //should only be called by PDMemoryStream
    }
    
    /**
     * This will create a new PDStream object.
     * 
     * @param document The document that the stream will be part of.
     */
    public PDStream( PDDocument document )
    {
        stream = new COSStream( document.getDocument().getScratchFile() );
    }
    
    /**
     * Constructor.
     *
     * @param str The stream parameter.
     */
    public PDStream( COSStream str )
    {
        stream = str;
    }
    
    /**
     * Constructor.  Reads all data from the input stream and embeds it into the
     * document, this will close the InputStream.
     *
     * @param doc The document that will hold the stream.
     * @param str The stream parameter.
     * @throws IOException If there is an error creating the stream in the document.
     */
    public PDStream( PDDocument doc, InputStream str ) throws IOException
    {
        this( doc, str, false );
    }
    
    /**
     * Constructor.  Reads all data from the input stream and embeds it into the
     * document, this will close the InputStream.
     *
     * @param doc The document that will hold the stream.
     * @param str The stream parameter.
     * @param filtered True if the stream already has a filter applied.
     * @throws IOException If there is an error creating the stream in the document.
     */
    public PDStream( PDDocument doc, InputStream str, boolean filtered ) throws IOException
    {
        OutputStream output = null;
        try
        {
            stream = new COSStream( doc.getDocument().getScratchFile() );
            if( filtered )
            {
                output = stream.createFilteredStream();
            }
            else
            {
                output = stream.createUnfilteredStream();
            }
            byte[] buffer = new byte[ 1024 ];
            int amountRead = -1;
            while( (amountRead = str.read(buffer)) != -1 )
            {
                output.write( buffer, 0, amountRead );
            }
        }
        finally
        {
            if( output != null )
            {
                output.close();
            }
            if( str != null )
            {
                str.close();
            }
        }
    }
    
    /**
     * If there are not compression filters on the current stream then this
     * will add a compression filter, flate compression for example.
     */
    public void addCompression()
    {
        List filters = getFilters();
        if( filters == null )
        {
            filters = new ArrayList();
            filters.add( COSName.FLATE_DECODE );
            setFilters( filters );
        }
    }
    
    /**
     * Create a pd stream from either a regular COSStream on a COSArray of cos streams.
     * @param base Either a COSStream or COSArray.
     * @return A PDStream or null if base is null.
     * @throws IOException If there is an error creating the PDStream.
     */
    public static PDStream createFromCOS( COSBase base ) throws IOException
    {
        PDStream retval = null;
        if( base instanceof COSStream )
        {
            retval = new PDStream( (COSStream)base );
        }
        else if( base instanceof COSArray )
        {
            retval = new PDStream( new COSStreamArray( (COSArray)base ) );
        }
        else
        {
            if( base != null )
            {
                throw new IOException( "Contents are unknown type:" + base.getClass().getName() );
            }
        }
        return retval;
    }


    /**
     * Convert this standard java object to a COS object.
     *
     * @return The cos object that matches this Java object.
     */
    public COSBase getCOSObject()
    {
        return stream;
    }
    
    /**
     * This will get a stream that can be written to.
     * 
     * @return An output stream to write data to.
     * 
     * @throws IOException If an IO error occurs during writing.
     */
    public OutputStream createOutputStream() throws IOException
    {
        return stream.createUnfilteredStream();
    }
    
    /**
     * This will get a stream that can be read from.
     * 
     * @return An input stream that can be read from.
     * 
     * @throws IOException If an IO error occurs during reading.
     */
    public InputStream createInputStream() throws IOException
    {
        return stream.getUnfilteredStream();
    }
    
    /**
     * This will get a stream with some filters applied but not others.  This is useful
     * when doing images, ie filters = [flate,dct], we want to remove flate but leave dct
     * 
     * @param stopFilters A list of filters to stop decoding at.
     * @return A stream with decoded data.
     * @throws IOException If there is an error processing the stream.
     */
    public InputStream getPartiallyFilteredStream( List stopFilters ) throws IOException
    {
        FilterManager manager = stream.getFilterManager();
        InputStream is = stream.getFilteredStream();
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        List filters = getFilters();
        Iterator iter = filters.iterator();
        String nextFilter = null;
        boolean done = false;
        while( iter.hasNext() && !done )
        {
            os.reset();
            nextFilter = (String)iter.next();
            if( stopFilters.contains( nextFilter ) )
            {
                done = true;
            }
            else
            {
                Filter filter = manager.getFilter( COSName.getPDFName(nextFilter) );
                filter.decode( is, os, stream );
                is = new ByteArrayInputStream( os.toByteArray() );
            }
        }
        return is;
    }
    
    /**
     * Get the cos stream associated with this object.
     *
     * @return The cos object that matches this Java object.
     */
    public COSStream getStream()
    {
        return stream;
    }
    
    /**
     * This will get the length of the filtered/compressed stream.  This is readonly in the 
     * PD Model and will be managed by this class.
     * 
     * @return The length of the filtered stream.
     */
    public int getLength()
    {
        return stream.getInt( "Length", 0 );
    }
    
    /**
     * This will get the list of filters that are associated with this stream.  Or
     * null if there are none.
     * @return A list of all encoding filters to apply to this stream.
     */
    public List getFilters()
    {
        List retval = null;
        COSBase filters = stream.getFilters();
        if( filters instanceof COSName )
        {
            COSName name = (COSName)filters;
            retval = new COSArrayList( name.getName(), name, stream, "Filter" );
        }
        else if( filters instanceof COSArray )
        {
            retval = COSArrayList.convertCOSNameCOSArrayToList( (COSArray)filters );
        }
        return retval;
    }
    
    /**
     * This will set the filters that are part of this stream.
     * 
     * @param filters The filters that are part of this stream.
     */
    public void setFilters( List filters )
    {
        COSBase obj = COSArrayList.convertStringListToCOSNameCOSArray( filters );
        stream.setItem( "Filter", obj );
    }
    
    /**
     * Get the list of decode parameters.  Each entry in the list will refer to 
     * an entry in the filters list.
     * 
     * @return The list of decode parameters.
     * 
     * @throws IOException if there is an error retrieving the parameters.
     */
    public List getDecodeParams() throws IOException
    {
        List retval = null;
        
        COSBase dp = stream.getDictionaryObject( "DecodeParms" );
        if( dp == null )
        {
            //See PDF Ref 1.5 implementation note 7, the DP is sometimes used instead.
            dp = stream.getDictionaryObject( "DP" );
        }
        if( dp instanceof COSDictionary )
        {
            Map map = COSDictionaryMap.convertBasicTypesToMap( (COSDictionary)dp );
            retval = new COSArrayList(map, dp, stream, "DecodeParams" );
        }
        else if( dp instanceof COSArray )
        {
            COSArray array = (COSArray)dp;
            List actuals = new ArrayList();
            for( int i=0; i<array.size(); i++ )
            {
                actuals.add( 
                    COSDictionaryMap.convertBasicTypesToMap( 
                        (COSDictionary)array.getObject( i ) ) );
            }
            retval = new COSArrayList(actuals, array);
        }
        
        return retval;
    }
    
    /**
     * This will set the list of decode params.
     * 
     * @param decodeParams The list of decode params.
     */
    public void setDecodeParams( List decodeParams )
    {
        stream.setItem(
            "DecodeParams", COSArrayList.converterToCOSArray( decodeParams ) );
    }
    
    /**
     * This will get the file specification for this stream.  This is only
     * required for external files.
     * 
     * @return The file specification.
     * 
     * @throws IOException If there is an error creating the file spec.
     */
    public PDFileSpecification getFile() throws IOException
    {
        COSBase f = stream.getDictionaryObject( "F" );
        PDFileSpecification retval = PDFileSpecification.createFS( f );
        return retval;
    }
    
    /**
     * Set the file specification.
     * @param f The file specification.
     */
    public void setFile( PDFileSpecification f )
    {
        stream.setItem( "F", f );
    }
    
    /**
     * This will get the list of filters that are associated with this stream.  Or
     * null if there are none.
     * @return A list of all encoding filters to apply to this stream.
     */
    public List getFileFilters()
    {
        List retval = null;
        COSBase filters = stream.getDictionaryObject( "FFilter" );
        if( filters instanceof COSName )
        {
            COSName name = (COSName)filters;
            retval = new COSArrayList( name.getName(), name, stream, "FFilter" );
        }
        else if( filters instanceof COSArray )
        {
            retval = COSArrayList.convertCOSNameCOSArrayToList( (COSArray)filters );
        }
        return retval;
    }
    
    /**
     * This will set the filters that are part of this stream.
     * 
     * @param filters The filters that are part of this stream.
     */
    public void setFileFilters( List filters )
    {
        COSBase obj = COSArrayList.convertStringListToCOSNameCOSArray( filters );
        stream.setItem( "FFilter", obj );
    }
    
    /**
     * Get the list of decode parameters.  Each entry in the list will refer to 
     * an entry in the filters list.
     * 
     * @return The list of decode parameters.
     * 
     * @throws IOException if there is an error retrieving the parameters.
     */
    public List getFileDecodeParams() throws IOException
    {
        List retval = null;
        
        COSBase dp = stream.getDictionaryObject( "FDecodeParms" );
        if( dp instanceof COSDictionary )
        {
            Map map = COSDictionaryMap.convertBasicTypesToMap( (COSDictionary)dp );
            retval = new COSArrayList(map, dp, stream, "FDecodeParams" );
        }
        else if( dp instanceof COSArray )
        {
            COSArray array = (COSArray)dp;
            List actuals = new ArrayList();
            for( int i=0; i<array.size(); i++ )
            {
                actuals.add( 
                    COSDictionaryMap.convertBasicTypesToMap( 
                        (COSDictionary)array.getObject( i ) ) );
            }
            retval = new COSArrayList(actuals, array);
        }
        
        return retval;
    }
    
    /**
     * This will set the list of decode params.
     * 
     * @param decodeParams The list of decode params.
     */
    public void setFileDecodeParams( List decodeParams )
    {
        stream.setItem(
            "FDecodeParams", COSArrayList.converterToCOSArray( decodeParams ) );
    }
    
    /**
     * This will copy the stream into a byte array. 
     * 
     * @return The byte array of the filteredStream
     * @throws IOException When getFilteredStream did not work
     */
    public byte[] getByteArray() throws IOException
    {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buf = new byte[1024];
        InputStream is = null;
        try
        {
            is = createInputStream();
            int amountRead = -1;
            while( (amountRead = is.read( buf )) != -1)
            {
                output.write( buf, 0, amountRead );
            }
        }
        finally
        {
            if( is != null )
            {
                is.close();
            }
        }
        return output.toByteArray();
    }
    
    /**
     * A convenience method to get this stream as a string.  Uses
     * the default system encoding. 
     * 
     * @return a String representation of this (input) stream, with the
     * platform default encoding.
     * 
     * @throws IOException if there is an error while converting the stream 
     *                     to a string.
     */
    public String getInputStreamAsString() throws IOException 
    {
        byte[] bStream = getByteArray();
        return new String(bStream);
    }
    
    /**
     * Get the metadata that is part of the document catalog.  This will 
     * return null if there is no meta data for this object.
     * 
     * @return The metadata for this object.
     */
    public PDMetadata getMetadata()
    {
        PDMetadata retval = null;
        COSStream mdStream = (COSStream)stream.getDictionaryObject( "Metadata" );
        if( mdStream != null )
        {
            retval = new PDMetadata( mdStream );
        }
        return retval;
    }
    
    /**
     * Set the metadata for this object.  This can be null.
     * 
     * @param meta The meta data for this object.
     */
    public void setMetadata( PDMetadata meta )
    {
        stream.setItem( "Metadata", meta );
    }
}