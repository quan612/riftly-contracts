// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable, IAccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

import {IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import {ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import {LicenseVersion, CantBeEvilUpgradable} from "./CantBeEvilUpgradable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract RiftlyRedeem is
    Initializable,
    AccessControlEnumerableUpgradeable,
    EIP712Upgradeable,
    CantBeEvilUpgradable
{
    using ECDSAUpgradeable for bytes32;

    /// @dev Emit an event when the contract is deployed
    event ContractDeployed(address owner);

    bytes32 public constant REDEEMABLE_ROLE = keccak256("REDEEMABLE_ROLE");
    address private _treasury;

    mapping(address => bool) private _collectionToApproval;

    function initialize() external initializer {
     
        __AccessControlEnumerable_init();
        __CantBeEvil_init(LicenseVersion.PUBLIC);
        __EIP712_init("Riftly_Redeem_1", "1");
    
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _treasury=address(0x9128C112f6BB0B2D888607AE6d36168930a37087);
        emit ContractDeployed(_msgSender());
    }

    function redeem(address _redeemableNft, address _receiver, uint _tokenId) external onlyRole(REDEEMABLE_ROLE)
    {
        IERC721(_redeemableNft).transferFrom(_treasury, _receiver, _tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            AccessControlEnumerableUpgradeable,
            CantBeEvilUpgradable
            // ,IERC165Upgradeable
        )
        returns (bool)
    {
        return
            type(IAccessControlEnumerableUpgradeable).interfaceId ==
            interfaceId ||
            CantBeEvilUpgradable.supportsInterface(interfaceId) ||
            super.supportsInterface(interfaceId);
    }
}
