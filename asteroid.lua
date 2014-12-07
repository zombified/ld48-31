require "globals"


function create_circle(rad, num_points, manip_func)
    local center = vector.new(0, 0)
    local deg_step = 360 / num_points
    local points = {}
    local pt, off = nil, nil
    local sat_poly_points = {}

    local cur_deg = 0
    while cur_deg < 360 do
        pt = vector.new(math.cos(math.rad(cur_deg)) * rad, math.sin(math.rad(cur_deg)) * rad)
        pt = manip_func(pt)
        table.insert(points, pt.x)
        table.insert(points, pt.y)
        table.insert(sat_poly_points, satlua.Vector(pt.x, pt.y))
        cur_deg = cur_deg + deg_step
    end

    return {
        points = points,
        sat_poly = satlua.Polygon(satlua.Vector(0, 0), sat_poly_points)
    }
end

function shape_asteroid(point)
    local mag = point:len()
    local norm = point:normalized()
    local newmag = math.random(math.floor(ASTEROID_MIN_VAR*mag), math.floor(ASTEROID_MAX_VAR*mag))

    -- direction scaled to the randomized magnitude
    local offset = norm * newmag

    return (point + offset)
end




function init_asteroid(rad)
    local circ = create_circle(rad, 8, shape_asteroid)

    local ast = {
        rad = rad,
        shape = circ.points,
        sat_poly = circ.sat_poly,
        angle = math.rad(-90),
        accel = vector.new(0, 0),
        vel = vector.new(0, 0),
        pos = vector.new(0, 0),

        health = math.random(ASTEROID_HEALTH_MIN, ASTEROID_HEALTH_MAX),

        r = math.random(0, 255),
        g = math.random(0, 255),
        b = math.random(0, 255),
        a = 255
    }

    return ast
end


function init_asteroid_field(ship)
    if table.getn(live_asteroids) > 0 then
        table.setn(live_asteroids, 0)
    end

    ship.sat_poly:setOffset(satlua.Vector(ship.pos.x, ship.pos.y))

    local count = math.random(ASTEROID_MIN_FIELD_SIZE, ASTEROID_MAX_FIELD_SIZE)
    local ast, ast2, x, y, overlaps, response
    for i=1, count do
        ast = init_asteroid(math.random(ASTEROID_MIN_RAD, ASTEROID_MAX_RAD))
        -- keep generating a position for the asteroid until it doesn't overlap
        -- with the ship or any other asteroids
        while true do
            x = math.random(1, love.graphics.getWidth()-1)
            y = math.random(1, love.graphics.getHeight()-1)
            ast.pos.x = x
            ast.pos.y = y

            ast.sat_poly:setOffset(satlua.Vector(ast.pos.x, ast.pos.y))

            overlaps = satlua.testPolygonPolygon(ship.sat_poly, ast.sat_poly, response)
            if not overlaps then
                for j=table.getn(live_asteroids), 1, -1 do
                    ast2 = live_asteroids[j]
                    ast2.sat_poly:setOffset(satlua.Vector(ast2.pos.x, ast2.pos.y))

                    overlaps = satlua.testPolygonPolygon(ast.sat_poly, ast2.sat_poly, response)
                    if overlaps then
                        break
                    end
                end
                if not overlaps then
                    break
                end
            end
        end
        table.insert(live_asteroids, ast)
    end
end

function update_asteroids(dt)
    local ast
    for i=table.getn(live_asteroids), 1, -1 do
        ast = live_asteroids[i]

        ast.pos = ast.pos + ast.vel

        if ast.pos.x < 0 then ast.pos.x = love.graphics.getWidth() end
        if ast.pos.x > love.graphics.getWidth() then ast.pos.x = 0 end
        if ast.pos.y < 0 then ast.pos.y = love.graphics.getHeight() end
        if ast.pos.y > love.graphics.getHeight() then ast.pos.y = 0 end
    end
end

function draw_asteroids()
    local ast
    for i=table.getn(live_asteroids), 1, -1 do
        ast = live_asteroids[i]
        love.graphics.push()
        love.graphics.translate(ast.pos.x, ast.pos.y)
        love.graphics.setColor(ast.r, ast.g, ast.b, ast.a)
        love.graphics.polygon("fill", ast.shape)
        love.graphics.pop()
    end
end

function update_asteroid_accel(ast)
    ast.accel.x = math.cos(ast.angle) * ASTEROID_ACCEL
    ast.accel.y = math.sin(ast.angle) * ASTEROID_ACCEL
    ast.vel.x = ast.vel.x + ast.accel.x
    ast.vel.y = ast.vel.y + ast.accel.y
    if ast.vel:len() > ASTEROID_MAX_SPEED then
        ast.vel = ast.vel:normalized()
        ast.vel = ast.vel * ASTEROID_MAX_SPEED
    end
end
