require "globals"


function init_projectile(pos, vel, accel, angle)
    proj = nil
    -- init from pool if we can, otherwise create a new one
    if table.getn(dead_projectiles) > 0 then
        proj = table.remove(dead_projectiles)
        proj.pos.x = pos.x
        proj.pos.y = pos.y
        proj.vel.x = 0
        proj.vel.y = 0
        proj.accel.x = 0
        proj.accel.y = 0
        proj.size.x = 20
        proj.size.y = 3
        proj.angle = angle
        proj.ttl = PROJ_TTL
        proj.sat_poly = nil
    else
        proj = {
            r = 255, g = 0, b = 0, a = 255,
            pos = vector.new(pos.x, pos.y),
            vel = vector.new(0, 0),
            accel = vector.new(0, 0),
            size = vector.new(20, 3),
            angle = angle,
            ttl = PROJ_TTL,
            sat_poly = nil
        }
    end

    proj.sat_poly = satlua.Box(satlua.Vector(-(proj.size.x/2), -(proj.size.y/2)), proj.size.x, proj.size.y):toPolygon()

    -- accel is found, basically just for the direction
    proj.accel.x = math.cos(proj.angle) * PROJ_ACCEL
    proj.accel.y = math.sin(proj.angle) * PROJ_ACCEL
    accel_dir  = proj.accel:normalized()

    -- the velocity is the direction scaled to the max speed since projectiles
    -- are immediately at max speed
    proj.vel.x = accel_dir.x * PROJ_MAX_SPEED
    proj.vel.y = accel_dir.y * PROJ_MAX_SPEED

    table.insert(live_projectiles, proj)
    return proj
end

function draw_projectiles()
    local proj, x, y
    for i=table.getn(live_projectiles), 1, -1 do
        proj = live_projectiles[i]

        x = -(proj.size.x/2)
        y = -(proj.size.y/2)

        love.graphics.push()
        love.graphics.translate(proj.pos.x, proj.pos.y)
        love.graphics.rotate(proj.angle)
        love.graphics.setColor(proj.r, proj.g, proj.b, proj.a)
        love.graphics.rectangle("fill", x, y, proj.size.x, proj.size.y)
        love.graphics.pop()
    end
end

function update_projectiles(dt)
    local proj
    for i=table.getn(live_projectiles), 1, -1 do
        proj = live_projectiles[i]

        proj.ttl = proj.ttl - dt
        if proj.ttl < 0 then -- dead
            table.remove(live_projectiles, i)
            table.insert(dead_projectiles, proj)
        else -- alive
            proj.pos = proj.pos + (proj.vel * dt)

            if proj.pos.x < 0 then proj.pos.x = love.graphics.getWidth() end
            if proj.pos.x > love.graphics.getWidth() then proj.pos.x = 0 end
            if proj.pos.y < 0 then proj.pos.y = love.graphics.getHeight() end
            if proj.pos.y > love.graphics.getHeight() then proj.pos.y = 0 end
        end
    end
end

