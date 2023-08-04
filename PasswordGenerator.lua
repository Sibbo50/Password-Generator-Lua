local function getDocumentsDirectory()
    if package.config:sub(1,1) == "\\" then -- Windows
        return os.getenv("USERPROFILE") .. "\\Documents\\"
    else -- macOS/Linux
        return os.getenv("HOME") .. "/Documents/"
    end
end
local function generatePassword(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    local specialChars = "!@#$%^&*()"
    local password = ""

    if length < 8 then
        return nil
    end
    local randomSpecialChar = string.sub(specialChars, math.random(1, #specialChars), math.random(1, #specialChars))
    password = password .. randomSpecialChar
    length = length - 1

    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        password = password .. string.sub(charset, randomIndex, randomIndex)
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
        print("\n\27[1;31mError: Please make sure that the file passwords.txt is in the Documents directory.")
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
                print("\n\27[32mPassword for " .. website .. " updated in 'passwords.txt'")
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
            print("\n\27[32mPassword for " .. website .. " saved to 'passwords.txt'")
        else
            print("\n\27[1;31mError: Could not save the password to file. Please remove any encryption from passwords.txt if it exists.")
        end
    end
end
local function main()
    io.write("Enter the name of the website or service: ")
    local website = io.read()

    io.write("Enter the length for your password: ")
    local length = tonumber(io.read())

    if length and length >= 8 then
        math.randomseed(os.clock() * 1000000000)
        local password = generatePassword(length)
        print("\n\27[32mPassword for " .. website .. ": " .. password)

        io.write("\nDo you want to save the password to a text file in your \27[33mDocuments folder\27[0m? (yes/no): ")
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
