// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract VotingSystem {
    address owner;
    mapping(address => bool) voters;
    mapping(uint256 => string) proposals;
    mapping(uint256 => uint256) yesVotes;
    mapping(uint256 => uint256) noVotes;
    mapping(uint256 => uint256) createTime;
    mapping(uint256 => mapping(address => bool)) hasVoted;
    uint256 nextId = 1;

    constructor(address[] memory _voters) {
        owner = msg.sender;
        for (uint256 i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyVoter() {
        require(voters[msg.sender]);
        _;
    } //modifier로 함수 실행 전후에 조건이나 로직 추가

    function addProposal(string memory _desc) external onlyOwner {
        proposals[nextId] = _desc;
        createTime[nextId] = block.timestamp; //현재시간 타임스탬프 저장
        nextId++;
    } //안건 추가 함수

    function vote(uint256 _proposalId, bool _support) external onlyVoter {
        require(block.timestamp < createTime[_proposalId] + 5 minutes, "Voting ended"); //5분 제한 확인
        require(!hasVoted[_proposalId][msg.sender], "Already voted"); //투표여부 확인
        hasVoted[_proposalId][msg.sender] = true;
        _support ? yesVotes[_proposalId]++ : noVotes[_proposalId]++; //삼항 연산자: 조건 ? 값1 : 값 2 => 조건이 참이면 값1, 거짓이면 값2
    } //투표 함수

    function isPassed(uint256 _proposalId) external view returns (bool) {
        require(block.timestamp >= createTime[_proposalId] + 5 minutes, "Voting ongoing");
        return yesVotes[_proposalId] > noVotes[_proposalId]; //bool로 리턴이므로 통과, 부결 반환
    }
}
//결과 확인 함수
