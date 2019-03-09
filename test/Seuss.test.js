const Seuss = artifacts.require("Seuss.sol");

contract("Seuss", (accounts) => {
  let seuss;
  const doctor = accounts[0];
  const patient = accounts[1];
  const pharmacy = accounts[2];
  const owner = accounts[3]

  beforeEach(async () => {
    seuss = await Seuss.new();
    await seuss.initialize(owner);
  })

  describe("purchase()", () => {
    it('should allow a purchase', async () => {
      await seuss.addDoctor(doctor,{from: owner})
      await seuss.addPharmacy(pharmacy,{from: owner})
      await seuss.addMedication('2', web3.utils.toWei('10', 'ether'), { from: pharmacy })

      let bundle = web3.eth.abi.encodeParameters(['uint256','address', 'uint256', 'address'], ['1', patient, '2', doctor]);
      const response = await seuss.purchase(bundle, pharmacy, {
        from: patient,
        value: web3.utils.toWei('10', 'ether')
      })
      const event = response.receipt.logs[0]
      assert.equal(event.event, 'PurchasedMedication')
      assert.equal(event.args.pharmacyAddress, pharmacy)
      assert.equal(event.args.doctorAddress, doctor)
    })

    // xit("should verify with no contract", async () => {
    //   let msg = web3.utils.utf8ToHex('Schoolbus').slice(2);
    //   const signature = await web3.eth.sign(msg, doctor);
    //   const r = signature.slice(0, 66);
    //   const s = '0x' + signature.slice(66, 130);
    //   let v = '0x' + signature.slice(130, 132);
    //   const signatureObject = {
    //     messageHash: web3.utils.keccak256("\x19Ethereum Signed Message:\n" + msg.length + msg),
    //     v,
    //     r,
    //     s
    //   };
    //   const recoveredAddress = await web3.eth.accounts.recover(signatureObject);
    //   assert.equal(recoveredAddress, doctor, "the addresses do not match");
    // })

    // it("should verify with contract", async () => {
    //   let msg = web3.utils.utf8ToHex('Schoolbus');
    //
    //   let hashedMsg = web3.utils.soliditySha3(msg)
    //   assert.equal(hashedMsg, await seuss.hashedMsg(msg))
    //
    //   let msgSlice = hashedMsg.slice(2)
    //   const prefixedHash = web3.utils.keccak256("\x19Ethereum Signed Message:\n32" + msgSlice)
    //
    //   assert.equal(prefixedHash, await seuss.prefixedHash(msg))
    //
    //   const signature = await web3.eth.sign(hashedMsg.slice(2), doctor);
    //   const r = signature.slice(0, 66);
    //   const s = '0x' + signature.slice(66, 130);
    //   let v = '0x' + signature.slice(130, 132);
    //
    //   const recoveredAddress = await seuss.verify(msg, v, r, s);
    //   assert.equal(recoveredAddress, doctor, "the addresses do not match");
    // })
  })
});
