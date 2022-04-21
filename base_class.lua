--[[
    4、Lua面向对象实现，要点如下
        a)、编写BaseClass实现lua的继承，父类至少有__init方法和__delete方法
        b)、类的创建，调用New方法。类创建时，需要先调用父类的__init方法，后调用自己的__init方法
        c)、类的销毁，调用DeleteMe方法。类销毁时，需要先调用父类的__delete方法，后调用自己的__delete方法
]]

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

        obj.DeleteMe = function(self)  -- 析构函数，只能将对象变为空表，完全删除对象需赋值nil
            local now = class_type
            while now do
                local super = now.super
                if now.__delete then
                    now.__delete(self)
                end
                now = super
            end

            for k, v in pairs(self) do
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
                -- vtbl[k] = ret  -- 会导致父类的更改子类无法继承
                return ret
            end
        })
    end

    return class_type
end

return BaseClass