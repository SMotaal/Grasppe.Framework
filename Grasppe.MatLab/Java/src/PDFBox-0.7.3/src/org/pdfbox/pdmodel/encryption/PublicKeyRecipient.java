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
package org.pdfbox.pdmodel.encryption;

import java.security.cert.X509Certificate;

/**
 * Represents a recipient in the public key protection policy.
 * 
 * @see PublicKeyProtectionPolicy
 * 
 * @author Benoit Guillon (benoit.guillon@snv.jussieu.fr)
 * 
 * @version $Revision: 1.2 $
 */
public class PublicKeyRecipient 
{   
    private X509Certificate x509;
    
    private AccessPermission permission;

    /**
     * Returns the X509 certificate of the recipient.
     * 
     * @return The X509 certificate
     */
    public X509Certificate getX509() 
    {
        return x509;
    }

    /**
     * Set the X509 certificate of the recipient.
     * 
     * @param aX509 The X509 certificate
     */
    public void setX509(X509Certificate aX509) 
    {
        this.x509 = aX509;
    }

    /**
     * Returns the access permission granted to the recipient.
     * 
     * @return The access permission object.
     */
    public AccessPermission getPermission() 
    {
        return permission;
    }

    /**
     * Set the access permission granted to the recipient.
     * 
     * @param permissions The permission to set.
     */
    public void setPermission(AccessPermission permissions) 
    {
        this.permission = permissions;
    }
}
