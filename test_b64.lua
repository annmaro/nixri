local function b64encode(s)
    local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local out = {}
    local i = 1
    while i <= #s do
        local c1 = s:byte(i)
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        local n = c1 * 65536 + (c2 or 0) * 256 + (c3 or 0)
        local pos = #out + 1
        out[pos] = B64:sub(math.floor(n / 262144) % 64 + 1, math.floor(n / 262144) % 64 + 1)
        out[pos + 1] = B64:sub(math.floor(n / 4096) % 64 + 1, math.floor(n / 4096) % 64 + 1)
        out[pos + 2] = (i + 1 <= #s) and B64:sub(math.floor(n / 64) % 64 + 1, math.floor(n / 64) % 64 + 1) or "="
        out[pos + 3] = (i + 2 <= #s) and B64:sub(n % 64 + 1, n % 64 + 1) or "="
        i = i + 3
    end
    return table.concat(out)
end
print(b64encode("annmaro:!@Motoedge@70'"))
