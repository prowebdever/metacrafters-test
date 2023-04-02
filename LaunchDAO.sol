import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DeployContract {

    struct _contract {
        uint id;
        address owner;
        address contractAddress;
    }
    _contract[] Contracts;
    mapping(address => address[]) addressContractMap;
        
    event Launch(address indexed, address indexed);

    constructor() {
         
    }

    function deploy(string memory name, string memory symbol, string memory description, uint256 totalSupply) external returns (address) {
        uint256 tokenSupply = totalSupply*(1 ether);
        DAOLaunch dao = new DAOLaunch(name, symbol, description, tokenSupply, msg.sender);
        Contracts.push();

        uint Index = Contracts.length - 1;
        Contracts[Index].owner = msg.sender;
        Contracts[Index].id = Index;
        Contracts[Index].contractAddress = address(dao);


        addressContractMap[msg.sender].push(address(dao));

        emit Launch(address(dao), msg.sender);

        return address(dao);
    }

    //Returns the DAO contract addresses for a particular owner
    function getContract() external view returns(address[] memory) {
        return(addressContractMap[msg.sender]);
    }

    //Get all the contract addresses of the various DAOs
    function getAllContracts() external view returns(_contract[] memory) {
        return Contracts;
    }

}

/**
 * @title DAOLaunch Token
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 * Based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/examples/SimpleToken.sol
 */
contract DAOLaunch is ERC20 {
    
    address owner;
    uint256 maxSupply;
    bool mintState;
    string daoName;
    string daoSymbol;
    string description;
    bool active;

    event Mint(address indexed, uint256 indexed);


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(string memory _name, string memory _symbol, string memory _description, 
        uint256 totalSupply, address _owner) ERC20(_name, _symbol) {
      daoName = _name;
      description = _description;
      maxSupply = totalSupply;
      owner = _owner;
      daoSymbol = _symbol;
      active = true;
    }

    //Mint the tokens for a DAO - possible only once
    function mintToken() public onlyOwner {
        require(maxSupply > 0, "Maximum Token Supply cannot be 0");
        require(owner != address(0), "Owner cannot be 0 address");
        require(!mintState, "Tokens have already been minted");

        _mint(owner, maxSupply);
        mintState = true;
        emit Mint(msg.sender, maxSupply);

    } 

    function deactivate() public onlyOwner() {
        active = false;
    }

    
    //Return the metadata of a DAO
    function getMetadata() external view returns(string memory, string memory, string memory, uint256, bool) {
        return (daoName, daoSymbol, description, maxSupply, active);
    }

}