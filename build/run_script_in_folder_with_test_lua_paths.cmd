@echo off
call .\build\configure_environment.cmd

cd %1
set LUA_PATH=%1\scripts\?.lua;%1\test\?.lua;%1\test-framework\?.lua;%1\test-framework\test-dependencies\?.lua;%1\test-framework\no-test-dependencies\?.lua;%LUA_DEFAULT_MODULES_PATH%\?.lua
%LUA_EXECUTABLE% %2
if %ERRORLEVEL% NEQ 0 (
    echo [91mTESTS FAILED[0m!
    exit(%ERRORLEVEL%)
) else (
    echo [92mTESTS OK[0m!
    exit(0)
)