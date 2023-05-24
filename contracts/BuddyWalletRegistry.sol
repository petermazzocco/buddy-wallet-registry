// SPDX-License-Identifier: UNLICENSED
// ERC6551 created by Tokenbound
pragma solidity ^0.8.9;
import "./oz/Create2.sol";
import "./interface/IERC6551Registry.sol";
import "./lib/ERC6551ByteCodeLib.sol";

/*
 * @dev The BuddyWalletRegistry is designed for Buddy Wallet to handle the
 * creation of new Buddy Wallets.
 * This contract is based off the ERC6551 EIP:
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 * The ONLY addition with this contract is the added boolean for state management.
 * If you want to interact with the original ERC6551 Registry, please visit:
 *  https://etherscan.io/address/0x02101dfb77fde026414827fdc604ddaf224f0921#code
 */

contract BuddyWalletRegistry is IERC6551Registry {
    error InitializationFailed();

    // Allows easier tracking of deployed Buddy Wallets
    mapping(address => bool) public isDeployed;

    /*
     * @dev Creates an account
     * @param implementation The address of the Buddy Wallet implementation.
     * @param chainId The chainId of the network the Buddy Wallet will be deployed on.
     * @param tokenContract The address of the ERC721 contract.
     * @param tokenId The tokenId of the ERC721 token.
     * @param salt The salt used to calculate the address.
     * @param initData The data used to initialize the Buddy Wallet.
     * @return The address of the Buddy Wallet.
     */

    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt,
        bytes calldata initData
    ) external returns (address) {
        require(!isDeployed[implementation], "Buddy already deployed.");

        bytes memory code = ERC6551BytecodeLib.getCreationCode(
            implementation,
            chainId,
            tokenContract,
            tokenId,
            salt
        );

        address _account = Create2.computeAddress(
            bytes32(salt),
            keccak256(code)
        );

        if (_account.code.length != 0) return _account;

        emit AccountCreated(
            _account,
            implementation,
            chainId,
            tokenContract,
            tokenId,
            salt
        );

        _account = Create2.deploy(0, bytes32(salt), code);

        if (initData.length != 0) {
            (bool success, ) = _account.call(initData);
            if (!success) revert InitializationFailed();
        }

        isDeployed[implementation] = true;

        return _account;
    }

    /*
     * @dev This function is used to calculate the address of a Buddy Wallet
     * @param implementation The address of the Buddy Wallet implementation.
     * @param chainId The chainId of the network the Buddy Wallet will be deployed on.
     * @param tokenContract The address of the ERC721 contract.
     * @param tokenId The tokenId of the ERC721 token.
     * @param salt The salt used to calculate the address.
     * @return The address of the Buddy Wallet.
     */
    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external view returns (address) {
        bytes32 bytecodeHash = keccak256(
            ERC6551BytecodeLib.getCreationCode(
                implementation,
                chainId,
                tokenContract,
                tokenId,
                salt
            )
        );

        return Create2.computeAddress(bytes32(salt), bytecodeHash);
    }

    /*
     * @dev This function is used to check if a Buddy Wallet has been deployed.
     * @param implementation The address of the Buddy Wallet implementation.
     * @return A boolean indicating if the Buddy Wallet has been deployed.
     */
    function isBuddyDeployed(
        address implementation
    ) external view returns (bool) {
        return isDeployed[implementation];
    }
}
