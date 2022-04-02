-- 创建时间:2021-07-01

local basefunc = require "Game/Common/basefunc"

SteeringForEvadeObstacle = basefunc.class(Steering)

function SteeringForEvadeObstacle:Ctor(parm)
	SteeringForEvadeObstacle.super.Ctor(self,parm)

	-- 推力的最小值
    self.minRepulsiveForce = 1
    -- 障碍物Tag
    self.obstacleTag = ""
    -- 探头长度
    self.probeLength = 1
    -- 探头的位置
    self.problePos = 1

	for k,v in pairs(parm) do
		self[k] = v
	end
end

function SteeringForEvadeObstacle:ComputeForce()
	-- RaycastHit hitInfo;
 --    if (!Physics.Raycast(problePos.position , problePos.forward , out hitInfo , probeLength)
 --        || hitInfo.collider.tag == obstacleTag)
 --        return Vector3.zero;

 --    expectForce = hitInfo.point - hitInfo.collider.transform.position;
 --    if (expectForce.magnitude < minRepulsiveForce)
 --        expectForce = expectForce.normalized * minRepulsiveForce;

 --    return expectForce * weight;
end
