
let ABI = window.abi;
let contractAddress = "0xE852Bef357307B3480C6f36bF1C0FBB0c07d78A4";
loginWithEth();


async function loginWithEth(){
    if(window.ethereum){
        await ethereum.request({ method: 'eth_requestAccounts' });
        window.web3 = await new Web3(ethereum);
        accountarray = await web3.eth.getAccounts();
        contract = new window.web3.eth.Contract(ABI, contractAddress, window.web3);
        account = accountarray[0];

    } else {
        alert("No ETHER Wallet available")
    }
}

async function GetLists(HolderList){ 
    let Addresses = [];
    let IDs = [];
    let index = 0;
    let len = HolderList.length;
    console.log(len)

    while(len > index){
        let IDlist = await contract.methods.walletOfOwner(HolderList[index]).call();
        innerindex = 0;
        while(IDlist.length > innerindex){
            Addresses.push(HolderList[index]);
            IDs.push(IDlist[innerindex]);
            innerindex++;
        }
        index++;
    }
    console.log(Addresses);
    console.log(IDs);
    return(Addresses, IDs);
}