//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "hardhat/console.sol";
import "./HexStrings.sol";
import "./ToColor.sol";

//learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

contract Smileys is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using HexStrings for uint160;
    using ToColor for bytes3;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Smileys", "SML") {
        // RELEASE THE SMILEYS!!!
    }

    mapping(uint256 => bytes3) public color;
    mapping(uint256 => bytes32) public genes;

    function mintItem() public returns (uint256) {
        _tokenIds.increment();

        uint256 id = _tokenIds.current();
        _mint(msg.sender, id);

        genes[id] = keccak256(
            abi.encodePacked(
                blockhash(block.number - 1),
                msg.sender,
                address(this)
            )
        );
        color[id] =
            bytes2(genes[id][0]) |
            (bytes2(genes[id][1]) >> 8) |
            (bytes3(genes[id][2]) >> 16);

        return id;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(_exists(id), "not exist");
        string memory name = string(
            abi.encodePacked("Smiley #", id.toString())
        );
        string memory description = string(
            abi.encodePacked(
                "This Smiley is the color #",
                color[id].toColor(bytes3(genes[id] >> 3)),
                " and #",
                color[id].toColor(bytes3(genes[id] >> 2)),
                "!!!"
            )
        );
        string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                "{'name':'",
                                name,
                                "','description':'",
                                description,
                                "', 'external_url':'https://burnyboys.com/token/",
                                id.toString(),
                                "', 'attributes': [{'trait_type': 'color1', 'value': '#",
                                color[id].toColor(bytes3(genes[id] >> 3)),
                                "'},{'trait_type': 'color2', 'value': ",
                                color[id].toColor(bytes3(genes[id] >> 2)),
                                "}], 'owner':'",
                                (uint160(ownerOf(id))).toHexString(20),
                                "', 'image': '",
                                "data:image/svg+xml;base64,",
                                image,
                                "'}"
                            )
                        )
                    )
                )
            );
    }

    function generateSVGofTokenById(uint256 id)
        internal
        view
        returns (string memory)
    {
        string memory svg = string(
            abi.encodePacked(
                "<svg viewBox='0 0 36 36' fill='none' xmlns='http://www.w3.org/2000/svg' width='80' height='80'>",
                "<mask id='mask__beam' maskUnits='userSpaceOnUse' x='0' y='0' width='36' height='36'>",
                "<rect width='36' height='36' rx='72' fill='white'></rect>",
                "</mask>",
                renderTokenById(id),
                "</svg>"
            )
        );

        return svg;
    }

    // Visibility is `public` to enable it being called by other contracts for composition.
    function renderTokenById(uint256 id) public view returns (string memory) {
        uint256 randomNumber = uint256(genes[id]);
        // string memory _faceColor = faceColor(randomNumber); // black or white
        string memory _randomSmile = randomSmile(randomNumber); // different type of smile
        string memory range9 = intRange(randomNumber, 9, 1);
        string memory range7 = intRange(randomNumber, 7, 1);
        string memory rotation = uintRange(randomNumber, 360, 1);
        string memory _color = color[id].toColor(bytes3(genes[id] >> 3));
        string memory range10 = uintRange(randomNumber, 10, 4);
        string memory range20 = uintRange(randomNumber, 20, 5);
        string memory render = string(
            abi.encodePacked(
                "<g mask='url(#mask__beam)'>",
                "<rect width='36' height='36' fill='#",
                color[id].toColor(bytes3(genes[id] >> 2)),
                "'></rect>",
                "<rect x='0' y='0' width='36' height='36' transform='translate(",
                range9,
                " ",
                range9, //translate 9 - 9
                ") rotate(",
                rotation,
                " 18 18) scale(1.1",
                // uint2str((randomNumber % 3)),
                ")' fill='#",
                _color,
                "' rx='36'></rect>",
                "<g transform='translate(", // translate -7 to 7
                range7,
                " 2) rotate(",
                range9,
                " 18 18)'>", // rotation max -9 to 9
                "<path d='",
                _randomSmile,
                "' fill='black'></path>",
                "<rect x='", // 10 - 13
                range10,
                "' y='14' width='1.5' height='2' rx='1' stroke='none' fill='black'></rect>",
                "<rect x='", // 20 - 24
                range20,
                "' y='14' width='1.5' height='2' rx='1' stroke='none' fill='black'></rect>",
                "</g>",
                "</g>" // end
            )
        );

        return render;
    }

    // function getRandomNumber(uint256 _id) internal returns (bytes32 requestId) {
    //     require(
    //         LINK.balanceOf(address(this)) >= fee,
    //         "Not enough LINK - fill contract with faucet"
    //     );
    //     requestId = requestRandomness(keyHash, fee);
    //     idToRequestId[_id] = requestId;
    // }

    // function fulfillRandomness(bytes32 requestId, uint256 randomness)
    //     internal
    //     override
    // {
    //     requestIdToRandomNumber[requestId] = randomness;
    // }

    function negativeSign(uint256 randomValue)
        public
        pure
        returns (int256 value)
    {
        if (randomValue % 2 > 0) {
            value = 1;
        } else {
            value = -1;
        }
    }

    function intRange(
        uint256 randomNumber,
        uint256 base,
        uint256 range
    ) internal pure returns (string memory) {
        return
            int2str(
                (int256((randomNumber % base) + range)) *
                    negativeSign(randomNumber)
            );
    }

    function uintRange(
        uint256 randomNumber,
        uint256 base,
        uint256 range
    ) internal pure returns (string memory) {
        return uint2str(base + (randomNumber % range));
    }

    function faceColor(uint256 randomValue)
        public
        pure
        returns (string memory value)
    {
        if (randomValue % 2 > 0) {
            value = "black";
        } else {
            value = "white";
        }
    }

    function randomSmile(uint256 randomValue)
        public
        pure
        returns (string memory value)
    {
        if (randomValue % 2 > 0) {
            value = string(
                abi.encodePacked(
                    "M13,",
                    uint2str(19 + (randomValue % 3)),
                    " a1,0.75 0 0,0 10,0"
                )
            );
        } else {
            value = string(
                abi.encodePacked(
                    "M15 ",
                    uint2str(20 + (randomValue % 2)),
                    "c2 1 4 1 6 0"
                )
            );
        }
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function int2str(int256 i) internal pure returns (string memory) {
        if (i == 0) return "0";
        bool negative = i < 0;
        uint256 j = uint256(negative ? -i : i);
        uint256 m = j; // Keep an unsigned copy
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        if (negative) ++len; // Make room for '-' sign
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (m != 0) {
            uint8 temp = uint8(48 + (m % 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            m /= 10;
        }
        if (negative) {
            // Prepend '-'
            bstr[0] = "-";
        }
        return string(bstr);
    }
}
