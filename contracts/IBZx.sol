/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity >=0.5.0 <0.6.0;
pragma experimental ABIEncoderV2;

interface IBZx {
    ////// Loan Closings //////

    function liquidate(
        bytes32 loanId,
        address receiver,
        uint256 closeAmount // denominated in loanToken
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 seizedAmount,
            address seizedToken
        );

    struct LoanReturnData {
        bytes32 loanId;
        uint96 endTimestamp;
        address loanToken;
        address collateralToken;
        uint256 principal;
        uint256 collateral;
        uint256 interestOwedPerDay;
        uint256 interestDepositRemaining;
        uint256 startRate; // collateralToLoanRate
        uint256 startMargin;
        uint256 maintenanceMargin;
        uint256 currentMargin;
        uint256 maxLoanTerm;
        uint256 maxLiquidatable;
        uint256 maxSeizable;
    }

    function getUserLoans(
        address user,
        uint256 start,
        uint256 count,
        uint256 loanType,
        bool isLender,
        bool unsafeOnly
    ) external view returns (LoanReturnData[] memory loansData);

    function getLoan(bytes32 loanId)
        external
        view
        returns (LoanReturnData memory loanData);

    function getActiveLoans(
        uint256 start,
        uint256 count,
        bool unsafeOnly
    ) external view returns (LoanReturnData[] memory loansData);

    function swapExternal(
        address sourceToken,
        address destToken,
        address receiver,
        address returnToSender,
        uint256 sourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bytes calldata swapData
    )
        external
        payable
        returns (
            uint256 destTokenAmountReceived,
            uint256 sourceTokenAmountUsed
        );

    function getSwapExpectedReturn(
        address sourceToken,
        address destToken,
        uint256 sourceTokenAmount
    ) external view returns (uint256);

    function tmpReduceToMarginLevel(bytes32 loanId, uint256 desiredMargin)
        external;
}
