fudge = {}

-- Language to use
-- one may set fudge.lang variable to language she needs
lang = fudge.lang or "default"

local levels = {}
levels.russian = {
    "хуже некуда", "совсем-совсем-совсем ужасно" , "совсем-совсем ужасно",
    "совсем ужасно", "ужасно", "плохо", "посредственно",
    "нормально", "хорошо", "прекрасно", "превосходно", "легендарно",
    "легендарно+", "легендарно++", "легендарно+++", "как Аллах"
}
levels.english = {
    "i'm a looser, baby", "very very very terrible", "very very terrible",
    "very terrible", "terrible", "poor", "mediocre"
    "fair", "good", "great", "superb", "legendary",
    "legendary+", "legendary++", "legendary+++", "like a boss"
}
levels.german = {
    "grauenhaft----", "grauenhaft---", "grauenhaft--",
    "grauenhaft-", "grauenhaft", "armselig", "unterdurchschnittlich",
    "durchschnittlich", "gut", "großartig", "superb", "legendär",
    "legendär+", "legendär++", "legendär+++", "legendär++++"
}
-- TODO: other languages

levels.default = levels.english
-- because english if locale C standard
-- and original FUDGE rulebook is in english

-- FIXME: magic numbers. Make it using levels.default
local default_level_key = 6
local min_level_key = 5
local max_level_key = 13


-- HACK for speed
local levels_tmp = {}
for key, level in pairs(levels[lang]) do
    levels_tmp[level] = key
end
local function fudge.to_number(level_text) 
    return levels_tmp[level_text]
end

local function fudge.to_string(level_key)
    assert(type(level_key) == "number", "Argument must be a number")
    return assert(levels[lang][level_key], "Level not found")
end

function fudge.normalize(level)
    level_key = fudge.to_number(level)
    if level_key < min_level then
        level_key = min_level_key
    elseif level_key > max_level then
        level_key = max_level
    end
    return fudge.to_string(level_key)
end

function fudge.roll()
    -- Return a 4-table of dices in numeric format
    local dices = {}
    for i = 1, 4 do
        table.insert(dices, math.random(-1, 1))
    end
    return dices
end

function fudge.dices_to_string(dices)
    local signs = ""
    for _, value in pairs(dices) do
        if value > 0 then
            signs = signs .. "+"
        elseif value < 0 then
            signs = signs .. "-"
        else
            signs = signs .. "="
        end
    end
    return signs
end

function fudge.diff(x, y)
    -- Return a difference between two FUDGE levels
    -- example:
    --  fudge.diff("хорошо", "посредственно") == 2
    return fudge.to_number(x) - fudge.to_number(y)
end

local function fudge.add_modifiers_table(level_key, modifiers)
    for _, i in ipairs(modifiers) do
       level_key = level_key + i
    end
    return level_key
end

function fudge.add_modifiers(level, ...)
    -- Return a level with appended modifiers
    -- modifiers can be numbers or table of numbers
    -- examples:
    --  fudge.add_modifiers("плохо", +1, +1, -3) == "ужасно"
    --  fudge.add_modifiers("плохо", {+1, +1, -3}) == "ужасно"
    --  fudge.add_modifiers("хорошо", fudge.dices()) will return
    --  "ужасно" if dices will misscrit
    level = fudge.to_number(level)
    for _, i in ipairs({...}) do
        if type(i) == "table" then
            level = fudge.add_modifiers_table(level, i)
        else
            level = level + i
        end
    end
    return fudge.to_string(level)
end
