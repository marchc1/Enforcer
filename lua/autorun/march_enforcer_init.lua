local i,a,s,ap,p,m,c=include,AddCSLuaFile,SERVER,"enforcer/",ipairs,MsgC,Color
local incCS,incSH,incSV,incAllCS,incAllSH,incAllSV,ff,exe

function ff(p,q) return file.Find(ap..p..q,"LUA") end
function incCS(f) f=ap..f if s then a(f) else return i(f) end end
function incSH(f) f=ap..f if s then a(f) return i(f) else return i(f) end end
function incSV(f) f=ap..f if s then return i(f) end end

function incAllCS(p,q) for _,v in p(ff(p,q)) do incCS(p..v) end end
function incAllSH(p,q) for _,v in p(ff(p,q)) do incSH(p..v) end end
function incAllSV(p,q) for _,v in p(ff(p,q)) do incSV(p..v) end end

function exe(s, ...)return CompileString(s)(...) end

local en,ec,e="Enforcer",c(0,200,255) if Enforcer==nil then Enforcer={}end e=Enforcer
e.AddonInfo={name=en,author="March",version={2,0,0,"ALPHA"}}
e.PrintDebugMessages=false
function e.Log(...)m(c(155,155,155),"[",c(255,255,255),os.date"%Y-%m-%d %H:%M:%S",c(155,155,155),"]")m(c(155,155,155),"[",ec,en,c(155,155,155),"] ",c(255,255,255),...,"\n")end
function e.Debug(...)if not e.PrintDebugMessages then return end e.Log(...)end

e.incCS,e.incSH,e.incSV,e.incAllCS,e.incAllSH,e.incAllSV,e.exe=incCS,incSH,incSV,incAllCS,incAllSH,incAllSV,exe
local fr="FunctionRequiresUnavailableDependency" if e[fr]==nil then e[fr]=function(...) ErrorNoHaltWithStack"An Enforcer-calling extension is either partially or fully incompatible with this server due to missing addons." end end

e.Log"Initializing..."
--incSH"preferences_init.lua"
incSH"library_init.lua"
incSH"detours_init.lua"
incSH"extensions_init.lua"

e.Log"Loaded!"