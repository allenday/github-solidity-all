/* A simple Ethereum Virtual Machine Database (EVMDB).
//
// Used for creating/managing DBs on the EVM.
//
// Provides insert, update, delete and search functions.
// The search is only exact search at the moment.
//
// Further developments may include type checking, "select" search,
// complicated DB structues etc.
//
// See https://github.com/eyalron33/EVMDB/ for documentation
//
// License:  MIT 
*/

pragma solidity ^0.4.4;

contract EVMDB {
    int256 constant NOT_FOUND   = -1;

    struct DB {
        address     owner;
        bytes32     name;
        bytes32[]   header;
        bytes32[][] data; 
        uint256[]   primary_key; // Assume 'primary key' is the first column in 'data'
    }
    
    DB[] DBs;
    address god;
    
    function EVMDB() {
        god = msg.sender;
    }
    
    /* Events and Modifiers */
    event DBCreated(bytes32 name, uint256 index);
    event RowInserted(uint256 db, uint256 row);
    event RowUpdated(uint256 db, uint256 row);
    event RowErased(uint256 db, uint256 row);
    modifier onlyGod { if (msg.sender != god) throw; _ ;}
    
    
    /////////////////////////////////////////////////
    /// ... DB manipulation functions ...
    /////////////////////////////////////////////////
     
    /// creates a new DB, and emits an event with the DB id.
    /// Primary key is *always* taken to be the first column.
    ///
    /// @param _name       name of the DB
    /// @param _headers    array (of any size) of DB header names
    ///
    /// @return            id of newly created DB
    function create(bytes32 _name, bytes32[] _headers) external returns (uint256) {
        if (_name != "") {
            uint256 DB_id = DBs.length;
            uint256 i;
        
            //array extension is manual
            DBs.length = DB_id + 1;
            DBs[DB_id].header.length = _headers.length;
        
        
            for (i=0; i<_headers.length; i++) {
                DBs[DB_id].header[i] = _headers[i]; 
            }
        
            DBs[DB_id].name = _name;
            DBs[DB_id].owner = msg.sender;
        
            DBCreated(_name, DB_id);
            return DB_id;
        }
    }
    
    /// inserts data to a new row in the DB
    ///
    /// @param _DB_id   id of the DB
    /// @param _data    data to insert
    ///
    /// @return         id of newly created row
    function insert(uint256 _DB_id, bytes32[] _data) external returns (uint256) {
        if (_DB_id < DBs.length && 
            msg.sender == DBs[_DB_id].owner &&
            _data.length == DBs[_DB_id].header.length) {
            
            uint256 row_id = DBs[_DB_id].data.length;
            uint256 i;
            
            //array extension is manual
            DBs[_DB_id].data.length = row_id + 1;
            DBs[_DB_id].data[row_id].length = _data.length;
        
            for (i=0; i<_data.length; i++) {    
                DBs[_DB_id].data[row_id][i] = _data[i];
            }
            
            //push to primary_key table
            uint256 place = place_to_push(_DB_id, _data[0]);
            push_key(_DB_id, place, row_id);
            
            RowInserted(_DB_id, row_id);
            return row_id;
        } else {
            log1(bytes32(_DB_id),"invalid parameters");
        }
    }
    
    /// updates a row in a DB
    ///
    /// @param _DB_id   id of the DB
    /// @param _row     number of row to update
    /// @param _data    new data
    function update(uint256 _DB_id, uint256 _row, bytes32[] _data) external { //TODO: row_id --> row everywhere
        if (_DB_id < DBs.length && 
            msg.sender == DBs[_DB_id].owner && 
            _row < DBs[_DB_id].data.length &&
            _data.length == DBs[_DB_id].header.length) {

            uint256 i;

            bool already_deleted = true;
            
            for (i=0; i<DBs[_DB_id].data[_row].length; i++) {
                if (DBs[_DB_id].data[_row][i] != 0) {
                    already_deleted = false;   
                }
            }

            //delete key
            if (!already_deleted) {
                int256 place = binary_search(_DB_id, DBs[_DB_id].data[_row][0]);
                delete_key(_DB_id, uint256(place));
            }
            
            //update value
            for (i=0; i<_data.length; i++) {    
                DBs[_DB_id].data[_row][i] = _data[i];
            }
            
            //update key
            place = int256(place_to_push(_DB_id, _data[0]));
            push_key(_DB_id, uint256(place), _row);
            
            RowUpdated(_DB_id, _row);
        } else {
            log1(bytes32(_DB_id),"invalid parameters");
        }
    }
    
    /// deletes a row from a DB
    ///
    /// @param _DB_id   id of the DB
    /// @param _row    number of row to delete
    function erase(uint256 _DB_id, uint256 _row) external {
        if (_DB_id < DBs.length && 
            msg.sender == DBs[_DB_id].owner && 
            _row < DBs[_DB_id].data.length) {
            
            uint256 i;
            bool already_deleted = true;
            
            for (i=0; i<DBs[_DB_id].data[_row].length; i++) {
                if (DBs[_DB_id].data[_row][i] != 0) {
                    already_deleted = false;   
                }
            }
            
            if (!already_deleted) {    
                //delete key
                int256 place = binary_search(_DB_id, DBs[_DB_id].data[_row][0]);
                delete_key(_DB_id, uint256(place));
            
                //delete from DB
                for (i=0; i<DBs[_DB_id].data[_row].length; i++) {
                    delete DBs[_DB_id].data[_row][i];
                }
                RowErased(_DB_id, _row);
            } else {
                log1(bytes32(_DB_id),"row already deleted");
            }        
        } else {
            log1(bytes32(_DB_id),"invalid parameters");
        }
    }
    
    /// search a DB via primary key (which is assumed to be the first column)
    ///
    /// @param _DB_id   id of the DB
    /// @param _value     value to search
    function search(uint256 _DB_id, bytes32 _value) external constant returns (int256) {
        if (_DB_id < DBs.length) {
            int256 place = binary_search(_DB_id, _value);
            if (place > -1) {
                return int256(DBs[_DB_id].primary_key[uint256(place)]);
            } else {
                return place;
            }
        } else {
                return -1;
        }
    }
    
    /////////////////////////////////////////////////
    /// ... Query DB functions ...
    ///////////////////////////////////////////////// 
    
    /// Queries for header names
    ///
    /// @param _DB_id   id of the DB
    ///
    /// @return    array of header name
    function get_header(uint256 _DB_id) constant external returns (bytes32[]) {
        if (_DB_id < DBs.length) {
            return DBs[_DB_id].header;
        } else {
            bytes32[] memory temp;
            temp[0] = "invalid parameters";
            return (temp);
        }
    }
    
    /// Queries for data by row number
    ///
    /// @param _DB_id   id of the DB
    /// @param _row     row number
    ///
    /// @return         array consisting of row's items
    function get_row(uint256 _DB_id, uint256 _row) constant external returns (bytes32[]) {
        if (_DB_id < DBs.length &&
            _row < DBs[_DB_id].data.length) {
            return (DBs[_DB_id].data[_row]);
        } else {
            bytes32[] memory temp;
            temp[0] = "invalid parameters";
            return (temp);
        }
    }
    
    /// Queries for an item by row and column numbers
    ///
    /// @param _DB_id   id of the DB
    /// @param _row     row number
    /// @param _col     column number
    ///
    /// @return         item
    function get_row_col(uint256 _DB_id, uint256 _row, uint256 _col) constant external returns (bytes32) {
        if (_DB_id < DBs.length &&
            _row < DBs[_DB_id].data.length &&
            _col < DBs[_DB_id].header.length) {
            return (DBs[_DB_id].data[_row][_col]);
        } else {
            return ("invalid parameters");
        }
    }
    
    /// Returns DB info: [owner, name, size], where size is #rows
    ///
    /// @param _DB_id   id of the DB
    ///
    /// @return    size of the DB
    function get_DB_info(uint256 _DB_id) constant external returns (address, bytes32, int256) {
        if (_DB_id < DBs.length) {
            return (DBs[_DB_id].owner, DBs[_DB_id].name, int256(DBs[_DB_id].data.length));
        }
        else {
            return (0x0000000000000000000000000000000000000000,"DB_id not existing",-1); // error
        }
    }
    
    /// Queries for the number of DBs in the smart contract
    ///
    /// @return    number of DBs
    function get_number_of_DBs() constant external returns (uint256) {
        return DBs.length;
    }
    
    /////////////////////////////////////////////////
    /// ... Internal Functions ...
    /////////////////////////////////////////////////

    // returns index of an element in a linked list or NOT_FOUND if not found    
    function binary_search(uint256 DB_id, bytes32 data) internal returns (int256) {
        uint256 m=0; // search index
        
        //Using int256 as L may be -1,
        //this means that greatest searched index is 2^128-1,
        int256 L = 0; 
        int256 R = int256(DBs[DB_id].primary_key.length)-1;        

        while (L <= R) {
            m = uint256((L+R)/2);
            if (DBs[DB_id].data[DBs[DB_id].primary_key[m]][0] < data) {
                L = int256(m)+1;
            } else if (DBs[DB_id].data[DBs[DB_id].primary_key[m]][0] > data) {
                R = int256(m)-1;
            } else {
               return int256(m);
            }
        }
        return NOT_FOUND;
    }
    
    // returns a index to enter a new element (unlike searching, who returns a location of an existing element)
    function place_to_push(uint256 DB_id, bytes32 data) internal returns (uint256) {
        uint256 m=0; // search index
        
        //Using int256 as L may be -1,
        //this means that greatest searched index is 2^128-1,
        int256 L = 0; 
        int256 R = int256(DBs[DB_id].primary_key.length)-1;        

        while (L <= R) {
            m = uint256((L+R)/2);
            if (DBs[DB_id].data[DBs[DB_id].primary_key[m]][0] < data) {
                L = int256(m)+1;
            } else if (DBs[DB_id].data[DBs[DB_id].primary_key[m]][0] > data) {  
                R = int256(m)-1;
            } else {
               return m;
            }
        }
        
        if ( (DBs[DB_id].primary_key.length>0) && (DBs[DB_id].data[DBs[DB_id].primary_key[m]][0] < data) )
            return m+1;
        else
            return m;
    }
    
    function push_key(uint256 DB_id, uint256 place, uint256 new_value) internal {
        uint256 i;
        uint256 length = DBs[DB_id].primary_key.length + 1;
        DBs[DB_id].primary_key.length = length; //array extension is manual
        
        // push old key forward to make place for new one
        for (i=length-1; i>place; i--) {
            DBs[DB_id].primary_key[i] = DBs[DB_id].primary_key[i-1];
        }
        
        DBs[DB_id].primary_key[place] = new_value;
    }
    
    function delete_key(uint256 DB_id, uint256 place) internal {
        uint256 i;
        uint256 length = DBs[DB_id].primary_key.length;
        
        for (i=place; i<length-1; i++) {
            DBs[DB_id].primary_key[i] = DBs[DB_id].primary_key[i+1];
        }
        
        delete DBs[DB_id].primary_key[length-1];
        DBs[DB_id].primary_key.length = length - 1;
    }
    
}