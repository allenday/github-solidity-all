pragma solidity ^0.4.8;

// MPQ Archives
// MPQ file format http://www.zezula.net/en/mpq/mpqformat.html

// Python MPQ Lib: https://github.com/eagleflo/mpyq/blob/master/mpyq.py

// Golang MPQ Lib: https://github.com/aphistic/go.Zamara/tree/master/mpq

// 依赖 `zlib` 和 `bz2` 压缩算法

import {Zlib} from './zlib.sol';
import {BZip2} from './bzip2.sol';

library Mpq {
    uint32 constant MPQ_FILE_IMPLODE        = 0x00000100;
    uint32 constant MPQ_FILE_COMPRESS       = 0x00000200;
    uint32 constant MPQ_FILE_ENCRYPTED      = 0x00010000;
    uint32 constant MPQ_FILE_FIX_KEY        = 0x00020000;
    uint32 constant MPQ_FILE_SINGLE_UNIT    = 0x01000000;
    uint32 constant MPQ_FILE_DELETE_MARKER  = 0x02000000;
    uint32 constant MPQ_FILE_SECTOR_CRC     = 0x04000000;
    uint32 constant MPQ_FILE_EXISTS         = 0x80000000;
    
    // MPQ user data
    struct TMPQUserData {
        // The ID_MPQ_USERDATA ('MPQ\x1B') signature
        bytes4 dwID;

        // Maximum size of the user data
        DWORD cbUserDataSize;

        // Offset of the MPQ header, relative to the begin of this header
        DWORD dwHeaderOffs;

        // Appears to be size of user data header (Starcraft II maps)
        DWORD cbUserDataHeader;
    }

    // MPQ file header
    struct TMPQHeader {
        // The ID_MPQ ('MPQ\x1A') signature
        bytes4 dwID;                         
        // Size of the archive header
        uint32 dwHeaderSize;                   

        // Size of MPQ archive
        // This field is deprecated in the Burning Crusade MoPaQ format, and the size of the archive
        // is calculated as the size from the beginning of the archive to the end of the hash table,
        // block table, or extended block table (whichever is largest).
        uint32 dwArchiveSize;

        // 0 = Format 1 (up to The Burning Crusade)
        // 1 = Format 2 (The Burning Crusade and newer)
        // 2 = Format 3 (WoW - Cataclysm beta or newer)
        // 3 = Format 4 (WoW - Cataclysm beta or newer)
        uint16 wFormatVersion;

        // Power of two exponent specifying the number of 512-byte disk sectors in each logical sector
        // in the archive. The size of each logical sector in the archive is 512 * 2^wBlockSize.
        uint16 wBlockSize;

        // Offset to the beginning of the hash table, relative to the beginning of the archive.
        uint32 dwHashTablePos;
        
        // Offset to the beginning of the block table, relative to the beginning of the archive.
        uint32 dwBlockTablePos;
        
        // Number of entries in the hash table. Must be a power of two, and must be less than 2^16 for
        // the original MoPaQ format, or less than 2^20 for the Burning Crusade format.
        uint32 dwHashTableSize;
        
        // Number of entries in the block table
        uint32 dwBlockTableSize;

        //-- MPQ HEADER v 2 -------------------------------------------

        // Offset to the beginning of array of 16-bit high parts of file offsets.
        uint64 HiBlockTablePos64;

        // High 16 bits of the hash table offset for large archives.
        uint16 wHashTablePosHi;

        // High 16 bits of the block table offset for large archives.
        uint16 wBlockTablePosHi;

        //-- MPQ HEADER v 3 -------------------------------------------

        // 64-bit version of the archive size
        uint64 ArchiveSize64;

        // 64-bit position of the BET table
        uint64 BetTablePos64;

        // 64-bit position of the HET table
        uint64 HetTablePos64;

        //-- MPQ HEADER v 4 -------------------------------------------

        // Compressed size of the hash table
        uint64 HashTableSize64;

        // Compressed size of the block table
        uint64 BlockTableSize64;

        // Compressed size of the hi-block table
        uint64 HiBlockTableSize64;

        // Compressed size of the HET block
        uint64 HetTableSize64;

        // Compressed size of the BET block
        uint64 BetTableSize64;

        // Size of raw data chunk to calculate MD5.
        // MD5 of each data chunk follows the raw file data.
        uint32 dwRawChunkSize;                                 

        // Array of MD5's
        unsigned char MD5_BlockTable[MD5_DIGEST_SIZE];      // MD5 of the block table before decryption
        unsigned char MD5_HashTable[MD5_DIGEST_SIZE];       // MD5 of the hash table before decryption
        unsigned char MD5_HiBlockTable[MD5_DIGEST_SIZE];    // MD5 of the hi-block table
        unsigned char MD5_BetTable[MD5_DIGEST_SIZE];        // MD5 of the BET table before decryption
        unsigned char MD5_HetTable[MD5_DIGEST_SIZE];        // MD5 of the HET table before decryption
        unsigned char MD5_MpqHeader[MD5_DIGEST_SIZE];       // MD5 of the MPQ header from signature to (including) MD5_HetTable
    }

    function parse(bytes mpq_archives) returns (string){
        return "TODO";
    }

    function list_files() {

    }

    function 
}

