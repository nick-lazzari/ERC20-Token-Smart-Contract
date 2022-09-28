//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}


contract ERC20 is IERC20 {
    uint public override totalSupply; // Total Token Supply
    mapping(address => uint) public override balanceOf; // Balance of a given address
    mapping(address => mapping(address =>uint)) public override allowance; // Owner approves spender to spend a certain amount
    string public name = "Test"; // Token Name
    string public symbol = "TEST"; // Token Symbol
    uint8 public decimals = 18; // 10^18 = 1 token

    function transfer(address recipient, uint amount) external override returns (bool) { // Transfer tokens
        balanceOf[msg.sender] -= amount; // Decrements the function callers balance, sets that to their amount
        balanceOf[recipient] += amount; // Increments the recipients balance, sets that to their amount
        emit Transfer(msg.sender, recipient, amount); 
        return true; // Bool set to true
    }

    function approve(address spender, uint amount) external override returns (bool) { // Approves address
        allowance[msg.sender][spender] = amount; // Allowance of specified address is approved by caller, address is set to amount specified
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount; // aloowance of sender is decreased
        balanceOf[sender] -= amount; // balance of sender is decreased
        balanceOf[recipient] += amount; // reciepents balance is updated
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}

contract Vault {
    IERC20 public immutable token;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mint(address _to, uint _amount) private {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
    }

    function _burn(address _to, uint _amount) private {
        totalSupply -= _amount;
        balanceOf[_to] -= _amount;
    }

    function deposit(uint _amount) external {

         /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */

        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint _shares) external {

         /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */

        uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
    }
    
}
