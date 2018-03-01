pragma solidity ^0.4.19;

contract TicTacToe {
  struct Game {
    uint8[9] board;
    address xPlayer;
    address oPlayer;
    bool xTurn;
    bool gameOver;
    bool xWon;
    uint32 createdAt;
  }

  Game[] public games;
  mapping (address => uint8) public numberOfGames;

  function createGame(address _oPlayerAddr) public returns(uint) {
    uint id = games.push(
      Game(
        [uint8(0),uint8(0),uint8(0),uint8(0),uint8(0),uint8(0),uint8(0),uint8(0),uint8(0)],
        msg.sender,
        _oPlayerAddr,
        true,
        false,
        false,
        uint32(now)
      )
    ) - 1;
    numberOfGames[msg.sender]++;
    numberOfGames[_oPlayerAddr]++;
    return id;
  }

  function getPlayerGames (address _player) external view returns (uint[], uint[]) {
    uint[] memory oGames = new uint[](numberOfGames[_player]);
    uint[] memory xGames = new uint[](numberOfGames[_player]);

    uint oCounter = 0;
    uint xCounter = 0;

    for (uint i = 0; i < games.length; i++) {
      if (games[i].oPlayer == _player) {
        oGames[oCounter] = i;
        oCounter++;
      }

      if (games[i].xPlayer == _player) {
        xGames[xCounter] = i;
        xCounter++;
      }
    }

    return (oGames, xGames);
  }

  function getPlayerLastGame (address _player) public view returns (uint) {
    require (games.length > 0);
    uint32 lastCreatedAt = 0;
    uint _id = 0;
    for (uint i = 0; i < games.length; i++) {
      if ((games[i].oPlayer == _player || games[i].xPlayer == _player) && (games[i].createdAt > lastCreatedAt)) {
        _id = i;
        lastCreatedAt = games[i].createdAt;
      }
    }
    return _id;
  }

  function clearGame() public {
    uint _id = getPlayerLastGame(msg.sender);
    require(_id >= 0);
    Game memory game = games[_id];
    if (numberOfGames[msg.sender] >= 0) {
      numberOfGames[msg.sender]--;
    }
    if (numberOfGames[game.oPlayer] >= 0) {
      numberOfGames[game.oPlayer]--;
    }
    delete games[_id];
  }

  // Can delete in favor of public accessor?
  function getGame(uint _id) external view returns (
    uint8[9] board,
    address xPlayer,
    address oPlayer,
    bool xTurn,
    bool gameOver,
    bool xWon,
    uint32 createdAt
  ) {
    Game memory game = games[_id];

    board = game.board;
    xPlayer = game.xPlayer;
    oPlayer = game.oPlayer;
    xTurn = game.xTurn;
    gameOver = game.gameOver;
    xWon = game.xWon;
    createdAt = game.createdAt;
  }

  function enterMove(uint _id, uint position, uint value) public {
    Game storage game = games[_id];
    game.board[position] = uint8(value);
    game.xTurn = !game.xTurn;

    bool _gameOver;
    bool _xWon;

    (_gameOver, _xWon) = _checkGameOver(_id);

    if(_gameOver) {
      game.gameOver = _gameOver;
      game.xWon = _xWon;
    }
  }

  function _checkGameOver(uint _id) internal view returns (
    bool _gameOver,
    bool _xWon
  ) {
    uint8[9] memory board = games[_id].board;

    _gameOver = false;
    _xWon = false;

    if(
      (board[0] == 1 && board[1] == 1 && board[2] == 1) ||
      (board[3] == 1 && board[4] == 1 && board[5] == 1) ||
      (board[6] == 1 && board[7] == 1 && board[8] == 1) ||
      (board[0] == 1 && board[3] == 1 && board[6] == 1) ||
      (board[1] == 1 && board[4] == 1 && board[7] == 1) ||
      (board[2] == 1 && board[5] == 1 && board[8] == 1) ||
      (board[0] == 1 && board[4] == 1 && board[8] == 1) ||
      (board[2] == 1 && board[4] == 1 && board[6] == 1)
    ) {
      _gameOver = true;
      _xWon = true;
    }

    if(
      (board[0] == 2 && board[1] == 2 && board[2] == 2) ||
      (board[3] == 2 && board[4] == 2 && board[5] == 2) ||
      (board[6] == 2 && board[7] == 2 && board[8] == 2) ||
      (board[0] == 2 && board[3] == 2 && board[6] == 2) ||
      (board[1] == 2 && board[4] == 2 && board[7] == 2) ||
      (board[2] == 2 && board[5] == 2 && board[8] == 2) ||
      (board[0] == 2 && board[4] == 2 && board[8] == 2) ||
      (board[2] == 2 && board[4] == 2 && board[6] == 2)
    ) {
      _gameOver = true;
    }
  }
}
