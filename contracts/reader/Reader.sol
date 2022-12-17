// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../data/Keys.sol";
import "../market/MarketUtils.sol";
import "../market/Market.sol";
import "../market/MarketStore.sol";
import "../position/Position.sol";
import "../position/PositionUtils.sol";

// @title Reader
// @dev Library for read functions
contract Reader {
    using Position for Position.Props;

    struct PositionInfo {
        Position.Props position;
        uint256 pendingBorrowingFees;
        PositionPricingUtils.PositionFundingFees pendingFundingFees;
    }

    function getMarkets(MarketStore marketStore, uint256 start, uint256 end) external view returns (Market.Props[] memory) {
        uint256 marketCount = marketStore.getMarketCount();
        if (start >= marketCount) {
            return new Market.Props[](0);
        }
        if (end > marketCount) {
            end = marketCount;
        }
        address[] memory marketKeys = marketStore.getMarketKeys(start, end);
        Market.Props[] memory markets = new Market.Props[](marketKeys.length);
        for (uint256 i = 0; i < marketKeys.length; i++) {
            address marketKey = marketKeys[i];
            Market.Props memory market = MarketUtils.getMarket(marketStore, marketKey);
            markets[i] = market;
        }

        return markets;
    }

    function getAccountPositionInfoList(DataStore dataStore, MarketStore marketStore, PositionStore positionStore, address account, uint256 start, uint256 end) external view returns (PositionInfo[] memory) {
        uint256 positionCount = positionStore.getAccountPositionCount(account);
        if (start >= positionCount) {
            return new PositionInfo[](0);
        }
        if (end > positionCount) {
            end = positionCount;
        }
        bytes32[] memory positionKeys = positionStore.getAccountPositionKeys(account, start, end);
        PositionInfo[] memory positionInfoList = new PositionInfo[](positionKeys.length);
        for (uint256 i = 0; i < positionKeys.length; i++) {
            bytes32 positionKey = positionKeys[i];
            positionInfoList[i] = getPositionInfo(dataStore, marketStore, positionStore, positionKey);
        }

        return positionInfoList;
    }

    function getPositionInfo(DataStore dataStore, MarketStore marketStore, PositionStore positionStore, bytes32 positionKey) public view returns (PositionInfo memory) {
        Position.Props memory position = positionStore.get(positionKey);
        Market.Props memory market = marketStore.get(position.market());
        uint256 pendingBorrowingFees = MarketUtils.getBorrowingFees(dataStore, position);
        PositionPricingUtils.PositionFundingFees memory pendingFundingFees = PositionPricingUtils.getFundingFees(
            dataStore,
            position,
            market.longToken,
            market.shortToken
        );

        return PositionInfo(
            position,
            pendingBorrowingFees,
            pendingFundingFees
        );
    }

    function getMarketTokenPrice(
        DataStore dataStore,
        Market.Props memory market,
        Price.Props memory longTokenPrice,
        Price.Props memory shortTokenPrice,
        Price.Props memory indexTokenPrice,
        bool maximize
    ) external view returns (uint256) {
        return MarketUtils.getMarketTokenPrice(
            dataStore,
            market,
            longTokenPrice,
            shortTokenPrice,
            indexTokenPrice,
            maximize
        );
    }

    function getNetPnl(
        DataStore dataStore,
        address market,
        address longToken,
        address shortToken,
        Price.Props memory indexTokenPrice,
        bool maximize
    ) external view returns (int256) {
        return MarketUtils.getNetPnl(
            dataStore,
            market,
            longToken,
            shortToken,
            indexTokenPrice,
            maximize
        );
    }

    function getPnl(
        DataStore dataStore,
        address market,
        address longToken,
        address shortToken,
        Price.Props memory indexTokenPrice,
        bool isLong,
        bool maximize
    ) internal view returns (int256) {
        return MarketUtils.getPnl(
            dataStore,
            market,
            longToken,
            shortToken,
            indexTokenPrice,
            isLong,
            maximize
        );
    }
}
