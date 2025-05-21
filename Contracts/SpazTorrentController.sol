// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SpazTorrentControl {
    address public owner;

    enum TorrentStatus { None, Added, Paused, Resumed, Deleted }

    struct Torrent {
        string magnetURI;
        TorrentStatus status;
    }

    mapping(string => Torrent) private torrents;

    event SpazTorrentAdded(string magnetURI);
    event SpazTorrentPaused(string magnetURI);
    event SpazTorrentResumed(string magnetURI);
    event SpazTorrentDeleted(string magnetURI);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier torrentExists(string memory magnetURI) {
        require(torrents[magnetURI].status != TorrentStatus.None, "Torrent does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addSpazTorrent(string memory magnetURI) public onlyOwner {
        require(torrents[magnetURI].status == TorrentStatus.None, "Torrent already exists");
        torrents[magnetURI] = Torrent(magnetURI, TorrentStatus.Added);
        emit SpazTorrentAdded(magnetURI);
    }

    function pauseSpazTorrent(string memory magnetURI) public onlyOwner torrentExists(magnetURI) {
        torrents[magnetURI].status = TorrentStatus.Paused;
        emit SpazTorrentPaused(magnetURI);
    }

    function resumeSpazTorrent(string memory magnetURI) public onlyOwner torrentExists(magnetURI) {
        torrents[magnetURI].status = TorrentStatus.Resumed;
        emit SpazTorrentResumed(magnetURI);
    }

    function deleteSpazTorrent(string memory magnetURI) public onlyOwner torrentExists(magnetURI) {
        torrents[magnetURI].status = TorrentStatus.Deleted;
        emit SpazTorrentDeleted(magnetURI);
    }

    function getTorrentStatus(string memory magnetURI) public view returns (TorrentStatus) {
        return torrents[magnetURI].status;
    }

    function isTorrentActive(string memory magnetURI) public view returns (bool) {
        TorrentStatus status = torrents[magnetURI].status;
        return status == TorrentStatus.Added || status == TorrentStatus.Resumed;
    }
}
