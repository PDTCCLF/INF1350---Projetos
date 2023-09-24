local down = {}
down[0]=love.graphics.newImage('img/bomberman/front/Bman_F_f00.png')
down[1]=love.graphics.newImage('img/bomberman/front/Bman_F_f01.png')
down[2]=love.graphics.newImage('img/bomberman/front/Bman_F_f02.png')
down[3]=love.graphics.newImage('img/bomberman/front/Bman_F_f03.png')
down[4]=love.graphics.newImage('img/bomberman/front/Bman_F_f04.png')
down[5]=love.graphics.newImage('img/bomberman/front/Bman_F_f05.png')
down[6]=love.graphics.newImage('img/bomberman/front/Bman_F_f06.png')
down[7]=love.graphics.newImage('img/bomberman/front/Bman_F_f07.png')

local up = {}
up[0]=love.graphics.newImage('img/bomberman/back/Bman_B_f00.png')
up[1]=love.graphics.newImage('img/bomberman/back/Bman_B_f01.png')
up[2]=love.graphics.newImage('img/bomberman/back/Bman_B_f02.png')
up[3]=love.graphics.newImage('img/bomberman/back/Bman_B_f03.png')
up[4]=love.graphics.newImage('img/bomberman/back/Bman_B_f04.png')
up[5]=love.graphics.newImage('img/bomberman/back/Bman_B_f05.png')
up[6]=love.graphics.newImage('img/bomberman/back/Bman_B_f06.png')
up[7]=love.graphics.newImage('img/bomberman/back/Bman_B_f07.png')

local right = {}
right[0]=love.graphics.newImage('img/bomberman/side/Bman_F_f00.png')
right[1]=love.graphics.newImage('img/bomberman/side/Bman_F_f01.png')
right[2]=love.graphics.newImage('img/bomberman/side/Bman_F_f02.png')
right[3]=love.graphics.newImage('img/bomberman/side/Bman_F_f03.png')
right[4]=love.graphics.newImage('img/bomberman/side/Bman_F_f04.png')
right[5]=love.graphics.newImage('img/bomberman/side/Bman_F_f05.png')
right[6]=love.graphics.newImage('img/bomberman/side/Bman_F_f06.png')
right[7]=love.graphics.newImage('img/bomberman/side/Bman_F_f07.png')

local walkSprites = { down=down, up=up, right=right }

return walkSprites
