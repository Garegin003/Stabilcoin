// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity 0.8.26;

contract ERC20 {
    uint256 private totalTokens;
    address public owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Mint(address _to, uint256 _value);
    event Burn(address _from, uint256 _value);

    constructor(string memory name_, string memory symbol_) {
        owner = msg.sender;
        _name = name_;
        _symbol = symbol_;

    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not an Owner");
        _;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(balanceOf(_from) >= _value, "Not enough tokens");
        require(_to != address(0), "Transfer to zero address");

        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        emit Transfer(msg.sender, _to, _value);
        return _transfer(msg.sender, _to, _value);
    }

    function mint(address _to, uint256 _value) external onlyOwner {
        _mint(_to, _value);
    }

    function _mint(address _to, uint256 _value) internal {
        balances[_to] += _value;
        totalTokens += _value;
        emit Transfer(address(0), _to, _value);
        emit Mint(_to, _value);
    }

    function burn(address _from, uint256 _value) external onlyOwner {
        _burn(_from, _value);
    }

    function _burn(address _from, uint256 _value) internal {
        balances[_from] -= _value;
        totalTokens -= _value;
        emit Transfer(_from, address(0), _value);
        emit Burn(_from, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(allowances[_from][msg.sender] >= _value, "Allowance exceeded");
        require(balanceOf(_from) >= _value, "Not enough tokens");
        require(_to != address(0), "Transfer to zero address");

        allowances[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        require(_spender != address(0), "Approve to zero address");

        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return allowances[_owner][_spender];
    }
}
