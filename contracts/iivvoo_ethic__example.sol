contract Example {

       string s;

       function set_s(string new_s) {
           s = new_s;
       }

       function get_s() returns (string) {
           return s;
       }
   }
