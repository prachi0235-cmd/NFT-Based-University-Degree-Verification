// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title NFT-Based University Degree Verification
 * @dev Smart contract for issuing and verifying university degrees as NFTs
 */
contract Project {
    
    // Struct to store degree information
    struct Degree {
        uint256 tokenId;
        string studentName;
        string degreeName;
        string university;
        uint256 issueDate;
        bool isValid;
        address studentAddress;
    }
    
    // State variables
    address public admin;
    uint256 private tokenCounter;
    
    // Mappings
    mapping(uint256 => Degree) public degrees;
    mapping(address => uint256[]) public studentDegrees;
    mapping(uint256 => address) public degreeOwner;
    
    // Events
    event DegreeIssued(
        uint256 indexed tokenId,
        address indexed student,
        string degreeName,
        string university,
        uint256 issueDate
    );
    
    event DegreeRevoked(uint256 indexed tokenId, address indexed student);
    
    event DegreeVerified(uint256 indexed tokenId, bool isValid);
    
    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier degreeExists(uint256 _tokenId) {
        require(degrees[_tokenId].tokenId != 0, "Degree does not exist");
        _;
    }
    
    constructor() {
        admin = msg.sender;
        tokenCounter = 0;
    }
    
    /**
     * @dev Issue a new degree NFT to a student
     * @param _studentAddress Address of the student receiving the degree
     * @param _studentName Name of the student
     * @param _degreeName Name of the degree (e.g., "Bachelor of Science in Computer Science")
     * @param _university Name of the issuing university
     * @return tokenId The ID of the newly issued degree NFT
     */
    function issueDegree(
        address _studentAddress,
        string memory _studentName,
        string memory _degreeName,
        string memory _university
    ) public onlyAdmin returns (uint256) {
        require(_studentAddress != address(0), "Invalid student address");
        require(bytes(_studentName).length > 0, "Student name required");
        require(bytes(_degreeName).length > 0, "Degree name required");
        require(bytes(_university).length > 0, "University name required");
        
        tokenCounter++;
        uint256 newTokenId = tokenCounter;
        
        degrees[newTokenId] = Degree({
            tokenId: newTokenId,
            studentName: _studentName,
            degreeName: _degreeName,
            university: _university,
            issueDate: block.timestamp,
            isValid: true,
            studentAddress: _studentAddress
        });
        
        degreeOwner[newTokenId] = _studentAddress;
        studentDegrees[_studentAddress].push(newTokenId);
        
        emit DegreeIssued(newTokenId, _studentAddress, _degreeName, _university, block.timestamp);
        
        return newTokenId;
    }
    
    /**
     * @dev Verify the authenticity and validity of a degree
     * @param _tokenId The ID of the degree to verify
     * @return isValid Whether the degree is valid
     * @return studentName Name of the degree holder
     * @return degreeName Name of the degree
     * @return university Issuing university
     * @return issueDate Date when the degree was issued
     */
    function verifyDegree(uint256 _tokenId) 
        public 
        view 
        degreeExists(_tokenId) 
        returns (
            bool isValid,
            string memory studentName,
            string memory degreeName,
            string memory university,
            uint256 issueDate
        ) 
    {
        Degree memory degree = degrees[_tokenId];
        
        return (
            degree.isValid,
            degree.studentName,
            degree.degreeName,
            degree.university,
            degree.issueDate
        );
    }
    
    /**
     * @dev Revoke a degree (mark as invalid)
     * @param _tokenId The ID of the degree to revoke
     */
    function revokeDegree(uint256 _tokenId) 
        public 
        onlyAdmin 
        degreeExists(_tokenId) 
    {
        require(degrees[_tokenId].isValid, "Degree already revoked");
        
        degrees[_tokenId].isValid = false;
        address student = degreeOwner[_tokenId];
        
        emit DegreeRevoked(_tokenId, student);
    }
    
    /**
     * @dev Get all degrees owned by a student
     * @param _studentAddress Address of the student
     * @return Array of token IDs owned by the student
     */
    function getStudentDegrees(address _studentAddress) 
        public 
        view 
        returns (uint256[] memory) 
    {
        return studentDegrees[_studentAddress];
    }
    
    /**
     * @dev Get detailed information about a degree
     * @param _tokenId The ID of the degree
     * @return Degree struct containing all degree information
     */
    function getDegreeDetails(uint256 _tokenId) 
        public 
        view 
        degreeExists(_tokenId) 
        returns (Degree memory) 
    {
        return degrees[_tokenId];
    }
    
    /**
     * @dev Get the total number of degrees issued
     * @return Total count of degrees
     */
    function getTotalDegrees() public view returns (uint256) {
        return tokenCounter;
    }
    
    /**
     * @dev Transfer admin rights to a new address
     * @param _newAdmin Address of the new admin
     */
    function transferAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid admin address");
        admin = _newAdmin;
    }
}
