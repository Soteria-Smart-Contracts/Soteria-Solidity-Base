
let ABI = window.abi;
let contractAddress =
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