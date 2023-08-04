local function getDocumentsDirectory()
    if package.config:sub(1,1) == "\\" then -- Windows
        return os.getenv("USERPROFILE") .. "\\Documents\\"
    else -- macOS/Linux
        return os.getenv("HOME") .. "/Documents/"
    end
end

local function shuffle(str)
    local t = {}
    for i = 1, #str do
        t[i] = str:sub(i, i)
    end

    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end

    return table.concat(t)
end

local function generatePassword(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    local specialChars = "!@#$%^&*()"
    local password = ""

    if length < 8 then
        return nil
    end

    -- Ensure two distinct random indices for the special character
    local index1 = math.random(1, #specialChars)
    local index2
    repeat
        index2 = math.random(1, #specialChars)
    until index2 ~= index1

    local randomSpecialChar = specialChars:sub(index1, index1) .. specialChars:sub(index2, index2)
    password = password .. randomSpecialChar
    length = length - 2

    charset = shuffle(charset)

    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        password = password .. charset:sub(randomIndex, randomIndex)
    end

    return password
end

local function savePasswordToFile(website, password)
    local documentsDir = getDocumentsDirectory()
    local file = io.open(documentsDir .. "passwords.txt", "r")
    local passwords = {}

    if file then
        for line in file:lines() do
            local savedWebsite, savedPassword = line:match("([^:]+):%s*(.+)")
            if savedWebsite and savedPassword then
                passwords[savedWebsite] = savedPassword
            end
        end
        file:close()
    else
        print("\n\27[1;31mError: Please make sure that the file passwords.txt is in the Documents directory and is readable")
        return
    end

    if passwords[website] then
        io.write("\n\27[33mA password for " .. website .. " already exists in passwords.txt. Do you want to overwrite it?\27[0m (yes/no): ")
        local response = io.read()

        if response:lower() == "yes" or response:lower() == "y" then
            passwords[website] = password
            file = io.open(documentsDir .. "passwords.txt", "w")
            if file then
                for savedWebsite, savedPassword in pairs(passwords) do
                    file:write(savedWebsite .. ": " .. savedPassword .. "\n")
                end
                file:close()
                io.flush()
                print("\n\27[32mPassword for " .. website .. " updated in \27[33mpasswords.txt\27[32m in your \27[33mDocuments folder")
            else
                print("\n\27[1;31mError: Could not update the passwords file.")
            end
        else
            print("\n\27[33mPassword for " .. website .. " was not saved.")
        end
    else
        file = io.open(documentsDir .. "passwords.txt", "a+")
        if file then
            file:write(website .. ": " .. password .. "\n")
            file:close()
            io.flush()
            print("\n\27[32mPassword for " .. website .. " saved to \27[33mpasswords.txt\27[32m in your \27[33mDocuments folder")
        else
            print("\n\27[1;31mError: Could not save the password to file. Please remove any encryption from passwords.txt if it exists.")
        end
    end
end

local function main()
    io.write("Enter the name of the website or service: ")
    local website = io.read()

    io.write("Enter the length of the password: ")
    local length = tonumber(io.read())

    if length and length >= 8 then
        math.randomseed(os.time())
        local password = generatePassword(length)
        print("\n\27[32mPassword for " .. website .. "\27[0m: " .. password)

        io.write("\nDo you want to save the password to passwords.txt in your \27[33mDocuments folder\27[0m? (yes/no): ")
        local response = io.read()

        if response:lower() == "yes" or response:lower() == "y" then
            local documentsDir = getDocumentsDirectory()
            local file = io.open(documentsDir .. "passwords.txt", "a+")
            if file then
                file:close()
                savePasswordToFile(website, password)
            else
                file = io.open(documentsDir .. "passwords.txt", "w")
                if file then
                    file:close()
                    savePasswordToFile(website, password)
                else
                    print("\n\27[1;31mError: Could not create or update the passwords file.")
                end
            end
        end
    else
        print("\n\27[1;31mError: Password length must be 8 or more")
    end
end

main()