package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
URL = require('socket.url')
HTTP = require('socket.http')
JSON = require('dkjson')
HTTPS = require('ssl.https')

local sudo = 114740646
local bot_api_key = "332124195:AAF0yZ7QNiY-5XOmCVNw-p2p1K3cIOwN-ec"
local BASE_URL = "https://api.telegram.org/bot"..bot_api_key
local BASE_FOLDER = "/home/xamarin"

function is_admin(msg)
	local var = false
	local admins = {114740646, 255660438}
	for k,v in pairs(admins) do
		if msg.from.id == v then
			var = true
		end
	end
	return var
end

function check_markdown(text)
	text = text:gsub("_",[[\_]])
	text = text:gsub("*",[[\*]])
	text = text:gsub("`",[[\`]])
	return text
end
function string:del(sep)
	local sep, fields = sep or "/", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	self = self:sub(0,self:len() - fields[#fields]:len() - 1)
	return self
end
function string:split(sep)
local sep, fields = sep or ":", {}
local pattern = string.format("([^%s]+)", sep)
self:gsub(pattern, function(c) fields[#fields+1] = c end)
return fields
end

function sendRequest(url)	
	local dat,res = HTTPS.request(url)
	
	local tab = JSON.decode(dat)
	if res ~= 200 then
		return false, res
	end
	if not tab.ok then
		return false, tab.description
	end
	return tab
end

function getMe()
	local url = BASE_URL .. '/getMe'
	return sendRequest(url)
end
function getUpdates(offset)
	local url = BASE_URL .. '/getUpdates?timeout=20'
	if offset then
		url = url .. '&offset=' .. offset
	end
	return sendRequest(url)
end
function sendMessage(chat_id, text, reply_to_message_id, use_markdown, reply_markup)
	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)
	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end
	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end
	if reply_markup then
		url = url .. '&reply_markup='..URL.escape(JSON.encode(reply_markup))
	end
	return sendRequest(url)
end
function getAlert(callback_query_id, text, show_alert)
	local url = BASE_URL .. '/answerCallbackQuery?callback_query_id=' .. callback_query_id .. '&text=' .. URL.escape(text)
	if show_alert then
		url = url..'&show_alert=true'
	end
	return sendRequest(url)
end
function sendDocument(chat_id, document, reply_to_message_id)
	local url = BASE_URL .. '/sendDocument'
	local curl_command = 'cd \''..currect_folder..'\' && curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'
	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end
	local s = io.popen(curl_command):read("*all")
	return
end
function download_to_file(url, file_name, file_path)
  print("url to download: "..url)

  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  -- nil, code, headers, status
  local response = nil
    options.redirect = false
    response = {HTTPS.request(options)}
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then return nil end
  local file_path = currect_folder..'/'..file_name

  print("Saved to: "..file_path)

  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
--------
function bot_run()
	bot = nil
	while not bot do -- Get bot info
		bot = getMe()
	end
	bot = bot.result
	local bot_info = "Username = @"..bot.username.."\nName = "..bot.first_name.."\nId = "..bot.id.." \n"
	print(bot_info)
	last_update = last_update or 0
	is_running = true
	currect_folder = BASE_FOLDER
end

function msg_processor(msg)
	if msg == nil then return end;if msg.date < os.time() - 5 then	return end
	local key = {}
	key.resize_keyboard = true
	key.one_time_keyboard = false
	key.selective = false
	if msg.text then
		if msg.text == "/start" or msg.text == "/start@"..bot.username then
			local text = "این یک ربات عمومی نیست!\n*This is not a public bot!*"
			if is_admin(msg) then
				text = "سلام ادمین گرامی شما میتوانید با ارسال هر دستور آن را در سرور اجرا کنید یا از دکمه های زیر استفاده کنید"
				key.keyboard = {{"لیست کل فایل ها","لیست فایل ها","فولدر فعلی"},{"ساعت و تاریخ سرور","تاریخ سرور","ساعت سرور"},{"اطلاعات حافظه سرور","حجم فولدر ها در این فولدر","لیست اسکرین های در حال اجرا"},{"اطلاعات رم سرور","اطلاعات هسته سرور"}}
			else
				key.remove_keyboard = true
			end
			sendMessage(msg.chat.id, text, msg.message_id, true, key)
			return
		end
		if msg.text == "/xamarin" or msg.text == "/xamarin@"..bot.username or msg.text == "/creator" or msg.text == "/creator@"..bot.username then
			text = "An Advanced [Server Manager](github.com/XamarinDevTeam/XamarinServerManager) Based On ❤️\n\nFounder & Developer : [Xamarin Developer](T.Me/Xamarin_Developer)\n\nOur Team : [Xamarin Dev Team](T.Me/XamarinDevTeam)"
			key.inline_keyboard = {
				{{text = "Xamarin Developer", url = "T.Me/Xamarin_Developer"}},
				{{text = "Xamarin Messenger", url = "T.Me/Xamarin_Developer_Bot"}},
				{{text = "Our GitHub", url = "GitHub.Com/XamarinDevTeam"}},
				{{text = "Our Channel", url = "T.Me/XamarinDevTeam"}},
			}
			sendMessage(msg.chat.id, text, msg.message_id, true, key)
			return
		end
		if msg.text == "فولدر فعلی" then
			sendMessage(msg.chat.id, "*فولدر فعلی :*\n `"..currect_folder.."`", msg.message_id, true)
			return
		end
		if msg.text == "لیست فایل ها" then
			local action = io.popen('cd "'..currect_folder..'"\nls'):read("*all")
			sendMessage(msg.chat.id, action, msg.message_id)
			return
		end
		if msg.text == "لیست کل فایل ها" then
			local action = io.popen('cd "'..currect_folder..'"\nls -f'):read("*all")
			sendMessage(msg.chat.id, action, msg.message_id)
			return
		end
		if msg.text == "حجم فولدر ها در این فولدر" then
			local action = io.popen('cd "'..currect_folder..'"\ndu -d 1 -h'):lines()
			key.inline_keyboard = {}
			for a in action do
				local inl = {}
				table.insert(inl,{text = (a:match(".*\t(.*)") == ".") and "همه فایل ها" or a:match(".*\t(.*)"):gsub("./",""), callback_data="not"})
				table.insert(inl,{text = a:match("(.*)\t.*"), callback_data="not"})
				table.insert(key.inline_keyboard, inl)
			end
			sendMessage(msg.chat.id, "حجم فولدر ها در فولدر :\n`"..currect_folder.."`", msg.message_id,true,key)
			return
		end
		if msg.text == "لیست اسکرین های در حال اجرا" then
			local action = io.popen('screen -ls'):lines()
			key.inline_keyboard = {}
			table.insert(key.inline_keyboard,{{text = "PID", callback_data="not"},{text = "نام", callback_data="not"}})
			for a in action do
				if a:match("(%d+)[.](.*)\9[(].*[)]\9[(]") then
					local inl = {}
					table.insert(inl,{text = a:match("(%d+)[.].*\9[(].*[)]\9[(]"), callback_data="kill"..a:match("(%d+)[.].*\9[(].*[)]\9[(]")})
					table.insert(inl,{text = a:match("%d+[.](.*)\9[(].*[)]\9[(]"), callback_data="not"})
					table.insert(key.inline_keyboard, inl)
				end
			end
			sendMessage(msg.chat.id, "لیست اسکرین های در حال اجرا :", msg.message_id,true,key)
			return
		end
		if msg.text == "اطلاعات حافظه سرور" then
			local action = io.popen('df -h'):lines()
			key.inline_keyboard = {}
			for a in action do
				local inl = {}
				for k,v in pairs(a:split(' ')) do
					if k == 6 then break end
					v = v:lower():gsub("filesystem","فایل"):gsub("size","کل"):gsub("used","مصرفی"):gsub("avail","مانده"):gsub("use","")
					table.insert(inl,{text = v, callback_data="not"})
				end
				table.insert(key.inline_keyboard, inl)
			end
			sendMessage(msg.chat.id, "اطلاعات حافظه سرور", msg.message_id,false,key)
			return
		end
		if msg.text == "اطلاعات رم سرور" then
			local action = io.popen('free -h'):lines()
			key.inline_keyboard = {}
			for a in action do
				local s = a:split(' ')
				local inl = {}
				if s[1] == "Mem:" then
					table.insert(inl,{text = s[3], callback_data="not"})
					table.insert(inl,{text = s[2], callback_data="not"})
					table.insert(inl,{text = "رم", callback_data="not"})
					table.insert(key.inline_keyboard, inl)
				elseif s[1] == "Swap:" then
					table.insert(inl,{text = s[3], callback_data="not"})
					table.insert(inl,{text = s[2], callback_data="not"})
					table.insert(inl,{text = "سوَپ", callback_data="not"})
					table.insert(key.inline_keyboard, inl)
				else
					table.insert(inl,{text = "استفاده شده", callback_data="not"})
					table.insert(inl,{text = "کل", callback_data="not"})
					table.insert(inl,{text = "بخش", callback_data="not"})
					table.insert(key.inline_keyboard, inl)
				end
			end
			sendMessage(msg.chat.id, "اطلاعات رم سرور :", msg.message_id,true,key)
			return
		end
		if msg.text == "اطلاعات هسته سرور" then
			local action = io.popen('cat /proc/stat'):lines()
			local loadavr = io.popen("top -bn1 | grep load | awk \'{printf \"%.2f\\n\", $(NF-2)}\'"):read("*all")
			key.inline_keyboard = {}
			table.insert(key.inline_keyboard, {{text = loadavr, callback_data="not"},{text = "لود متوسط", callback_data="not"}})
			for a in action do
				local inl = {}
				local s = a:split(' ')
				if s[1] == "cpu" then
					table.insert(inl,{text = (math.floor((tonumber(s[2])+tonumber(s[4]))*10000/(tonumber(s[2])+tonumber(s[4])+tonumber(s[5])))/100).."%", callback_data="not"})
					table.insert(inl,{text = "همه هسته ها", callback_data="not"})
					table.insert(key.inline_keyboard, inl)
				elseif s[1]:match("cpu") then
					table.insert(inl,{text = (math.floor((tonumber(s[2])+tonumber(s[4]))*10000/(tonumber(s[2])+tonumber(s[4])+tonumber(s[5])))/100).."%", callback_data="not"})
					table.insert(inl,{text = "هسته "..(tonumber(s[1]:match("%d+"))+1), callback_data="not"})
					table.insert(key.inline_keyboard, inl)
				end
			end
			sendMessage(msg.chat.id, "اطلاعات هسته های سرور :", msg.message_id,true,key)
			return
		end
		if msg.text == "ساعت و تاریخ سرور" then sendMessage(msg.chat.id, os.date("*%Y/%m/%d - %H:%M:%S*"), msg.message_id, true);return;end
		if msg.text == "ساعت سرور" then sendMessage(msg.chat.id, os.date("*%H:%M:%S*"), msg.message_id, true);return;end
		if msg.text == "تاریخ سرور" then sendMessage(msg.chat.id, os.date("*%Y/%m/%d*"), msg.message_id, true);return;end
		if msg.text:lower() == "cd .." then
			currect_folder = currect_folder:del()
			sendMessage(msg.chat.id, "*فولدر فعلی :*\n `"..currect_folder.."`", msg.message_id, true)
			return
		elseif msg.text:match("^[Cc][Dd] (.*)$") then
			local matches = msg.text:match("^[Cc][Dd] (.*)$")
			currect_folder = currect_folder.."/"..matches
			for a in io.popen('find '..currect_folder):lines() do
				currect_folder = a
				break
			end
			sendMessage(msg.chat.id, "*فولدر فعلی :*\n `"..currect_folder.."`", msg.message_id, true)
			return
		end
		if msg.text:match("^[Uu][Pp][Ll][Oo][Aa][Dd] (.*)$") then
			local matches = msg.text:match("^[Uu][Pp][Ll][Oo][Aa][Dd] (.*)$")
			if io.popen('find '..currect_folder..'/'..matches):read("*all") == '' then
				sendMessage(msg.chat.id, "فایل پیدا نشد", msg.message_id, true)
			else
				sendMessage(msg.chat.id, "در حال آپلود : "..matches, msg.message_id, true)
				sendDocument(msg.chat.id, matches)
			end
			return
		end
		if msg.text:lower():match("^[Dd][Oo][Ww][Nn][Ll][Oo][Aa][Dd] (.*)$") or msg.text:lower():match("^[Dd][Oo][Ww][Nn][Ll][Oo][Aa][Dd]$") then--Turn your bot privacy off or it won't  work on chats(groups and supergroups)
			if not msg.reply_to_message then
				sendMessage(msg.chat.id, "لطفا روی فایل مورد نظر ریپلای کنید", msg.message_id, true)
				return
			end
			local file = ""
			local filename = ""
			if msg.reply_to_message.photo then
				file = msg.reply_to_message.photo[#msg.reply_to_message.photo].file_id
				filename = "somepic.jpg"
			elseif msg.reply_to_message.video then
				file = msg.reply_to_message.video.file_id
				filename = "somevideo.mp4"
			elseif msg.reply_to_message.video_note then
				file = msg.reply_to_message.video_note.file_id
				filename = "somevideonote.mp4"
			elseif msg.reply_to_message.document then
				file = msg.reply_to_message.document.file_id
				filename = msg.reply_to_message.document.file_name
			elseif msg.reply_to_message.audio then
				filename = msg.reply_to_message.audio.performer.." - "..msg.reply_to_message.audio.title..".mp3"
				file = msg.reply_to_message.audio.file_id
			elseif msg.reply_to_message.sticker then
				filename = "somesticker.webp"
				file = msg.reply_to_message.sticker.file_id
			elseif msg.reply_to_message.voice then
				filename = "somevoice.ogg"
				file = msg.reply_to_message.voice.file_id
			elseif msg.text then
				sendMessage(msg.chat.id, "لطفا روی یک فایل ریپلای کنید", msg.message_id, true)
				return
			else
				return
			end
			if string.match(msg.text, "^[Dd][Oo][Ww][Nn][Ll][Oo][Aa][Dd] (.*)$") then
				local matches = string.match(msg.text, "^[Dd][Oo][Ww][Nn][Ll][Oo][Aa][Dd] (.*)$")
				filename = matches
			end
			local url = BASE_URL .. '/getFile?file_id='..file
			local res = HTTPS.request(url)
			local jres = JSON.decode(res)
			if not jres.ok then
				local err = jres.description:lower():gsub("bad request: ","")
				err = err:gsub("file is too big","فایل بزرگ است")
				sendMessage(msg.chat.id, "فایل بزرگ است", msg.reply_to_message.message_id, true)
			end
			local download = download_to_file("https://api.telegram.org/file/bot"..bot_api_key.."/"..jres.result.file_path, filename)
			sendMessage(msg.chat.id, "فایل دانلود شده و در آدرس زیر ذخیره شد : \n`"..download.."`", msg.reply_to_message.message_id, true)
			return
		end
		if msg.text:match("^/kill(%d+)$") then
			local pid = msg.text:match("^/kill(%d+)$")
			local action = io.popen("kill "..pid):read("*all")
			return sendMessage(msg.chat.id, (action == "") and "انجام شد" or action, msg.message_id)
		end
		local action = io.popen('cd "'..currect_folder..'"\n'..msg.text):read("*all")
		sendMessage(msg.chat.id, (action == "") and "انجام شد" or action, msg.message_id)
	end
	if msg.inline_query then
	end
	return
end
function inline_processor(msg)
	if msg == nil then return end;if not is_admin(msg) then return getAlert(msg.id, "دست به سرور مردم نزن جیزه 😐") end
	if msg.data then
		if msg.data == "not" then
			return getAlert(msg.id, "داداش داری اشتباه میزنی 😐")
		end
		if msg.data:match("^kill(%d+)$") then
			return sendMessage(msg.message.chat.id,"لطفا برای بستن این پروسس روی دستور زیر بزنید\n/"..msg.data)
		end
	end
end

bot_run()
while is_running do
	local response = getUpdates(last_update+1)
	if response then
		for i,v in ipairs(response.result) do
			last_update = v.update_id
			msg_processor(v.message)
			inline_processor(v.callback_query)
		end
	else
		print("Conection failed")
	end
end
print("Bot halted")
