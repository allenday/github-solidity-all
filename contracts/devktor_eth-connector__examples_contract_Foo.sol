contract Foo
{
    mapping(string=>string) data;
    mapping(string=>uint) flags;

    function Foo(string key, string value)
    {
        set(key, value);
    }

    function set(string key, string value)
    {
        data[key] = value;
    }

    function get(string key) returns(string)
    {
        return data[key];
    }

    function setFlag(string key, uint value)
    {
        flags[key] = value;
    }

    function getFlag(string key) returns(uint)
    {
        return flags[key];
    }

}
