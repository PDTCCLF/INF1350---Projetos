--[[----------------------------------------------------------------------------
Copyright (c) 2011, Danny Fritz <dannyfritz@gmail.com>
http://creativecommons.org/licenses/by/3.0/
Licensed under the Creative Commons Attribution 3.0 Unported License.
--]]----------------------------------------------------------------------------

--[[ Connect4:

	An object to draw and interact with the Connect 4 game.

]]

local tween = require 'lib.tween.tween'

Connect4 = class('Connect4')
Connect4.BOARD_WIDTH = 7
Connect4.BOARD_HEIGHT = 6
Connect4.BOARD_PIXEL = 64
Connect4.PIECE_IMAGE = 'img/circle.png'
Connect4.BOARD_IMAGE = 'img/board.png'

local piece_image
local board_image
local board

--------------------------------------------------------------------------------
function Connect4:initialize()
	self:New_Game()
	piece_image = love.graphics.newImage(self.PIECE_IMAGE)
	board_image = love.graphics.newImage(self.BOARD_IMAGE)
	self.has_won = false
end

--------------------------------------------------------------------------------
--[[
	Start a new game of connect 4.
]]
function Connect4:New_Game()
	board = {}
	for x=1, self.BOARD_WIDTH do
		table.insert(board, {})
		for y=1, self.BOARD_HEIGHT do
			table.insert(board[x], false)
		end
	end
end

--------------------------------------------------------------------------------
--[[
	Update the connect 4 board.
]]
function Connect4:Update(dt)
	tween.update(dt)
	if not self.has_won then
		self.has_won = self:Check_Win()
	end
end

--------------------------------------------------------------------------------
--[[
	Draw the connect 4 board.
]]
function Connect4:Draw()
	local original_color = {love.graphics.getColor()}
	local board = board
	for x=1, self.BOARD_WIDTH do
		for y=1, self.BOARD_HEIGHT do
			local piece = board[x][y]
			if piece then
				local player = piece.player
				love.graphics.setColor(
						255*(player%2),
						255*(player%3)/2,
						255*(player%4)/3,
						255)
				love.graphics.draw(piece_image, piece.x, piece.y)
			end
		end
	end
	love.graphics.setColor(original_color)
	love.graphics.draw(board_image, 64, 64)
end

--------------------------------------------------------------------------------
--[[
	Create a blank map with walls around the perimeter.

	Input:
		player (number): ID of the player
		column (number): Column the new piece goes in
	
	Output:
		success (boolean): true if the move was successful, false otherwise
]]
function Connect4:Move(player, column)
	if self.has_won then
		return
	end
	if column<=0 or column>self.BOARD_WIDTH then
		return false
	end
	for y=1, self.BOARD_HEIGHT do
		if y==self.BOARD_HEIGHT and not board[column][y] then
			self:New_Piece(player, y, column)
			return true
		elseif board[column][y] and y==1 then
			return false
		elseif board[column][y] and y~=1 then
			self:New_Piece(player, y-1, column)
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
--[[
	Create a new player.

	Input:
		player (number): ID of the player
		row (number): Row the new piece goes in
		column (number): Column the new piece goes in

	Output:
		piece: A table of a new piece.
]]
function Connect4:New_Piece(player, row, column)
	local piece = {}
	piece.player = player
	piece.x = column*self.BOARD_PIXEL
	piece.y = 0
	tween(row/2, piece, { y=row*self.BOARD_PIXEL }, 'outBounce')
	board[column][row] = piece
end

--------------------------------------------------------------------------------
--[[
	Check if the game is over.
]]
function Connect4:Check_Win()
	if self.has_won then
		return
	end
	for x=1, self.BOARD_WIDTH do
		for y=1, self.BOARD_HEIGHT do
			if self:Check_Piece_Win(x, y) then
				return self:Check_Piece_Player(x, y)
			end
		end
	end
end

--[[
	Check if a certain location is a winning location

	Input:
		x (number): Column of the piece
		y (number): Row of the piee

	Output:
		(boolean): true if there is a win
]]
function Connect4:Check_Piece_Win(x, y)
	local board = board
	if not board[x][y] then
		return
	end
	local player = board[x][y].player

	local right, down_left, down, down_right = 0, 0, 0, 0

	--Down Left
	local row = y + 1
	for col = x-1, x-3, -1 do
		if self:Check_Piece_Player(col, row) == player then
			down_left = down_left + 1
		else
			col = x - 3
		end
		row = row + 1
	end

	--Down Right
	local row = y + 1
	for col = x+1, x+3, 1 do
		if self:Check_Piece_Player(col, row) == player then
			down_right = down_right + 1
		else
			col = x + 3
		end
		row = row + 1
	end

	--Right
	for col = x+1, x+3 do
		if self:Check_Piece_Player(col, y) == player then
			right = right + 1
		else
		 col = x + 3
		end
	end

	--Down
	for row = y+1, y+3 do
		if self:Check_Piece_Player(x, row) == player then
			down = down + 1
		else
		 row = y + 3
		end
	end

	if down_right >= 3 then
		return true
	elseif down >= 3 then
		return true
	elseif down_left >= 3 then
		return true
	elseif right >= 3 then
		return true
	end
end

--[[
	Check if a certain location is a winning location

	Input:
		x (number): Column of the piece
		y (number): Row of the piee

	Output:
		player (boolean): ID of the player
]]
function Connect4:Check_Piece_Player(x, y)
	if x<=0 or x>self.BOARD_WIDTH then
		return false
	elseif y<=0 or y>self.BOARD_HEIGHT then
		return false
	end

	if board[x][y] then
		return board[x][y].player
	end

	return false
end