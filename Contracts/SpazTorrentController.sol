// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SpazTorrentControl {
    address public owner;

    event SpazTorrentAdded(string magnetURI);
    event SpazTorrentPaused(string magnetURI);
    event SpazTorrentResumed(string magnetURI);
    event SpazTorrentDeleted(string magnetURI);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function addSpazTorrent(string memory magnetURI) public onlyOwner {
        emit SpazTorrentAdded(magnetURI);
    }

    function pauseSpazTorrent(string memory magnetURI) public onlyOwner {
        emit SpazTorrentPaused(magnetURI);
    }

    function resumeSpazTorrent(string memory magnetURI) public onlyOwner {
        emit SpazTorrentResumed(magnetURI);
    }

    function deleteSpazTorrent(string memory magnetURI) public onlyOwner {
        emit SpazTorrentDeleted(magnetURI);
    }
}
