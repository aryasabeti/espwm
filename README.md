# espwm

## A PWM control module for NodeMCU

espwm originated from our desire to control an LED. We wanted to be able to design light patterns with smooth and predictable visuals, and compose more complex patterns from smaller ones.

## How To Use

espwm uses an internal queue, along with user-defined state machines, here called patterns. To use it you must define a transition function T, along with its initial state S. T *must* return a table in the form of S, and S *must* specify 2 parameters, `duty` and `interval`. After `interval` amount of time the transition function T will be applied and the output pin will be updated according to the new state. When your transition function returns nil, the next pattern in the queue will be fetched. In short:

- Specify an initial state `S` containing at minimum `duty` and `param`
- Specify a transition function `T(S) --> S'`
- Generate a pattern `P <-- pattern(T, S)`
- Enqueue `P` 

## Examples

Linear fade in from 0 to maximum:

    require('espwm')
    espwm.init(1, 6) -- using IO 1, timer 6
    MAX_DUTY = 1023

    fade_in = function(p)
      if p.duty >= MAX_DUTY then
        return nil
      else
        p.duty = p.duty + 1
        return p
      end
    end

    espwm.q_pattern({interval=2, duty=0}, fade_in)

A heartbeat:

    heart_beat = function(p)
      local intervals = {40, 200, 40, 900}

      p.index = p.index + 1
      if p.index > 4 then
        p.index = 1
      end

      p.interval = intervals[p.index]
      p.duty = (p.index % 2) * MAX_DUTY

      return p
    end

    espwm.q_pattern({interval=40, duty=MAX_DUTY, index=1}, heart_beat)

Notice that this heartbeat will never return nil, so it's up to the user to call `next_pattern` in this case.

You can also create patterns and choose to enqueue them later. Assuming your params and transitions are defined elsewhere:

    con_begin = espwm.pattern(cb_params, cb_transition)
    con_success = espwm.pattern(cs_params, cs_transition)
    con_fail = espwm.pattern(cf_params, cf_transition)

    espwm.enqueue(con_begin)
    http.get("http://mywebsite.com", nil, function(code, data)
        if (code < 0) then
            print("HTTP request failed")
            espwm.enqueue(con_fail)
        else
            print("HTTP request succeeded")
            print(code, data)
            espwm.enqueue(con_success)
        end
    end)

Here the user can define patterns, for example, to fade in when the HTTP request begins, then smoothly fade out on success or blink rapidly on failure.

## Other Words

espwm is brand new - right now it can only use a single output pin, and no attention has been given to efficiency. Any contributions in the form of feedback or pull requests is welcome. Enjoy.
