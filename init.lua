local F18 = 79
local layerActive = false

local layout = {
    [49] = {"\u{00A0}", ""}, -- Space
    [50] = {"`", "~"}, -- `/ё
    [10] = {"`", "~"}, -- `/ё

    [18] = {"¹", "¡"},
    [19] = {"²", "½"},
    [20] = {"³", "⅓"},
    [21] = {"$", "€"},
    [23] = {"‰", ""},
    [22] = {"ˆ", "↑"},
    [26] = {"¿", ""},
    [28] = {"∞", "≈"},
    [25] = {"←", "〈"},
    [29] = {"→", "〉"},

    [27] = {"—", "–"},
    [24] = {"≠", "±"},

    [0]  = {"ә", "Ә"}, -- a
    [5]  = {"ғ", "Ғ"}, -- g
    [12] = {"қ", "Қ"}, -- q
    [45] = {"ң", "Ң"}, -- n
    [31] = {"ө", "Ө"}, -- o
    [32] = {"ұ", "Ұ"}, -- u
    [16] = {"ү", "Ү"}, -- y
    [4]  = {"һ", "Һ"}, -- h
    [34] = {"і", "І"}, -- i

    [14] = {"ў", "Ў"}, -- e
    [11] = {"ї", "Ї"}, -- b
    [39] = {"є", "Є"}, -- '

    [15] = {"®", ""},  -- r
    [17] = {"₸", "₽"}, -- t
    [35] = {"′", "″"}, -- p

    [33] = {"[", "{"},
    [30] = {"]", "}"},

    [2]  = {"°", "⌀"}, -- d
    [8]  = {"©", "™"}, -- c
    [38] = {"„", ""},  -- j
    [40] = {"“", "‘"}, -- k
    [37] = {"”", "’"}, -- l

    [7]  = {"×", "·"}, -- x
    [46] = {"−", "•"}, -- m

    [43] = {"«", "≤"},
    [47] = {"»", "≥"},
    [44] = {"…", "́"},
}

local restoreTimer = nil

local function sendText(text)
    if text == nil or text == "" then
        return
    end

    local oldClipboard = hs.pasteboard.getContents()

    hs.pasteboard.setContents(text)
    hs.eventtap.event.newKeyEvent({"cmd"}, 9, true):post()
    hs.eventtap.event.newKeyEvent({"cmd"}, 9, false):post()

    if restoreTimer ~= nil then
        restoreTimer:stop()
        restoreTimer = nil
    end

    restoreTimer = hs.timer.doAfter(0.15, function()
        hs.pasteboard.setContents(oldClipboard)
        restoreTimer = nil
    end)

end

local watcher = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.flagsChanged
}, function(event)
    local ok, result = pcall(function()
        local keyCode = event:getKeyCode()
        local eventType = event:getType()

        if keyCode == F18 then
            layerActive = eventType ~= hs.eventtap.event.types.keyUp
            return true
        end

        if not layerActive then
            return false
        end

        if eventType ~= hs.eventtap.event.types.keyDown then
            return false
        end

        local pair = layout[keyCode]
        if pair == nil then
            return false
        end

        local flags = event:getFlags()
        local text = flags.shift and pair[2] or pair[1]

        sendText(text)
        return true
    end)

    if not ok then
        print("Keyboard layer error:", result)
        layerActive = false
        return false
    end

    return result
end)

watcher:start()

hs.timer.doEvery(10, function()
    if watcher ~= nil and not watcher:isEnabled() then
        print("Keyboard watcher was disabled; restarting")
        watcher:start()
    end
end)

hs.alert.show("Custom keyboard layer loaded")