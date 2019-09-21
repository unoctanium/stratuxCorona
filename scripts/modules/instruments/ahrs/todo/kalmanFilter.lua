-- KasBot V2  -  Kalman filter module - http://www.x-firm.com/?page_id=145
-- Modified by Kristian Lauszus
-- See his blog post for more information: http://blog.tkjelectronics.dk/2012/09/a-practical-approach-to-kalman-filter-and-how-to-implement-it
-- ported to LUA by Unoctanium. More information: https://github.com/unoctanium

return { new = function(params)

  -- Construct and initialize instance
  local Instance = {}

  -- Public properties
  --Inst.publicVariable = nil

  --
  -- PRIVATE
  --

  -- Set Process parameters
  local Q_angle = 0.001 -- params.qAngle --0.001   -- Process noise variance for the accelerometer
  local Q_bias = 0.003 -- params.qBias --0.003    -- Process noise variance for the gyro bias
  local R_measure = 0.03 --params.rMeasure --0.03  -- Measurement noise variance - this is actually the variance of the measurement noise

  -- Reset parameters
  local angle = 0.0 --params.angle --0.0   -- The angle calculated by the Kalman filter - part of the 2x1 state vector
  local bias = 0.0 --params.bias --0.0    -- The gyro bias calculated by the Kalman filter - part of the 2x1 state vector
  local rate = 0.0 --params.rate --0.0    -- Unbiased rate calculated from the rate and the calculated bias - you have to call getAngle to update the rate
  -- Error covariance matrix
  local p00 = 0.0 -- Since we assume that the bias is 0 and we know the starting angle (use setAngle), the error covariance matrix is set like so - see: http://en.wikipedia.org/wiki/Kalman_filter#Example_application.2C_technical
  local p01 = 0.0
  local p10 = 0.0
  local p11 = 0.0


  -- The angle should be in degrees and the rate should be in degrees per second and the delta time in seconds
  function Instance.getAngle(newAngle, newRate, dt)

    -- Discrete Kalman filter time update equations - Time Update ("Predict")
    -- Update xhat - Project the state ahead
    -- Step 1 --
    rate = newRate - bias
    angle = angle + dt * rate

    -- Update estimation error covariance - Project the error covariance ahead
    -- Step 2 --
    p00 = p00 + dt * (dt*p11 - p01 - p10 + Q_angle)
    p01 = p01 - dt * p11
    p10 = p10 - dt * p11
    p11 = p11 + Q_bias * dt

    -- Discrete Kalman filter measurement update equations - Measurement Update ("Correct")
    -- Calculate Kalman gain - Compute the Kalman gain
    -- Step 4 --
    local S = p00 + R_measure -- Estimate error
    -- Step 5 --
    local k0, k1 -- Kalman gain - This is a 2x1 vector
    k0 = p00 / S
    k1 = p10 / S

    -- Calculate angle and bias - Update estimate with measurement zk (newAngle)
    -- Step 3 --
    local y = newAngle - angle -- Angle difference
    -- Step 6 --
    angle = angle + k0 * y
    bias = bias + k1 * y

    -- Calculate estimation error covariance - Update the error covariance
    -- Step 7 --
    local P00_temp = p00
    local P01_temp = p01

    p00 = p00 - k0 * P00_temp
    p01 = p01 - k0 * P01_temp
    p10 = p10 - k1 * P00_temp
    p11 = p11 - k1 * P01_temp

    return angle
  
  end

  function Instance.setAngle(_angle)
     angle = _angle -- Used to set angle, this should be set as the starting angle
  end
  
  function Instance.getRate() 
    return rate -- Return the unbiased rate
  end

  --
  -- These are used to tune the Kalman filter
  --

  function Instance.setQangle(_Q_angle)
    Q_angle = _Q_angle
  end

  function Instance.setQbias(_Q_bias)
    Q_bias = _Q_bias
  end

  function Instance.setRmeasure(_R_measure)
    R_measure = _R_measure
  end
  
  function Instance.getQangle()
    return Q_angle
  end

  function Instance.getQbias()
    return Q_bias
  end

  function Instance.getRmeasure() 
    return R_measure
  end


return Instance end }
