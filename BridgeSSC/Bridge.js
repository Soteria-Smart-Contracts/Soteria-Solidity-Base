import { Web3 } from 'web3';

const web3 = new Web3("https://node.expanse.tech/");

LatestBlock = await web3.eth.getBlock('latest') // get latest block