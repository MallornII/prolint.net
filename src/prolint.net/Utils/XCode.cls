 
/*------------------------------------------------------------------------
   File        : XCode
   Purpose     : Class for working with xcoded files and data
   Syntax      : 
   Description : 
   Author(s)   : Andrew Ni
   Created     : 04.01.2019 22:27:15
   Notes       : 
 ----------------------------------------------------------------------*/

block-level on error undo, throw.

using Utils.IO.
using Utils.Strings.
using Progress.IO.FileInputStream.

class Utils.XCode final: 

    define private static variable defaultXCodeKey as character initial "Progress" no-undo.
    define private static variable maxKey          as integer   initial 15 no-undo.
    define private static variable _keyData        as integer   extent no-undo. 
    define private static variable _crcTable       as integer   extent no-undo.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
		
    constructor static XCode():
        _crcTable = GetConstantCrcTable().
        SetKey(defaultXCodeKey).
    end constructor.


    /*------------------------------------------------------------------------------
     Purpose: Converts (encodes or decodes) data
     Notes:
    ------------------------------------------------------------------------------*/

    method public static memptr ConvertData
        (
        input inData as memptr,
        input toEncode as logical
        ):
        
        define variable convertedBytes as memptr  no-undo.
        define variable isEncoded      as logical no-undo.
        define variable idx            as integer no-undo.
        define variable i              as integer no-undo.
        define variable crcValue       as integer no-undo.
        define variable base1          as integer no-undo.
        define variable keyValue       as integer no-undo.
        define variable tmpValue       as integer no-undo.
        define variable outData        as memptr  no-undo.
        
        if get-size(inData) = 0 then
            undo, throw new Progress.Lang.AppError("The data is empty, no conversion needed":t, 0).
        
        isEncoded = IsFirstByteFromEncryptedFile(get-byte(inData, 1)).
        
        if isEncoded = toEncode then
            undo, throw new Progress.Lang.AppError(substitute("The data is already &1.":t, if isEncoded then "encoded":t else "decoded":t), 0).
        
        set-size(convertedBytes) = get-size(inData) + 1.
        crcValue = (if get-byte(inData, 1) = 0x11 then 0x0025 else  0x7fed).
        
        if toEncode then
            put-byte(convertedBytes, 1) = 0x13.
            
        do i = (if toEncode then 0 else 1) to get-size(inData) - 1:            
            base1 = Utils.Math:bin_and(idx, maxKey).
            idx = idx + 1.
            keyValue = _keyData[Utils.Math:bin_and(base1 + _keyData[maxKey - base1 + 1], maxKey) + 1].            
            
            put-byte(convertedBytes, idx + 1) = Utils.Math:bin_xor(get-byte(inData, i + 1), keyValue).
            if toEncode then
                tmpValue = _crcTable[get-byte(inData, i + 1) + 1].
            else
                tmpValue = _crcTable[get-byte(convertedBytes, idx + 1) + 1].
            tmpValue = Utils.Math:bin_xor(tmpValue, _crcTable[Utils.Math:bin_and(crcValue, 255) + 1]).
            crcValue = Utils.Math:bin_xor(tmpValue, Utils.Math:bin_and(Utils.Math:bin_rshift(crcValue, 8), 255)).
            tmpValue = _crcTable[Utils.Math:bin_and(keyValue, 255) + 1].
            tmpValue = Utils.Math:bin_xor(tmpValue, _crcTable[Utils.Math:bin_and(crcValue, 255) + 1]).
            crcValue = Utils.Math:bin_xor(tmpValue, Utils.Math:bin_and(Utils.Math:bin_rshift(crcValue, 8), 255)).
            
            _keyData[base1 + 1] = Utils.Math:bin_and(crcValue, 255).
        end. 
        
        set-size(outData) = (if toEncode then idx + 1 else idx).
        copy-lob convertedBytes starting at (if toEncode then 1 else 2) for get-size(outData) to outData overlay at 1.
        set-size(ConvertedBytes) = 0.
        return outData.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Converts (encodes or decodes) file
     Notes:
    ------------------------------------------------------------------------------*/

    method public static void ConvertFile( input sourceFile as character, input toEncode as logical, input targetPath as character ):
        
        define variable targetDir as character no-undo.
        define variable sourcePtr as memptr no-undo.
        define variable targetPtr as memptr no-undo.        
        
        targetDir = IO:GetDirectory(targetPath).
        if not Strings:IsEmptyOrNull(targetDir) and not IO:PathExists(targetDir) then
            os-create-dir value(targetDir).
            
        copy-lob file sourceFile to sourcePtr no-convert.
        targetPtr = ConvertData(sourcePtr, toEncode).
        copy-lob targetPtr to file targetPath no-convert.
        
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private static integer extent GetConstantCrcTable(  ):
        
        define variable crcTable as integer extent 256 no-undo.
        define variable j        as integer no-undo.
        define variable k        as integer no-undo.
        define variable l        as integer no-undo.
        
        do j = 0 to extent(crcTable) - 1:
            k = 1.
            l = 0xC0.
            do while k < 255:
                if Utils.Math:bin_and(j, k) <> 0 then
                    crcTable[j + 1] = Utils.Math:bin_xor(Utils.Math:bin_xor(0xC001, l), crcTable[j + 1]).
                k = Utils.Math:bin_lshift(k, 1).
                l = Utils.Math:bin_lshift(l, 1).
            end.
        end.

        return crcTable.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private static integer extent GetKeyData( input inKey as character ):
        
        define variable outputKeyBytes as integer extent no-undo.
        define variable keyBytes       as integer extent 8 no-undo.
        define variable i              as integer no-undo.
        define variable offset         as integer no-undo.
        
        if inKey = ? then
            inKey = defaultXCodeKey.
            
        extent(outputKeyBytes) = maxKey + 1.
        
        do i = 1 to 8:
            keyBytes[i] = asc(substring(inKey, i, 1)).
        end.
        
        do i = 0 to extent(keyBytes) - 1:
            offset = Utils.Math:bin_and((i - keyBytes[4]), 7).         
            outputKeyBytes[offset + 1] = (if keyBytes[i + 1] = 0 then 17 + offset else keyBytes[i + 1] + i).
            outputKeyBytes[i + 9] = Utils.Math:bin_xor(outputKeyBytes[offset + 1], keyBytes[Utils.Math:bin_and(i - 5, 7) + 1]).
        end.
        
        return outputKeyBytes.     

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static logical IsFileEncoded( input sourceFile as character ):
        define variable inStream as Progress.IO.FileInputStream no-undo.
        define variable firstByte as memptr no-undo.
        
        if not IO:PathExists(sourceFile) then
            return false.        
        
        inStream = new FileInputStream(sourceFile).
        set-size(firstByte) = 1.
        inStream:Read(firstByte, 1, 1).
        return IsFirstByteFromEncryptedFile(get-byte(firstByte, 1)).
        
        finally:
            set-size(firstByte) = 0.
            inStream:Close().
            delete object inStream.
        end finally.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private static logical IsFirstByteFromEncryptedFile( input firstByte as integer ):        
        return Utils.Math:bin_or(firstByte, 2) = 0x13.
    end method.

    /*------------------------------------------------------------------------------
     Purpose: Sets the key for encoding or decoding
     Notes:
    ------------------------------------------------------------------------------*/

    method public static void SetKey( input inKey as character ):
        
        define variable i as integer no-undo.
        _keyData = GetKeyData(inKey).   
        return.

    end method.

end class.