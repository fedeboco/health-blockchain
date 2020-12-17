# Blockchain for health record tracking
Based on Ethereum, IPFS, MetaMask and MyEtherWallet. MINGW64 environment.

This repo shows the basics of blockchains and IPFS integration. It lacks of security features, register encryption and IPFS' CID encryption. A consistent API should be developed. The implemented contract allows a medic to upload a health record's IPFS ID and a patient to download it, using the decentralized server to retrieve the file.

---

# References

**Blockchain testing with Truffle and Ganache**
- https://www.trufflesuite.com/docs/truffle/getting-started/installation
- https://www.trufflesuite.com/ganache
- https://www.trufflesuite.com/tutorials/configuring-visual-studio-code

**Solidity docs (contracts)**
- https://docs.soliditylang.org/en/v0.5.3/assembly.html

**IPFS docs**
- https://docs.ipfs.io/

**Other references**
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6764776/
- https://www.researchgate.net/publication/346581282_A_Blockchain_based_solution_for_Managing_Transplant_Waiting_Lists_and_Medical_Records

---

# Setup Truffle

Truffle install (requires Node.js)

    npm install -g truffle

Project init in current directory

    truffle init

Install Ganache GUI and start the workspace on Truffle's project directory.

---

# Private Server in IPFS

Install IPFS (GUI is also available. Used GUI on Windows and CLI on Linux)

    sudo snap install ipfs

Check version (mine is in 0.7.0)

    ipfs version

Init config

    ipfs init

Generate random swarm key (swarm ID). Only nodes with this ID can connect to the swarm / network, so we need to copy this file on every node.

    echo -e "/key/swarm/psk/1.0.0/\n/base16/\n`tr -dc 'a-f0-9' < /dev/urandom | head -c64`" > ~/.ipfs/swarm.key

Remove bootstrap nodes and check it's `null`. A bootstrap node is a peer node that also connects clients to other nodes of the network. We want to manually define them.

    ipfs bootstrap rm --all
    ipfs config show

Get node ID of bootstrap node

    ipfs config show | grep "PeerID"

Example: `12D3KooWLQFyJEBs3MG26tumCDFcE6AAAZpreDoAN9e581mDs11c`

Get IP of bootstrap node with `ipconfig` on Windows or `netsat -rn` on Linux, for a local network. On Virtual Box, typical IP's are `192.168.56.1` and `10.0.2.2`. Check with `ping` on both systems.

Add bootstrap node on every machine, including the bootstrap node itself (remove with `rm` instead of `add` or `rm --all`).

    ipfs bootstrap add /ip4/<ip>/tcp/4001/ipfs/<peer id hash>

Example: `ipfs bootstrap add /ip4/192.168.56.1/tcp/4001/ipfs/12D3KooWLQFyJEBlertPNtumCDFE1a6e8F4eDoAN9eJ581mDs11c`

Start IPFS

    ipfs daemon

Check connection to peer

    ipfs swarm peers
    ipfs ping /ip4/<ip>/tcp/4001/ipfs/<peer id hash>

---

# Working with files in IPFS

Add file (returns hash)

    echo "Hola Mundo!" > test.txt
    ipfs add test.txt

Output file

    ipfs cat <hash>

Example: `ipfs cat QmbAYbAss5d8PJaCK4CKMZXBxvRghMCA7iuc43NWxpyuYT`

Save file

    ipfs cat QmbAYbAss5d8PJaC94CK4CXBxvRghMCA7iuc43NWxpyuYT > test.txt

Check bandwidth use

    ipfs stats bw

---

# Truffle & Ganache

## Test contract

In truffle directory, create a contract

    truffle create contract HelloWorld

Open `HelloWorld.sol` file created in `contracts` and write ni function `hi()`

    pragma solidity >=0.4.22 <0.8.0;

    contract HelloWorld {
        constructor() public {
        }

        function hi() public pure returns (string memory) {
            return ("Hola");
        }
    }

Compile contract

    truffle compile

Create a `2_deploy_hello_contract.js` file in `migrations` folder for deploying contract

    var HelloWorld = artifacts.require("./HelloWorld.sol");

    module.exports = function (deployer) {
        deployer.deploy(HelloWorld);
    };

Launch Ganache and get the `RPC SERVER address`, `port` and `network_id`. Now, edit `truffle-config.js` file in `truffle` folder, uncommenting and editing the following lines, replacing data with your Ganache's data

    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: 5777,
        }

Deploy your contracts

    truffle migrate

Open console

    truffle console

On console (should display `truffle(development)>`) test your contract

    HelloWorld.deployed().then(function(contractInstance){contractInstance.hi().then(function(v){console.log(v)})})

---

# Healthcare test using MyEtherWallet

Create new contract

    truffle create contract HealthRecord

Add some code in `HealthRecord.sol` where `uploadRecord()` allows medics to upload some record's IPFS ID in `recordHash` and the patient's blockchain address in `patient`

    pragma solidity >=0.4.22 <0.8.0;

    contract HealthRecord {
        address private patient;
        string private recordHash;
        bool private seen;

        constructor() public {}

        function uploadRecord(  string memory inputHash, 
                                address inputPatient) 
                                public returns(bool) {
            recordHash = inputHash;
            patient = inputPatient;
            seen = false;
            return true;
        }

        function getRecordHash() public view returns (string memory) {
            require(msg.sender == patient, "Invalid address.");
            return recordHash;
        }
    }

Deploy contract

    truffle migrate

Install `MetaMask` at `https://metamask.io/` for your internet browser.

Add local blockchain to `Metamask`. Usual URL on Virtual Box is `http://10.0.2.2:7545`.

![alt text](https://github.com/fedeboco/health-blockchain/blob/main/img/7%20-%20metamaskConfig.png?raw=true)

Import Ganache accounts to metamask using private keys.

![alt text](https://github.com/fedeboco/health-blockchain/blob/main/img/8%20-%20metamaskUser.png?raw=true)

Login to `https://www.myetherwallet.com/` using `MetaMask`

![alt text](https://github.com/fedeboco/health-blockchain/blob/main/img/9%20-%20MEWLogin.png?raw=true)

Under contracts section, select your contract using the contract's blockchain address and your contract's `ABI` info available in the `HealthRecord.json` file under the `build` folder. Input the patient's address and health record's IPFS ID

![alt text](https://github.com/fedeboco/health-blockchain/blob/main/img/10%20-%20HospitalUpload.png?raw=true)

Now in the patient's computer (Ubuntu), download the file using the same contract. Be sure to be logged in patient's account.

![alt text](https://github.com/fedeboco/health-blockchain/blob/main/img/13%20-%20linuxContract.png?raw=true)

Start IPFS client with `ipfs daemon` on terminal

![alt text](https://github.com/fedeboco/health-blockchain/blob/main/img/15%20-%20ipfs%20running.png?raw=true)

Download your health record with `ipfs cat <IPFS CID>` where `IPFS CID` is the ID the patient downloaded from MyEtherWallet.

![alt text](https://github.com/fedeboco/health-blockchain/blob/main/img/16%20-%20registryGet.png?raw=true)

