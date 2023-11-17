-- The pattern that is used to detect test files if no custom pattern is specified.
local TEST_FILE_PATTERN = "%-test%.lua$"
-- Indentation for test reports.
local INDENT_SPACES = 2

local loveunit = {
  _NAME = "loveunit",
  _DESCRIPTION = "Minimalistic and hackable unit tests for LÖVE-based libraries",
  _VERSION = "1.0.0",
  _LICENSE = [[
    MIT License

    Copyright (c) 2023 Fabian Staacke

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]],
}

local testCases = {}

-------------------------------------------------------------------------------
-- Utilities
-------------------------------------------------------------------------------

local utils = {}

--- Check if the specified argument is of the expected type.
--- @param index integer The index of the argument, starting with 1
--- @param value any The value of the argument
--- @param expectedType string The expected type of the argument as a string
--- @param level? integer The error level
--- @return string value The input value
function utils.assertArgument(index, value, expectedType, level)
  local valueType = type(value)
  if valueType ~= expectedType then
    error(
      string.format("Type of argument %d should be '%s' but was '%s'", index, expectedType, valueType),
      level or 3
    )
  end
  return value
end

--- @param t table
--- @param value any
--- @return integer?
--- @nodiscard
function utils.indexOf(t, value)
  for index = 0, #t do
    if t[index] == value then
      return index
    end
  end
  return nil
end

--- Convert the specified value to a string.
---
--- Works like Lua's tostring function, but without calling the `__tostring`
--- metamethod on tables.
--- @param value any The value to be converted
--- @return string
--- @nodiscard
function utils.rawtostring(value)
  if type(value) ~= "table" then
    return tostring(value)
  end
  local mt = getmetatable(value)
  local rawString = tostring(setmetatable(value, nil))
  setmetatable(value, mt)
  return rawString
end

--- Return whether the two numbers `a` and `b` are close to each other.
--- @param a number
--- @param b number
--- @param epsilon number? Tolerated margin of error (default: 1e-09)
--- @return boolean equal
--- @nodiscard
function utils.almostEqual(a, b, epsilon)
  epsilon = epsilon or 1e-09
  return math.abs(a - b) <= epsilon * math.max(math.abs(a), math.abs(b))
end


--- Return true if the specified values are considered equal, false otherwise.
--- @param first any
--- @param second any
--- @param almost boolean? If true, compare numbers with tolerance (default: false)
--- @return boolean equal
--- @nodiscard
--- @package
function utils.compareValues(first, second, almost)
  if type(first) == "table" and type(second) == "table" then
    local firstMt, secondMt = getmetatable(first), getmetatable(second)

    -- Compare with __eq metamethod, if available.
    if firstMt and secondMt and type(firstMt.__eq) == "function" and firstMt.__eq == secondMt.__eq then
      return first == second
    end

    -- The pcall takes care of edge cases, where __index raises an error for
    -- non-exisiting table indexes.
    local _, equalsMethod = pcall(utils.tableGet, first, "equals")

    if firstMt and type(equalsMethod) == "function" then
      local success, equal = pcall(equalsMethod, first, second)

      if success and type(equal) == "boolean" then
        return equal
      end
    end

    return utils.compareTables(first, second, almost)
  end

  if almost == true and type(first) == "number" and type(second) == "number" then
    return utils.almostEqual(first, second)
  end

  return first == second
end

--- Return true if the specified tables are equal, false otherwise.
--- @param table1 table
--- @param table2 table
--- @param almost boolean? If true, compare numbers with tolerance (default: false)
--- @return boolean equal
--- @nodiscard
--- @package
function utils.compareTables(table1, table2, almost)
  if type(table1) == "table" and table1 == table2 then
    return true
  end

  for key, value in pairs(table1) do
    if not utils.compareValues(table2[key], value, almost) then
      return false
    end
  end

  for key in pairs(table2) do
    if table1[key] == nil then
      return false
    end
  end

  return true
end

--- @param t table
--- @param index any
--- @return any
--- @nodiscard
function utils.tableGet(t, index)
  utils.assertArgument(1, t, "table")
  return t[index]
end

--- @param depth integer
--- @return string
--- @nodiscard
function utils.indent(depth)
  return string.rep(" ", INDENT_SPACES * depth)
end

-------------------------------------------------------------------------------
-- Value marshalling
-------------------------------------------------------------------------------

local serial = {}

--- Serialize a primitive value to a sequence of string tokens.
--- @param value any The value to serialize
--- @param tokens table The table that receives the tokens
function serial._serializePrimitive(value, tokens)
  if type(value) == "string" then
    table.insert(tokens, string.format("%q", value))
  else
    table.insert(tokens, tostring(value))
  end
end

--- Serialize a table key to a sequence of string tokens.
--- @param key any The key to serialize
--- @param tokens table The table that receives the tokens
function serial._serializeKey(key, tokens)
  table.insert(tokens, "[")
  serial._serializePrimitive(key, tokens)
  table.insert(tokens, "]")
end

--- Serialize a table to a squence of string tokens.
--- @param tbl table The table to serialize
--- @param tokens table The table that receives the tokens
--- @param stack table Stack of tables to detect loops
function serial._serializeTable(tbl, tokens, stack)
  local knownKeys = {}

  table.insert(stack, tbl)
  table.insert(tokens, "{")

  -- Write the index part of the table.
  if #tbl > 0 then
    for index, value in ipairs(tbl) do
      serial._serializeValue(value, tokens, stack)
      table.insert(tokens, ",")
      knownKeys[index] = true
    end
  end

  -- Write the hash part of the table.
  for key, value in pairs(tbl) do
    if not knownKeys[key] then
      serial._serializeKey(key, tokens)
      table.insert(tokens, "=")
      serial._serializeValue(value, tokens, stack)
      table.insert(tokens, ",")
    end
  end

  table.insert(tokens, "}")
  table.remove(stack)
end

--- Serialize a value to a sequence of string tokens.
--- @param value any The value to serialize
--- @param tokens table The table that receives the tokens
--- @param stack table Stack of tables to detect loops
function serial._serializeValue(value, tokens, stack)
  if type(value) == "table" then
    local mt = getmetatable(value)
    if (mt and mt.__tostring) or utils.indexOf(stack, value) then
      table.insert(tokens, string.format("%q", tostring(value)))
    else
      serial._serializeTable(value, tokens, stack)
    end
  else
    serial._serializePrimitive(value, tokens)
  end
end

--- Serialize the given value to a string.
--- @param value any
--- @return string serializedValue
--- @nodiscard
function serial.serialize(value)
  local tokens = {}
  serial._serializeValue(value, tokens, {})
  return table.concat(tokens)
end

-------------------------------------------------------------------------------
-- Test results
-------------------------------------------------------------------------------

local Result = {}
Result.__index = Result

--- @param name string
--- @param failed boolean
--- @param error string?
--- @return table result
function Result.new(name, failed, error)
  return setmetatable({
    name = name,
    failed = failed,
    error = error,
  }, Result)
end

--- @param lines string[]
--- @param depth integer
function Result:write(lines, depth)
  if self.failed then
    table.insert(lines, utils.indent(depth) .. "FAILED: " .. self.name)
    table.insert(lines, utils.indent(depth + 1) .. self.error)
  end
end

-------------------------------------------------------------------------------
-- Test groups
-------------------------------------------------------------------------------

local Group = {}
Group.__index = Group

--- @param name string
--- @return table group
--- @nodiscard
function Group.new(name)
  return setmetatable({
    name = name,
    testCount = 0,
    failedTestCount = 0,
    results = {},
    subgroups = {},
  }, Group)
end

--- @param result table
function Group:addResult(result)
  assert(getmetatable(result) == Result)
  table.insert(self.results, result)
end

--- @param subgroup table
function Group:addSubgroup(subgroup)
  assert(getmetatable(subgroup) == Group)
  table.insert(self.subgroups, subgroup)
end

--- @param lines string[]
--- @param depth integer
function Group:write(lines, depth)
  if self.failedTestCount == 0 then
    return
  end

  table.insert(lines, utils.indent(depth) .. self.name)

  for _, result in ipairs(self.results) do
    result:write(lines, depth + 1)
  end

  for _, subgroup in ipairs(self.subgroups) do
    subgroup:write(lines, depth + 1)
  end
end

-------------------------------------------------------------------------------
-- Test cases
-------------------------------------------------------------------------------

local TestCase = {}
TestCase.__index = TestCase

--- @param name string
--- @return table testCase
function TestCase.new(name)
  local self = setmetatable({}, TestCase)
  self._groupstack = {}
  self:_pushGroup(name)
  table.insert(testCases, self)
  return self
end

--- Add a named test group.
--- @param groupName string The group name
--- @param groupFunc function A function that contains the grouped test cases
function TestCase:group(groupName, groupFunc)
  utils.assertArgument(1, groupName, "string")
  utils.assertArgument(2, groupFunc, "function")

  self:_pushGroup(groupName)
  groupFunc()
  self:_popGroup()
end

--- Run the specified test with optional test data.
---
--- When specified, `testData` is expected to be a sequence of tables. The values of
--- each table are unpacked and passed to the test function.
--- @param testName string The name of the test
--- @param testFunc function A function that provides the test
--- @param testData? table[] Optional test data for the test
function TestCase:run(testName, testFunc, testData)
  utils.assertArgument(1, testName, "string")
  utils.assertArgument(2, testFunc, "function")

  local passed, message

  if testData then
    utils.assertArgument(3, testData, "table")
    for i = 1, #testData do
      passed, message = pcall(testFunc, unpack(testData[i]))
      if not passed then
        break
      end
    end
  else
    passed, message = pcall(testFunc)
  end

  local result = Result.new(testName, not passed, message)
  self:_peekGroup():addResult(result)

  for _, group in ipairs(self._groupstack) do
    group.testCount = group.testCount + 1

    if result.failed then
      group.failedTestCount = group.failedTestCount + 1
    end
  end
end

--- Get the total number of tests.
--- @return number testCount
--- @nodiscard
function TestCase:getTestCount()
  return self:_peekGroup().testCount
end

--- Get the number of failed tests.
--- @return number testCount
--- @nodiscard
function TestCase:getFailedTestCount()
  return self:_peekGroup().failedTestCount
end

--- @param lines string[]
--- @package
function TestCase:write(lines)
  self:_peekGroup():write(lines, 0)
end

--- Assert that the given value is true.
--- @param value any
--- @param message? string The message to show if the assertion fails
function TestCase:assertTrue(value, message)
  self:assertSame(true, value, message)
end

--- Assert that the given value is false.
--- @param value any
--- @param message? string The message to show if the assertion fails
function TestCase:assertFalse(value, message)
  self:assertSame(false, value, message)
end

--- Assert that a given value is equal to an expected value.
--- @param expectedValue any
--- @param actualValue any
--- @param message? string The message to show if the assertion fails
function TestCase:assertEqual(expectedValue, actualValue, message)
  if not utils.compareValues(expectedValue, actualValue) then
    error(string.format(
      message or "Expected value: %s | Actual value: %s",
      serial.serialize(expectedValue),
      serial.serialize(actualValue)
    ), 0)
  end
end

--- Assert that a given value is not equal to another value.
--- @param first any
--- @param second any
--- @param message? string The message to show if the assertion fails
function TestCase:assertNotEqual(first, second, message)
  if utils.compareValues(first, second) then
    error(message or string.format(
      "Both values are equal: %s | %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that a given value is almost equal to an expected value.
--- @param expectedValue any
--- @param actualValue any
--- @param message? string The message to show if the assertion fails
function TestCase:assertAlmostEqual(expectedValue, actualValue, message)
  if not utils.compareValues(expectedValue, actualValue, true) then
    error(string.format(
      message or "Expected value: %s | Actual value: %s",
      serial.serialize(expectedValue),
      serial.serialize(actualValue)
    ), 0)
  end
end

--- Assert that two values are not almost equal.
--- @param first any
--- @param second any
--- @param message? string The message to show if the assertion fails
function TestCase:assertNotAlmostEqual(first, second, message)
  if not utils.compareValues(first, second, true) then
    error(string.format(
      message or "Both values are almost equal: %s | %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that a given value is the same as the expected value.
--- @param expectedValue any
--- @param actualValue any
--- @param message? string The message to show if the assertion fails
function TestCase:assertSame(expectedValue, actualValue, message)
  if not rawequal(expectedValue, actualValue) then
    error(string.format(
      message or "Expected value: %s | Actual value: %s",
      tostring(expectedValue),
      tostring(actualValue)
    ), 0)
  end
end

--- Assert that tweo values are not the same.
--- @param first any
--- @param second any
--- @param message? string The message to show if the assertion fails
function TestCase:assertNotSame(first, second, message)
  if rawequal(first, second) then
    error(string.format(
      message or "Both values are the same: %s | %s",
      tostring(first),
      tostring(second)
    ), 0)
  end
end

--- Assert that the first value is smaller than the second value.
--- @param first any
--- @param second any
--- @param message? string The message to show if the assertion fails
function TestCase:assertSmallerThan(first, second, message)
  if first >= second then
    error(string.format(
      message or "Value %s is not smaller than %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is smaller than or equal to the second value.
--- @param first any
--- @param second any
--- @param message? string The message to show if the assertion fails
function TestCase:assertSmallerThanEqual(first, second, message)
  if first > second then
    error(string.format(
      message or "Value %s is not smaller than or equal to %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is greater than the second value.
--- @param first any
--- @param second any
--- @param message? string The message to show if the assertion fails
function TestCase:assertGreaterThan(first, second, message)
  if first <= second then
    error(string.format(
      message or "Value %s is not greater than %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is greater than or equal to the second value.
--- @param first any
--- @param second any
--- @param message? string The message to show if the assertion fails
function TestCase:assertGreaterThanEqual(first, second, message)
  if first < second then
    error(string.format(
      message or "Value %s is not greater than or equal to %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the given function throws an error when called.
--- @param func function The function
--- @param message? string The message to show if the assertion fails
function TestCase:assertError(func, message)
  if pcall(func) then
    error(message or "The function was expected to throw an error", 0)
  end
end


--- Push a new group onto the stack.
--- @param groupName string
--- @package
function TestCase:_pushGroup(groupName)
  utils.assertArgument(1, groupName, "string")

  local newGroup = Group.new(groupName)

  if #self._groupstack > 0 then
    self:_peekGroup():addSubgroup(newGroup)
  end

  table.insert(self._groupstack, newGroup)
end

--- Remove the topmost group from the stack and return it.
--- @return table group
--- @package
function TestCase:_popGroup()
  return assert(table.remove(self._groupstack), "Stack is empty!")
end

--- Get the topmost group from the stack.
--- @return table group
--- @package
function TestCase:_peekGroup()
  return assert(self._groupstack[#self._groupstack], "Stack is empty!")
end

--- @package
function TestCase:_markAsFailed()
  for index = #self._groupstack, 1, -1 do
    self._groupstack[index].fails = self._groupstack[index].fails + 1
  end
end

-------------------------------------------------------------------------------
-- Module API
-------------------------------------------------------------------------------

--- Create a new test case with the specified name.
--- @param name string
--- @return table testCase
--- @nodiscard
function loveunit.newTestCase(name)
  return TestCase.new(name)
end

--- Run all unit test files from the specified directory.
--- @param path string The directory path
--- @param recursive? boolean Search for test files recursively (default: false)
--- @param pattern? string The pattern for detecting test files (default: `"%-test%.lua$"`)
function loveunit.runTestFiles(path, recursive, pattern)
  pattern = pattern or TEST_FILE_PATTERN
  local items = love.filesystem.getDirectoryItems(path)

  for _, item in ipairs(items) do
    local itemPath = path:gsub("[/\\]$", "") .. "/" .. item
    local info = love.filesystem.getInfo(itemPath)

    if info.type == "file" and string.match(item, pattern) then
      local chunk, err = love.filesystem.load(itemPath)
      if err then
        error(err)
      end
      chunk()
    elseif info.type == "directory" and recursive then
      loveunit.runTestFiles(itemPath, true, pattern)
    end
  end
end

--- Get the test results.
--- @return boolean success True if all tests succeeded, false otherwise
--- @return string reportText String representation of test results
--- @nodiscard
function loveunit.report()
  local lines = {}
  local testCount = 0
  local failedTestCount = 0

  for _, testCase in ipairs(testCases) do
    testCase:write(lines)
    testCount = testCount + testCase:getTestCount()
    failedTestCount = failedTestCount + testCase:getFailedTestCount()
  end

  table.insert(lines, string.format("%s of %s tests passed!", testCount - failedTestCount, testCount))
  testCases = {}

  return failedTestCount == 0, table.concat(lines, "\n")
end

return loveunit