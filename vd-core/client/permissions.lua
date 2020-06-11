VDCore.PermissionGroups = {
    ['user'] = { 
        permlevel = 0,

        permissions = {
            'vd-admin.use'
        }
    },

    ['admin'] = {
        permlevel = 100,

        permissions = {

        },

        groups = {
            'user'
        }
    }
}

VDCore.hasPermission = function(permission) 
    if VDCore.Table.Contains(VDCore.PermissionGroups['admin'].permissions, permission) then 
        return true
    elseif VDCore.PermissionGroups['admin'].groups ~= nil then
        for i,v in pairs(VDCore.PermissionGroups['admin'].groups) do 
            if VDCore.Table.Contains(VDCore.PermissionGroups[VDCore.PermissionGroups['admin'].groups[v]].permissions, permission) then 
                break
                return true
            end
        end
    end

    return false
end