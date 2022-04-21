-- 存储类的类型
local _class = {}

--定义类的继承
function BaseClass(super)
    local class_type = {}
    class_type.__init = false

    class_type.__delete = false
    class_type.super = super

    class_type.New = function(...)  -- 构造函数
        local obj = {}
        setmetatable(obj, {__index = _class[class_type]}) -- 类与对象的映射

        local create
        create = function(c, ...)
            if c.super then
                create(c.super, ...)
            end

            if c.__init then
                c.__init(obj, ...)
            end
        end

        create(class_type, ...)

        obj.Delete = function(self)  -- 析构函数，只能将对象变为空表，完全删除对象需赋值nil
            local now = class_type
            while now do
                local super = now.super
                if now.__delete then
                    now.__delete(self)
                end
                now = super
            end

            for k in pairs(self) do
                self[k] = nil
            end

            setmetatable(self, nil)
        end
        
        return obj
    end    

    local vtbl = {}
    _class[class_type] = vtbl

    -- 类与类成员的映射
    setmetatable(class_type, {
        __newindex = function(t, k, v)
            vtbl[k] = v
        end,
        __index = vtbl
    })

    -- 派生类与基类的映射
    if super then
        setmetatable(vtbl, {
            __index = function(t, k)
                local ret = _class[super][k]
                return ret
            end
        })
    end

    return class_type
end

return BaseClass