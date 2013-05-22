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
package org.pdfbox.io;

import java.io.FilterInputStream;
import java.io.InputStream;
import java.io.IOException;

/**
 * This class represents an ASCII85 stream.
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.6 $
 */
public class ASCII85InputStream extends FilterInputStream
{
    private int index;
    private int n;
    private boolean eof;

    private byte[] ascii;
    private byte[] b;

    /**
     * Constructor.
     *
     * @param is The input stream to actually read from.
     */
    public ASCII85InputStream( InputStream is )
    {
        super(is);
        index = 0;
        n = 0;
        eof = false;
        ascii = new byte[5];
        b = new byte[4];
    }

    /**
     * This will read the next byte from the stream.
     *
     * @return The next byte read from the stream.
     *
     * @throws IOException If there is an error reading from the wrapped stream.
     */
    public final int read() throws IOException
    {
        if( index >= n )
        {
            if(eof)
            {
                return -1;
            }
            index = 0;
            int k;
            byte z;
            do
            {
                int zz=(byte)in.read();
                if(zz==-1)
                {
                    eof=true;
                    return -1;
                }
                z = (byte)zz;
            }  while( z=='\n' || z=='\r' || z==' ');

            if (z == '~' || z=='x')
            {
                eof=true;
                ascii=b=null;
                n = 0;
                return -1;
            }
            else if (z == 'z')
            {
                b[0]=b[1]=b[2]=b[3]=0;
                n = 4;
            }
            else
            {
                ascii[0]=z; // may be EOF here....
                for (k=1;k<5;++k)
                {
                    do
                    {
                        int zz=(byte)in.read();
                        if(zz==-1)
                        {
                            eof=true;
                            return -1;
                        }
                        z=(byte)zz;
                    } while ( z=='\n' || z=='\r' || z==' ' );
                    ascii[k]=z;
                    if (z == '~' || z=='x')
                    {
                        break;
                    }
                }
                n = k - 1;
                if ( n==0 )
                {
                    eof = true;
                    ascii = null;
                    b = null;
                    return -1;
                }
                if ( k < 5 )
                {
                    for (++k; k < 5; ++k )
                    {
                        ascii[k] = 0x21;
                    }
                    eof=true;
                }
                // decode stream
                long t=0;
                for ( k=0; k<5; ++k)
                {
                    z=(byte)(ascii[k] - 0x21);
                    if (z < 0 || z > 93)
                    {
                        n = 0;
                        eof = true;
                        ascii = null;
                        b = null;
                        throw new IOException("Invalid data in Ascii85 stream");
                    }
                    t = (t * 85L) + z;
                }
                for ( k = 3; k>=0; --k)
                {
                    b[k] = (byte)(t & 0xFFL);
                    t>>>=8;
                }
            }
        }
        return b[index++] & 0xFF;
    }

    /**
     * This will read a chunk of data.
     *
     * @param data The buffer to write data to.
     * @param offset The offset into the data stream.
     * @param len The number of byte to attempt to read.
     *
     * @return The number of bytes actually read.
     *
     * @throws IOException If there is an error reading data from the underlying stream.
     */
    public final int read(byte[] data, int offset, int len) throws IOException
    {
        if(eof && index>=n)
        {
            return -1;
        }
        for(int i=0;i<len;i++)
        {
            if(index<n)
            {
                data[i+offset]=b[index++];
            }
            else
            {
                int t = read();
                if ( t == -1 )
                {
                    return i;
                }
                data[i+offset]=(byte)t;
            }
        }
        return len;
    }

    /**
     * This will close the underlying stream and release any resources.
     *
     * @throws IOException If there is an error closing the underlying stream.
     */
    public void close() throws IOException
    {
        ascii = null;
        eof = true;
        b = null;
        super.close();
    }

    /**
     * non supported interface methods.
     *
     * @return False always.
     */
    public boolean markSupported()
    {
        return false;
    }

    /**
     * Unsupported.
     *
     * @param nValue ignored.
     *
     * @return Always zero.
     */
    public long skip(long nValue)
    {
        return 0;
    }

    /**
     * Unsupported.
     *
     * @return Always zero.
     */
    public int available()
    {
        return 0;
    }

    /**
     * Unsupported.
     *
     * @param readlimit ignored.
     */
    public void mark(int readlimit)
    {
    }

    /**
     * Unsupported.
     *
     * @throws IOException telling that this is an unsupported action.
     */
    public void reset() throws IOException
    {
        throw new IOException("Reset is not supported");
    }
}