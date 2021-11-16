pragma solidity ^0.8.4;


contract Multi_Sig {
    uint8 Signatures;
    string text;
    string newtext;
    address MultiSig1;
    address MultiSig2;
    address MultiSig3;
    
    mapping(address => uint8) Signed;
    
    constructor(){
        MultiSig1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        MultiSig2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        MultiSig3 = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
        Signed[MultiSig1] = 0;
        Signed[MultiSig2] = 0;
        Signed[MultiSig3] = 0;
    }
    
    function changetext(string memory Text) public returns (bool success){
        require(msg.sender == MultiSig1 || msg.sender == MultiSig2 || msg.sender == MultiSig3);
        require(Signed[msg.sender] == 0);
        Signed[msg.sender] = 1;
        if (Signatures == 2){
            text = newtext;
            Signatures = 0;
            Signed[MultiSig1] = 0;
            Signed[MultiSig2] = 0;
            Signed[MultiSig3] = 0;
        }
        if (Signatures == 1){
            Signatures = (Signatures + 1);
        }
        if (Signatures == 0){
            newtext = Text;
            Signatures = (Signatures + 1);
        }
        
        return(success);
        
    }
    
    function GetText()public view returns(string memory _text){
        return(text);
    }
    
    function getSigned() public view returns(uint8 _Signed){
        return(Signed[msg.sender]);
    }
    
    
    //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    //0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c
}
