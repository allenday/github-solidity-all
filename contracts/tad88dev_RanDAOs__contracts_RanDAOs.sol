/*
RanDAOs - RanDAO Simple
Copyright (C) 2016  Dung Tran <tad88.dev@gmail.com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
pragma solidity ^0.4.2;

contract RanDAOs{
    uint256 constant MIN_DEPOSIT = 1 ether;
    uint16 constant MIN_POWER = 128;
    uint16 constant MAX_POWER = 4096;
    uint16 constant MIN_DIFFERENCE = 16;
    uint16 constant FINGERPRINT_LEN = 128;
    uint constant MAX_CONRIBUTE = 5;
    uint constant ROUND_LENGTH = 20;

    uint256 TotalCampaign = 0;
    
    struct Contribute{
        address Sender;
        bytes32 Key;
        uint16 Power;
        uint16 Difference;
        uint32 Difficulty;
    }
    
    struct Campaign{
        uint256 CampaignId;
        address Creator;
        uint256 StartBlock;
        uint256 Deposit;
        uint16 Difference;
        uint16 Power;
        uint32 Difficulty;
        uint128 Fingerprint;
        uint8 Total;
        uint128 Result;
        mapping (uint => Contribute) Contributes;
    }

    //Events

    //New campaign created
    event EventNewCampaign(
        address Creator,
        uint256 Campaign_id,
        uint256 Deposit,
        uint128 Fingerprint,
        uint32 Difficulty,
        uint256 Require_deposit);
    
    //New challenger is success
    event EventNewChallenger(
        address Challenger,
        uint256 Campaign_id,
        uint128 Fingerprint,
        uint32 Difficulty,
        uint256 Require_deposit);
    
    mapping  (uint => Campaign) StoreCampaigns;

    //Calculate Difficulty
    function _DifficultyCalulate(uint16 Power, uint16 Difference)
    private returns(uint32) {
        return uint32(Power)*(2**16) | (uint32(FINGERPRINT_LEN) - uint32(Difference));
    }
    
    /*
    Check campaign is available
    */
    function IsCampaignAvailable(uint CampaignId)
    public returns(bool){
        return StoreCampaigns[CampaignId].Creator == address(0);
    }
    
    /*
    Create new campaign by giving valid DIFFERENCE and POWER
    */
    function CreateCampaign (uint16 Difference, uint16 Power)
    public payable returns(uint256){
        uint256 CampaignId;
        Campaign memory NewCampaign;
        //Only accept lower than 32 bits difference
        if(Difference > MIN_DIFFERENCE 
            || Power < MIN_POWER
            || msg.value < MIN_DEPOSIT){
            throw;
        }else{
            CampaignId = TotalCampaign++;
            NewCampaign.Creator = msg.sender;
            NewCampaign.Deposit = msg.value;

            NewCampaign.StartBlock = block.number;
            NewCampaign.Difficulty = _DifficultyCalulate(Power, Difference);
            NewCampaign.Difference = Difference;
            NewCampaign.Power = Power;
            NewCampaign.Fingerprint = uint128(block.blockhash(block.number-1));

            //Show us new event is ready
            EventNewCampaign(
                msg.sender,
                CampaignId,
                msg.value,
                NewCampaign.Fingerprint,
                NewCampaign.Difficulty,
                msg.value/10
            );

            NewCampaign.CampaignId = CampaignId; 
            StoreCampaigns[CampaignId] = NewCampaign;
            return CampaignId;
        }
    }

    function StartCampaign(){
        
    } 
    
    /*
    Submit your contribute, if it wasn't existing then:
    We will add to contribute if total submissions <  MAX_CONRIBUTE
    We will update if it is a better contribute which have greater power and lower difference bits.
    */
    function Submit(uint256 MyCampaign, bytes32 Key, uint16 Power)
    public payable returns(bool){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        Contribute memory CurContribute;
        //Make sure that contribute is good power
        if(Power < MIN_POWER
            || Power > MAX_POWER
            || CurCampaign.Creator == address(0)){
            throw;
        }
        bytes32 Buffer = sha3(CurCampaign.Fingerprint, Key);
        for(uint16 Index = 1; Index < Power; Index++){
            Buffer = sha3(Buffer);
        }
        CurContribute.Difference = BitCompare(uint128(Buffer), CurCampaign.Fingerprint);
        CurContribute.Difficulty = _DifficultyCalulate(Power, CurContribute.Difference);

        if(CurContribute.Difference <= CurCampaign.Difference
            && CurContribute.Difficulty > CurCampaign.Difficulty
            && msg.value >= CurCampaign.Deposit/10){
            
            CurContribute.Sender = msg.sender;
            CurContribute.Key = Key;
            CurContribute.Power = Power;

            //Update new difficulty, newer challenger must pass
            CurCampaign.Difficulty = CurContribute.Difficulty;

            //Add gurantee deposit
            CurCampaign.Deposit += msg.value;

            //Update fingerprint for new challenger
            CurCampaign.Fingerprint = uint128(Key) / 2**FINGERPRINT_LEN;

            //New challenger have successed
            EventNewChallenger(
                msg.sender,
                CurCampaign.CampaignId,
                CurCampaign.Fingerprint,
                CurCampaign.Difficulty,
                CurCampaign.Deposit/10
            );
            
            if(CurCampaign.Total < MAX_CONRIBUTE){
                return AddContribute(MyCampaign, CurContribute);
            }else{
                return UpdateContribute(MyCampaign, CurContribute);
            }
        }
        throw;
    }
    
    /*
    Get the result if possible
    */
    function GetResult(uint256 MyCampaign)
    public returns(uint192){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        if(CurCampaign.Result != 0){
            return CurCampaign.Result;
        }
        throw;
    }
    
    /*
    Reveal the result
    1st 50% prize pool
    2nd 20% prize pool
    3rd 15% prize pool
    4th 10% prize pool
    5th 5% prize pool
    All other contributors lost their deposit
    */
    function Reveal(uint256 MyCampaign)
    public returns(uint192){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        uint256 RandomNumber = 0;
        if(CurCampaign.Result == 0){
            throw;
        }
        if(CurCampaign.Creator == msg.sender){
            for(uint Count = CurCampaign.Total; Count < CurCampaign.Total; Count++){
                RandomNumber ^= uint256(CurCampaign.Contributes[Count].Key);
            }
            CurCampaign.Result = uint128(RandomNumber/(2**128)); //Remove 128 bits fingerprint
            return CurCampaign.Result;
        }
    }
    
    /*
    Compare two number and count how many difference bits
    */
    function BitCompare(uint NumberA, uint NumberB)
    internal returns(uint16){
        uint Difference = NumberA ^ NumberB;
        uint16 CompareResult = 0;
        while(Difference > 0){
            if(Difference & 1 == 1){
                CompareResult++;  
            }
            Difference = Difference/(2**1); //Shift right 1 bit
        }
        return CompareResult;
    }
    
    /*
    If your contribute is new it will be accept
    */
    function AddContribute(uint256 MyCampaign, Contribute NewContribute)
    internal returns(bool){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        CurCampaign.Contributes[CurCampaign.Total] = NewContribute;
        CurCampaign.Total++;
        return true;
    }
    
    /*
    Update old contribute by new one if it better (Have higher DIFFICULTY)
    */
    function UpdateContribute(uint256 MyCampaign, Contribute NewContribute)
    internal returns(bool){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        uint256 LowestDifficulty = 0;
        uint8 IndexDifficulty = 0;
        for(uint8 Count = CurCampaign.Total; Count > 0; Count--){
            //Set inital value for LowestDifficulty
            if(Count == CurCampaign.Total){
                LowestDifficulty = CurCampaign.Contributes[Count].Difficulty;
            }
            //Searching for LowestDifficulty index number
            if(LowestDifficulty > CurCampaign.Contributes[Count].Difficulty) {
                LowestDifficulty = CurCampaign.Contributes[Count].Difficulty;
                IndexDifficulty = Count;
            }
        }
        //Update old contribute by higher difficulty
        if(NewContribute.Difficulty > CurCampaign.Contributes[IndexDifficulty].Difficulty){
            CurCampaign.Contributes[IndexDifficulty] = NewContribute;
            return true;
        }
        return false;
    }
}
