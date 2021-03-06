-- Copyright (c) 2015  Phil Leblanc  -- see LICENSE file

------------------------------------------------------------
--[[ 

test ec25519 module

]]

local ec = require 'ec25519'

------------------------------------------------------------
-- utilities
local function pt(t) print(table.concat(t, " ")) end
local function pf(...) print(string.format(...)) end

local function verify(x, y) 
	-- verify that x[i] == y[i] for all i
	b = #x == #y
	for i = 1, #x do b = b and (x[i] == y[i]) end
	return b
end

------------------------------------------------------------
function test_scalarmult_base()
	local n1 = {
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	}
	local n2 = {
	255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
	255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
	}
	local n3 = {
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	}
	local q = {}
	local qexp1 = {
	164,224,146,146,182,81,194,120,185,119,44,86,159,95,169,187,
	19,217,6,180,106,182,140,157,249,220,43,68,9,248,162,9
	}
	local qexp2 = {
	132,124,13,44,55,82,52,243,101,230,96,149,81,135,163,115,
	90,15,118,19,209,96,157,58,106,77,140,83,174,170,90,34
	}
	local qexp3 = {
	47,229,125,163,71,205,98,67,21,40,218,172,95,187,41,7,48,
	255,246,132,175,196,207,194,237,144,153,95,88,203,59,116
	}
	--
	ec.crypto_scalarmult_base(q, n1)
--~ 	pt(q)
	assert(verify(q, qexp1))
	--
	ec.crypto_scalarmult_base(q, n2)
--~ 	pt(q)
	assert(verify(q, qexp2))
	--
	ec.crypto_scalarmult_base(q, n3)
--~ 	pt(q)
	assert(verify(q, qexp3))
end --test_scalarmult

local function test_scalarmult_perf()
	local c0 = os.clock()
	for i = 1, 100 do		-- 99 sec elapsed ~ 0.33 sec / mult (on ac38)
		test_scalarmult_base() 
	end
	local c1 = os.clock()
	print("ok.  300 multiplications (in sec):", c1-c0)
end

local function test_scalarmult()
	local n1 = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
	local n2 = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
	local q = {}
	local qexp = {
		4,127,3,145,33,24,80,55,195,2,25,30,69,152,41,73,247,
		217,178,195,16,207,14,23,51,33,83,95,188,20,223,62
		}
	ec.crypto_scalarmult(q, n1, n2)
	assert(verify(q, qexp))
end

local function test_kexch()
	local ska = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
	local skb = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
	local pka, pkb = {}, {}
	ec.crypto_scalarmult_base(pka, ska)
	ec.crypto_scalarmult_base(pkb, skb)
	local r1, r2 = {}, {}
	ec.crypto_scalarmult(r1, ska, pkb)
	ec.crypto_scalarmult(r2, skb, pka)
--~ 	pt(r1)
--~ 	pt(r2)
	assert(verify(r1, r2))
end

test_scalarmult()
test_scalarmult_base()
test_kexch()

print("test_ec25519: ok")


