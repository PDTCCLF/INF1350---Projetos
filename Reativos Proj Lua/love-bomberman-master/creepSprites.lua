local down = {}
down[0]=love.graphics.newImage('img/creep/front/Creep_F_f00.png')
down[1]=love.graphics.newImage('img/creep/front/Creep_F_f01.png')
down[2]=love.graphics.newImage('img/creep/front/Creep_F_f02.png')
down[3]=love.graphics.newImage('img/creep/front/Creep_F_f03.png')
down[4]=love.graphics.newImage('img/creep/front/Creep_F_f04.png')
down[5]=love.graphics.newImage('img/creep/front/Creep_F_f05.png')

local up = {}
up[0]=love.graphics.newImage('img/creep/back/Creep_B_f00.png')
up[1]=love.graphics.newImage('img/creep/back/Creep_B_f01.png')
up[2]=love.graphics.newImage('img/creep/back/Creep_B_f02.png')
up[3]=love.graphics.newImage('img/creep/back/Creep_B_f03.png')
up[4]=love.graphics.newImage('img/creep/back/Creep_B_f04.png')
up[5]=love.graphics.newImage('img/creep/back/Creep_B_f05.png')

local right = {}
right[0]=love.graphics.newImage('img/creep/side/Creep_S_f00.png')
right[1]=love.graphics.newImage('img/creep/side/Creep_S_f01.png')
right[2]=love.graphics.newImage('img/creep/side/Creep_S_f02.png')
right[3]=love.graphics.newImage('img/creep/side/Creep_S_f03.png')
right[4]=love.graphics.newImage('img/creep/side/Creep_S_f04.png')
right[5]=love.graphics.newImage('img/creep/side/Creep_S_f05.png')
right[6]=love.graphics.newImage('img/creep/side/Creep_S_f06.png')

local walkSprites = { down=down, up=up, right=right }

return walkSprites
