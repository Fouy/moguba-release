local cjson = require "cjson"
local mysql = require("libs.mysql")
local html_util = require("libs.html")
local type_service = require("service.article_type_service")
local tag_service = require("service.tag_service")
local utf8sub = require("libs.utf8sub")

local _M = {}

-- 新增文章
function _M:save( article_entity )
	article_entity['type'] = ngx.quote_sql_str(article_entity['type'])
	article_entity['tag'] = ngx.quote_sql_str(article_entity['tag'])
	article_entity['title'] = ngx.quote_sql_str(article_entity['title'])
	article_entity['source'] = ngx.quote_sql_str(article_entity['source'])
	article_entity['content'] = ngx.quote_sql_str(article_entity['content'])
	article_entity['hot'] = ngx.quote_sql_str(article_entity['hot'])

	local db = mysql:new()
	local sql = "insert into article(`type_id`, `tag_id`, `title`, `content`, `create_date`, `source`, `hot`, `create_time`, `modify_time`) " 
			.. " values (%s, %s, %s, %s, now(), %s, %s, now(), now() )"
	sql = string.format(sql, article_entity['type'], article_entity['tag'], article_entity['title'], article_entity['content'], article_entity['source'], article_entity['hot'])
	-- 刷新文章总数
	local updatesql = "update article_type set count = count + 1 where type_id = %s"
	updatesql = string.format(updatesql, article_entity['type'])

	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sql .. ' ; ' .. updatesql .. ' ; ')
	db:close()
	if not res then
		ngx.say(err)
		return {}
	end

end

-- 更新文章
function _M:update( article_entity )
	article_entity['type'] = ngx.quote_sql_str(article_entity['type'])
	article_entity['tag'] = ngx.quote_sql_str(article_entity['tag'])
	article_entity['title'] = ngx.quote_sql_str(article_entity['title'])
	article_entity['source'] = ngx.quote_sql_str(article_entity['source'])
	article_entity['content'] = ngx.quote_sql_str(article_entity['content'])
	local articleId = tonumber(article_entity["articleId"])

	local db = mysql:new()
	local sql = "update article set `type_id`=%s, `tag_id`=%s, `title`=%s, `content`=%s, `source`=%s, `hot`=%s, `modify_time`=now() " 
			.. " where article_id = %d"
	sql = string.format(sql, article_entity['type'], article_entity['tag'], article_entity['title'], article_entity['content'], article_entity['source'], article_entity['hot'], articleId)

	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		ngx.say(err)
		return {}
	end
end

-- 查询列表
function _M:list( args )
	local pageSize = tonumber(args["pageSize"])
	local start = (tonumber(args["pageNumber"])-1) * pageSize
	local typeId = args["typeId"]
	local keyword = args["keyword"]
	local hot = args["hot"]

	local db = mysql:new()
	local sql = "select * from article where 1=1 "
	if typeId ~= nil and typeId ~= "" then
		sql = sql .. " and type_id = %d "
		sql = string.format(sql, tonumber(typeId))
	end
	if hot ~= nil and hot ~= "" then
		sql = sql .. " and hot = %d "
		sql = string.format(sql, tonumber(hot))
	end
	if keyword ~= nil and keyword ~= "" then
		sql = sql .. " and title like %s "
		sql = string.format(sql, ngx.quote_sql_str('%%' .. keyword .. '%%'))
	end
	
	-- 查询总数
	local countSql = string.format('select count(*) as count from (%s) t', sql);

	sql = sql .. " order by create_time desc limit %d, %d "
	sql = string.format(sql, start, pageSize)

	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sql)
	local countRes, countErr, countErrno, countSqlstate = db:query(countSql)
	db:close()
	if not res then
		ngx.say(err)
		return {}
	end

	for i,v in ipairs(res) do
		v["content"] = html_util:clearHTML(v["content"])
		if utf8sub:utf8len(v["content"]) > 100 then
			v["content"] = utf8sub:utf8sub(v["content"], 1, 100)
		end

		if v["type_id"] then
			local typeEntity = type_service:detail(v["type_id"])
			v["type_name"] = typeEntity["name"]
		end
		if v["tag_id"] then
			local tagEntity = tag_service:detail(v["tag_id"])
			v["tag_name"] = tagEntity["name"]
		end
		if v["hot"] == 0 then
			v["hot_name"] = '否'
		elseif v["hot"] == 1 then
			v["hot_name"] = '是'
		end
	end

	return res, countRes[1]['count']
end

-- 查询详情
function _M:detail( articleId )
	articleId = ngx.quote_sql_str(articleId)

	local db = mysql:new()
	local sql = "select * from article where article_id = %s"
	sql = string.format(sql, articleId)

	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		ngx.say(err)
		return {}
	end

	local entity = res[1]
	if entity["type_id"] then
		local typeEntity = type_service:detail(entity["type_id"])
		entity["type_name"] = typeEntity["name"]
	end
	if entity["tag_id"] then
		local tagEntity = tag_service:detail(entity["tag_id"])
		entity["tag_name"] = tagEntity["name"]
	end

	return entity
end

-- 删除文章
function _M:delete( articleId )
	articleId = ngx.quote_sql_str(articleId)

	local db = mysql:new()
	local sql = "delete from article where article_id = %s"
	sql = string.format(sql, articleId)

	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		ngx.say(err)
		return {}
	end
end

return _M
