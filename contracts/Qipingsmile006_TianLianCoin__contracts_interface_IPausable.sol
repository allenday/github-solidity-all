pragma solidity ^0.4.15;

contract IPausable {
	/* 暂停交易 */
	function pause() public;
	/* 取消暂停 */
	function unPause() public;
}
