/**
 * Copyright (c) 2003, www.pdfbox.org
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

import org.pdfbox.cos.COSArray;
import org.pdfbox.cos.COSDictionary;
import org.pdfbox.cos.COSName;
import org.pdfbox.cos.COSString;

import org.pdfbox.pdmodel.common.COSArrayList;

import java.util.ArrayList;
import java.util.List;

/**
 * This holds common functionality for check boxes and radio buttons.
 *
 * @author sug
 * @version $Revision: 1.4 $
 */
public abstract class PDChoiceButton extends PDField
{

    /**
     * @see PDField#PDField(PDAcroForm,org.pdfbox.cos.COSDictionary)
     *
     * @param theAcroForm The acroForm for this field.
     * @param field The field for this button.
     */
    public PDChoiceButton( PDAcroForm theAcroForm, COSDictionary field)
    {
        super(theAcroForm, field);
    }

    /**
     * This will get the option values "Opt" entry of the pdf button.
     *
     * @return A list of java.lang.String values.
     */
    public List getOptions()
    {
        List retval = null;
        COSArray array = (COSArray)getDictionary().getDictionaryObject( COSName.getPDFName( "Opt" ) );
        if( array != null )
        {
            List strings = new ArrayList();
            for( int i=0; i<array.size(); i++ )
            {
                strings.add( ((COSString)array.getObject( i )).getString() );
            }
            retval = new COSArrayList( strings, array );
        }
        return retval;
    }

    /**
     * This will will set the list of options for this button.
     *
     * @param options The list of options for the button.
     */
    public void setOptions( List options )
    {
        getDictionary().setItem(
            COSName.getPDFName( "Opt" ),
            COSArrayList.converterToCOSArray( options ) );
    }
}