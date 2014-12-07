require "globals"


function init_resource()
    local w, h = 10, 10

    local sat_poly = satlua.Polygon(satlua.Vector(0, 0), {
        satlua.Vector(w/2, h/2),
        satlua.Vector(-(w/2), h/2),
        satlua.Vector(-(w/2), -(h/2)),
        satlua.Vector(w/2, -(h/2)),
    })

    return {
        pos = vector.new(0, 0),
        accel = vector.new(0, 0),
        vel = vector.new(0, 0),
        angle = 0,

        worth = math.random(RESOURCE_MIN_WORTH*100, RESOURCE_MAX_WORTH*100)/100,

        w = w,
        h = h,
        sat_poly = sat_poly,

        r = 255, g = 255, b = 0, a = 255
    }
end


function draw_resources()
    local res, pts
    for i=table.getn(live_resources), 1, -1 do
        res = live_resources[i]
        pts = live_resources[i].sat_poly.points
        love.graphics.push()
        love.graphics.translate(res.pos.x, res.pos.y)
        love.graphics.setColor(res.r*(1-res.worth), res.g*res.worth, res.b, res.a)
        love.graphics.polygon("line", pts[1].x, pts[1].y, pts[2].x, pts[2].y, pts[3].x, pts[3].y, pts[4].x, pts[4].y)
        love.graphics.pop()
    end
end


function init_resource_field()
    local res
    for i=math.random(RESOURCE_MIN, RESOURCE_MAX), 1, -1 do
        res = init_resource()
        res.angle = math.rad(math.random(0, 359))
        res.accel.x = math.cos(res.angle) * RESOURCE_ACCEL
        res.accel.y = math.sin(res.angle) * RESOURCE_ACCEL
        res.vel.x = res.vel.x + res.accel.x
        res.vel.y = res.vel.y + res.accel.y
        res.pos.x = math.random(0, love.graphics.getWidth())
        res.pos.y = math.random(0, love.graphics.getHeight())
        table.insert(live_resources, res)
    end
end
