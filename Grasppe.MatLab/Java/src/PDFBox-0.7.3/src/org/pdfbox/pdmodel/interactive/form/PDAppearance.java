/**
 * Copyright (c) 2003-2006, www.pdfbox.org
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
package org.pdfbox.pdmodel.interactive.form;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.pdfbox.cos.COSArray;
import org.pdfbox.cos.COSDictionary;
import org.pdfbox.cos.COSFloat;
import org.pdfbox.cos.COSName;
import org.pdfbox.cos.COSNumber;
import org.pdfbox.cos.COSStream;
import org.pdfbox.cos.COSString;

import org.pdfbox.pdfparser.PDFStreamParser;
import org.pdfbox.pdfwriter.ContentStreamWriter;

import org.pdfbox.pdmodel.PDResources;

import org.pdfbox.pdmodel.common.PDRectangle;

import org.pdfbox.pdmodel.font.PDFont;
import org.pdfbox.pdmodel.font.PDFontDescriptor;
import org.pdfbox.pdmodel.font.PDSimpleFont;

import org.pdfbox.pdmodel.interactive.action.PDAdditionalActions;
import org.pdfbox.pdmodel.interactive.annotation.PDAppearanceDictionary;
import org.pdfbox.pdmodel.interactive.annotation.PDAppearanceStream;
import org.pdfbox.pdmodel.interactive.annotation.PDAnnotationWidget;

import org.pdfbox.util.PDFOperator;

/**
 * This one took me a while, but i'm proud to say that it handles
 * the appearance of a textbox. This allows you to apply a value to
 * a field in the document and handle the appearance so that the
 * value is actually visible too.
 * The problem was described by Ben Litchfield, the author of the
 * example: org.pdfbox.examlpes.fdf.ImportFDF. So Ben, here is the
 * solution.
 *
 * @author sug
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.19 $
 */
public class PDAppearance
{
    private PDVariableText parent;

    private String value;
    private COSString defaultAppearance;

    private PDAcroForm acroForm;
    private List widgets = new ArrayList();


    /**
     * Constructs a COSAppearnce from the given field.
     *
     * @param theAcroForm the acro form that this field is part of.
     * @param field the field which you wish to control the appearance of
     * @throws IOException If there is an error creating the appearance.
     */
    public PDAppearance( PDAcroForm theAcroForm, PDVariableText field ) throws IOException
    {
        acroForm = theAcroForm;
        parent = field;
        
        widgets = field.getKids();
        if( widgets == null )
        {
            widgets = new ArrayList();
            widgets.add( field.getWidget() );
        }
        
        defaultAppearance = getDefaultAppearance();

        
    }

    /**
     * Returns the default apperance of a textbox. If the textbox
     * does not have one, then it will be taken from the AcroForm.
     * @return The DA element
     */
    private COSString getDefaultAppearance()
    {
        
        COSString dap = parent.getDefaultAppearance();
        if (dap == null)
        {
            COSArray kids = (COSArray)parent.getDictionary().getDictionaryObject( "Kids" );
            if( kids != null && kids.size() > 0 )
            {
                COSDictionary firstKid = (COSDictionary)kids.getObject( 0 );
                dap = (COSString)firstKid.getDictionaryObject( "DA" );
            }
            if( dap == null )
            {
                dap = (COSString) acroForm.getDictionary().getDictionaryObject(COSName.getPDFName("DA"));
            }
        }
        return dap;
    }
    
    private int getQ()
    {
        int q = parent.getQ();
        if( parent.getDictionary().getDictionaryObject( "Q" ) == null )
        {
            COSArray kids = (COSArray)parent.getDictionary().getDictionaryObject( "Kids" );
            if( kids != null && kids.size() > 0 )
            {
                COSDictionary firstKid = (COSDictionary)kids.getObject( 0 );
                COSNumber qNum = (COSNumber)firstKid.getDictionaryObject( "Q" );
                if( qNum != null )
                {
                    q = qNum.intValue();
                }
            }
        }
        return q;
    }

    /**
     * Extracts the original appearance stream into a list of tokens.
     *
     * @return The tokens in the original appearance stream
     */
    private List getStreamTokens( PDAppearanceStream appearanceStream ) throws IOException
    {
        List tokens = null;
        if( appearanceStream != null )
        {
            tokens = getStreamTokens( appearanceStream.getStream() );
        }
        return tokens;
    }
    
    private List getStreamTokens( COSString string ) throws IOException
    {
        PDFStreamParser parser;

        List tokens = null;
        if( string != null )
        {
            ByteArrayInputStream stream = new ByteArrayInputStream( string.getBytes() );
            parser = new PDFStreamParser( stream, acroForm.getDocument().getDocument().getScratchFile() );
            parser.parse();
            tokens = parser.getTokens();
        }
        return tokens;
    }
    
    private List getStreamTokens( COSStream stream ) throws IOException
    {
        PDFStreamParser parser;

        List tokens = null;
        if( stream != null )
        {
            parser = new PDFStreamParser( stream );
            parser.parse();
            tokens = parser.getTokens();
        }
        return tokens;
    }

    /**
     * Tests if the apperance stream already contains content.
     *
     * @return true if it contains any content
     */
    private boolean containsMarkedContent( List stream )
    {
        return stream.contains( PDFOperator.getOperator( "BMC" ) ); 
    }

    /**
     * This is the public method for setting the appearance stream.
     *
     * @param apValue the String value which the apperance shoud represent
     *
     * @throws IOException If there is an error creating the stream.
     */
    public void setAppearanceValue(String apValue) throws IOException
    {
        // MulitLine check and set
        if ( parent.isMultiline() && apValue.indexOf('\n') != -1 )
        {
            apValue = convertToMultiLine( apValue );
        }

        value = apValue;
        Iterator widgetIter = widgets.iterator();
        while( widgetIter.hasNext() )
        {
            Object next = widgetIter.next();
            PDAnnotationWidget widget = null;
            if( next instanceof PDField )
            {
                widget = ((PDField)next).getWidget();
            }
            else
            {
                widget = (PDAnnotationWidget)next;
            }
            PDAdditionalActions actions = widget.getActions();
            if( actions != null && 
                actions.getF() != null && 
                widget.getDictionary().getDictionaryObject( "AP" ) ==null)
            {
                //do nothing because the field will be formatted by acrobat
                //when it is opened.  See FreedomExpressions.pdf for an example of this.
            }
            else
            {
            
                PDAppearanceDictionary appearance = widget.getAppearance();
                if( appearance == null )
                {
                    appearance = new PDAppearanceDictionary();
                    widget.setAppearance( appearance );
                }
    
                Map normalAppearance = appearance.getNormalAppearance();
                PDAppearanceStream appearanceStream = (PDAppearanceStream)normalAppearance.get( "default" );
                if( appearanceStream == null )
                {
                    COSStream cosStream = new COSStream( acroForm.getDocument().getDocument().getScratchFile() );
                    appearanceStream = new PDAppearanceStream( cosStream );
                    appearanceStream.setBoundingBox( widget.getRectangle().createRetranslatedRectangle() );
                    appearance.setNormalAppearance( appearanceStream );
                }
                
                List tokens = getStreamTokens( appearanceStream );
                List daTokens = getStreamTokens( getDefaultAppearance() );
                PDFont pdFont = getFontAndUpdateResources( tokens, appearanceStream );
                
                if (!containsMarkedContent( tokens ))
                {
                    ByteArrayOutputStream output = new ByteArrayOutputStream();
        
                    //BJL 9/25/2004 Must prepend existing stream
                    //because it might have operators to draw things like
                    //rectangles and such
                    ContentStreamWriter writer = new ContentStreamWriter( output );
                    writer.writeTokens( tokens );
        
                    output.write( " /Tx BMC\n".getBytes() );
                    insertGeneratedAppearance( widget, output, pdFont, tokens, appearanceStream );
                    output.write( " EMC".getBytes() );
                    writeToStream( output.toByteArray(), appearanceStream );
                }
                else
                {
                    if( tokens != null )
                    {
                        if( daTokens != null )
                        {
                            int bmcIndex = tokens.indexOf( PDFOperator.getOperator( "BMC" ));
                            int emcIndex = tokens.indexOf( PDFOperator.getOperator( "EMC" ));
                            if( bmcIndex != -1 && emcIndex != -1 &&
                                emcIndex == bmcIndex+1 )
                            {
                                //if the EMC immediately follows the BMC index then should
                                //insert the daTokens inbetween the two markers.
                                tokens.addAll( emcIndex, daTokens );
                            }
                        }
                        ByteArrayOutputStream output = new ByteArrayOutputStream();
                        ContentStreamWriter writer = new ContentStreamWriter( output );
                        float fontSize = calculateFontSize( pdFont, appearanceStream.getBoundingBox(), tokens, null );
                        boolean foundString = false;
                        for( int i=0; i<tokens.size(); i++ )
                        {
                            if( tokens.get( i ) instanceof COSString )
                            {
                                foundString = true;
                                COSString drawnString =((COSString)tokens.get(i)); 
                                drawnString.reset();
                                drawnString.append( apValue.getBytes() );
                            }
                        }
                        int setFontIndex = tokens.indexOf( PDFOperator.getOperator( "Tf" ));
                        tokens.set( setFontIndex-1, new COSFloat( fontSize ) );
                        if( foundString )
                        {
                            writer.writeTokens( tokens );   
                        }
                        else
                        {
                            int bmcIndex = tokens.indexOf( PDFOperator.getOperator( "BMC" ) );
                            int emcIndex = tokens.indexOf( PDFOperator.getOperator( "EMC" ) );
    
                            if( bmcIndex != -1 )
                            {
                                writer.writeTokens( tokens, 0, bmcIndex+1 );
                            }
                            else
                            {
                                writer.writeTokens( tokens );
                            }
                            output.write( "\n".getBytes() );
                            insertGeneratedAppearance( widget, output, 
                                pdFont, tokens, appearanceStream );
                            if( emcIndex != -1 )
                            {
                                writer.writeTokens( tokens, emcIndex, tokens.size() );
                            }
                        }
                        writeToStream( output.toByteArray(), appearanceStream );
                    }
                    else
                    {
                        //hmm?
                    }
                }
            }
        }
    }

    private void insertGeneratedAppearance( PDAnnotationWidget fieldWidget, OutputStream output, 
        PDFont pdFont, List tokens, PDAppearanceStream appearanceStream ) throws IOException
    {
        PrintWriter printWriter = new PrintWriter( output, true );
        float fontSize = 0.0f;
        PDRectangle boundingBox = null;
        boundingBox = appearanceStream.getBoundingBox();
        if( boundingBox == null )
        {
            boundingBox = fieldWidget.getRectangle().createRetranslatedRectangle();
        }
        printWriter.println( "BT" );
        if( defaultAppearance != null )
        {
            String daString = defaultAppearance.getString();
            PDFStreamParser daParser = new PDFStreamParser(new ByteArrayInputStream( daString.getBytes() ), null );
            daParser.parse();
            List daTokens = daParser.getTokens();
            fontSize = calculateFontSize( pdFont, boundingBox, tokens, daTokens );
            int fontIndex = daTokens.indexOf( PDFOperator.getOperator( "Tf" ) );
            if(fontIndex != -1 )
            {
                daTokens.set( fontIndex-1, new COSFloat( fontSize ) );
            }
            ContentStreamWriter daWriter = new ContentStreamWriter(output);
            daWriter.writeTokens( daTokens );
        }
        printWriter.println( getTextPosition( boundingBox, pdFont, fontSize, tokens ) );
        int q = getQ();
        if( q == PDTextbox.QUADDING_LEFT )
        {
            //do nothing because left is default
        }
        else if( q == PDTextbox.QUADDING_CENTERED ||
                 q == PDTextbox.QUADDING_RIGHT )
        {
            float fieldWidth = boundingBox.getWidth();
            float stringWidth = (pdFont.getStringWidth( value )/1000)*fontSize;
            float adjustAmount = fieldWidth - stringWidth - 4;

            if( q == PDTextbox.QUADDING_CENTERED )
            {
                adjustAmount = adjustAmount/2.0f;
            }

            printWriter.println( adjustAmount + " 0 Td" );
        }
        else
        {
            throw new IOException( "Error: Unknown justification value:" + q );
        }
        printWriter.println("(" + value + ") Tj");
        printWriter.println("ET" );
        printWriter.flush();
    }

    private PDFont getFontAndUpdateResources( List tokens, PDAppearanceStream appearanceStream ) throws IOException
    {

        PDFont retval = null;
        PDResources streamResources = appearanceStream.getResources();
        PDResources formResources = acroForm.getDefaultResources();
        if( formResources != null )
        {
            if( streamResources == null )
            {
                streamResources = new PDResources();
                appearanceStream.setResources( streamResources );
            }
            
            COSString da = getDefaultAppearance();
            if( da != null )
            {
                String data = da.getString();
                PDFStreamParser streamParser = new PDFStreamParser(
                        new ByteArrayInputStream( data.getBytes() ), null );
                streamParser.parse();
                tokens = streamParser.getTokens();
            }

            int setFontIndex = tokens.indexOf( PDFOperator.getOperator( "Tf" ));
            COSName cosFontName = (COSName)tokens.get( setFontIndex-2 );
            String fontName = cosFontName.getName();
            retval = (PDFont)streamResources.getFonts().get( fontName );
            if( retval == null )
            {
                retval = (PDFont)formResources.getFonts().get( fontName );
                streamResources.getFonts().put( fontName, retval );
            }
        }
        return retval;
    }

    private String convertToMultiLine( String line )
    {
        int currIdx = 0;
        int lastIdx = 0;
        StringBuffer result = new StringBuffer(line.length() + 64);
        while( (currIdx = line.indexOf('\n',lastIdx )) > -1 )
        {
            result.append(line.substring(lastIdx,currIdx));
            result.append(" ) Tj\n0 -13 Td\n(");
            lastIdx = currIdx + 1;
        }
        result.append(line.substring(lastIdx));
        return result.toString();
    }

    /**
     * Writes the stream to the actual stream in the COSStream.
     *
     * @throws IOException If there is an error writing to the stream
     */
    private void writeToStream( byte[] data, PDAppearanceStream appearanceStream ) throws IOException
    {
        OutputStream out = appearanceStream.getStream().createUnfilteredStream();
        out.write( data );
        out.flush();
    }


    /**
     * w in an appearance stream represents the lineWidth.
     * @return the linewidth
     */
    private float getLineWidth( List tokens )
    {
        
        float retval = 1;
        if( tokens != null ) 
        {
            int btIndex = tokens.indexOf(PDFOperator.getOperator( "BT" ));
            int wIndex = tokens.indexOf(PDFOperator.getOperator( "w" ));
            //the w should only be used if it is before the first BT.
            if( (wIndex > 0) && (wIndex < btIndex) ) 
            {
                retval = ((COSNumber)tokens.get(wIndex-1)).floatValue();
            }
        }
        return retval;
    }
    
    private PDRectangle getSmallestDrawnRectangle( PDRectangle boundingBox, List tokens )
    {
        PDRectangle smallest = boundingBox;
        for( int i=0; i<tokens.size(); i++ )
        {
            Object next = tokens.get( i );
            if( next == PDFOperator.getOperator( "re" ) )
            {
                COSNumber x = (COSNumber)tokens.get( i-4 );
                COSNumber y = (COSNumber)tokens.get( i-3 );
                COSNumber width = (COSNumber)tokens.get( i-2 );
                COSNumber height = (COSNumber)tokens.get( i-1 );
                PDRectangle potentialSmallest = new PDRectangle();
                potentialSmallest.setLowerLeftX( x.floatValue() );
                potentialSmallest.setLowerLeftY( y.floatValue() );
                potentialSmallest.setUpperRightX( x.floatValue() + width.floatValue() );
                potentialSmallest.setUpperRightY( y.floatValue() + height.floatValue() );
                if( smallest == null ||
                    smallest.getLowerLeftX() < potentialSmallest.getLowerLeftX() ||
                    smallest.getUpperRightY() > potentialSmallest.getUpperRightY() )
                {
                    smallest = potentialSmallest;
                }
                
            }
        }
        return smallest;
    }

    /**
     * My "not so great" method for calculating the fontsize.
     * It does not work superb, but it handles ok.
     * @return the calculated font-size
     *
     * @throws IOException If there is an error getting the font height.
     */
    private float calculateFontSize( PDFont pdFont, PDRectangle boundingBox, List tokens, List daTokens ) 
        throws IOException
    {
        float fontSize = 0;
        if( daTokens != null )
        {
            //daString looks like   "BMC /Helv 3.4 Tf EMC"
            
            int fontIndex = daTokens.indexOf( PDFOperator.getOperator( "Tf" ) );
            if(fontIndex != -1 )
            {
                fontSize = ((COSNumber)daTokens.get(fontIndex-1)).floatValue();
            }
        }
        if( parent.doNotScroll() )
        {
            //if we don't scroll then we will shrink the font to fit into the text area.
            float widthAtFontSize1 = pdFont.getStringWidth( value );
            float availableWidth = boundingBox.getWidth();
            float perfectFitFontSize = availableWidth / widthAtFontSize1;
        }
        else if( fontSize == 0 )
        {
            float lineWidth = getLineWidth( tokens );
            float stringWidth = pdFont.getStringWidth( value );
            float height = 0;
            if( pdFont instanceof PDSimpleFont )
            {
                height = ((PDSimpleFont)pdFont).getFontDescriptor().getFontBoundingBox().getHeight();
            }
            else
            {
                //now much we can do, so lets assume font is square and use width
                //as the height
                height = pdFont.getAverageFontWidth();
            }
            height = height/1000f;
    
            float availHeight = getAvailableHeight( boundingBox, lineWidth );
            fontSize =(availHeight/height); 
        }
        return fontSize;
    }

    /**
     * Calculates where to start putting the text in the box.
     * The positioning is not quite as accurate as when Acrobat
     * places the elements, but it works though.
     *
     * @return the sting for representing the start position of the text
     *
     * @throws IOException If there is an error calculating the text position.
     */
    private String getTextPosition( PDRectangle boundingBox, PDFont pdFont, float fontSize, List tokens ) 
        throws IOException
    {
        float lineWidth = getLineWidth( tokens );
        float pos = 0.0f;
        if(parent.isMultiline())
        {
            int rows = (int) (getAvailableHeight( boundingBox, lineWidth ) / ((int) fontSize));
            pos = ((rows)*fontSize)-fontSize;
        }
        else
        {
            if( pdFont instanceof PDSimpleFont )
            {
                //BJL 9/25/2004
                //This algorithm is a little bit of black magic.  It does
                //not appear to be documented anywhere.  Through examining a few
                //PDF documents and the value that Acrobat places in there I
                //have determined that the below method of computing the position
                //is correct for certain documents, but maybe not all.  It does
                //work f1040ez.pdf and Form_1.pdf
                PDFontDescriptor fd = ((PDSimpleFont)pdFont).getFontDescriptor();
                float bBoxHeight = boundingBox.getHeight();
                float fontHeight = fd.getFontBoundingBox().getHeight() + 2 * fd.getDescent();
                fontHeight = (fontHeight/1000) * fontSize;
                pos = (bBoxHeight - fontHeight)/2;
            }
            else
            {
                throw new IOException( "Error: Don't know how to calculate the position for non-simple fonts" );
            }
        }
        PDRectangle innerBox = getSmallestDrawnRectangle( boundingBox, tokens );
        float xInset = 2+ 2*(boundingBox.getWidth() - innerBox.getWidth());
        return Math.round(xInset) + " "+ pos + " Td";
    }
    
    /**
     * calculates the available width of the box.
     * @return the calculated available width of the box
     */
    private float getAvailableWidth( PDRectangle boundingBox, float lineWidth )
    {
        return boundingBox.getWidth() - 2 * lineWidth;
    }

    /**
     * calculates the available height of the box.
     * @return the calculated available height of the box
     */
    private float getAvailableHeight( PDRectangle boundingBox, float lineWidth )
    {
        return boundingBox.getHeight() - 2 * lineWidth;
    }
}