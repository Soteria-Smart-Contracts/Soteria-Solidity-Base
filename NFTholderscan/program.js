
let ABI = window.abi;
let contractAddress = "0x208a67F5e2e0f58FC9b118618eE2c2324F2E2b4e";
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
    index = 0;

    while(HolderList.length < index){
        let IDlist = await contract.methods.walletOfOwner(HolderList[index]).call();
        
    }

}