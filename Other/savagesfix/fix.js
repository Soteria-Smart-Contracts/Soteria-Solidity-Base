const ABI = window.abi;
const contractAddress = '0x9Ad9fd0b94d47D342e92AB5998197Ae89B802B9A';
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

async function checknum(){ 
    let num = await contract.methods.lastnum().call();
    console.log(num);
    document.getElementsByClassName("num")[0].innerHTML = num;
    return num;
}

