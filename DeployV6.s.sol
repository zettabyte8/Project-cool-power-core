// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/CoolPowerCoreReserveCoinV6.sol";

contract DeployCoolPowerCoreV6 is Script {
    address constant GNOSIS_SAFE = 0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37;
    address constant INVENTOR    = 0x1419734ee0d1e213f4496d6bf088cc3b480ccedf;

    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address aeroRouter = vm.envOr("AERODROME_ROUTER", address(0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43));

        vm.startBroadcast(deployerKey);
        CoolPowerCoreReserveCoinV6 cpc = new CoolPowerCoreReserveCoinV6(
            GNOSIS_SAFE,
            INVENTOR,
            aeroRouter
        );
        vm.stopBroadcast();

        console2.log("CoolPowerCoreReserveCoinV6 deployed:", address(cpc));
    }
}
