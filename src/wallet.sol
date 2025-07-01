// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MultisigWallet {
    address owner;
    mapping(address => bool) public isVoter;
    uint256 public nextId = 1;
    
    struct Proposal {
        uint256 id;
        address to;
        uint256 value;
        bytes data;
        mapping(address => bool) signed;
        uint256 signatureCount;
    }
    mapping(uint256 => Proposal) public proposals;

    constructor(address[] memory _voters) {
        owner = msg.sender;
        for(uint i = 0; i < _voters.length; i++) isVoter[_voters[i]] = true;
    }//Contract를 처음 만들 때 => 생성자

    modifier onlyOwner() { require(msg.sender == owner); _; }
    modifier onlyVoter() { require(isVoter[msg.sender]); _; }

    function addProposal(address _to, uint256 _value, bytes memory _data) external onlyOwner {
        Proposal storage p = proposals[nextId];
        p.id = nextId;
        p.to = _to;
        p.value = _value;
        p.data = _data;
        nextId++;
    }

    function submitSignature(uint256 _proposalId, bytes memory _signature) external onlyVoter {
        Proposal storage p = proposals[_proposalId];//안건 정보 불러오기
        require(p.id != 0, "Invalid proposal");//유효한 안건인지 확인
        bytes32 digest = keccak256(abi.encodePacked(p.id, p.to, p.value, p.data));//메시지 다이제스트 생성
        address signer = recoverSigner(digest, _signature);//서명자 주소 복구
        require(isVoter[signer], "Invalid signer");//유효한 유권자인지 확인
        require(!p.signed[signer], "Already signed");//중복 서명 방지
        p.signed[signer] = true;//서명 상태 저장
        p.signatureCount++;//서명 카운트 증가
    }

    function executeProposal(uint256 _proposalId) external {
        Proposal storage p = proposals[_proposalId];//안건 정보 불러오기
        require(p.id != 0, "Invalid proposal");//유효한 안건인지 확인
        require(p.signatureCount >= 2, "Insufficient signatures"); // 임계치 2로 가정, 최소 서명 개수 확인
        (bool success, ) = p.to.call{value: p.value}(p.data);//트랜잭션 실행**
        require(success, "Execution failed");//실행 성공 여부 확인
    }

    function recoverSigner(bytes32 _digest, bytes memory _signature) internal pure returns (address) {
        require(_signature.length == 65, "Invalid signature length");//서명 길이 확인
        bytes32 r; bytes32 s; uint8 v;
        assembly {//ECDSA 서명은 65바이트로 구성 32+32+1
            r := mload(add(_signature, 32))//mload는 해당 위치에서 32바이트 로드-> r값 획득
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))//분해가 필요한 이유: 내장함수 ecrecover(digest,v ,r, s) 형태 요구
        }//어셈블리로 서명 분해** 왜 32,64,96인가? => 솔리디티에서 동적 배열의 메모리 저장 방식이 그렇다
        if (v < 27) v += 27; // v는 27 또는 28이다.
        require(v == 27 || v == 28, "Invalid signature");
        return ecrecover(_digest, v, r, s); // 수학적 연산: 타원 곡선 암호학을 사용해 서명 검증
    }

    receive() external payable {}
}
