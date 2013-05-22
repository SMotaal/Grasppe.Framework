/**
 * Copyright (c) 2003-2005, www.pdfbox.org
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
package org.pdfbox.pdfviewer;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;

import java.awt.geom.GeneralPath;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.pdfbox.pdmodel.PDPage;
import org.pdfbox.pdmodel.PDResources;

import org.pdfbox.pdmodel.common.PDRectangle;
import org.pdfbox.pdmodel.font.PDFont;
import org.pdfbox.pdmodel.interactive.annotation.PDAnnotation;
import org.pdfbox.pdmodel.interactive.annotation.PDAppearanceDictionary;
import org.pdfbox.pdmodel.interactive.annotation.PDAppearanceStream;

import org.pdfbox.util.PDFStreamEngine;
import org.pdfbox.util.ResourceLoader;
import org.pdfbox.util.TextPosition;

/**
 * This will paint a page in a PDF document to a graphics context.
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.19 $
 */
public class PageDrawer extends PDFStreamEngine
{

    private Graphics2D graphics;
    private Dimension pageSize;
    private PDPage page;

    private List lineSubPaths = new ArrayList();
    private GeneralPath linePath = new GeneralPath();
    private Color strokingColor = Color.BLACK;
    private Color nonStrokingColor = Color.BLACK;
    
    /**
     * Default constructor, loads properties from file.
     * 
     * @throws IOException If there is an error loading properties from the file.
     */
    public PageDrawer() throws IOException
    {
        super( ResourceLoader.loadProperties( "Resources/PageDrawer.properties" ) );
    }

    /**
     * This will draw the page to the requested context.
     *
     * @param g The graphics context to draw onto.
     * @param p The page to draw.
     * @param pageDimension The size of the page to draw.
     *
     * @throws IOException If there is an IO error while drawing the page.
     */
    public void drawPage( Graphics g, PDPage p, Dimension pageDimension ) throws IOException
    {
        graphics = (Graphics2D)g;
        page = p;
        pageSize = pageDimension;
        
        graphics.setRenderingHint( RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON );
        PDResources resources = page.findResources();
        processStream( page, resources, page.getContents().getStream() );
        List annotations = page.getAnnotations();
        for( int i=0; i<annotations.size(); i++ )
        {
            PDAnnotation annot = (PDAnnotation)annotations.get( i );
            PDRectangle rect = annot.getRectangle();
            String appearanceName = annot.getAppearanceStream();
            PDAppearanceDictionary appearDictionary = annot.getAppearance();
            if( appearDictionary != null )
            {
                if( appearanceName == null )
                {
                    appearanceName = "default";
                }
                Map appearanceMap = appearDictionary.getNormalAppearance();
                PDAppearanceStream appearance = 
                    (PDAppearanceStream)appearanceMap.get( appearanceName );
                if( appearance != null )
                {
                    g.translate( (int)rect.getLowerLeftX(), (int)-rect.getLowerLeftY()  );
                    //g.translate( 20, -20 );
                    processSubStream( page, appearance.getResources(), appearance.getStream() );
                    g.translate( (int)-rect.getLowerLeftX(), (int)+rect.getLowerLeftY()  );
                }
            }
        }
        // Transformations should be done in order
        // 1 - Translate
        // 2 - Rotate
        // 3 - Scale
        // Refer to PDFReference p176 (or 188 in xpdf)
        //AffineTransform transform = graphics.getTransform();        
        //transform.setToTranslate( 0, page.findMediaBox().getHeight()/2 );
        //transform.setToRotation((double)p.getRotation());
        //transform.setTransform( 1, 0, 0, 1, 0, 0 );        
        //transform.setToScale( 1, 1 );
        
        //AffineTransform rotation = graphics.getTransform();
        //rotation.rotate( (page.findRotation() * Math.PI) / 180d );
        //graphics.setTransform( rotation );
    }

    /**
     * You should override this method if you want to perform an action when a
     * string is being shown.
     *
     * @param text The string to display.
     */
    protected void showCharacter( TextPosition text )
    {
        //should use colorspaces for the font color but for now assume that
        //the font color is black
        try
        {
            graphics.setColor( Color.black );
            PDFont font = text.getFont();
            font.drawString( text.getCharacter(), graphics, text.getFontSize(), text.getXScale(), text.getYScale(),
                             text.getX(), text.getY() );
        }
        catch( IOException io )
        {
            io.printStackTrace();
        }
    }
    
    /**
     * Get the graphics that we are currently drawing on.
     * 
     * @return The graphics we are drawing on.
     */
    public Graphics2D getGraphics()
    {
        return graphics;
    }
    
    /**
     * Get the page that is currently being drawn.
     * 
     * @return The page that is being drawn.
     */
    public PDPage getPage()
    {
        return page;
    }
    
    /**
     * Get the size of the page that is currently being drawn.
     * 
     * @return The size of the page that is being drawn.
     */
    public Dimension getPageSize()
    {
        return pageSize;
    }
    
    /**
     * Fix the y coordinate based on page rotation.
     * 
     * @param x The x coordinate.
     * @param y The y coordinate.
     * @return The updated y coordinate.
     */
    public double fixY( double x, double y )
    {
        double retval = y;
        int rotation = page.findRotation();
        if( rotation == 0 )
        {
            retval = pageSize.getHeight() - y;
        }
        else if( rotation == 90 )
        {
            retval = y;
        }
        return retval;
    }
    
    /**
     * Get the current line path to be drawn.
     * 
     * @return The current line path to be drawn.
     */
    public GeneralPath getLinePath()
    {
        return linePath;
    }

    /**
     * Set the line path to draw.
     * 
     * @param newLinePath Set the line path to draw.
     */
    public void setLinePath(GeneralPath newLinePath)
    {
        linePath = newLinePath;
    }
    
    /**
     * Get the current list of line paths to be drawn.
     * 
     * @return The current list of line paths to be drawn.
     */
    public List getLineSubPaths()
    {
        return lineSubPaths;
    }

    /**
     * Set the list of line paths to draw.
     * 
     * @param newLineSubPaths Set the list of line paths to draw.
     */
    public void setLineSubPaths(List newLineSubPaths)
    {
        lineSubPaths = newLineSubPaths;
    }

    /**
     * Get the non stroking color.
     * 
     * @return The non stroking color.
     */
    public Color getNonStrokingColor()
    {
        return nonStrokingColor;
    }

    /**
     * Set the non stroking color.
     * 
     * @param newNonStrokingColor The non stroking color.
     */
    public void setNonStrokingColor(Color newNonStrokingColor)
    {
        nonStrokingColor = newNonStrokingColor;
    }

    /**
     * Get the stroking color.
     * 
     * @return The stroking color.
     */
    public Color getStrokingColor()
    {
        return strokingColor;
    }

    /**
     * Set the stroking color.
     * 
     * @param newStrokingColor The stroking color.
     */
    public void setStrokingColor(Color newStrokingColor)
    {
        strokingColor = newStrokingColor;
    }
}