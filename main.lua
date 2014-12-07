require "globals"
require "ship"
require "projectile"
require "asteroid"
require "resource"


function love.load()
    math.randomseed(os.time())

    ENGINE_SOUND = love.audio.newSource("assets/590329main_ringtone_SDO_launchNats.mp3", "static")
    LASER_SOUND = love.audio.newSource("assets/Laser_Shoot16.wav", "static")
    LASER_SOUND:setLooping(false)
    EXPLOSION_SOUND = love.audio.newSource("assets/Explosion13.wav", "static")
    EXPLOSION_SOUND:setLooping(false)

    font = love.graphics.newImageFont("assets/herkld-28.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.!:;,/\\%?'\"[] +-")
    love.graphics.setFont(font)

    player = init_ship()
    init_asteroid_field(player)
    init_resource_field(player)
end

function love.update(dt)
    update_ship(player, dt)

    -- let the player move around after death
    if not player.alive then
        return
    end

    update_projectiles(dt)
    update_asteroids(dt)


    local proj, ast, response

    response = satlua.Response()

    -- projectile-asteroid collisions
    for i=table.getn(live_projectiles), 1, -1 do
        proj = live_projectiles[i]
        proj.sat_poly:setOffset(satlua.Vector(proj.pos.x, proj.pos.y))
        for j=table.getn(live_asteroids), 1, -1 do
            ast = live_asteroids[j]
            ast.sat_poly:setOffset(satlua.Vector(ast.pos.x, ast.pos.y))

            response:clear()
            if satlua.testPolygonPolygon(proj.sat_poly, ast.sat_poly, response) then
                EXPLOSION_SOUND:stop()
                EXPLOSION_SOUND:play()

                -- kill the projectile
                table.remove(live_projectiles, i)
                table.insert(dead_projectiles, proj)

                -- damage the asteroid
                ast.health = ast.health - PROJ_DMG

                -- split asteroid if damaged enough
                if ast.health <= 0 then
                    table.remove(live_asteroids, j)
                    -- TODO: actual split, right now the original is just destroyed
                -- apply acceleration/velocity to asteroid if it didn't get destroyed
                else
                    ast.angle = proj.angle

                    -- adjust acceleration and velocity of asteroid
                    update_asteroid_accel(ast)
                end
            end
        end
    end

    -- asteroid-asteroid collisions
    local acircle, bcircle, aast, bast, fragments, newast, newrad, res
    local newasts = {}
    for i=table.getn(live_asteroids), 1, -1 do
        aast = live_asteroids[i]
        acircle = satlua.Circle(aast.pos, aast.rad)
        for j=table.getn(live_asteroids), 1, -1 do
            if i ~= j and aast.health ~= 0 and bast ~= 0 then
                bast = live_asteroids[j]
                bcircle = satlua.Circle(bast.pos, bast.rad)
                response:clear()
                if satlua.testCircleCircle(acircle, bcircle, response) then
                    -- destroy both
                    aast.health = 0
                    bast.health = 0

                    -- create new ones
                    --fragments = math.random(ASTEROID_MIN_FRAGMENT, ASTEROID_MAX_FRAGMENT)
                    fragments = 2
                    for k=fragments-1, 0, -1 do
                        newrad = math.max(aast.rad, bast.rad)/fragments
                        if newrad < ASTEROID_MIN_RAD then
                            -- asteroids that break up to small are just dust
                            break
                        end
                        newast = init_asteroid(newrad)

                        -- set the new asteroid on a random angle
                        --newast.angle = math.rad((360/fragments)*k)
                        newast.angle = math.rad(math.random(0, 359))

                        -- update the new asteroids accel and velocity according to it's angle
                        newast.accel.x = math.cos(newast.angle) * ASTEROID_ACCEL
                        newast.accel.y = math.sin(newast.angle) * ASTEROID_ACCEL
                        newast.vel.x = newast.vel.x + (newast.accel.x)
                        newast.vel.y = newast.vel.y + (newast.accel.y)

                        -- move position of new asteroid along new angle, offset by the "a" asteroids position
                        newast.pos.x = math.cos(newast.angle) * (newrad*2) + aast.pos.x
                        newast.pos.y = math.sin(newast.angle) * (newrad*2) + aast.pos.y
                        table.insert(newasts, newast)
                    end
                end
            end
        end
    end
    for i=table.getn(live_asteroids), 1, -1 do
        -- check health of all asteroids, and kill of the ones that are dead now
        ast = live_asteroids[i]
        if ast.health <= 0 then
            table.remove(live_asteroids, i)
        end
    end
    for i=table.getn(newasts), 1, -1 do
        table.insert(live_asteroids, newasts[i])
    end

    -- player-astroid collisions
    player.sat_poly:setOffset(satlua.Vector(player.pos.x, player.pos.y))
    for i=table.getn(live_asteroids), 1, -1 do
        ast = live_asteroids[i]
        ast.sat_poly:setOffset(satlua.Vector(ast.pos.x, ast.pos.y))
        response:clear()
        if satlua.testPolygonPolygon(player.sat_poly, ast.sat_poly, response) then
            player.alive = false
        end
    end

    -- player-resource collisions
    player.sat_poly:setOffset(satlua.Vector(player.pos.x, player.pos.y))
    for i=table.getn(live_resources), 1, -1 do
        res = live_resources[i]
        res.sat_poly:setOffset(satlua.Vector(res.pos.x, res.pos.y))
        response:clear()
        if satlua.testPolygonPolygon(player.sat_poly, res.sat_poly, response) then
            table.remove(live_resources, i)
            player.resources = player.resources + RESOURCE_PURE_WORTH * res.worth
        end
    end

end

function love.draw()
    if player.alive then
        draw_asteroids()
        draw_resources()
        draw_projectiles() -- drawn before player to hide underneath ship
    end
    draw_ship(player)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("score:" .. player.resources, 10, 20)

    if not player.alive then
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.print("YOU DIED", (love.graphics.getWidth()/2)-(8*6), (love.graphics.getHeight()/2)-(28/2))
        love.graphics.setColor(200, 200, 200, 255)
        love.graphics.print("press enter to reset screen", (love.graphics.getWidth()/2)-(27*7), (love.graphics.getHeight()/2)+28)
    end
end



function love.keypressed(key, isrepeat)
    if key == "escape" then
        love.event.quit()
    end

    if key == " " and not isrepeat then
        LASER_SOUND:stop()
        LASER_SOUND:play()
        init_projectile(player.pos, player.vel, player.accel, player.angle)
    end

    -- player dead, wants to restart, so re-generate asteroid field
    -- and reset player
    if key == "return" and not player.alive and not isrepeat then
        live_projectiles = {}
        dead_projectiles = {}
        live_asteroids = {}
        live_resources = {}

        player = init_ship()
        init_asteroid_field(player)
        init_resource_field(player)
    end
end
