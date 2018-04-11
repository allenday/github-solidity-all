contract HotCold {

    // Public generates a getter, e.g contract.hot()

    string4 public hot;
    string4 public cold;

    // Swaps the values, so not const. And doesn't return a value, so no return.

    function swapHotCold() {
        string4 temp = hot;
        hot = cold;
        cold = temp;
    }

    // Constructor, called during contract creation, cannot be called after

    function HotCold() {
        cold = "cold";
        hot = "hot";
    }

}
