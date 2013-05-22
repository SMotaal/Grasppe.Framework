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
package org.pdfbox.filter;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.DeflaterOutputStream;
import java.util.zip.InflaterInputStream;

import org.pdfbox.cos.COSDictionary;

/**
 * This is the used for the FlateDecode filter.
 * 
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @author Marcel Kammer
 * @version $Revision: 1.10 $
 */
public class FlateFilter implements Filter
{
    private static final int    BUFFER_SIZE    = 2048;

    /**
     * This will decode some compressed data.
     * 
     * @param compressedData
     *            The compressed byte stream.
     * @param result
     *            The place to write the uncompressed byte stream.
     * @param options
     *            The options to use to encode the data.
     * 
     * @throws IOException
     *             If there is an error decompressing the stream.
     */

    public void decode(InputStream compressedData, OutputStream result, COSDictionary options) throws IOException
    {
        COSDictionary dict = (COSDictionary) options.getDictionaryObject("DecodeParms");
        int predictor = -1;
        int colors = -1;
        int bitsPerPixel = -1;
        int columns = -1;
        InflaterInputStream decompressor = null;
        ByteArrayInputStream bais = null;
        ByteArrayOutputStream baos = null;
        if (dict!=null)
        {
            predictor = dict.getInt("Predictor");
            colors = dict.getInt("Colors");
            bitsPerPixel = options.getInt("BitsPerComponent");
            columns = dict.getInt("Columns");
        }

        try
        {
            // Decompress data to temporary ByteArrayOutputStream
            decompressor = new InflaterInputStream(compressedData);
            byte[] buffer = new byte[BUFFER_SIZE];
            int amountRead;

            // Decode data using given predictor
            if (predictor==-1 || predictor == 1 && predictor == 10)
            {
                // decoding not needed
                while ((amountRead = decompressor.read(buffer, 0, BUFFER_SIZE)) != -1)
                {
                    result.write(buffer, 0, amountRead);
                }
            }
            else
            {
                if (colors==-1 || bitsPerPixel==-1 || columns==-1)
                {
                    throw new IOException("Could not read all parameters to decode image");
                }
                
                baos = new ByteArrayOutputStream();
                while ((amountRead = decompressor.read(buffer, 0, BUFFER_SIZE)) != -1)
                {
                    baos.write(buffer, 0, amountRead);
                }
                baos.flush();

                // Copy data to ByteArrayInputStream for reading
                bais = new ByteArrayInputStream(baos.toByteArray());
                baos.close();
                baos = null;

                byte[] decodedData = decodePredictor(predictor, colors, bitsPerPixel, columns, bais);
                bais.close();
                bais = new ByteArrayInputStream(decodedData);

                // write decoded data to result
                while ((amountRead = bais.read(buffer)) != -1)
                {
                    result.write(buffer, 0, amountRead);
                }
                bais.close();
                bais = null;
            }            
            
            
            result.flush();
        }
        finally
        {
            if (decompressor != null)
            {
                decompressor.close();
            }
            if (bais != null)
            {
                bais.close();
            }
            if (baos != null)
            {
                baos.close();
            }
        }
    }

    private byte[] decodePredictor(int predictor, int colors, int bitsPerComponent, int columns, InputStream data) 
        throws IOException
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buffer = new byte[2048];

        if (predictor == 1 || predictor == 10)
        {
            // No prediction or PNG NONE
            int i = 0;
            while ((i = data.read(buffer)) != -1)
            {
                baos.write(buffer, 0, i);
            }
        }
        else
        {
            // calculate sizes
            int bpp = (colors * bitsPerComponent + 7) / 8;
            int rowlength = (columns * colors * bitsPerComponent + 7) / 8 + bpp;
            byte[] actline = new byte[rowlength];
            byte[] lastline = new byte[rowlength];// Initialize lastline with
                                                    // Zeros according to
                                                    // PNG-specification
            boolean done = false;
            int linepredictor = predictor;

            while (!done)
            {
                if (predictor == 15)
                {
                    linepredictor = data.read();// read per line predictor
                    if (linepredictor == -1)
                    {
                        done = true;// reached EOF
                        break;
                    }
                    else
                    {
                        linepredictor += 10; // add 10 to tread value 1 as 11
                    }
                    // (instead of PRED NONE) and 2
                    // as 12 (instead of PRED TIFF)
                }

                // read line
                int i = 0;
                int offset = bpp;
                while (offset < rowlength && ((i = data.read(actline, offset, rowlength - offset)) != -1))
                {
                    offset += i;
                }

                // Do prediction as specified in PNG-Specification 1.2
                switch (linepredictor)
                {
                    case 2:// PRED TIFF SUB
                        /**
                         * @todo decode tiff
                         */
                        throw new IOException("TIFF-Predictor not supported");
                    case 11:// PRED SUB
                        for (int p = bpp; p < rowlength; p++)
                        {
                            int sub = actline[p] & 0xff;
                            int left = actline[p - bpp] & 0xff;
                            actline[p] = (byte) (sub + left);
                        }
                        break;
                    case 12:// PRED UP
                        for (int p = bpp; p < rowlength; p++)
                        {
                            int up = actline[p] & 0xff;
                            int prior = lastline[p] & 0xff;
                            actline[p] = (byte) (up + prior);
                        }
                        break;
                    case 13:// PRED AVG
                        for (int p = bpp; p < rowlength; p++)
                        {
                            int avg = actline[p] & 0xff;
                            int left = actline[p - bpp] & 0xff;
                            int up = lastline[p] & 0xff;
                            actline[p] = (byte) (avg + ((left + up) / 2));
                        }
                        break;
                    case 14:// PRED PAETH
                        for (int p = bpp; p < rowlength; p++)
                        {
                            int paeth = actline[p] & 0xff;
                            int a = actline[p - bpp] & 0xff;// left
                            int b = lastline[p] & 0xff;// upper
                            int c = lastline[p - bpp] & 0xff;// upperleft
                            int value = a + b - c;
                            int absa = Math.abs(value - a);
                            int absb = Math.abs(value - b);
                            int absc = Math.abs(value - c);

                            if (absa <= absb && absa <= absc)
                            {
                                actline[p] = (byte) (paeth + absa);
                            }
                            else if (absb <= absc)
                            {
                                actline[p] += (byte) (paeth + absb);
                            }
                            else
                            {
                                actline[p] += (byte) (paeth + absc);
                            }
                        }
                        break;
                    default:
                        break;
                }

                lastline = actline;
                baos.write(actline, bpp, actline.length - bpp);
            }
        }

        return baos.toByteArray();
    }

    /**
     * This will encode some data.
     * 
     * @param rawData
     *            The raw data to encode.
     * @param result
     *            The place to write to encoded results to.
     * @param options
     *            The options to use to encode the data.
     * 
     * @throws IOException
     *             If there is an error compressing the stream.
     */
    public void encode(InputStream rawData, OutputStream result, COSDictionary options) throws IOException
    {
        DeflaterOutputStream out = new DeflaterOutputStream(result);
        byte[] buffer = new byte[BUFFER_SIZE];
        int amountRead = 0;
        while ((amountRead = rawData.read(buffer, 0, BUFFER_SIZE)) != -1)
        {
            out.write(buffer, 0, amountRead);
        }
        out.close();
        result.flush();
    }
}