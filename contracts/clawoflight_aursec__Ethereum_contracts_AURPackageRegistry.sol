// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
// Copyright © 2016-2017 Lukas Krismer and Bennett Piater.

pragma solidity ^0.4.0;
import "contracts/Owned.sol";

/**
 * @title Registry of AUR package hashes
 * @author Bennett Piater
 */
contract AURPackageRegistry is Owned {

    // Struct that holds the consensus and the number of submissions for each hash for a package.
    struct PackageData {
        string currentConsensusPkgHash;
        string secondBestPkgHash;
        mapping (string => uint) timesHashSubmitted;
    }

    // Map "$pkgname-$pkgver-$pkgrel" to the corresponding struct
    mapping (string => PackageData) packages;

    // Map a hash to a map of addresses.
    // This allows checking whether an address submitted a hash.
    mapping (string => mapping (address => bool)) addressesThatSubmittedAHash;

    event PkgHashSubmitted(string indexed packageID, string pkgHash, uint submissionCount, address indexed submitter);
    event ConsensusFormed(string indexed packageID, string pkgHash, uint submissionCount, uint secondBestSubmissionCount);
    event SecondMostCommonHashChanged(string indexed packageID, string pkgHash, uint submissionCount);

    /**
     * @notice Get the current consensus and how many nodes submitted it for a given package,version,release combination.
     *
     * @param packageID The id of the package to submit: pkgname-pkgver-pkgrel
     *
     * @return pkgHash The hash of the package, or the empty string if none is stored.
     * @return submissionCount The number of nodes that submitted this hash
     */
    function getCurrentConsensus(string packageID) constant returns (string pkgHash, uint submissionCount, uint secondBestSubmissionCount) {
        string hash = packages[packageID].currentConsensusPkgHash;
        string secondBestHash = packages[packageID].secondBestPkgHash;
        return (hash, packages[packageID].timesHashSubmitted[hash], packages[packageID].timesHashSubmitted[secondBestHash]);
    }


    /**
     * @notice Submit a new hash for a package.
     *
     * @param packageID The id of the package to submit: pkgname-pkgver-pkgrel
     * @param pkgHash The hash of the package
     * @return success Whether the submission succeeded
     */
    function submitPkgHash(string packageID, string pkgHash) returns (bool success) {
        // Only allow every address (=client, ideally) to submit a hash once
        if (addressesThatSubmittedAHash[pkgHash][msg.sender])
            return false;
        addressesThatSubmittedAHash[pkgHash][msg.sender] = true;

        PackageData package = packages[packageID];
        package.timesHashSubmitted[pkgHash] += 1;
        PkgHashSubmitted(packageID, pkgHash, package.timesHashSubmitted[pkgHash], msg.sender); // Trigger notification

        // If this hash has become the new consensus
        if (package.timesHashSubmitted[pkgHash] > package.timesHashSubmitted[package.currentConsensusPkgHash]) {
            package.secondBestPkgHash = package.currentConsensusPkgHash; // Remember the previous consensus
            package.currentConsensusPkgHash = pkgHash;
            // Trigger notification
            ConsensusFormed(packageID, pkgHash, package.timesHashSubmitted[pkgHash], package.timesHashSubmitted[package.secondBestPkgHash]);

        // If this hash has become the new second-most often committed hash
        } else if (package.timesHashSubmitted[pkgHash] > package.timesHashSubmitted[package.secondBestPkgHash]) {
            package.secondBestPkgHash = pkgHash;
            SecondMostCommonHashChanged(packageID, pkgHash, package.timesHashSubmitted[pkgHash]);
        }
        return true;
    }
}
