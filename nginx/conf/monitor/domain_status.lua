local json = require ("cjson")
local access = ngx.shared.access
local args = ngx.req.get_uri_args()
local host = args["host"]
local port = args["port"]
local one_minute_ago = tonumber(os.date("%s")) - 60
local now = tonumber(os.date("%s"))
 
local status_table = {}
local flow_total = 0
local reqt_total = 0
local req_total = 0
 
if not host then
    ngx.print("host arg not found.")
    ngx.exit(ngx.HTTP_OK)
end

if not port then
    ngx.print("port arg not found.")
    ngx.exit(ngx.HTTP_OK)
end

-- status
for k, v in pairs(access:get_keys()) do
    local m, err = ngx.re.match(v,
        "^"..host.."-"..port.."-".."([0-9]{3})".."-([0-9]+)")
    if m then
        local http_code = m[1]
        local timestamp = m[2]
        if tonumber(timestamp) >= one_minute_ago then
            local tick_count = access:get(m[0])
            if status_table[http_code] == nil then
                status_table[http_code] = 1
            else
                status_table[http_code] = status_table[http_code] + tick_count
            end
        end
    end
end

for timestamp=one_minute_ago, now do
    local flow_key = table.concat({host, "-", port, "-flow-", timestamp})
    local req_time_key = table.concat({host, "-", port, "-reqt-", timestamp})
    local total_req_key = table.concat({host, "-", port, "-total_req-", timestamp})
    -- flow total
    local flow_sum = access:get(flow_key) or 0
    flow_total = flow_total + flow_sum
    -- reqt
    local req_sum = access:get(total_req_key) or 0
    local req_time_sum = access:get(req_time_key) or 0
    reqt_total = reqt_total + req_time_sum
    req_total = req_total + req_sum
end

if req_total == 0 then
    reqt_avg = 0
else
    reqt_avg = reqt_total/req_total
end

ngx.print('{"status":'..json.encode(status_table)..',"flow":'..
          flow_total..',"reqt_avg":'..reqt_avg..',"req_total":'..
          req_total..',"reqt_total":'..reqt_total..'}')
