// https://docs.google.com/presentation/d/1vBViqLBR0bD3hOY_SgQUwMFj9Nq8eCgggCmlx6_Tz04/edit#slide=id.g9c10c90de_0_10

contract greeter {
    function greet(bytes32 input) returns (bytes32) {
        if (input == "") { 
            return "Hello, World"; 
        } else {
            return input;
        }
    }
}
