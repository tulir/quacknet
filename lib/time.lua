function mcUnix()
	return (os.time() * 1000 + 18000) % 24000 + os.day() * 24000
end

function uptime()
	return os.clock()
end

function time()
    return textutils.formatTime(os.time(), true)
end

local function divmod(x, y)
    local quotient = math.floor(x / y)
    local remainder = x - y * quotient
    return quotient, remainder
end

function is_leap_year(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

function month_lengths(year)
    local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if is_leap_year(year) then
        days_in_month[2] = 29
    end
    return days_in_month
end

local function get_month(year, day)
    local days_in_month = month_lengths(year)
    local month = 1
    while day > days_in_month[month] do
        day = day - days_in_month[month]
        month = month + 1
    end
    return month, day
end

local month_names = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
function month_name(month)
    return month_names[month]
end

local function ordinal(dayn)
    last_digit = dayn % 10
    if last_digit == 1 and dayn ~= 11
        then return 'st'
    elseif last_digit == 2 and dayn ~= 12
        then return 'nd'
    elseif last_digit == 3 and dayn ~= 13
        then return 'rd'
    else
        return 'th'
    end
end

function date()
    local day = os.day()
    year, day = divmod(day, 365)
    month, day = get_month(year, day)
    return string.format("%s %d%s, %04d", month_name(month), day, ordinal(day), year)
end

function datetime()
    return date() .. ", " .. time()
end
