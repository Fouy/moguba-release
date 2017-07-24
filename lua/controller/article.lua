local cjson = require "cjson"
local req = require "dispatch.req"
local result = require "common.result"
local article_service = require "service.article_service"
local article_type_service = require "service.article_type_service"
local common_service = require "service.common_service"
local template = require("resty.template")
local page = require "common.page"

local _M = {}

-- 编辑页面
function _M:editor()
	local args = req.getArgs()
	local articleId = args["articleId"]
	local context = {}

	if articleId ~= nil and articleId ~= "" then
		local entity = article_service:detail(articleId)
		context["entity"] = entity
		context["articleId"] = articleId
	end

	template.render("editor.html", context)
end

-- 保存文章
function _M:save()
	local args = req.getArgs()
	local _type = args["type"]
	local tag = args["tag"]
	local title = args["title"]
	local source = args["source"]
	local content = args["content"]
	local articleId = args["articleId"]
	local token = args["token"]
	local hot = args["hot"]

	if token == nil or token ~= "340323" then
		ngx.say(cjson.encode(result:error("口令错误")))
		return 
	end
	if hot == nil or hot == "" then
		ngx.say(cjson.encode(result:error("热门错误")))
		return 
	end
	if title == nil or title == "" then
		ngx.say(cjson.encode(result:error("标题为空")))
		return 
	end
	if source == nil or source == "" then
		ngx.say(cjson.encode(result:error("文章来源为空")))
		return 
	end
	if content == nil or content == "" then
		ngx.say(cjson.encode(result:error("内容为空")))
		return
	end

	if articleId == nil or articleId == "" then
		article_service:save(args)
		ngx.say(cjson.encode(result:success("新增成功")))
		return
	else
		article_service:update(args)
		ngx.say(cjson.encode(result:success("更新成功")))
		return
	end

end


-- 查询列表
function _M:list()
	local args = req.getArgs()
	local pageNumber = args["pageNumber"]
	local pageSize = args["pageSize"]

	if pageNumber == nil or pageNumber == "" then
		args["pageNumber"] = 1
	end
	if pageSize == nil or pageSize == "" then
		args["pageSize"] = 10
	end

	local list, count = article_service:list(args)
	-- ngx.log(ngx.ERR, '((((((((((((((((())))))))))' .. count)
	
	ngx.say(cjson.encode(page:new(count, args["pageNumber"], list)))

end

-- 分类页
function _M:category()
	local args = req.getArgs()
	local pageNo = args["pageNo"]
	local pageSize = args["pageSize"]
	local typeId = args["typeId"]

	if pageNo == nil or pageNo == "" then
		args["pageNo"] = 1
	end
	if pageSize == nil or pageSize == "" then
		args["pageSize"] = 10
	end
	if typeId == nil or typeId == "" then
		ngx.say(cjson.encode(result:error("分类ID为空")))
		return
	end

	local list = article_service:list(args)
	local typeEntity = article_type_service:detail(typeId)
	local context = {list = list, pageNo = tonumber(args["pageNo"])+1, typeEntity = typeEntity }
	
	-- 增加热门文章数据
	context["hotList"] = common_service:hotList()
	template.render("blog/category.html", context)

end

-- 获取单个文章
function _M:detail()
	local args = req.getArgs()
	local articleId = args["articleId"]

	if articleId == nil or articleId == "" then
		ngx.say(cjson.encode(result:error("ID为空")))
		return
	end

	local entity = article_service:detail(articleId)
	ngx.say(cjson.encode(result:success("更新成功", entity)))

end

-- 删除文章
function _M:delete()
	local args = req.getArgs()
	local articleId = args["articleId"]

	if articleId == nil or articleId == "" then
		ngx.say(cjson.encode(result:error("ID为空")))
		return
	end

	article_service:delete(articleId)
	ngx.say(cjson.encode(result:success("删除成功")))

end

return _M