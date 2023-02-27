// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable, IAccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {ERC721AUpgradeable} from "./ERC721A/ERC721AUpgradeable.sol";
import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import {IERC721MetadataUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import {IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import {ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import {LicenseVersion, CantBeEvilUpgradable} from "./CantBeEvilUpgradable.sol";

contract RiftlyNFT is
    Initializable,
    ERC721AUpgradeable,
    AccessControlEnumerableUpgradeable,
    EIP712Upgradeable,
    CantBeEvilUpgradable
{
    using ECDSAUpgradeable for bytes32;
     bytes32 public constant MINTABLE_ROLE = keccak256("MINTABLE_ROLE");

    /// @dev Emit an event when the contract is deployed
    event ContractDeployed(address owner);

    address private _treasury;
    string private _riftlyNftURI;


    mapping(address => bool) public proxyToApproved;

    function initialize() external initializer {
        __ERC721A_init("RiftlyNFT_3", "RNFT");
        __AccessControlEnumerable_init();
        __CantBeEvil_init(LicenseVersion.PUBLIC);
        __EIP712_init("RiftlyNFT_3", "1");
    
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _treasury=address(0x9128C112f6BB0B2D888607AE6d36168930a37087);

        emit ContractDeployed(_msgSender());
    }

    function isTokenExists(uint256 _tokenId) external view returns (bool) {
        if (_exists(_tokenId)) {
            return true;
        }
        return false;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view override returns (string memory) {
        return _riftlyNftURI;
    }

    function treasuryMint(uint256 amount)
        external onlyRole(MINTABLE_ROLE)
    {
        _safeMint(address(_treasury), amount);
    }

    function setBaseURI(string calldata baseURI_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _riftlyNftURI = baseURI_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            AccessControlEnumerableUpgradeable,
            ERC721AUpgradeable,
            CantBeEvilUpgradable
        )
        returns (bool)
    {
        return
            type(IAccessControlEnumerableUpgradeable).interfaceId ==
            interfaceId ||
            ERC721AUpgradeable.supportsInterface(interfaceId) ||
            CantBeEvilUpgradable.supportsInterface(interfaceId) ||

            super.supportsInterface(interfaceId);
    }

    /**
     *
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        override (ERC721AUpgradeable)
        returns (bool)
    {
        if (proxyToApproved[operator]) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function setProxyState(address proxyAddress, bool isApprove)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        proxyToApproved[proxyAddress] = isApprove;
    }

    /// @dev Returns the tokenIds of the address. O(totalSupply) in complexity.
    function tokensOfOwner(address owner)
        external
        view
        returns (uint256[] memory)
    {
        unchecked {
            uint256[] memory a = new uint256[](balanceOf(owner));
            uint256 end = _currentIndex;
            uint256 tokenIdsIdx;
            address currOwnershipAddr;
            for (uint256 i; i < end; i++) {
                TokenOwnership memory ownership = _ownerships[i];
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    a[tokenIdsIdx++] = i;
                }
            }
            return a;
        }
    }
}
