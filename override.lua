local override = {
    list = {},
}; do
    --[[
        two modes supported:
        - instance mode: override.new(instance, values)
            instance: instance to override
            values: table with values

        - class mode: override.new(parent, class, values)
            parent: parent to search for class
            class: class to search for
            values: table with values
    ]]
    override.new = function(parent, class, values)
        local delete = false
        local instance = nil

        if not values then
            values = class
            instance = parent
        else
            instance = parent:FindFirstChildOfClass(class)
        end

        if override.list[instance] then
            return false
        end

        if not instance then
            delete = true

            instance = Instance.new(class)
            instance.Name = class
            instance.Parent = parent
        end

        local defaults = {}
        for key, _ in pairs(values) do
            if delete then
                break
            end

            defaults[key] = instance[key]
        end

        override.list[instance] = {
            instance = instance,
            values = values,
            defaults = defaults,
            delete = delete,
        }

        return true
    end

    override.set = function()
        for instance, entry in pairs(override.list) do
            for key, value in pairs(entry.values) do
                entry.instance[key] = value
            end
        end
    end

    override.clear = function()
        for instance, entry in pairs(override.list) do
            if entry.delete then
                entry.instance:Destroy()
                continue
            end

            for key, value in pairs(entry.defaults) do
                entry.instance[key] = value
            end
        end
    end
end
