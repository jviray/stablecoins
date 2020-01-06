pragma solidity ^0.5.9;

// https://www.reddit.com/r/MakerDAO/comments/dqq4bq/is_there_a_kovan_dai_faucet/
// https://github.com/makerdao/developerguides/blob/master/dai/dai-in-smart-contracts/README.md

// Adding only the ERC-20 function we need 
interface RinkebyDaiToken {
    function transfer(address dst, uint wad) external returns (bool);
    function balanceOf(address guy) external view returns (uint);
}

contract owned {
    RinkebyDaiToken rdt;
	address owner;

	constructor() public{
		owner = msg.sender;
		rdt = RinkebyDaiToken(0x9364aE80f29472C6BD2a0aA4A37c03207f194DA3);
	}
	
	modifier onlyOwner {
		require(msg.sender == owner,
		        "Only the contract owner can call this function");
		_;
	}
}

contract mortal is owned {
	// Only owner can shutdown this contract. 
	function destroy() public onlyOwner {
	    rdt.transfer(owner, rdt.balanceOf(address(this)));
	    selfdestruct(msg.sender);
	}
}

contract RDTFaucet is mortal {
    
	event Withdrawal(address indexed to, uint amount);
	event Deposit(address indexed from, uint amount);
	

	// Give out Dai to anyone who asks
	function withdraw(uint withdraw_amount) public {
		// Limit withdrawal amount
		require(withdraw_amount <= 0.1 ether);
		require(rdt.balanceOf(address(this)) >= withdraw_amount,
			"Insufficient balance in faucet for withdrawal request");
		// Send the amount to the address that requested it
		rdt.transfer(msg.sender, withdraw_amount);
		emit Withdrawal(msg.sender, withdraw_amount);
	}
	
	// Accept any incoming amount
	function () external payable {
		emit Deposit(msg.sender, msg.value);
	}
}