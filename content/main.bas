REM PATRIOTA ADVENTURES
REM License: CC-BY.
REM Press Ctrl+R to run.

drv = driver()
print drv, ", detail type is: ", typeof(drv);

' Items
own_bullets = list()
alive_enemies = list()

' Screens
INGAME = 0
INSTRUCTION = 1
GAMEOVER = 2

' Stages
URSAL = 0
CUBA = 1
VENEZUELA = 2
CHINA = 3

'Stats
LIFES = 3
SPEED = 50
POWER = 1
BULLET_SPEED = 80
BULLET_SPAWN = 10

' Enemys
LGBT_ENEMY = 0
MARX_ENEMY = 1

' Sprites
patriotaSprite = load_resource("patriota.sprite")
fakeNewsSprite = load_resource("zap.sprite")
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

class cEnemy(point)
	health = 0

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
	endif
enddef

class cBullet(point)
    def setPosition(xb, yb)
	  x = xb
	  y = yb
	enddef
endclass
bullet = new(cBullet)

class cPatriota(point)
    def setPosition(xp, yp)
	    x = xp
	    y = yp
	enddef
	
	x = 45
	y = 80

	def updatePosition(delta)
	    px = x
	    py = y
		' RIGHT
		if btn(0) then
			px = x - delta * SPEED
			if px < 0 then px = 0
	    ' LEFT UP
		elseif btn(1) and btn(2) then
			px = x + delta * SPEED
			if px > 160 then px = 160
			py = up(y, delta, SPEED / 2)
	    ' LEFT
		elseif btn(1) then
			px = x + delta * SPEED
			if px > 160 then px = 160
		' UP
		elseif btn(2) then
			py = up(y, delta, SPEED)
	    ' DOWN
		elseif btn(3) then
			py = y + delta * SPEED
			if py >= 112 then py = 111
		
	endif
	setPosition(px, py)
	spr patriotaSprite, x, y
    enddef

endclass

def debugMouse()
	touch 0, tx, ty, tb0
	text 30, 30, "MOUSE AT " + str(tx) + "," + str(ty), rgba(5, 255, 255)
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

def spawnNewBullet(origin)
	bullet = new(cBullet)
	bullet.setPosition(origin.x + 10, origin.y)
	push(own_bullets, bullet)
enddef

b = 0
def setBullets(delta, origin)
	handleOwnBullets = coroutine
	(
		lambda(delta)
		(
			if len(own_bullets) > 0 then
				idxBullet = 0
				while idxBullet < len(own_bullets)
					instbullet = get(own_bullets, idxBullet)
					newY = up(instbullet.y, delta, BULLET_SPEED)
					instbullet.setPosition(instbullet.x, newY)
					spr bulletSprite, instbullet.x, instbullet.y
					' FIX

					idxEnemy = 0
					if len(alive_enemies) > 0 then
						while idxEnemy < len(alive_enemies)
							instenemy = get(alive_enemies, idxEnemy)
							if isTouched(instbullet, instenemy, 10) then
								takeDamage(instenemy, idxEnemy)
								remove(own_bullets, idxBullet)
							endif
							idxEnemy = idxEnemy + 1
						wend
					endif

					if instbullet.y = 0 then
						remove(own_bullets, idxBullet)
					endif
					idxBullet = idxBullet + 1
				wend
			endif
		)
		delta
	)

	b = b + 1
    if b = BULLET_SPAWN then
		spawnNewBullet(origin)
		b = 0
	endif
	start(handleOwnBullets)
enddef

def setEnemies(delta)
	handleEnemies = coroutine
	(
		lambda(delta)
		(
			for e in alive_enemies
				spr lgbtSprite, e.x, e.y
			next
		)
		delta
	)
	start(handleEnemies)
enddef

patriota = new(cPatriota)
enemy = new(cEnemy)
enemy.setPosition(50, 50)
enemy.setEnemyProperties(0)
push(alive_enemies, enemy)
t = 0
play "T120 B6 E6 D#6 E6 F#6 G#3 F#6 G#6 A6 A#6 B3", 0, 0, true

def update(delta)
    ' debugMouse()
	' Ticks
	t = t + 1
	patriota.updatePosition(delta)
	setBullets(delta, patriota)
	setEnemies(delta)

	if t > 1 then
		t = t - 1
		col rgba(rnd(255), rnd(255), rnd(255), 127)
		text 5, 10, "PATRIOTA ADVENTURES"
	endif
enddef

update_with(drv, call(update))
