contract Orientation
{

    struct student
    {
        address choice[]; // person delegated to
        uint rank;   // index of the voted proposal
    }
    // This is a type for a single proposal.
    struct School
    {
        bytes32 name;   // short name (up to 32 bytes)
        uint id;
        uint available;
        address ranks[];

    }

    address public School;

    mapping(address => School) public School;
    School[] public schools;
    Student[] public students;


    function Orientation(bytes32[] proposalNames)
    {
        choices = students[choice];
        for choice in choices{
            uint i = 0;
            while (school[i].name != choice)
            i++;
                if ( student.rank > min(school[i].ranks.length) ) {
                school[i].ranks.pop(min(school[i].ranks.length);
                school[i].ranks.push(student.rank);
                return;
                }

            }));
    }

    // Give `Student` the right to choose a school.
    // May only be called by `choice`.
    