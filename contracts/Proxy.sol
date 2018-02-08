pragma solidity ^0.4.18;

import './interfaces/IERC20.sol';
import './interfaces/IProxy.sol';

contract Proxy is IProxy {

    IERC20 public BT;
    IERC20 public QT;

    address public owner;
    address public buyer;
    uint256 public optionsExpiry;
    uint256 public strikePrice;

    modifier onlyOption() {
        require(msg.sender == owner);
        _;
    }

    function Proxy(address _baseToken, address _quoteToken, uint256 _expiry, uint256 _strikePrice, address _buyer) public {
        owner = msg.sender;
        BT = IERC20(_baseToken);
        QT = IERC20(_quoteToken); 
        optionsExpiry = _expiry;
        strikePrice = _strikePrice;
        buyer = _buyer;
    }

    function distributeStakes(address _to, uint256 _amount) onlyOption public returns (bool success) {
        require(msg.sender == owner);
        require(QT.transfer(_to, strikePrice));
        require(QT.transferFrom(_to, buyer, _amount));
        return true; 
    } 

    function withdrawal() onlyOption public returns (bool success) {
        require(msg.sender == owner);
        require(now > optionsExpiry);
        uint256 balanceBT = BT.balanceOf(this);
        uint256 balanceQT = QT.balanceOf(this);
        require(BT.transfer(buyer, balanceBT));
        require(QT.transfer(buyer, balanceQT));
        return true;
    }

}