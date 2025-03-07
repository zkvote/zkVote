// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 7994879645860279141390685679892352393430456928171669794037681603902529687500;
    uint256 constant alphay  = 2618698789957074892027134676537898929877754084277725100900665698612741485740;
    uint256 constant betax1  = 13942288099443633761790324214495207743010698481694117105653880928759870302199;
    uint256 constant betax2  = 15613925323428292637541214018186065457363027807537046004320140469678858913634;
    uint256 constant betay1  = 818387989553416733187236826849768090354868254995027834238562065650434952462;
    uint256 constant betay2  = 3354393015731849490139553476732297086967082858123280910386550226675293548390;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 13036265233453445318235379169842263691631792638813050630281120703363358169686;
    uint256 constant deltax2 = 20796026339400775531927180828995644160212524100278455224090825150099321385873;
    uint256 constant deltay1 = 1937798093745347378413266822591809278490257458243669268891927290591466873723;
    uint256 constant deltay2 = 5969201173084056838866603169141375996527696816086862396270561971736321284946;

    // Initial point for the pairing check
    uint256 constant IC0x = 1865265939026887013545366555647323381218165292480448565802277908036807775982;
    uint256 constant IC0y = 15634010962884035660651205009416058849926431530388392292722270398023022079772;
    
    uint256 constant IC1x = 12021481615375350436464289939926616269596629569269652264574984707872858001331;
    uint256 constant IC1y = 10621345603571854130561266190473686208880747629677628013495301128876267656264;
    
 
    // Memory data
    uint16 constant pVk = 0; // Verification Key Pointer
    uint16 constant pPairing = 128; // Pairing Pointer

    uint16 constant pLastMem = 896; // Last memory pointer

    /** 
     * Verifies a proof using the provided public signals and the input proof parameters.
        * @param _pA The proof A parameter.
        * @param _pB The proof B parameter.
        * @param _pC The proof C parameter.
        * @param _pubSignals The public signals.
        * @return A boolean indicating whether the proof is valid or not.
        * @dev This function uses assembly to perform the verification process.
        * It checks the field constraints and performs the pairing check.
        * The function is designed to be called externally and returns a boolean value.
     */
    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[1] calldata _pubSignals) public view returns (bool) {
        // use assembly to optimize the verification process
        assembly {
            function checkField(v) {
                // Check if the value is in the field
                // v < r
                // v >= 0
                if iszero(lt(v, r)) {
                    mstore(0, 0) // store 0 in memory at position 0
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success // Record success of the static call
                let mIn := mload(0x40) // Load the next free memory pointer
                mstore(mIn, x) // Store x in memory
                mstore(add(mIn, 32), y) // Store y in memory
                mstore(add(mIn, 64), s) // Store s in memory

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64) // Call the G1 multiplication function

                // Check for success in G1 multiplication
                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
                // Store the result in pR
                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64) 

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            // Check the pairing conditions and perform necessary calculations
            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing) // Pointer to the pairing data
                let _pVk := add(pMem, pVk) // Pointer to the verification key

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
