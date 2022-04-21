local BaseClass = require("base_class")

local A = BaseClass()

function A.__init()
    print("构造A")
end

function A.__delete()
    print("析构A")
end

local B = BaseClass(A)

function B.__init()
    print("构造B")
end

function B.__delete()
    print("析构B")
end

local instance = B.New()
instance:Delete()