REM PATRIOTA ADVENTURES
REM License: CC-BY.
REM Press Ctrl+R to run.

drv = driver()
print drv, ", detail type is: ", typeof(drv);

' Items
own_bullets = list()
alive_enemies = list()
leftShrapnels = list()
rightShrapnels = list()
bonuses = list()

' Stage
INTRO = 0
INSTRUCTION = 1
INGAME = 2
GAMEOVER = 3

' Screens
URSAL = 0
CUBA = 1
VENEZUELA = 2
CHINA = 3

'Stats
LIFES = 3
SPEED = 50
MAX_SPAWN = 6

' Enemys
LGBT_ENEMY = 0
MARX_ENEMY = 1

stage = INTRO
screen = URSAL

' RESOURCES

olavao = load_resource("olavao.quantized")
brasilolhochorando = load_resource("olho.quantized")

patriotrometro_0 = load_resource("patriotrometro0.quantized")
patriotrometro_1 = load_resource("patriotrometro1.quantized")
patriotrometro_2 = load_resource("patriotrometro2.quantized")
patriotrometro_3 = load_resource("patriotrometro3.quantized")

' Maps
fiesp_bg = load_resource("fiesp_bg.quantized")
inst_bg  = load_resource("inst_bg.quantized")

' Sprites
patriotaSprite = load_resource("patriota.sprite")
zapSprite = load_resource("zap.sprite")
bulletSprite = load_resource("bullet.sprite")

lgbtSprite = load_resource("lgbt.sprite")
'sfx 4096+1,860,0.2,1,380,0.01
' \say "harder better faster stonger" , 150, 70, 110, 90

REM next todo
REM - up, down, left,right e horizontais
REM esquema de fases
REM intro 
REM spawn de monstros

class point
    var x = 0
	var y = 0
endclass

def up(y, delta, speed)
	newY = y - delta * speed
	if newY < 0 then newY = 0
	return newY
enddef

def down(y, delta, speed)
	newY = y + delta * speed
	if newY >= 112 then newY = 111
	return newY
enddef

def moveRight(x, delta, speed)
	newX = x + delta * SPEED
	if newX > 150 then newX = 149
	return newX
enddef

def moveLeft(x, delta, speed)
	newX = x - delta * SPEED
	if newX < 0 then newX = 0
	return newX
enddef

class cBonus(point)
	def setPosition(xb, yb)
		x = xb
		y = yb
	enddef
endclass

class cEnemy(point)
	health = 0
	withDrop = true

	def setPosition(xe ,ye)
		x = xe
		y = ye
	enddef

	def setEnemyProperties(n)
		if n = LGBT_ENEMY then
			health = 1
			behavior = 0
		else if n = MARX_ENEMY
			health = 3
			behavior = 0
		endif
	enddef
endclass

def takeDamage(enemy, idx)
	enemy.health = enemy.health -1
	if enemy.health = 0 then
		remove(alive_enemies, ix)
		if enemy.withDrop = true then
			drop = new(cBonus)
			drop.setPosition(enemy.x, enemy.y)
			push(bonuses, drop)
		endif
	endif
enddef

def isTouched(a, b, size)
    x = a.x - b.x 
	y = a.y - b.y
	if abs(x) <= size and abs(y) <= size then
		return true
	else
		return false
	endif
enddef

class cBullet(point)
    def setPosition(xb, yb)
	  x = xb
	  y = yb
	enddef
	
	def checkIfIsTouched(instbullet, idxBullet, instenemy, idxEnemy, size)
    	if isTouched(instbullet, instenemy, size) then
			takeDamage(instenemy, idxEnemy)
			remove(own_bullets, idxBullet)
			return 1
		endif
		return 0
	enddef
endclass
bullet = new(cBullet)

class cShrapnel(cBullet)
	
endclass

class cPatriota(point)
    def setPosition(xp, yp)
	    x = xp
	    y = yp
	enddef
	
	life = 3
	bulletSpeed = 170
	bulletSpawn = 20
	niobioLvl = 0
	indestructableTime = 0
	x = 45
	y = 80

	def updatePosition(delta)
	    px = x
	    py = y
		' LEFT UP
		if btn(2) and btn(0) then
			px = moveLeft(x, delta, SPEED / 2)
			py = up(y, delta, SPEED / 2)
		' RIGHT UP
		elseif btn(1) and btn(2) then
			px = moveRight(x, delta, SPEED / 2)
			py = up(y, delta, SPEED / 2)
		' RIGHT DOWN
		elseif btn(1) and btn(3) then
			px = moveRight(x, delta, SPEED / 2)
			py = down(y, delta, SPEED / 2)
		' LEFT DOWN
		elseif btn(0) and btn(3) then
			px = moveLeft(x, delta, SPEED / 2)
			py = down(y, delta, SPEED / 2)
		' LEFT
		elseif btn(0) then
			px = moveLeft(x, delta, SPEED)
	    ' RIGHT
		elseif btn(1) then
			px = moveRight(x, delta, SPEED)
		' UP
		elseif btn(2) then
			py = up(y, delta, SPEED)
	    ' DOWN
		elseif btn(3) then
			py = down(y, delta, SPEED)
		endif

	setPosition(px, py)
	spr patriotaSprite, x, y
    enddef
	
	def decreaseHealth()
		life = life - 1
	enddef
	
	def resetHealth()
		life = 3
	enddef
	
	def powerUp()
		niobioLvl = niobioLvl + 1
	enddef

	def checkIfIsTouched(instbullet, patriota, size)
		if indestructableTime > 0 then
			indestructableTime = indestructableTime - 1
		elseif isTouched(instbullet, patriota, size) then
			patriota.decreaseHealth()
			print(patriota.life)
			indestructableTime = 60
		endif
	enddef
endclass

def debugMouse()
	touch 0, tx, ty, tb0
	text 30, 30, "MOUSE AT " + str(tx) + "," + str(ty), rgba(5, 255, 255)
enddef

def spawnNewBullet(origin)
	bullet = new(cBullet)
	bullet.setPosition(origin.x + 10, origin.y)
	push(own_bullets, bullet)
enddef

def spawnNewShrapnels(origin)
	leftShrapnel = new(cShrapnel)
	leftShrapnel.setPosition(origin.x + 9, origin.y - 2)
	push(leftShrapnels, leftShrapnel)
	
	rightShrapnel = new(cShrapnel)
	rightShrapnel.setPosition(origin.x + 14, origin.y - 2)
	push(rightShrapnels, rightShrapnel)
enddef

b = 0
def setBullets(delta, origin)
	handleOwnBullets = coroutine
	(
		lambda(delta, origin)
		(
			' Set left shrapnels position
			if len(leftShrapnels) > 0 then
				for idxShrapnels = 0 to len(leftShrapnels) - 1
					instLeftShrapnel = get(leftShrapnels, idxShrapnels)
					
					' Check shrapnel coision with enemies
					isRemoved = 0
					if len(alive_enemies) > 0 then
						for idxEnemy = 0 to len(alive_enemies) - 1
							instenemy = get(alive_enemies, idxEnemy)
							isRemoved = instLeftShrapnel.checkIfIsTouched(instLeftShrapnel, idxShrapnels, instenemy, idxEnemy, 5)
						next
					endif
					
					if instLeftShrapnel.y = 0 and isRemoved <> 1 then
						remove(leftShrapnels, idxBullet)
					else
						newY = up(instLeftShrapnel.y, delta, origin.bulletSpeed)
						newX = moveLeft(instLeftShrapnel.x, delta, origin.bulletSpeed / 8)
						instLeftShrapnel.setPosition(newX, newY)
						line newX, instLeftShrapnel.y, newX - 1, instLeftShrapnel.y - 1, 1
					endif
				next
			endif
			
			' Set right shrapnels position
			if len(rightShrapnels) > 0 then
				for idxShrapnels = 0 to len(rightShrapnels) - 1
					instRightShrapnel = get(rightShrapnels, idxShrapnels)
					
					' Check shrapnel colision with enemies
					isRemoved = 0
					if len(alive_enemies) > 0 then
						for idxEnemy = 0 to len(alive_enemies) - 1
							instenemy = get(alive_enemies, idxEnemy)
							isRemoved = instRightShrapnel.checkIfIsTouched(instRightShrapnel, idxShrapnels, instenemy, idxEnemy, 5)
						next
					endif
					
					if instRightShrapnel.y = 0 and isRemoved <> 1 then
						remove(rightShrapnels, idxBullet)
					else
						newY = up(instRightShrapnel.y, delta, origin.bulletSpeed)
						newX = moveRight(instRightShrapnel.x, delta, origin.bulletSpeed / 8)
				   		instRightShrapnel.setPosition(newX, newY)
						line newX, instRightShrapnel.y, newX + 1, instRightShrapnel.y - 1, 1
					endif
				next
			endif
		
			' Set bullets position
			if len(own_bullets) > 0 then
				for idxBullet = 0 to len(own_bullets) - 1
					instbullet = get(own_bullets, idxBullet)
					newY = up(instbullet.y, delta, origin.bulletSpeed)
					instbullet.setPosition(instbullet.x, newY)
					spr bulletSprite, instbullet.x, instbullet.y
	
					' Check bullet colision with enemies
					if len(alive_enemies) > 0 then
						for idxEnemy = 0 to len(alive_enemies) - 1
							instenemy = get(alive_enemies, idxEnemy)
							instbullet.checkIfIsTouched(instbullet, idxBullet, instenemy, idxEnemy, 10)
						next
					endif
					' Remove bullets that are on top
					if instbullet.y = 0 then
						remove(own_bullets, idxBullet)
					endif
				next
			endif
		)
		delta, origin
	)

	' b = ticks contados para o spawn de outra bala
	b = b + 1
    if b = origin.bulletSpawn then
		spawnNewBullet(origin)
		if origin.bulletSpawn = MAX_SPAWN then
			spawnNewShrapnels(origin)
		endif
		b = 0
	endif

	start(handleOwnBullets)
enddef

def setEnemies(delta, patriota)
	handleEnemies = coroutine
	(
		lambda(delta)
		(
			for e in alive_enemies
				spr lgbtSprite, e.x, e.y
			next
			for b in bonuses
				spr zapSprite, b.x, x.y + 20
			next
		)
		delta
	)
	start(handleEnemies)
enddef

def ursalEnemies(delta)
	spawnEnemies = coroutine
	(
		lambda(delta)
		(
			enemy = new(cEnemy)
			enemy.setPosition(50, 20)
			enemy.setEnemyProperties(0)
			push(alive_enemies, enemy)

			wait_for(5)
			enemy = new(cEnemy)
			enemy.setPosition(80, 20)
			enemy.setEnemyProperties(0)
			push(alive_enemies, enemy)

			wait_for(5)
			enemy = new(cEnemy)
			enemy.setPosition(100, 20)
			enemy.setEnemyProperties(0)
			push(alive_enemies, enemy)
		)
	)
	start(spawnEnemies)
enddef

patriota = new(cPatriota)

iNiobioWarning = 0
def setPatriota(delta, patriota)
	patriota.updatePosition(delta)
	
	if len(alive_enemies) > 0 then
		for enemyIdx = 0 to len(alive_enemies) - 1
			enemyInst = get(alive_enemies, enemyIdx)
			patriota.checkIfIsTouched(enemyInst, patriota, 4)
		 next
	endif
	
	if len(bonuses) > 0 then
		for bonusIdx = 0 to len(bonuses) - 1
			bonusInst = get(bonuses, bonusIdx)
			if isTouched(patriota, bonusInst, 8) then
				patriota.powerUp()
				remove(bonuses, bonusIdx)
			endif
		next
	endif

	if patriota.niobioLvl = 0 then
		patriota.bulletSpeed = 100
		patriota.bulletSpawn = 20
		img patriotrometro_0, 2, 105
	elseif patriota.niobioLvl = 1 then
		patriota.bulletSpeed = 200
		patriota.bulletSpawn = 10
		img patriotrometro_1, 2, 105
	elseif patriota.niobioLvl = 2 then
		patriota.bulletSpeed = 300
		patriota.bulletSpawn = 8
		img patriotrometro_2, 2, 105
	elseif patriota.niobioLvl = 3 then
		patriota.bulletSpeed = 310
		patriota.bulletSpawn = MAX_SPAWN
		img patriotrometro_3, 2, 105
		iNiobioWarning = iNiobioWarning + 1
		if iNiobioWarning > 0 and iNiobioWarning < 10 then
			text 20, 105, "Seu niobio esta" rgba(226, 106, 106)
			text 14, 115, "no máximo poder!!!" rgba(226, 106, 106)
		elseif iNiobioWarning >= 10 then
			iNiobioWarning = 0
		endif
	endif

	return patriota
enddef

t = 0
REM play "T120 B6 E6 D#6 E6 F#6 G#3 F#6 G#6 A6 A#6 B3", 0, 0, true

def game(delta)
	if screen = URSAL then
		img fiesp_bg, 0, 0
		ursalEnemies(delta)
	endif
	'debugMouse()

	patriota = setPatriota(delta, patriota)
	
	if patriota.life = 0 then
		stage = GAMEOVER
	endif
	' setBullets(delta, patriota)
	setEnemies(delta, patriota)
enddef

t = 0
def title(delta)
	if t > 1 then
		if t mod 3 = 0 then
			text 5, 10, "PATRIOTA ADVENTURES" rgba(50, 205, 50, 127)
		elseif t mod 3 = 1 then
			text 5, 10, "PATRIOTA ADVENTURES" rgba(0, 191, 255, 127)
		elseif t mod 3 = 2 then
			text 5, 10, "PATRIOTA ADVENTURES" rgba(0, 0, 205, 127)
		endif
	endif
	
	if t = 30 then
		stage = INGAME
	   ' stage = INSTRUCTION
	endif
	t = t + 1
enddef

tgo = 0
def gameovers(delta)
	img inst_bg, 0, 0
	text 45, 30, "GAME OVER" rgba(105, 105, 105,207)
	img brasilolhochorando, 35,50
	
	if tgo > 100 then
		patriota.life = 3
		tgo = 0
		stage = INGAME
	endif
	tgo = tgo + 1
enddef

ti = 0
def instructions(delta)
	img inst_bg, 0, 0
	img olavao, 50, 50
	text 55, 105, "Olavo" rgba(105, 105, 105, 127)
	if ti > 1 then
		if ti <= 150 then
			text 10, 10, " O Brasil precisa" rgba(105, 105, 105, 207)
			text 5, 20, "    de voce!!!" rgba(105, 105, 105, 207)
		elseif ti <= 250 then
			text 5, 10, "Estamos sendo" rgba(105, 105, 105, 207)
			text 10, 20, " ameacados pelo" rgba(105, 105, 105, 207)
		    text 10, 30, " comunismo!!1!!" rgba(105, 105, 105, 207)
		elseif ti <= 350 then
			text 5, 10, "E a globo" rgba(105, 105, 105, 207)
			text 5, 20, "  so mente!!" rgba(105, 105, 105, 207)
		elseif ti <= 450 then
			text 3, 10, "Somente o verdadeiro" rgba(105, 105, 105, 207)
			text 3, 20, "patriota pode trazer" rgba(105, 105, 105, 207)
			text 3, 30, "a ordem e progresso" rgba(105, 105, 105, 207)
		elseif ti <= 550 then
			text 5, 10, "ACABE COM OS" rgba(105, 105, 105, 207)
			text 5, 20, "VERMELHOS DA URSAL!!" rgba(105, 105, 105, 207)
		elseif ti <= 680 then
			stage = INGAME
		endif
	endif
	ti = ti + 1
enddef

update_with(drv, lambda(delta)(
	if stage = INTRO then
		title(delta)
	elseif stage = INSTRUCTION then
		instructions(delta)
	elseif stage = INGAME then
		game(delta)
	elseif stage = GAMEOVER then
		gameovers(delta)
	endif
))