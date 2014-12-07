require "globals"


function init_ship()
    local radius = 10
    local x1, y1, x2, y2, x3, y3
    x1 = radius
    y1 = 0
    x2 = -radius
    y2 = -radius
    x3 = -radius
    y3 = radius
    local xpos = (love.graphics.getWidth() / 2);
    local ypos = (love.graphics.getHeight() / 2);
    local sat_poly = satlua.Polygon(satlua.Vector(0, 0), {
        satlua.Vector(x1, y1),
        satlua.Vector(x2, y2),
        satlua.Vector(x3, y3)
    })

    return {
        sat_poly = sat_poly,

        radius = radius,

        x1 = x1, y1 = y1,
        x2 = x2, y2 = y2,
        x3 = x3, y3 = y3,

        r = 255, g = 255, b = 255, a = 255,
        tr = 255, tg = 149, tb = 0, a = 255,

        pos = vector.new(xpos, ypos),
        angle = math.rad(-90),
        accel = vector.new(0, 0),
        vel = vector.new(0, 0),

        resources = 0,

        alive = true
    }
end

function draw_ship(ship)
    love.graphics.push()
    love.graphics.translate(ship.pos.x, ship.pos.y)
    love.graphics.rotate(ship.angle)
    -- draw engine firing when ship is thrusting (which is a copy of the ship,
    -- just resized, repositioned, rotated and a different color)
    if love.keyboard.isDown("up") and ship.alive then
        love.graphics.push()
        love.graphics.translate(-ship.radius-5, 0)
        love.graphics.rotate(math.rad(180))
        love.graphics.scale(.5)
        love.graphics.setColor(255, 149, 0, 255)
        love.graphics.polygon('fill', ship.x1, ship.y1, ship.x2, ship.y2, ship.x3, ship.y3)
        love.graphics.pop()
    end
    -- draw ship
    love.graphics.setColor(ship.r, ship.g, ship.b, ship.a)
    love.graphics.polygon('fill', ship.x1, ship.y1, ship.x2, ship.y2, ship.x3, ship.y3)
    love.graphics.pop()
end

function update_ship(ship, dt)
    -- above, switch to below
    if (ship.pos.y + ship.radius) < 0 then
        ship.pos.y = love.graphics.getHeight() - ship.radius
    -- below, switch to above
    elseif (ship.pos.y - ship.radius) > love.graphics.getHeight() then
        ship.pos.y = ship.radius
    end
    -- left, switch to the right
    if (ship.pos.x + ship.radius) < 0 then
        ship.pos.x = love.graphics.getWidth() - ship.radius
    -- right, switch to the left
    elseif (ship.pos.x - ship.radius) > love.graphics.getWidth() then
        ship.pos.x = ship.radius
    end

    if love.keyboard.isDown("left") and ship.alive then
        ship.angle = ship.angle - (ANGULAR_VELOCITY * dt)
    elseif love.keyboard.isDown("right") and ship.alive then
        ship.angle = ship.angle + (ANGULAR_VELOCITY * dt)
    end

    if love.keyboard.isDown("up") and ship.alive then
        ENGINE_SOUND:play()

        ship.accel.x = math.cos(ship.angle) * ACCELERATION
        ship.accel.y = math.sin(ship.angle) * ACCELERATION

        ship.vel = ship.vel + (ship.accel * dt)

        -- scale velocity to max possible speed if it's length exceeds the speed
        if ship.vel:len() > MAX_SPEED then
            ship.vel = ship.vel:normalized() * MAX_SPEED
        end
    else
        ENGINE_SOUND:stop()
    end

    ship.pos = ship.pos + (ship.vel * dt)
end


