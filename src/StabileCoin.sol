// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {ERC20} from "./ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {EthUsdPrice} from "./EthUsdPrice.sol";

contract StabilCoin is ERC20 {
    DepositorCoin public depositorCoin;
    EthUsdPrice public ethUsdPrice;
    uint256 public feeRatePercentage;

    constructor(string memory name_, string memory symbol_, EthUsdPrice _ethUsdPrice,uint256 _feeRatePercentage) ERC20(name_, symbol_) {
        ethUsdPrice = _ethUsdPrice;
        feeRatePercentage = _feeRatePercentage; 
    }

    function mint() external payable {
        uint256 mintStabilCoin = msg.value * ethUsdPrice.getPrice();
        _mint(msg.sender, mintStabilCoin);
    }

    function burn(uint256 burnStableCoinAmount) external {
        _burn(msg.sender, burnStableCoinAmount);
        uint256 refundingEth = burnStableCoinAmount / ethUsdPrice.getPrice();

        (bool success,) = msg.sender.call{value: refundingEth}("");
        require(success, "STC: Burn Refund transaction failed");
    }

    function depositCollateralBuffer() external payable {
        uint256 surplusInUsd = _getSurplusInContractInUsd();
        uint256 usdInDpcPrice = depositorCoin.totalSupply() / surplusInUsd;
        uint256 mintDepositorCoinAmount = msg.value * ethUsdPrice.getPrice() * usdInDpcPrice;

        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    function withdrawCollateralBuffer(uint256 burnDepositorCoinAmount) external {
        uint256 surplusInUsd = _getSurplusInContractInUsd();
        uint256 usdInDpcPrice = depositorCoin.totalSupply() / surplusInUsd;
        depositorCoin.burn(msg.sender, burnDepositorCoinAmount);

        uint256 refundingUsd = burnDepositorCoinAmount / usdInDpcPrice;
        uint256 refundingEth = refundingUsd / ethUsdPrice.getPrice();

        (bool success,) = msg.sender.call{value: refundingEth}("");
        require(success, "STC: Withdraw collateral buffer transaction failed");
    }

    function _getSurplusInContractInUsd() private view returns (uint256) {
        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) * ethUsdPrice.getPrice();
        uint256 totalStabilCoinBalanceInUsd = totalSupply();
        uint256 surplus = totalStabilCoinBalanceInUsd - ethContractBalanceInUsd;
        return surplus;
    }
}
