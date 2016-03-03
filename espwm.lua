local pwm = pwm
local tmr = tmr
local table = table
local next = next

local PWM_PIN = nil
local TIMER = nil
local MAX_DUTY = 1023
local Q = {}

module(...)

function init(pwm_pin, timer)
  TIMER = timer
  tmr.unregister(TIMER)

  PWM_PIN = pwm_pin
  pwm.setup(PWM_PIN, 500, 0)
  pwm.start(PWM_PIN)
  pwm.stop(PWM_PIN)
end

-- params MUST contain duty and interval
local function pattern(params, trans_func)
  local params = params
  local callback = nil

  callback = function()
    if params and params.duty ~= nil then
      pwm.setduty(PWM_PIN, params.duty)
      tmr.alarm(TIMER, params.interval, tmr.ALARM_SINGLE, callback)
      params = trans_func(params)
    else
      next_pattern()
    end
  end

  return callback
end

local function enqueue(pattern)
  table.insert(Q, pattern)
  if not tmr.state(TIMER) then
    next_pattern()
  end
end

function next_pattern()
  if next(Q) then
    local next_p = table.remove(Q, 1) -- how expensive is this?
    next_p()
  end
end

function q_pattern(params, trans_func)
  enqueue(pattern(params, trans_func))
end

function kill()
  Q = {}
  tmr.unregister(TIMER)
  pwm.setduty(PWM_PIN, 0)
end
