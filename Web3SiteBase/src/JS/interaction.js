const contractAddress = "0xf5c9e57e177B4F5CCfCb13b18e4154774E917401";
const ABI = window.abi;
let account;
let netID;


async function loginWithEth(){
    if(LoggedIn == false){
    if(window.ethereum){
        await ethereum.request({ method: 'eth_requestAccounts' });
        window.web3 = await new Web3(ethereum);
        await getID();
        if (netID != 61){
            console.log("The current Metamask/Web3 network is not Ethereum Classic, please connect to the Ethereum Classic."); 
            alert("The current Metamask/Web3 network is not Ropsten, please connect to the Ethereum Classic network.");
            return("Failed to connect")
        }
        accountarray = await web3.eth.getAccounts();
        contract = new window.web3.eth.Contract(ABI, contractAddress, window.web3);
        account = accountarray[0];
    
        console.log('Logged In')
        LoginText.innerHTML = "Connected with:" + '<br>' + account.substring(0, 7) + '...';
        if(CanSign == true){
            Signer.innerText = "This account is a signer"
        }else{
            Signer.innerText = "This account is not a signer"
        }
        LoggedIn = true;
    } else { 
        alert("No ETHER Wallet available")
    }
    }
}