const web3 = new Web3("https://node.expanse.tech/");

function GetLatestBlock
LatestBlock = await web3.eth.getBlock('latest');

console.log(LatestBlock);