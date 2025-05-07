// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * @title TimeCapsule
 * @dev A decentralized time capsule contract for storing messages/files on IPFS
 * that can only be accessed after a specific future date and time
 * @author Your Name
 * @notice This contract allows users to create digital time capsules with IPFS content
 */
contract TimeCapsule {
    // Struct to store the details of a Time Capsule
    struct Capsule {
        uint256 unlockTime;    // Final timestamp when capsule can be unlocked
        string messageHash;    // IPFS hash pointing to the capsule's contents (can be encrypted client-side)
        address owner;         // Address of the capsule creator
        string title;          // Title of the capsule
        bool isPublic;         // Whether the capsule is public after unlock
        bool isActive;         // Flag to check if capsule is still active or deleted
        uint256 creationTime;  // When the capsule was created
    }
    
    // Mapping from capsule ID to Capsule details
    mapping(uint256 => Capsule) public capsules;
    uint256 public capsuleCount;
    
    // Events for off-chain indexing
    event CapsuleCreated(uint256 indexed capsuleId, address indexed owner, uint256 unlockTime, string messageHash, string title, bool isPublic, uint256 creationTime);
    event CapsuleUnlocked(uint256 indexed capsuleId, address indexed unlockedBy, uint256 unlockTime);
    event CapsuleDeleted(uint256 indexed capsuleId, address indexed owner, uint256 deletionTime);
    
    /**
     * @dev Creates a new time capsule
     * @param _messageHash IPFS hash of the capsule content (can be encrypted client-side for privacy)
     * @param _unlockDate Unix timestamp of the date (midnight) when capsule should unlock
     * @param _timeOfDayInSeconds Seconds since midnight for the specific unlock time
     * @param _title Title of the capsule
     * @param _isPublic Whether the capsule can be viewed by anyone after unlock
     */
    function createCapsule(
        string memory _messageHash, 
        uint256 _unlockDate, 
        uint256 _timeOfDayInSeconds, 
        string memory _title,
        bool _isPublic
    ) public {
        // Validate time of day input (must be less than 24 hours)
        require(_timeOfDayInSeconds < 86400, "Time of day must be less than 86400 seconds (24 hours)");
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_messageHash).length > 0, "Message hash cannot be empty");
        
        // Calculate the base date (midnight of the unlock date)
        uint256 midnightTimestamp = (_unlockDate / 86400) * 86400;
        
        // Add the time of day to get the final unlock timestamp
        uint256 unlockTimestamp = midnightTimestamp + _timeOfDayInSeconds;
        
        // Ensure the unlock time is in the future
        require(unlockTimestamp > block.timestamp, "Unlock time must be in the future.");
        
        // Increment the capsule count to create a unique ID
        capsuleCount++;
        
        // Create the new capsule and store it in the mapping
        capsules[capsuleCount] = Capsule(
            unlockTimestamp, 
            _messageHash, 
            msg.sender, 
            _title,
            _isPublic,
            true,               // isActive = true
            block.timestamp     // creationTime = now
        );
        
        // Add to user's capsules mapping (gas optimization for retrieval)
        userCapsules[msg.sender].push(capsuleCount);
        
        // Emit the CapsuleCreated event for off-chain indexing
        emit CapsuleCreated(
            capsuleCount, 
            msg.sender, 
            unlockTimestamp, 
            _messageHash, 
            _title,
            _isPublic,
            block.timestamp
        );
    }
    
    /**
     * @dev Unlocks a time capsule and retrieves its IPFS hash if conditions are met
     * @param _capsuleId ID of the capsule to unlock
     * @return messageHash IPFS hash pointing to the capsule's contents
     */
    function unlockCapsule(uint256 _capsuleId) public returns (string memory) {
        // Ensure the capsule exists
        require(_capsuleId > 0 && _capsuleId <= capsuleCount, "Capsule does not exist.");
        
        Capsule storage capsule = capsules[_capsuleId];
        
        // Ensure the capsule is active
        require(capsule.isActive, "Capsule has been deleted.");
        
        // Ensure the current time is greater than or equal to the unlock time
        require(block.timestamp >= capsule.unlockTime, "Capsule is still locked.");
        
        // If the capsule is private, only the owner can unlock it
        if (!capsule.isPublic) {
            require(msg.sender == capsule.owner, "Only the owner can unlock a private capsule.");
        }
        
        // Emit event for analytics
        emit CapsuleUnlocked(_capsuleId, msg.sender, block.timestamp);
        
        // Return the message hash (IPFS hash) of the unlocked capsule
        return capsule.messageHash;
    }
    
    /**
     * @dev Gets details about a capsule with privacy restrictions
     * @param _capsuleId ID of the capsule
     * @return owner Address of capsule creator
     * @return unlockTime Timestamp when capsule can be unlocked
     * @return title Title of the capsule
     * @return isPublic Whether the capsule is public after unlock
     */
    function getCapsuleDetails(uint256 _capsuleId) public view returns (
        address owner, 
        uint256 unlockTime, 
        string memory title,
        bool isPublic
    ) {
        // Ensure the capsule exists
        require(_capsuleId > 0 && _capsuleId <= capsuleCount, "Capsule does not exist.");
        
        Capsule memory capsule = capsules[_capsuleId];
        
        // Restrict access to private capsules
        if (!capsule.isPublic && msg.sender != capsule.owner) {
            revert("Access denied: private capsule");
        }
        
        return (capsule.owner, capsule.unlockTime, capsule.title, capsule.isPublic);
    }
    
    /**
     * @dev Checks if a capsule is ready to be unlocked
     * @param _capsuleId ID of the capsule to check
     * @return Boolean indicating if capsule can be unlocked
     */
    function isCapsuleUnlockable(uint256 _capsuleId) public view returns (bool) {
        // Ensure the capsule exists
        require(_capsuleId > 0 && _capsuleId <= capsuleCount, "Capsule does not exist.");
        
        Capsule memory capsule = capsules[_capsuleId];
        
        // Check if capsule is active and unlockable
        return capsule.isActive && block.timestamp >= capsule.unlockTime;
    }
    
    /**
     * @dev Gets public metadata about a capsule without privacy restrictions
     * @param _capsuleId ID of the capsule
     * @return owner Address of capsule creator
     * @return unlockTime Timestamp when capsule can be unlocked
     * @return isActive Whether the capsule is still active
     * @return isPublic Whether the capsule is public after unlock
     * @notice This function only returns public metadata and not the title
     */
    function getPublicCapsuleMetadata(uint256 _capsuleId) public view returns (
        address owner,
        uint256 unlockTime,
        bool isActive,
        bool isPublic
    ) {
        // Ensure the capsule exists
        require(_capsuleId > 0 && _capsuleId <= capsuleCount, "Capsule does not exist.");
        
        Capsule memory capsule = capsules[_capsuleId];
        return (capsule.owner, capsule.unlockTime, capsule.isActive, capsule.isPublic);
    }
    
    // Mapping to track capsules owned by each address (for gas optimization)
    mapping(address => uint256[]) private userCapsules;
    
    /**
     * @dev Gets all capsule IDs created by a specific address
     * @param _owner Address of the capsule creator
     * @return Array of capsule IDs
     */
    function getCapsulesByOwner(address _owner) public view returns (uint256[] memory) {
        return userCapsules[_owner];
    }
    
    // Public unlockable capsules should be tracked off-chain through events
    // This function returns only the most recent public unlockable capsules to avoid gas issues
    uint256 private constant MAX_PUBLIC_RESULTS = 10;
    
    /**
     * @dev Gets a limited number of most recent public unlockable capsules
     * @return Array of public unlockable capsule IDs (limited to MAX_PUBLIC_RESULTS)
     * @notice This function is gas-limited and returns at most MAX_PUBLIC_RESULTS capsules
     * @notice For a complete list, use events and off-chain indexing
     */
    function getRecentPublicUnlockableCapsules() public view returns (uint256[] memory) {
        // Count how many public unlockable capsules exist (up to the limit)
        uint256 publicUnlockableCount = 0;
        uint256 resultCount = 0;
        
        // Count backward from most recent capsules
        for (uint256 i = capsuleCount; i > 0 && resultCount < MAX_PUBLIC_RESULTS; i--) {
            if (capsules[i].isPublic && block.timestamp >= capsules[i].unlockTime) {
                publicUnlockableCount++;
                resultCount++;
            }
        }
        
        // Create an array to store the capsule IDs
        uint256[] memory result = new uint256[](publicUnlockableCount);
        uint256 counter = 0;
        
        // Fill the array with the capsule IDs (most recent first)
        resultCount = 0;
        for (uint256 i = capsuleCount; i > 0 && resultCount < MAX_PUBLIC_RESULTS; i--) {
            if (capsules[i].isPublic && block.timestamp >= capsules[i].unlockTime) {
                result[counter] = i;
                counter++;
                resultCount++;
            }
        }
        
        return result;
    }
    
    /**
     * @dev Gets time remaining until capsule can be unlocked
     * @param _capsuleId ID of the capsule
     * @return Time remaining in seconds, 0 if already unlockable
     */
    function getTimeRemaining(uint256 _capsuleId) public view returns (uint256) {
        // Ensure the capsule exists
        require(_capsuleId > 0 && _capsuleId <= capsuleCount, "Capsule does not exist.");
        
        Capsule memory capsule = capsules[_capsuleId];
        
        // Ensure the capsule is active
        require(capsule.isActive, "Capsule has been deleted.");
        
        // If already unlockable, return 0
        if (block.timestamp >= capsule.unlockTime) {
            return 0;
        }
        
        // Return time remaining in seconds
        return capsule.unlockTime - block.timestamp;
    }
    
    /**
     * @dev Allows the owner to delete their capsule
     * @param _capsuleId ID of the capsule to delete
     */
    function deleteCapsule(uint256 _capsuleId) public {
        // Ensure the capsule exists
        require(_capsuleId > 0 && _capsuleId <= capsuleCount, "Capsule does not exist.");
        
        Capsule storage capsule = capsules[_capsuleId];
        
        // Only the owner can delete the capsule
        require(msg.sender == capsule.owner, "Only the owner can delete this capsule.");
        
        // Ensure the capsule is active
        require(capsule.isActive, "Capsule has already been deleted.");
        
        // Mark as inactive rather than deleting from storage
        capsule.isActive = false;
        
        // Emit event for off-chain indexing
        emit CapsuleDeleted(_capsuleId, msg.sender, block.timestamp);
    }
}