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
package org.pdfbox.pdmodel;

import java.awt.print.PageFormat;
import java.awt.print.Pageable;
import java.awt.print.Paper;
import java.awt.print.Printable;
import java.awt.print.PrinterException;
import java.awt.print.PrinterJob;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.List;

import org.pdfbox.cos.COSArray;
import org.pdfbox.cos.COSDictionary;
import org.pdfbox.cos.COSDocument;
import org.pdfbox.cos.COSInteger;
import org.pdfbox.cos.COSName;
import org.pdfbox.cos.COSStream;
import org.pdfbox.exceptions.COSVisitorException;
import org.pdfbox.exceptions.CryptographyException;
import org.pdfbox.exceptions.InvalidPasswordException;
import org.pdfbox.io.RandomAccess;
import org.pdfbox.pdfparser.PDFParser;
import org.pdfbox.pdfwriter.COSWriter;
import org.pdfbox.pdmodel.common.PDRectangle;
import org.pdfbox.pdmodel.common.PDStream;
import org.pdfbox.pdmodel.encryption.AccessPermission;
import org.pdfbox.pdmodel.encryption.BadSecurityHandlerException;
import org.pdfbox.pdmodel.encryption.DecryptionMaterial;
import org.pdfbox.pdmodel.encryption.PDEncryptionDictionary;
import org.pdfbox.pdmodel.encryption.ProtectionPolicy;
import org.pdfbox.pdmodel.encryption.SecurityHandler;
import org.pdfbox.pdmodel.encryption.SecurityHandlersManager;
import org.pdfbox.pdmodel.encryption.StandardDecryptionMaterial;
import org.pdfbox.pdmodel.encryption.StandardProtectionPolicy;

/**
 * This is the in-memory representation of the PDF document.  You need to call
 * close() on this object when you are done using it!!
 *
 * @author <a href="mailto:ben@benlitchfield.com">Ben Litchfield</a>
 * @version $Revision: 1.43 $
 */
public class PDDocument implements Pageable
{
    private COSDocument document;
    
    // NOTE BGUILLON: this property must be removed because it is 
    // not the responsability of this class to know    
    //private boolean encryptOnSave = false;
    
    
    // NOTE BGUILLON: these properties are not used anymore. See getCurrentAccessPermission() instead 
    //private String encryptUserPassword = null;
    //private String encryptOwnerPassword = null;

    //cached values
    private PDDocumentInformation documentInformation;
    private PDDocumentCatalog documentCatalog;

    //The encParameters will be cached here.  When the document is decrypted then
    //the COSDocument will not have an "Encrypt" dictionary anymore and this object
    //must be used.
    private PDEncryptionDictionary encParameters = null;
    
    /**
     * This will tell if the document was decrypted with the master password.
     * NOTE BGUILLON: this property is not used anymore. See getCurrentAccessPermission() instead
     */
   //private boolean decryptedWithOwnerPassword = false;
    
    
    /**
     * The security handler used to decrypt / encrypt the document.
     */
    private SecurityHandler securityHandler = null;
    

    /**
     * Constructor, creates a new PDF Document with no pages.  You need to add
     * at least one page for the document to be valid.
     *
     * @throws IOException If there is an error creating this document.
     */
    public PDDocument() throws IOException
    {
        document = new COSDocument();

        //First we need a trailer
        COSDictionary trailer = new COSDictionary();
        document.setTrailer( trailer );

        //Next we need the root dictionary.
        COSDictionary rootDictionary = new COSDictionary();
        trailer.setItem( COSName.ROOT, rootDictionary );
        rootDictionary.setItem( COSName.TYPE, COSName.CATALOG );
        rootDictionary.setItem( COSName.VERSION, COSName.getPDFName( "1.4" ) );

        //next we need the pages tree structure
        COSDictionary pages = new COSDictionary();
        rootDictionary.setItem( COSName.PAGES, pages );
        pages.setItem( COSName.TYPE, COSName.PAGES );
        COSArray kidsArray = new COSArray();
        pages.setItem( COSName.KIDS, kidsArray );
        pages.setItem( COSName.COUNT, new COSInteger( 0 ) );
    }

    /**
     * This will add a page to the document.  This is a convenience method, that
     * will add the page to the root of the hierarchy and set the parent of the
     * page to the root.
     *
     * @param page The page to add to the document.
     */
    public void addPage( PDPage page )
    {
        PDPageNode rootPages = getDocumentCatalog().getPages();
        rootPages.getKids().add( page );
        page.setParent( rootPages );
        rootPages.updateCount();
    }
    
    /**
     * Remove the page from the document.
     *
     * @param page The page to remove from the document.
     * 
     * @return true if the page was found false otherwise.
     */
    public boolean removePage( PDPage page )
    {
        PDPageNode parent = page.getParent();
        boolean retval = parent.getKids().remove( page );
        if( retval )
        {
            //do a recursive updateCount starting at the root
            //of the document
            getDocumentCatalog().getPages().updateCount();
        }
        return retval;
    }
    
    /**
     * Remove the page from the document.
     * 
     * @param pageNumber 0 based index to page number.
     * @return true if the page was found false otherwise.
     */
    public boolean removePage( int pageNumber )
    {
        boolean removed = false;
        List allPages = getDocumentCatalog().getAllPages();
        if( allPages.size() > pageNumber)
        {
            PDPage page = (PDPage)allPages.get( pageNumber );
            removed = removePage( page );
        }
        return removed;
    }

    /**
     * This will import and copy the contents from another location.  Currently
     * the content stream is stored in a scratch file.  The scratch file is
     * associated with the document.  If you are adding a page to this document
     * from another document and want to copy the contents to this document's
     * scratch file then use this method otherwise just use the addPage method.
     *
     * @param page The page to import.
     * @return The page that was imported.
     *
     * @throws IOException If there is an error copying the page.
     */
    public PDPage importPage( PDPage page ) throws IOException
    {
        PDPage importedPage = new PDPage( new COSDictionary( page.getCOSDictionary() ) );
        InputStream is = null;
        OutputStream os = null;
        try
        {
            PDStream src = page.getContents();
            PDStream dest = new PDStream( new COSStream( src.getStream(), document.getScratchFile() ) );
            importedPage.setContents( dest );
            os = dest.createOutputStream();

            byte[] buf = new byte[10240];
            int amountRead = 0;
            is = src.createInputStream();
            while((amountRead = is.read(buf,0,10240)) > -1)
            {
                os.write(buf, 0, amountRead);
            }
            addPage( importedPage );
        }
        finally
        {
            if( is != null )
            {
                is.close();
            }
            if( os != null )
            {
                os.close();
            }
        }
        return importedPage;

    }

    /**
     * Constructor that uses an existing document.  The COSDocument that
     * is passed in must be valid.
     *
     * @param doc The COSDocument that this document wraps.
     */
    public PDDocument( COSDocument doc )
    {
        document = doc;
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
     * This will get the document info dictionary.  This is guaranteed to not return null.
     *
     * @return The documents /Info dictionary
     */
    public PDDocumentInformation getDocumentInformation()
    {
        if( documentInformation == null )
        {
            COSDictionary trailer = document.getTrailer();
            COSDictionary infoDic = (COSDictionary)trailer.getDictionaryObject( COSName.INFO );
            if( infoDic == null )
            {
                infoDic = new COSDictionary();
                trailer.setItem( COSName.INFO, infoDic );
            }
            documentInformation = new PDDocumentInformation( infoDic );
        }
        return documentInformation;
    }

    /**
     * This will set the document information for this document.
     *
     * @param info The updated document information.
     */
    public void setDocumentInformation( PDDocumentInformation info )
    {
        documentInformation = info;
        document.getTrailer().setItem( COSName.INFO, info.getDictionary() );
    }

    /**
     * This will get the document CATALOG.  This is guaranteed to not return null.
     *
     * @return The documents /Root dictionary
     */
    public PDDocumentCatalog getDocumentCatalog()
    {
        if( documentCatalog == null )
        {
            COSDictionary trailer = document.getTrailer();
            COSDictionary infoDic = (COSDictionary)trailer.getDictionaryObject( COSName.ROOT );
            if( infoDic == null )
            {
                documentCatalog = new PDDocumentCatalog( this );
            }
            else
            {
                documentCatalog = new PDDocumentCatalog( this, infoDic );
            }

        }
        return documentCatalog;
    }

    /**
     * This will tell if this document is encrypted or not.
     *
     * @return true If this document is encrypted.
     */
    public boolean isEncrypted()
    {
        return document.isEncrypted();
    }

    /**
     * This will get the encryption dictionary for this document.  This will still
     * return the parameters if the document was decrypted.  If the document was
     * never encrypted then this will return null.  As the encryption architecture
     * in PDF documents is plugable this returns an abstract class, but the only
     * supported subclass at this time is a PDStandardEncryption object.
     *
     * @return The encryption dictionary(most likely a PDStandardEncryption object)
     *
     * @throws IOException If there is an error determining which security handler to use.
     */
    public PDEncryptionDictionary getEncryptionDictionary() throws IOException
    {    
        if( encParameters == null ) 
        {
            if( isEncrypted() )
            {
                encParameters = new PDEncryptionDictionary(document.getEncryptionDictionary());
            }
            else
            {
                encParameters = new PDEncryptionDictionary();
            }
        }
        return encParameters;               
    }

    /**
     * This will set the encryption dictionary for this document.
     *
     * @param encDictionary The encryption dictionary(most likely a PDStandardEncryption object)
     *
     * @throws IOException If there is an error determining which security handler to use.
     */
    public void setEncryptionDictionary( PDEncryptionDictionary encDictionary ) throws IOException
    {
        encParameters = encDictionary;
    }

    /**
     * This will determine if this is the user password.  This only applies when
     * the document is encrypted and uses standard encryption.
     *
     * @param password The plain text user password.
     *
     * @return true If the password passed in matches the user password used to encrypt the document.
     *
     * @throws IOException If there is an error determining if it is the user password.
     * @throws CryptographyException If there is an error in the encryption algorithms.
     * 
     * @deprecated
     */
    public boolean isUserPassword( String password ) throws IOException, CryptographyException
    {
            return false;
        /*boolean retval = false;
        if( password == null )
        {
            password = "";
        }
        PDFEncryption encryptor = new PDFEncryption();
        PDEncryptionDictionary encryptionDictionary = getEncryptionDictionary();
        if( encryptionDictionary == null )
        {
            throw new IOException( "Error: Document is not encrypted" );
        }
        else
        {
            if( encryptionDictionary instanceof PDStandardEncryption )
            {
                COSString documentID = (COSString)document.getDocumentID().get(0);
                PDStandardEncryption standard = (PDStandardEncryption)encryptionDictionary;
                retval = encryptor.isUserPassword(
                    password.getBytes(),
                    standard.getUserKey(),
                    standard.getOwnerKey(),
                    standard.getPermissions(),
                    documentID.getBytes(),
                    standard.getRevision(),
                    standard.getLength()/8 );
            }
            else
            {
                throw new IOException( "Error: Encyption dictionary is not 'Standard'" +
                    encryptionDictionary.getClass().getName() );
            }
        }
        return retval;*/
    }

    /**
     * This will determine if this is the owner password.  This only applies when
     * the document is encrypted and uses standard encryption.
     *
     * @param password The plain text owner password.
     *
     * @return true If the password passed in matches the owner password used to encrypt the document.
     *
     * @throws IOException If there is an error determining if it is the user password.
     * @throws CryptographyException If there is an error in the encryption algorithms.
     * 
     * @deprecated
     */
    public boolean isOwnerPassword( String password ) throws IOException, CryptographyException
    {
            return false;
        /*boolean retval = false;
        if( password == null )
        {
            password = "";
        }
        PDFEncryption encryptor = new PDFEncryption();
        PDEncryptionDictionary encryptionDictionary = getEncryptionDictionary();
        if( encryptionDictionary == null )
        {
            throw new IOException( "Error: Document is not encrypted" );
        }
        else
        {
            if( encryptionDictionary instanceof PDStandardEncryption )
            {
                COSString documentID = (COSString)document.getDocumentID().get( 0 );
                PDStandardEncryption standard = (PDStandardEncryption)encryptionDictionary;
                retval = encryptor.isOwnerPassword(
                    password.getBytes(),
                    standard.getUserKey(),
                    standard.getOwnerKey(),
                    standard.getPermissions(),
                    documentID.getBytes(),
                    standard.getRevision(),
                    standard.getLength()/8 );
            }
            else
            {
                throw new IOException( "Error: Encyption dictionary is not 'Standard'" +
                    encryptionDictionary.getClass().getName() );
            }
        }
        return retval;*/
    }

    /**
     * This will decrypt a document. This method is provided for compatibility reasons only. User should use
     * the new security layer instead and the openProtection method especially. 
     *
     * @param password Either the user or owner password.
     *
     * @throws CryptographyException If there is an error decrypting the document.
     * @throws IOException If there is an error getting the stream data.
     * @throws InvalidPasswordException If the password is not a user or owner password.
     * 
     */
    public void decrypt( String password ) throws CryptographyException, IOException, InvalidPasswordException
    {
        try 
        {
            StandardDecryptionMaterial m = new StandardDecryptionMaterial(password);
            this.openProtection(m);        
            document.dereferenceObjectStreams();
        }
        catch(BadSecurityHandlerException e)
        {
            throw new CryptographyException(e);
        }
    }
    
    /**
     * This will tell if the document was decrypted with the master password.  This
     * entry is invalid if the PDF was not decrypted.
     * 
     * @return true if the pdf was decrypted with the master password.
     * 
     * @deprecated use <code>getCurrentAccessPermission</code> instead
     */
    public boolean wasDecryptedWithOwnerPassword()
    {
        return false;        
    }

    /**
     * This will <b>mark</b> a document to be encrypted.  The actual encryption
     * will occur when the document is saved.
     * This method is provided for compatibility reasons only. User should use
     * the new security layer instead and the openProtection method especially.
     *
     * @param ownerPassword The owner password to encrypt the document.
     * @param userPassword The user password to encrypt the document.
     *
     * @throws CryptographyException If an error occurs during encryption.
     * @throws IOException If there is an error accessing the data.
     * 
     */
    public void encrypt( String ownerPassword, String userPassword )
        throws CryptographyException, IOException
    {
        try
        {
            StandardProtectionPolicy policy = 
                new StandardProtectionPolicy(ownerPassword, userPassword, new AccessPermission());
            this.protect(policy);
        }
        catch(BadSecurityHandlerException e)
        {
            throw new CryptographyException(e);
        }                
    }
    
    
    /**
     * The owner password that was passed into the encrypt method. You should
     * never use this method.  This will not longer be valid once encryption
     * has occured.
     * 
     * @return The owner password passed to the encrypt method.
     * 
     * @deprecated Do not rely on this method anymore. 
     */
    public String getOwnerPasswordForEncryption()
    {
        return null;
    }
    
    /**
     * The user password that was passed into the encrypt method.  You should
     * never use this method.  This will not longer be valid once encryption
     * has occured.
     * 
     * @return The user password passed to the encrypt method.
     * 
     * @deprecated Do not rely on this method anymore.
     */
    public String getUserPasswordForEncryption()
    {
        return null;       
    }
    
    /**
     * Internal method do determine if the document will be encrypted when it is saved.
     * 
     * @return True if encrypt has been called and the document 
     *              has not been saved yet.
     *              
     * @deprecated Do not rely on this method anymore. It is the responsibility of 
     * COSWriter to hold this state       
     */
    public boolean willEncryptWhenSaving()
    {
        return false;
    }
    
    /**
     * This shoule only be called by the COSWriter after encryption has completed.
     * 
     * @deprecated Do not rely on this method anymore. It is the responsability of
     * COSWriter to hold this state.
     */
    public void clearWillEncryptWhenSaving()
    {
        //method is deprecated.
    }
    
    /**
     * This will load a document from a url.
     *
     * @param url The url to load the PDF from.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static PDDocument load( URL url ) throws IOException
    {
        return load( url.openStream() );
    }
    
    /**
     * This will load a document from a url.
     *
     * @param url The url to load the PDF from.
     * @param scratchFile A location to store temp PDFBox data for this document.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static PDDocument load( URL url, RandomAccess scratchFile ) throws IOException
    {
        return load( url.openStream(), scratchFile );
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
    public static PDDocument load( String filename ) throws IOException
    {
        return load( new FileInputStream( filename ) );
    }
    
    /**
     * This will load a document from a file.
     *
     * @param filename The name of the file to load.
     * @param scratchFile A location to store temp PDFBox data for this document.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static PDDocument load( String filename, RandomAccess scratchFile ) throws IOException
    {
        return load( new FileInputStream( filename ), scratchFile );
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
    public static PDDocument load( File file ) throws IOException
    {
        return load( new FileInputStream( file ) );
    }
    
    /**
     * This will load a document from a file.
     *
     * @param file The name of the file to load.
     * @param scratchFile A location to store temp PDFBox data for this document.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static PDDocument load( File file, RandomAccess scratchFile ) throws IOException
    {
        return load( new FileInputStream( file ) );
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
    public static PDDocument load( InputStream input ) throws IOException
    {
        return load( input, null );
    }
    
    /**
     * This will load a document from an input stream.
     *
     * @param input The stream that contains the document.
     * @param scratchFile A location to store temp PDFBox data for this document.
     *
     * @return The document that was loaded.
     *
     * @throws IOException If there is an error reading from the stream.
     */
    public static PDDocument load( InputStream input, RandomAccess scratchFile ) throws IOException
    {
        PDFParser parser = new PDFParser( new BufferedInputStream( input ), scratchFile );
        parser.parse();
        return parser.getPDDocument();
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
        //update the count in case any pages have been added behind the scenes.
        getDocumentCatalog().getPages().updateCount();
        COSWriter writer = null;
        try
        {
            writer = new COSWriter( output );
            writer.write( this );
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
     * This will return the total page count of the PDF document.  Note: This method
     * is deprecated in favor of the getNumberOfPages method.  The getNumberOfPages is
     * a required interface method of the Pageable interface.  This method will
     * be removed in a future version of PDFBox!!
     *
     * @return The total number of pages in the PDF document.
     * @deprecated Use the getNumberOfPages method instead!
     */
    public int getPageCount()
    {
        return getNumberOfPages();
    }
    
    /**
     * {@inheritDoc}
     */
    public int getNumberOfPages()
    {
        PDDocumentCatalog cat = getDocumentCatalog();
        return (int)cat.getPages().getCount();
    }
    
    /**
     * {@inheritDoc}
     */
    public PageFormat getPageFormat(int pageIndex)
    {
        PDPage page = (PDPage)getDocumentCatalog().getAllPages().get( pageIndex );
        PDRectangle mediaBox = page.findMediaBox();
        PageFormat format = new PageFormat();
        Paper paper = new Paper();
        //hmm the imageable area might need to be the CropBox instead
        //of the media box???
        double width=mediaBox.getWidth();
        double height=mediaBox.getHeight();
        if( width > height )
        {
            format.setOrientation( PageFormat.LANDSCAPE );
            width=mediaBox.getHeight();
            height=mediaBox.getWidth();
        }
        paper.setImageableArea( 0,0,width,height);
        paper.setSize( width, height );
        format.setPaper( paper );
        return format;
    }
    
    /**
     * {@inheritDoc}
     */
    public Printable getPrintable(int pageIndex)
    {
        return (Printable)getDocumentCatalog().getAllPages().get( pageIndex );
    }
    
    /**
     * This will send the PDF document to a printer.  The printing functionality
     * depends on the org.pdfbox.pdfviewer.PageDrawer functionality.  The PageDrawer
     * is a work in progress and some PDFs will print correctly and some will
     * not.  This is a convenience method to create the java.awt.print.PrinterJob.  
     * The PDDocument implements the java.awt.print.Pageable interface and 
     * PDPage implementes the java.awt.print.Printable interface, so advanced printing
     * capabilities can be done by using those interfaces instead of this method. 
     * 
     * @throws PrinterException If there is an error while sending the PDF to
     * the printer, or you do not have permissions to print this document.
     */
    public void print() throws PrinterException
    {
        
        AccessPermission currentPermissions = this.getCurrentAccessPermission();
        
        if(!currentPermissions.canPrint())
        {
            throw new PrinterException( "You do not have permission to print this document." );    
        }
        PrinterJob printJob = PrinterJob.getPrinterJob();
        printJob.setPageable(this);
        if( printJob.printDialog() )
        {
            printJob.print();
        }
    }
    
    /**
     * This will send the PDF to the default printer without prompting the user
     * for any printer settings. 
     * 
     * @see PDDocument#print()
     * 
     * @throws PrinterException If there is an error while printing.
     */
    public void silentPrint() throws PrinterException
    {
        
        AccessPermission currentPermissions = this.getCurrentAccessPermission();
        
        if(!currentPermissions.canPrint())
        {
            throw new PrinterException( "You do not have permission to print this document." ); 
        }
        PrinterJob printJob = PrinterJob.getPrinterJob();
        printJob.setPageable(this);
        printJob.print();
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
    
    
    /**
     * Protects the document with the protection policy pp. The document content will be really encrypted
     * when it will be saved. This method only marks the document for encryption.
     * 
     * @see org.pdfbox.pdmodel.encryption.StandardProtectionPolicy
     * @see org.pdfbox.pdmodel.encryption.PublicKeyProtectionPolicy
     * 
     * @param pp The protection policy.
     * 
     * @throws BadSecurityHandlerException If there is an error during protection.
     */    
    public void protect(ProtectionPolicy pp) throws BadSecurityHandlerException
    {
        SecurityHandler handler = SecurityHandlersManager.getInstance().getSecurityHandler(pp);
        securityHandler = handler;
    }
    
    /**
     * Tries to decrypt the document in memory using the provided decryption material.
     * 
     *  @see org.pdfbox.pdmodel.encryption.StandardDecryptionMaterial
     *  @see org.pdfbox.pdmodel.encryption.PublicKeyDecryptionMaterial
     * 
     * @param pm The decryption material (password or certificate).
     * 
     * @throws BadSecurityHandlerException If there is an error during decryption.
     * @throws IOException If there is an error reading cryptographic information.
     * @throws CryptographyException If there is an error during decryption.
     */    
    public void openProtection(DecryptionMaterial pm) 
        throws BadSecurityHandlerException, IOException, CryptographyException 
    {
        PDEncryptionDictionary dict = this.getEncryptionDictionary();
        if(dict.getFilter() != null)
        {
            SecurityHandler handler = SecurityHandlersManager.getInstance().getSecurityHandler(dict.getFilter());
            securityHandler = handler;
            handler.decryptDocument(this, pm);
            document.dereferenceObjectStreams();
        }
        else 
        {
            throw new RuntimeException("This document does not need to be decrypted");
        }
    }
    
    /**
     * Returns the access permissions granted when the document was decrypted.
     * If the document was not decrypted this method returns the access permission 
     * for a document owner (ie can do everything).
     * The returned object is in read only mode so that permissions cannot be changed.
     * Methods providing access to content should rely on this object to verify if the current
     * user is allowed to proceed.
     * 
     * @return the access permissions for the current user on the document.
     */
    
    public AccessPermission getCurrentAccessPermission()
    {
        if(this.securityHandler == null)
        {
            return AccessPermission.getOwnerAccessPermission();
        }
        return securityHandler.getCurrentAccessPermission();
    }
    
    /**
     * Get the security handler that is used for document encryption.
     * 
     * @return The handler used to encrypt/decrypt the document.
     */
    public SecurityHandler getSecurityHandler()
    {
        return securityHandler;
    }
}