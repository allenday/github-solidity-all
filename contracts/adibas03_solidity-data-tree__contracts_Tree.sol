pragma solidity^0.4.11;

import "../libraries/TreeLib.sol";

contract Tree{

    mapping(bytes32=>TreeLib.Index) indexes;//Or a single index, based on how you want to arange your indexes
    mapping(bytes32=>bytes32) parent_child_lookup;

    uint max_depth=2; // Maxdepth of the tree; advised 5
    uint mtypes_count=3;//Count of mtypes,available structure types from the lib
    bytes8[3] mtypes = [ bytes8("Node"), bytes8("Section"), bytes8("Index")]; //Increase type to match structure types
    enum ltypes {Node,Section,Index} //Increase type to match structure types

    uint parent_max_size = 10; //Max size for all parents equaling Max nodes = parent_max_size^(max_depth-1)

    function TreeContract(){
    }

    function indexExists(bytes32 index_id) constant returns (bool){
        return (indexes[index_id].id == index_id);
    }

    function childExists(bytes32 child_id) constant returns(bool){
        return (getParent(child_id) != 0x0);
    }

    function nodeExists(bytes32 index_id,bytes32 node_id) constant returns(bool){
        if(childExists(node_id) ){
          return getHeirachy(node_id)[1] == index_id;
        }
        return false;
    }

    function getParent(bytes32 child_id) constant returns(bytes32){
        return parent_child_lookup[child_id];
    }

    function getHeirachy(bytes32 child_id) constant returns (bytes32[2] memory search_up /*should match (max_depth)*/){
        bytes32 main_index_id;

        //Fetch the node's parent
        main_index_id = getParent(child_id);
        search_up[0] = main_index_id;

        uint i = 1;
        while((main_index_id = getParent(main_index_id)) != 0x0){
        search_up[i] = main_index_id;
        i++;
        }
    }

    function nextSection(bytes32 index_id) internal constant returns (bytes32 id){
      //get the next available section in the index
      TreeLib.Index storage index = indexes[index_id];
      id = indexes[index_id].root;
      while(true){
        if(index.children[id].size+1 > index.maxsize && index.children[id].id != 0x0){
          id = index.children[id].right;
          continue;
        }
        else break;
      }
      return id;
    }

    function getSection(bytes32 section_id) internal constant returns(TreeLib.Section storage sector){
        bytes32[2] memory search_up; //size should match (max_depth)
        search_up = getHeirachy(section_id);

        //GenecricTree.SubSection storage subsector; //Only enabled if max_dept >2
        //Structure based on sector parent being index
        if(search_up.length>0){
          sector = indexes[search_up[0]].children[section_id];
        }
    }

    function getIndex(bytes32 index_id)constant returns(uint mtype,uint size, uint maxsize, bytes32 id, bytes32 root, bytes32 last){

        TreeLib.Index memory index = indexes[index_id];
        return (index.mtype,index.size,index.maxsize,index.id,index.root,index.last);
    }

    function getNode(bytes32 node_id) constant returns (bytes32 id,bytes32 left,bytes32 right,bytes32 parent,bytes32 data){
        //set returns based on nature of base node
        //require(child_type_lookup[node_id] == ltypes.Node);
        return TreeLib.getNode(getSection(getParent(node_id)),node_id);
    }

    function getNodesBatch(bytes32 index_id,bytes32 last_node_id) constant returns (bytes32[5][5] results) {
          TreeLib.Index storage index = indexes[index_id];

          //throw if empty
          require(index.size>0);

          if(last_node_id == 0x0)last_node_id = index.children[index.root].root;
          else last_node_id = index.children[getParent(last_node_id)].children[last_node_id].right;

          bytes32 section_id = getParent(last_node_id);
          TreeLib.Section storage sector = index.children[section_id];

          uint r = 0;

          while(r<5 && last_node_id!=0x0){
           results[0][r]= sector.children[last_node_id].id;
           results[1][r]= sector.children[last_node_id].left;
           results[2][r]= sector.children[last_node_id].right;
           results[3][r]= sector.children[last_node_id].parent;
           results[4][r]= sector.children[last_node_id].data;
           r++;

           if(sector.children[last_node_id].right == 0x0){
             if(sector.right != 0x0){
               sector = index.children[sector.right];
               last_node_id = sector.root;
               continue;
             }
           break;
           }
           else {
             last_node_id = sector.children[last_node_id].right;}
          }

          return results;
    }

    function removeSection(bytes32 index_id,bytes32 section_id) internal idNotEmpty(section_id){
      assert(getParent(section_id) == index_id);
      TreeLib.Index storage index = indexes[index_id];
      delete(parent_child_lookup[section_id]);
      TreeLib.removeSection(index,section_id);
    }

    function removeNode(bytes32 index_id,bytes32 node_id) idNotEmpty(node_id){
      bytes32 section_id = getParent(node_id);
      assert(getParent(section_id) == index_id);
      TreeLib.Section storage sector = getSection(section_id);

      delete(parent_child_lookup[node_id]);
      TreeLib.removeNode(sector,node_id);

      if(sector.size == 0)
      removeSection(index_id,section_id);
    }

    function generateSection() internal constant returns (bytes32 section_id){
      uint i = 0;
      while(childExists(sha3(block.difficulty+i,block.number+i,block.timestamp+1))){
        i++;
      }
      return sha3(block.difficulty+i,block.number+i,block.timestamp+1);
    }

    function newIndex(bytes32 index_id) internal idNotEmpty(index_id){
        indexes[index_id] = TreeLib.newIndex(index_id,parent_max_size);
    }

    function insertSection(bytes32 parent_id) internal returns(bytes32){
        //Create new index, if it does not exist
        if(!indexExists(parent_id))
          newIndex(parent_id);

        bytes32 section_id = generateSection();

        //Parent is an Index, store as child of index
        TreeLib.Index storage index = indexes[parent_id];
        parent_child_lookup[section_id] =  parent_id;
        TreeLib.insertSection(index,section_id);
        return section_id;
    }

    function insertNode(bytes32 index_id, bytes32 node_id, bytes32 data){
        //Ensure index and node are not empty
        require(index_id!= 0x0 && node_id != 0x0);

        //Create new index, if it does not exist
        if(!indexExists(index_id))
          newIndex(index_id);

        //check to see the next available sector
        bytes32 section_id = nextSection(index_id);
        if(section_id == 0x0)
          section_id = insertSection(index_id);

        parent_child_lookup[node_id] =  section_id;
        TreeLib.insertNode(getSection(section_id),node_id,data);
    }

    function insertNodeBatch(bytes32 index_id, bytes32[2][5] data){
      require(index_id!= 0x0);

      //Create new index, if it does not exist
      if(!indexExists(index_id))
        newIndex(index_id);

      //check to see the next available sector
      bytes32 section_id = nextSection(index_id);
      if(section_id == 0x0)
        section_id = insertSection(index_id);
      uint to_fill = indexes[index_id].children[section_id].maxsize - indexes[index_id].children[section_id].size;

      for(uint d=0;d<data.length;d++){
        bytes32 node_id = data[d][0];
        bytes32 node_data = data[d][1];
        //Ensure index and node are not empty
        if(node_id == 0x0)
        continue;

        //Generate new sector if exceeded
        if(to_fill < d+1){
          section_id = nextSection(index_id);
          if(section_id == 0x0)
            section_id = insertSection(index_id);
          to_fill += indexes[index_id].children[section_id].maxsize - indexes[index_id].children[section_id].size;
        }

        bytes32 right = 0x0;
        bytes32 left = 0x0;
        if(d==0){
          TreeLib.Section storage sector = getSection(section_id);
          left = sector.last;
          sector.children[left].right = node_id;
        }
        else{
          left = data[d-1][0];
        }
        if(data.length>d+1)
          right = data[d+1][0];

        parent_child_lookup[node_id] =  section_id;
        TreeLib.insertNodeBatch(getSection(section_id),left,right,node_id,node_data);
      }
    }

    modifier idNotEmpty(bytes32 id){
        require(id != 0x0);
        _;
    }


}
