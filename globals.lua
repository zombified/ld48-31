vector = require "lib.hump.vector"
satlua = require "lib.satlua.SAT"


MAX_SPEED = 250  -- pixels/second
ACCELERATION = 200 -- pixels/second/second
ANGULAR_VELOCITY = math.rad(180) -- degrees/second
PROJ_ACCEL = 400
PROJ_MAX_SPEED = 400
PROJ_TTL = 3 -- Time To Live, in seconds
PROJ_DMG = 1 -- damage projectile does to asteroids
ASTEROID_HEALTH_MAX = 10
ASTEROID_HEALTH_MIN = 1
ASTEROID_POINTS = 8 -- number of points that define the polygon representing an astroid
ASTEROID_MAX_VAR = 1.5 -- % maximum variance in point position
ASTEROID_MIN_VAR = .7 -- % min variance in point position
ASTEROID_MAX_RAD = 15 -- pixels
ASTEROID_MIN_RAD = 5 -- pixels
ASTEROID_MIN_FIELD_SIZE = 30 -- number of asteroidal objects
ASTEROID_MAX_FIELD_SIZE = 60 -- number of asteroidal objects
ASTEROID_ACCEL = .5 -- pixels/second/second
ASTEROID_MAX_SPEED = 10 --pixels/second
ASTEROID_MIN_FRAGMENT = 3
ASTEROID_MAX_FRAGMENT = 6
RESOURCE_ACCEL = 1
RESOURCE_MIN = 20
RESOURCE_MAX = 30
RESOURCE_MIN_WORTH = .3
RESOURCE_MAX_WORTH = .8
RESOURCE_PURE_WORTH = 1000

player = nil
live_projectiles = {}
dead_projectiles = {}
live_asteroids = {}
live_resources = {}


ENGINE_SOUND = nil
LASER_SOUND = nil
EXPLOSION_SOUND = nil
