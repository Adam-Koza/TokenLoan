pragma solidity 0.5.0;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a, "Overflow detected.");
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "Underflow detected.");
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "Overflow detected.");
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0, "Can't divide by zero.");
        c = a / b;
    }
}