/**
 * Copyright (c) 2003-2004, www.pdfbox.org
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
package org.pdfbox.encryption;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.pdfbox.cos.COSArray;
import org.pdfbox.cos.COSBase;
import org.pdfbox.cos.COSDictionary;
import org.pdfbox.cos.COSDocument;
import org.pdfbox.cos.COSName;
import org.pdfbox.cos.COSObject;
import org.pdfbox.cos.COSStream;
import org.pdfbox.cos.COSString;
import org.pdfbox.exceptions.CryptographyException;
import org.pdfbox.exceptions.InvalidPasswordException;
import org.pdfbox.pdmodel.PDDocument;
import org.pdfbox.pdmodel.encryption.PDStandardEncryption;

/**
 * This class will deal with encrypting/decrypting a document.
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.13 $
 * 
 * @deprecated use the new security API instead.
 * 
 * @see org.pdfbox.pdmodel.encryption.StandardSecurityHandler
 */
public class DocumentEncryption
{
    private PDDocument pdDocument = null;
    private COSDocument document = null;

    private byte[] encryptionKey = null;
    private PDFEncryption encryption = new PDFEncryption();

    private Set objects = new HashSet();
    
    /**
     * A set that contains potential signature dictionaries.  This is used
     * because the Contents entry of the signature is not encrypted.
     */
    private Set potentialSignatures = new HashSet();

    /**
     * Constructor.
     *
     * @param doc The document to decrypt.
     */
    public DocumentEncryption( PDDocument doc )
    {
        pdDocument = doc;
        document = doc.getDocument();
    }

    /**
     * Constructor.
     *
     * @param doc The document to decrypt.
     */
    public DocumentEncryption( COSDocument doc )
    {
        pdDocument = new PDDocument( doc );
        document = doc;
    }

    /**
     * This will encrypt the given document, given the owner password and user password.
     * The encryption method used is the standard filter.
     *
     * @throws CryptographyException If an error occurs during encryption.
     * @throws IOException If there is an error accessing the data.
     */
    public void initForEncryption()
        throws CryptographyException, IOException
    {
        String ownerPassword = pdDocument.getOwnerPasswordForEncryption();
        String userPassword = pdDocument.getUserPasswordForEncryption();
        if( ownerPassword == null )
        {
            ownerPassword = "";
        }
        if( userPassword == null )
        {
            userPassword = "";
        }
        PDStandardEncryption encParameters = (PDStandardEncryption)pdDocument.getEncryptionDictionary();
        int permissionInt = encParameters.getPermissions();
        int revision = encParameters.getRevision();
        int length = encParameters.getLength()/8;
        COSArray idArray = document.getDocumentID();

        //check if the document has an id yet.  If it does not then
        //generate one
        if( idArray == null || idArray.size() < 2 )
        {
            idArray = new COSArray();
            try
            {
                MessageDigest md = MessageDigest.getInstance( "MD5" );
                BigInteger time = BigInteger.valueOf( System.currentTimeMillis() );
                md.update( time.toByteArray() );
                md.update( ownerPassword.getBytes() );
                md.update( userPassword.getBytes() );
                md.update( document.toString().getBytes() );
                byte[] id = md.digest( this.toString().getBytes() );
                COSString idString = new COSString();
                idString.append( id );
                idArray.add( idString );
                idArray.add( idString );
                document.setDocumentID( idArray );
            }
            catch( NoSuchAlgorithmException e )
            {
                throw new CryptographyException( e );
            }

        }
        COSString id = (COSString)idArray.getObject( 0 );
        encryption = new PDFEncryption();

        byte[] o = encryption.computeOwnerPassword(
            ownerPassword.getBytes("ISO-8859-1"),
            userPassword.getBytes("ISO-8859-1"), revision, length);

        byte[] u = encryption.computeUserPassword(
            userPassword.getBytes("ISO-8859-1"),
            o, permissionInt, id.getBytes(), revision, length);

        encryptionKey = encryption.computeEncryptedKey(
            userPassword.getBytes("ISO-8859-1"), o, permissionInt, id.getBytes(), revision, length);

        encParameters.setOwnerKey( o );
        encParameters.setUserKey( u );
        
        document.setEncryptionDictionary( encParameters.getCOSDictionary() );
    }
    
    

    /**
     * This will decrypt the document.
     *
     * @param password The password for the document.
     *
     * @throws CryptographyException If there is an error decrypting the document.
     * @throws IOException If there is an error getting the stream data.
     * @throws InvalidPasswordException If the password is not a user or owner password.
     */
    public void decryptDocument( String password )
        throws CryptographyException, IOException, InvalidPasswordException
    {
        if( password == null )
        {
            password = "";
        }

        PDStandardEncryption encParameters = (PDStandardEncryption)pdDocument.getEncryptionDictionary();


        int permissions = encParameters.getPermissions();
        int revision = encParameters.getRevision();
        int length = encParameters.getLength()/8;

        COSString id = (COSString)document.getDocumentID().getObject( 0 );
        byte[] u = encParameters.getUserKey();
        byte[] o = encParameters.getOwnerKey();

        boolean isUserPassword =
            encryption.isUserPassword( password.getBytes(), u,
                o, permissions, id.getBytes(), revision, length );
        boolean isOwnerPassword =
            encryption.isOwnerPassword( password.getBytes(), u,
                o, permissions, id.getBytes(), revision, length );

        if( isUserPassword )
        {
            encryptionKey =
                encryption.computeEncryptedKey(
                    password.getBytes(), o,
                    permissions, id.getBytes(), revision, length );
        }
        else if( isOwnerPassword )
        {
            byte[] computedUserPassword =
                encryption.getUserPassword(
                    password.getBytes(),
                    o,
                    revision,
                    length );
            encryptionKey =
                encryption.computeEncryptedKey(
                    computedUserPassword, o,
                    permissions, id.getBytes(), revision, length );
        }
        else
        {
            throw new InvalidPasswordException( "Error: The supplied password does not match " +
                                                "either the owner or user password in the document." );
        }
        
        COSDictionary trailer = document.getTrailer();
        COSArray fields = (COSArray)trailer.getObjectFromPath( "Root/AcroForm/Fields" );
        
        //We need to collect all the signature dictionaries, for some
        //reason the 'Contents' entry of signatures is not really encrypted
        if( fields != null )
        {
            for( int i=0; i<fields.size(); i++ )
            {
                COSDictionary field = (COSDictionary)fields.getObject( i );
                addDictionaryAndSubDictionary( potentialSignatures, field );
            }
        }

        List allObjects = document.getObjects();
        Iterator objectIter = allObjects.iterator();
        while( objectIter.hasNext() )
        {
            decryptObject( (COSObject)objectIter.next() );
        }
        document.setEncryptionDictionary( null );
    }
    
    private void addDictionaryAndSubDictionary( Set set, COSDictionary dic )
    {
        set.add( dic );
        COSArray kids = (COSArray)dic.getDictionaryObject( "Kids" );
        for( int i=0; kids != null && i<kids.size(); i++ )
        {
            addDictionaryAndSubDictionary( set, (COSDictionary)kids.getObject( i ) );
        }
        COSBase value = dic.getDictionaryObject( "V" );
        if( value instanceof COSDictionary )
        {
            addDictionaryAndSubDictionary( set, (COSDictionary)value );
        }
    }

    /**
     * This will decrypt an object in the document.
     *
     * @param object The object to decrypt.
     *
     * @throws CryptographyException If there is an error decrypting the stream.
     * @throws IOException If there is an error getting the stream data.
     */
    private void decryptObject( COSObject object )
        throws CryptographyException, IOException
    {
        long objNum = object.getObjectNumber().intValue();
        long genNum = object.getGenerationNumber().intValue();
        COSBase base = object.getObject();
        decrypt( base, objNum, genNum );
    }

    /**
     * This will dispatch to the correct method.
     *
     * @param obj The object to decrypt.
     * @param objNum The object number.
     * @param genNum The object generation Number.
     *
     * @throws CryptographyException If there is an error decrypting the stream.
     * @throws IOException If there is an error getting the stream data.
     */
    public void decrypt( Object obj, long objNum, long genNum )
        throws CryptographyException, IOException
    {
        if( !objects.contains( obj ) )
        {
            objects.add( obj );

            if( obj instanceof COSString )
            {
                decryptString( (COSString)obj, objNum, genNum );
            }
            else if( obj instanceof COSStream )
            {
                decryptStream( (COSStream)obj, objNum, genNum );
            }
            else if( obj instanceof COSDictionary )
            {
                decryptDictionary( (COSDictionary)obj, objNum, genNum );
            }
            else if( obj instanceof COSArray )
            {
                decryptArray( (COSArray)obj, objNum, genNum );
            }
        }
    }

    /**
     * This will decrypt a stream.
     *
     * @param stream The stream to decrypt.
     * @param objNum The object number.
     * @param genNum The object generation number.
     *
     * @throws CryptographyException If there is an error getting the stream.
     * @throws IOException If there is an error getting the stream data.
     */
    private void decryptStream( COSStream stream, long objNum, long genNum )
        throws CryptographyException, IOException
    {
        decryptDictionary( stream, objNum, genNum );
        InputStream encryptedStream = stream.getFilteredStream();
        encryption.encryptData( objNum,
                                genNum,
                                encryptionKey,
                                encryptedStream,
                                stream.createFilteredStream() );
    }

    /**
     * This will decrypt a dictionary.
     *
     * @param dictionary The dictionary to decrypt.
     * @param objNum The object number.
     * @param genNum The object generation number.
     *
     * @throws CryptographyException If there is an error decrypting the document.
     * @throws IOException If there is an error creating a new string.
     */
    private void decryptDictionary( COSDictionary dictionary, long objNum, long genNum )
        throws CryptographyException, IOException
    {
        Iterator keys = dictionary.keyList().iterator();
        while( keys.hasNext() )
        {
            COSName key = (COSName)keys.next();
            Object value = dictionary.getItem( key );
            //if we are a signature dictionary and contain a Contents entry then
            //we don't decrypt it.
            if( !(key.getName().equals( "Contents" ) && 
                  value instanceof COSString && 
                  potentialSignatures.contains( dictionary )))
            {
                decrypt( value, objNum, genNum );
            }
        }
    }

    /**
     * This will decrypt a string.
     *
     * @param string the string to decrypt.
     * @param objNum The object number.
     * @param genNum The object generation number.
     *
     * @throws CryptographyException If an error occurs during decryption.
     * @throws IOException If an error occurs writing the new string.
     */
    private void decryptString( COSString string, long objNum, long genNum )
        throws CryptographyException, IOException
    {
        ByteArrayInputStream data = new ByteArrayInputStream( string.getBytes() );
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        encryption.encryptData( objNum,
                                genNum,
                                encryptionKey,
                                data,
                                buffer );
        string.reset();
        string.append( buffer.toByteArray() );
    }

    /**
     * This will decrypt an array.
     *
     * @param array The array to decrypt.
     * @param objNum The object number.
     * @param genNum The object generation number.
     *
     * @throws CryptographyException If an error occurs during decryption.
     * @throws IOException If there is an error accessing the data.
     */
    private void decryptArray( COSArray array, long objNum, long genNum )
        throws CryptographyException, IOException
    {
        for( int i=0; i<array.size(); i++ )
        {
            decrypt( array.get( i ), objNum, genNum );
        }
    }
}