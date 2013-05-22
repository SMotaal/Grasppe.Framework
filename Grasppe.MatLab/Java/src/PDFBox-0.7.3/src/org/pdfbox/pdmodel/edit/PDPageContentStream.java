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
package org.pdfbox.pdmodel.edit;

import java.awt.Color;
import java.awt.color.ColorSpace;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import java.text.NumberFormat;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.HashMap;

import org.pdfbox.pdmodel.PDDocument;
import org.pdfbox.pdmodel.PDPage;
import org.pdfbox.pdmodel.PDResources;

import org.pdfbox.pdmodel.common.COSStreamArray;
import org.pdfbox.pdmodel.common.PDStream;

import org.pdfbox.pdmodel.font.PDFont;
import org.pdfbox.pdmodel.graphics.color.PDColorSpace;
import org.pdfbox.pdmodel.graphics.color.PDDeviceCMYK;
import org.pdfbox.pdmodel.graphics.color.PDDeviceGray;
import org.pdfbox.pdmodel.graphics.color.PDDeviceN;
import org.pdfbox.pdmodel.graphics.color.PDDeviceRGB;
import org.pdfbox.pdmodel.graphics.color.PDICCBased;
import org.pdfbox.pdmodel.graphics.color.PDPattern;
import org.pdfbox.pdmodel.graphics.color.PDSeparation;
import org.pdfbox.pdmodel.graphics.xobject.PDXObjectImage;
import org.pdfbox.util.MapUtil;

import org.pdfbox.cos.COSArray;
import org.pdfbox.cos.COSDictionary;
import org.pdfbox.cos.COSName;
import org.pdfbox.cos.COSString;


/**
 * This class will is a convenience for creating page content streams.  You MUST
 * call close() when you are finished with this object.
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.18 $
 */
public class PDPageContentStream
{
    private PDPage page;
    private OutputStream output;
    private boolean inTextMode = false;
    private Map fontMappings = new HashMap();
    private Map imageMappings = new HashMap();
    private PDResources resources;
    private Map fonts;
    private Map images;
    
    private PDColorSpace currentStrokingColorSpace = new PDDeviceGray();
    private PDColorSpace currentNonStrokingColorSpace = new PDDeviceGray();
    
    //cached storage component for getting color values
    private float[] colorComponents = new float[4];
    
    private NumberFormat formatDecimal = NumberFormat.getNumberInstance( Locale.US );
    
    private static final String BEGIN_TEXT = "BT\n";
    private static final String END_TEXT = "ET\n";
    private static final String SET_FONT = "Tf\n";
    private static final String MOVE_TEXT_POSITION = "Td\n";
    private static final String SHOW_TEXT = "Tj\n";
    
    private static final String SAVE_GRAPHICS_STATE = "q\n";
    private static final String RESTORE_GRAPHICS_STATE = "Q\n";
    private static final String CONCATENATE_MATRIX = "cm\n";
    private static final String XOBJECT_DO = "Do\n";
    private static final String RG_STROKING = "RG\n";
    private static final String RG_NON_STROKING = "rg\n";
    private static final String K_STROKING = "K\n";
    private static final String K_NON_STROKING = "k\n";
    private static final String G_STROKING = "G\n";
    private static final String G_NON_STROKING = "g\n";
    private static final String APPEND_RECTANGLE = "re\n";
    private static final String FILL = "f\n";
    
    private static final String SET_STROKING_COLORSPACE = "CS\n";
    private static final String SET_NON_STROKING_COLORSPACE = "cs\n";
    
    private static final String SET_STROKING_COLOR_SIMPLE="SC\n";
    private static final String SET_STROKING_COLOR_COMPLEX="SCN\n";
    private static final String SET_NON_STROKING_COLOR_SIMPLE="sc\n";
    private static final String SET_NON_STROKING_COLOR_COMPLEX="scn\n";
    
    
    
    private static final int SPACE = 32;
    
    
    /**
     * Create a new PDPage content stream.
     * 
     * @param document The document the page is part of.
     * @param sourcePage The page to write the contents to.
     * @throws IOException If there is an error writing to the page contents.
     */
    public PDPageContentStream( PDDocument document, PDPage sourcePage ) throws IOException
    {
        this(document,sourcePage,false,true);
    }
    
    /**
     * Create a new PDPage content stream.
     * 
     * @param document The document the page is part of.
     * @param sourcePage The page to write the contents to.
     * @param appendContent Indicates whether content will be overwritten. If false all previous content is deleted.
     * @param compress Tell if the content stream should compress the page contents.
     * @throws IOException If there is an error writing to the page contents.
     */
    public PDPageContentStream( PDDocument document, PDPage sourcePage, boolean appendContent, boolean compress ) 
        throws IOException
    {
        page = sourcePage;
        resources = page.getResources();
        if( resources == null )
        {
            resources = new PDResources();
            page.setResources( resources );
        }
        fonts = resources.getFonts();
        images = resources.getImages();
        // If request specifies the need to append to the document
        if(appendContent)
        {
            // Get the pdstream from the source page instead of creating a new one
            PDStream contents = sourcePage.getContents();
            
            // Create a pdstream to append new content 
            PDStream contentsToAppend = new PDStream( document );
            
            // This will be the resulting COSStreamArray after existing and new streams are merged
            COSStreamArray compoundStream = null;
            
            // If contents is already an array, a new stream is simply appended to it
            if(contents.getStream() instanceof COSStreamArray)
            {
                compoundStream = (COSStreamArray)contents.getStream();
                compoundStream.appendStream( contentsToAppend.getStream());
            }
            else
            {
                // Creates the COSStreamArray and adds the current stream plus a new one to it 
                COSArray newArray = new COSArray();
                newArray.add(contents.getCOSObject());
                newArray.add(contentsToAppend.getCOSObject());
                compoundStream = new COSStreamArray(newArray);                
            }
            
            if( compress )
            {
                List filters = new ArrayList();
                filters.add( COSName.FLATE_DECODE );
                contentsToAppend.setFilters( filters );
            }
            
            // Sets the compoundStream as page contents 
            sourcePage.setContents( new PDStream(compoundStream) );
            output = contentsToAppend.createOutputStream();
        }
        else
        {        
            PDStream contents = new PDStream( document );
            if( compress )
            {
                List filters = new ArrayList();
                filters.add( COSName.FLATE_DECODE );
                contents.setFilters( filters );
            }
            sourcePage.setContents( contents );
            output = contents.createOutputStream();            
        }
        formatDecimal.setMaximumFractionDigits( 10 );
        formatDecimal.setGroupingUsed( false );
    }
    
    /**
     * Begin some text operations.
     * 
     * @throws IOException If there is an error writing to the stream or if you attempt to 
     *         nest beginText calls.
     */
    public void beginText() throws IOException
    {
        if( inTextMode )
        {
            throw new IOException( "Error: Nested beginText() calls are not allowed." );
        }
        appendRawCommands( BEGIN_TEXT );
        inTextMode = true;
    }
    
    /**
     * End some text operations.
     * 
     * @throws IOException If there is an error writing to the stream or if you attempt to 
     *         nest endText calls.
     */
    public void endText() throws IOException
    {
        if( !inTextMode )
        {
            throw new IOException( "Error: You must call beginText() before calling endText." );
        }
        appendRawCommands( END_TEXT );
        inTextMode = false;
    }
    
    /**
     * Set the font to draw text with.
     * 
     * @param font The font to use.
     * @param fontSize The font size to draw the text.
     * @throws IOException If there is an error writing the font information.
     */
    public void setFont( PDFont font, float fontSize ) throws IOException
    {
        String fontMapping = (String)fontMappings.get( font );
        if( fontMapping == null )
        {
            fontMapping = MapUtil.getNextUniqueKey( fonts, "F" );
            fontMappings.put( font, fontMapping );
            fonts.put( fontMapping, font );
        }
        appendRawCommands( "/");
        appendRawCommands( fontMapping );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( fontSize ) );
        appendRawCommands( SPACE );
        appendRawCommands( SET_FONT );        
    }
    
    /**
     * Draw an image at the x,y coordinates, with the default size of the image.
     * 
     * @param image The image to draw.
     * @param x The x-coordinate to draw the image.
     * @param y The y-coordinate to draw the image.
     * 
     * @throws IOException If there is an error writing to the stream.
     */
    public void drawImage( PDXObjectImage image, float x, float y ) throws IOException
    {
        drawImage( image, x, y, image.getWidth(), image.getHeight() );
    }
    
    /**
     * Draw an image at the x,y coordinates and a certain width and height.
     * 
     * @param image The image to draw.
     * @param x The x-coordinate to draw the image.
     * @param y The y-coordinate to draw the image.
     * @param width The width of the image to draw.
     * @param height The height of the image to draw.
     * 
     * @throws IOException If there is an error writing to the stream.
     */
    public void drawImage( PDXObjectImage image, float x, float y, float width, float height ) throws IOException
    {
        String imageMapping = (String)imageMappings.get( image );
        if( imageMapping == null )
        {
            imageMapping = MapUtil.getNextUniqueKey( images, "Im" );
            imageMappings.put( image, imageMapping );
            images.put( imageMapping, image );
        }
        appendRawCommands( SAVE_GRAPHICS_STATE );
        appendRawCommands( formatDecimal.format( width ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( 0 ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( 0 ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( height ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( x ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( y ) );
        appendRawCommands( SPACE );
        appendRawCommands( CONCATENATE_MATRIX );
        appendRawCommands( SPACE );
        appendRawCommands( "/" );
        appendRawCommands( imageMapping );
        appendRawCommands( SPACE );
        appendRawCommands( XOBJECT_DO );
        appendRawCommands( SPACE );
        appendRawCommands( RESTORE_GRAPHICS_STATE ); 
    }
    
    /**
     * The Td operator.
     * @param x The x coordinate.
     * @param y The y coordinate.
     * @throws IOException If there is an error writing to the stream.
     */
    public void moveTextPositionByAmount( float x, float y ) throws IOException
    {
        if( !inTextMode )
        {
            throw new IOException( "Error: must call beginText() before moveTextPositionByAmount");
        }
        appendRawCommands( formatDecimal.format( x ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( y ) );
        appendRawCommands( SPACE );
        appendRawCommands( MOVE_TEXT_POSITION );
    }
    
    /**
     * This will draw a string at the current location on the screen.
     * 
     * @param text The text to draw.
     * @throws IOException If an io exception occurs.
     */
    public void drawString( String text ) throws IOException
    {
        if( !inTextMode )
        {
            throw new IOException( "Error: must call beginText() before drawString");
        }
        COSString string = new COSString( text );
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        string.writePDF( buffer );
        appendRawCommands( new String( buffer.toByteArray(), "ISO-8859-1"));
        appendRawCommands( SPACE );
        appendRawCommands( SHOW_TEXT );
    }
    
    /**
     * Set the stroking color space.  This will add the colorspace to the PDResources
     * if necessary.
     * 
     * @param colorSpace The colorspace to write.
     * @throws IOException If there is an error writing the colorspace.
     */
    public void setStrokingColorSpace( PDColorSpace colorSpace ) throws IOException
    {
        writeColorSpace( colorSpace );
        appendRawCommands( SET_STROKING_COLORSPACE );
    }
    
    /**
     * Set the stroking color space.  This will add the colorspace to the PDResources
     * if necessary.
     * 
     * @param colorSpace The colorspace to write.
     * @throws IOException If there is an error writing the colorspace.
     */
    public void setNonStrokingColorSpace( PDColorSpace colorSpace ) throws IOException
    {
        writeColorSpace( colorSpace );
        appendRawCommands( SET_NON_STROKING_COLORSPACE );
    }
    
    private void writeColorSpace( PDColorSpace colorSpace ) throws IOException
    {
        COSName key = null;
        if( colorSpace instanceof PDDeviceGray ||
            colorSpace instanceof PDDeviceRGB ||
            colorSpace instanceof PDDeviceCMYK )
        {
            key = COSName.getPDFName( colorSpace.getName() );
        }
        else
        {
            COSDictionary colorSpaces = 
                (COSDictionary)resources.getCOSDictionary().getDictionaryObject(COSName.COLORSPACE);
            if( colorSpaces == null )
            {
                colorSpaces = new COSDictionary();
                resources.getCOSDictionary().setItem( COSName.COLORSPACE, colorSpaces );
            }
            key = colorSpaces.getKeyForValue( colorSpace.getCOSObject() );
            
            if( key == null )
            {
                int counter = 0;
                String csName = "CS";
                while( colorSpaces.containsValue( csName + counter ) )
                {
                    counter++;
                }
                key = COSName.getPDFName( csName + counter );
                colorSpaces.setItem( key, colorSpace );
            }
        }
        key.writePDF( output );
        appendRawCommands( SPACE );
    }
    
    /**
     * Set the color components of current stroking colorspace.
     * 
     * @param components The components to set for the current color.
     * @throws IOException If there is an error while writing to the stream.
     */
    public void setStrokingColor( float[] components ) throws IOException
    {
        for( int i=0; i< components.length; i++ )
        {
            appendRawCommands( formatDecimal.format( components[i] ) );
            appendRawCommands( SPACE );
        }
        if( currentStrokingColorSpace instanceof PDSeparation ||
            currentStrokingColorSpace instanceof PDPattern ||
            currentStrokingColorSpace instanceof PDDeviceN ||
            currentStrokingColorSpace instanceof PDICCBased )
        {
            appendRawCommands( SET_STROKING_COLOR_COMPLEX );
        }
        else
        {
            appendRawCommands( SET_STROKING_COLOR_SIMPLE );
        }
    }
    
    /**
     * Set the stroking color, specified as RGB.
     * 
     * @param color The color to set.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setStrokingColor( Color color ) throws IOException
    {
        ColorSpace colorSpace = color.getColorSpace();
        if( colorSpace.getType() == ColorSpace.TYPE_RGB )
        {
            setStrokingColor( color.getRed(), color.getGreen(), color.getBlue() );
        }
        else if( colorSpace.getType() == ColorSpace.TYPE_GRAY )
        {
            color.getColorComponents( colorComponents );
            setStrokingColor( colorComponents[0] );
        }
        else if( colorSpace.getType() == ColorSpace.TYPE_CMYK )
        {
            color.getColorComponents( colorComponents );
            setStrokingColor( colorComponents[0], colorComponents[2], colorComponents[2], colorComponents[3] );
        }
        else
        {
            throw new IOException( "Error: unknown colorspace:" + colorSpace );
        }
    }
    
    /**
     * Set the non stroking color, specified as RGB.
     * 
     * @param color The color to set.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setNonStrokingColor( Color color ) throws IOException
    {
        ColorSpace colorSpace = color.getColorSpace();
        if( colorSpace.getType() == ColorSpace.TYPE_RGB )
        {
            setNonStrokingColor( color.getRed(), color.getGreen(), color.getBlue() );
        }
        else if( colorSpace.getType() == ColorSpace.TYPE_GRAY )
        {
            color.getColorComponents( colorComponents );
            setNonStrokingColor( colorComponents[0] );
        }
        else if( colorSpace.getType() == ColorSpace.TYPE_CMYK )
        {
            color.getColorComponents( colorComponents );
            setNonStrokingColor( colorComponents[0], colorComponents[2], colorComponents[2], colorComponents[3] );
        }
        else
        {
            throw new IOException( "Error: unknown colorspace:" + colorSpace );
        }
    }
    
    /**
     * Set the stroking color, specified as RGB, 0-255.
     * 
     * @param r The red value.
     * @param g The green value.
     * @param b The blue value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setStrokingColor( int r, int g, int b ) throws IOException
    {
        appendRawCommands( formatDecimal.format( r/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( g/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( b/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( RG_STROKING );
    }
    
    /**
     * Set the stroking color, specified as CMYK, 0-255.
     * 
     * @param c The cyan value.
     * @param m The magenta value.
     * @param y The yellow value.
     * @param k The black value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setStrokingColor( int c, int m, int y, int k) throws IOException
    {
        appendRawCommands( formatDecimal.format( c/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( m/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( y/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( k/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( K_STROKING );
    }
    
    /**
     * Set the stroking color, specified as CMYK, 0.0-1.0.
     * 
     * @param c The cyan value.
     * @param m The magenta value.
     * @param y The yellow value.
     * @param k The black value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setStrokingColor( double c, double m, double y, double k) throws IOException
    {
        appendRawCommands( formatDecimal.format( c ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( m ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( y ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( k ) );
        appendRawCommands( SPACE );
        appendRawCommands( K_STROKING );
    }
    
    /**
     * Set the stroking color, specified as grayscale, 0-255.
     * 
     * @param g The gray value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setStrokingColor( int g ) throws IOException
    {
        appendRawCommands( formatDecimal.format( g/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( G_STROKING );
    }
    
    /**
     * Set the stroking color, specified as Grayscale 0.0-1.0.
     * 
     * @param g The gray value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setStrokingColor( double g ) throws IOException
    {
        appendRawCommands( formatDecimal.format( g ) );
        appendRawCommands( SPACE );
        appendRawCommands( G_STROKING );
    }
    
    /**
     * Set the color components of current non stroking colorspace.
     * 
     * @param components The components to set for the current color.
     * @throws IOException If there is an error while writing to the stream.
     */
    public void setNonStrokingColor( float[] components ) throws IOException
    {
        for( int i=0; i< components.length; i++ )
        {
            appendRawCommands( formatDecimal.format( components[i] ) );
            appendRawCommands( SPACE );
        }
        if( currentNonStrokingColorSpace instanceof PDSeparation ||
            currentNonStrokingColorSpace instanceof PDPattern ||
            currentNonStrokingColorSpace instanceof PDDeviceN ||
            currentNonStrokingColorSpace instanceof PDICCBased )
        {
            appendRawCommands( SET_NON_STROKING_COLOR_COMPLEX );
        }
        else
        {
            appendRawCommands( SET_NON_STROKING_COLOR_SIMPLE );
        }
    }
    
    /**
     * Set the non stroking color, specified as RGB, 0-255.
     * 
     * @param r The red value.
     * @param g The green value.
     * @param b The blue value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setNonStrokingColor( int r, int g, int b ) throws IOException
    {
        appendRawCommands( formatDecimal.format( r/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( g/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( b/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( RG_NON_STROKING );
    }
    
    /**
     * Set the non stroking color, specified as CMYK, 0-255.
     * 
     * @param c The cyan value.
     * @param m The magenta value.
     * @param y The yellow value.
     * @param k The black value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setNonStrokingColor( int c, int m, int y, int k) throws IOException
    {
        appendRawCommands( formatDecimal.format( c/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( m/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( y/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( k/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( K_NON_STROKING );
    }
    
    /**
     * Set the non stroking color, specified as CMYK, 0.0-1.0.
     * 
     * @param c The cyan value.
     * @param m The magenta value.
     * @param y The yellow value.
     * @param k The black value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setNonStrokingColor( double c, double m, double y, double k) throws IOException
    {
        appendRawCommands( formatDecimal.format( c ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( m ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( y ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( k ) );
        appendRawCommands( SPACE );
        appendRawCommands( K_NON_STROKING );
    }
    
    /**
     * Set the non stroking color, specified as grayscale, 0-255.
     * 
     * @param g The gray value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setNonStrokingColor( int g ) throws IOException
    {
        appendRawCommands( formatDecimal.format( g/255d ) );
        appendRawCommands( SPACE );
        appendRawCommands( G_NON_STROKING );
    }
    
    /**
     * Set the non stroking color, specified as Grayscale 0.0-1.0.
     * 
     * @param g The gray value.
     * @throws IOException If an IO error occurs while writing to the stream.
     */
    public void setNonStrokingColor( double g ) throws IOException
    {
        appendRawCommands( formatDecimal.format( g ) );
        appendRawCommands( SPACE );
        appendRawCommands( G_NON_STROKING );
    }
    
    /**
     * Draw a rectangle on the page using the current non stroking color.
     * 
     * @param x The lower left x coordinate.
     * @param y The lower left y coordinate.
     * @param width The width of the rectangle.
     * @param height The height of the rectangle.
     * @throws IOException If there is an error while drawing on the screen.
     */
    public void fillRect( float x, float y, float width, float height ) throws IOException
    {
        appendRawCommands( formatDecimal.format( x ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( y ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( width ) );
        appendRawCommands( SPACE );
        appendRawCommands( formatDecimal.format( height ) );
        appendRawCommands( SPACE );
        appendRawCommands( APPEND_RECTANGLE );
        appendRawCommands( FILL );
    }
    
    
    /**
     * This will append raw commands to the content stream.
     * 
     * @param commands The commands to append to the stream.
     * @throws IOException If an error occurs while writing to the stream.
     */
    public void appendRawCommands( String commands ) throws IOException
    {
        appendRawCommands( commands.getBytes( "ISO-8859-1" ) );
    }
    
    /**
     * This will append raw commands to the content stream.
     * 
     * @param commands The commands to append to the stream.
     * @throws IOException If an error occurs while writing to the stream.
     */
    public void appendRawCommands( byte[] commands ) throws IOException
    {
        output.write( commands );
    }
    
    /**
     * This will append raw commands to the content stream.
     * 
     * @param data Append a raw byte to the stream.
     * 
     * @throws IOException If an error occurs while writing to the stream.
     */
    public void appendRawCommands( int data ) throws IOException
    {
        output.write( data );
    }
    
    /**
     * Close the content stream.  This must be called when you are done with this
     * object.
     * @throws IOException If the underlying stream has a problem being written to.
     */
    public void close() throws IOException
    {
        output.close();
    }
}