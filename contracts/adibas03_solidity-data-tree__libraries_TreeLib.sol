pragma solidity ^0.4.11;

library TreeLib{

    /* Base structures, members can be combined to create the right structure

    struct Base{ //Base members required by all structures
        bytes32 id;//Id of the structure
        uint mtype;//Type of structure [ increses from 0 for the base structure (main nodes) ]
    }

    struct Sibling{ //members for structures which have siblings
        bytes32 left; //Id to sibling on the left
        bytes32 right; //Id to sibling on the right
    }

    struct Group{ //members for structures which are parents
        uint size; //Total number of children
        uint maxsize; //Max allowed number of children
        bytes32 root; //Id for the first child
        bytes32 last; //Id for the last child
        mapping(bytes32=>Base) children //List of children, type of child has to be a valid type to work
    }

    struct Child{ //members for structure which have parents
        bytes32 parent;//Id of the parent
    }

    struct Content{ //Actual data members
        bytes32 data;//Actual data being saved, could be changed to desired type
    }
    */

    struct Node{ //The base structure
        uint mtype;
        bytes32 id;
        bytes32 left;
        bytes32 right;
        bytes32 parent;
        bytes32 data;
    }

    struct Section{ //The structure having Nodes as its children
        uint mtype;
        uint size;
        uint maxsize;
        bytes32 id;
        bytes32 left;
        bytes32 right;
        bytes32 root;
        bytes32 last;
        bytes32 parent;
        mapping(bytes32=>Node) children;
    }

    /*
    //Only enabled if max_dept >2
    struct SubSection{ //The intermediarry structure, multiple layers can exist under one Index
        uint mtype;
        uint size;
        uint maxsize;
        bytes32 id;
        bytes32 left;
        bytes32 right;
        bytes32 parent;
        mapping(bytes32=>Section) children; //Can either be SubSections or Sections
    }

    //Only enabled if max_dept >3
    struct SupSection{ //The intermediarry structure, multiple layers can exist under one Index
        uint mtype;
        uint size;
        uint maxsize;
        bytes32 id;
        bytes32 left;
        bytes32 right;
        bytes32 parent;
        mapping(bytes32=>SubSection) children; //Can either be SubSections or Sections
    }

    //Add more types as necessary based on Max depth
    */

    struct Index{ //The highest structure
        uint mtype;
        uint size;
        uint maxsize;
        bytes32 id;
        bytes32 root;
        bytes32 last;
        mapping(bytes32=>Section) children;
    }


    function getNode(Section storage sector, bytes32 node_id) constant returns (bytes32 id,bytes32 left,bytes32 right,bytes32 parent,bytes32 data){
        //set returns based on nature of base node
        //set correct type of parent of Node as designed

        return (sector.children[node_id].id,sector.children[node_id].left,sector.children[node_id].right,sector.children[node_id].parent,sector.children[node_id].data);
    }

    function removeSection(Index storage index,bytes32 section_id) internal {
      require(index.children[section_id].id == section_id);
      Section storage sector = index.children[section_id];

      index.children[sector.left].right = sector.right;
      if(index.root == section_id)
      index.root = sector.right;

      index.children[sector.right].left = sector.left;
      if(index.last == section_id)
      index.last = sector.left;

      delete(index.children[section_id]);
      if(index.size>0)
      index.size--;
    }

    function removeNode(Section storage sector,bytes32 node_id){
      require(sector.children[node_id].id == node_id);
      Node storage node = sector.children[node_id];

      sector.children[node.left].right = node.right;
      if(sector.root == node_id)
      sector.root = node.right;

      sector.children[node.right].left = node.left;
      if(sector.last == node_id)
      sector.last = node.left;

      delete(sector.children[node_id]);
      if(sector.size>0)
      sector.size--;
    }

    function newIndex(bytes32 index_id,uint maxsize) internal returns(Index memory) {
        return Index(2,0,maxsize,index_id,0x0,0x0); //Update "2" to match ltype index for structure
    }

    function newSection(bytes32 section_id,bytes32 left_id,bytes32 parent_id,uint maxsize) internal returns(Section memory section) {
        return Section(1,0,maxsize,section_id,left_id,0x0,0x0,0x0,parent_id);//Update "1" to match ltype index for structure
    }

    function newNode(bytes32 node_id ,bytes32 left_id,bytes32 right_id,bytes32 parent_id,bytes32 data) internal returns(Node memory node) {
        return Node(0,node_id,left_id,right_id,parent_id,data);//Update initial "0" to match ltype index for structure
    }

    function insertSection(Index storage index,bytes32 section_id) internal { //Create correspondong insert functions for other intermediate types
        require(index.size < index.maxsize);

        if(index.size < 1){
            index.root = section_id;
        }
        else{
            index.children[index.last].right = section_id;
        }
        index.children[section_id] = newSection(section_id,index.last,index.id,index.maxsize);
        index.last = section_id;
        index.size ++;
    }

    function insertNode(Section storage sector,bytes32 node_id,bytes32 data) internal {
        require(sector.size < sector.maxsize);


        if(sector.size < 1){
            sector.root = node_id;
        }
        else{
            sector.children[sector.last].right = node_id;
        }

        sector.children[node_id] = newNode(node_id,sector.last,0x0,sector.id,data);
        sector.last = node_id;
        sector.size ++;
    }

    function insertNodeBatch(Section storage sector,bytes32 left,bytes32 right,bytes32 node_id,bytes32 data) internal {

        if(sector.size < 1){
            sector.root = node_id;
        }

        sector.children[node_id] = newNode(node_id,left,right,sector.id,data);
        sector.last = node_id;
        sector.size ++;
    }

}
