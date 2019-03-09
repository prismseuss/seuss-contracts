pragma solidity ^0.5.0;

import "openzeppelin-eth/contracts/ownership/Ownable.sol";

contract Seuss is Ownable {
  mapping(address => mapping(uint256 => bool)) purchasedPrescriptions;
  mapping(address => mapping(uint256 => uint256)) pharmacyPrescriptionPrices;
  mapping(address => bool) doctorMap;
  mapping(address => bool) pharmacyMap;

  event PurchasedMedication(address pharmacyAddress, address doctorAddress, uint256 prescriptionId, address patientAddress, uint256 gcn, uint256 price);
  event AddedDoctor(address doctorAddress);
  event AddedPharmacy(address pharmacyAddress);
  //
  // function verify(bytes memory bundle, uint8 v, bytes32 r, bytes32 s) public pure returns(address) {
  //   return ecrecover(prefixedHash(bundle), v, r, s);
  // }
  //
  // function prefixedHash(bytes memory bundle) public pure returns (bytes32) {
  //   bytes memory prefix = "\x19Ethereum Signed Message:\n32";
  //   return keccak256(
  //     abi.encodePacked(prefix, hashedMsg(bundle))
  //   );
  // }
  //
  // function hashedMsg(bytes memory msg) public pure returns (bytes32) {
  //   return keccak256(abi.encodePacked(msg));
  // }

  function purchase(bytes memory bundle, /*uint8 v, bytes32 r, bytes32 s,*/ address payable pharmacyAddress) public payable onlyPharmacy(pharmacyAddress) {
    // address doctorAddress = verify(bundle, v, r, s);

    (uint256 prescriptionId, address patientAddress, uint256 gcn, address doctorAddress) = abi.decode(bundle, (uint256, address, uint256, address));

    require(isDoctor(doctorAddress), "Not a doctor");
    require(notPurchasedBefore(doctorAddress, prescriptionId), "Already purchased");
    require(msg.sender == patientAddress, "Not the patient");
    uint256 price = pharmacyPrescriptionPrices[pharmacyAddress][gcn];
    require(price > 0, "pharmacy does not sell that drug");
    require(msg.value == price, "Did not pay the correct amount");

    purchasedPrescriptions[doctorAddress][prescriptionId] = true;

    emit PurchasedMedication(pharmacyAddress, doctorAddress, prescriptionId, patientAddress, gcn, msg.value);

    pharmacyAddress.transfer(msg.value);
  }

  function isDoctor(address doctorAddress) private view returns (bool) {
    return doctorMap[doctorAddress];
  }

  function addDoctor(address doctorAddress) public onlyOwner {
    doctorMap[doctorAddress] = true;

    emit AddedDoctor(doctorAddress);
  }

  modifier onlyPharmacy(address pharmacyAddress) {
    require(pharmacyMap[pharmacyAddress], "Is not a pharmacy");
    _;
  }

  function addPharmacy(address pharmacyAddress) public onlyOwner {
    pharmacyMap[pharmacyAddress] = true;
    emit AddedPharmacy(pharmacyAddress);
  }

  function addMedication(uint256 gcn, uint256 price) public onlyPharmacy(msg.sender) {
    pharmacyPrescriptionPrices[msg.sender][gcn] = price;
  }

  function notPurchasedBefore(address doctorAddress, uint256 prescriptionId) private view returns (bool) {
    return !purchasedPrescriptions[doctorAddress][prescriptionId];
  }
}
