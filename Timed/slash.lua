--------------------------------------------------------------------------------
-- Timed (c) 2011, 2013 by Siarkowy
-- Released under the terms of BSD 2.0 license.
--------------------------------------------------------------------------------

local Timed = Timed

local function todo() ChatFrame1:AddMessage("TODO!") end

Timed.slash = {
    name = "Timed",
    handler = Timed,
    type = "group",
    childGroups = "tabs",
    args = {
        gui = {
            name = "GUI",
            desc = "Show graphical options panel.",
            type = "execute",
            guiHidden = true,
            func = "ShowOptionsFrame",
            order = 0
        },

        -- Heading

        about = {
            name = "Synchronized .debug threatlist data distributor particularly for raiding use by Siarkowy.",
            type = "description",
            cmdHidden = true,
            order = 100
        },
        toggle = {
            name = "Disable",
            desc = "Toggle addon state.",
            type = "execute",
            func = "Toggle",
            order = 101
        },
        vercheck = {
            name = "Version check",
            desc = "Perform group version check.",
            type = "execute",
            func = todo,
            order = 102
        },

        -- General

        general = {
            name = "General",
            type = "header",
            cmdHidden = true,
            order = 200
        },
        warnings = {
            name = "Warn on overaggro",
            desc = "Toggle overaggro warnings on and off.",
            type = "toggle",
            get = "GetWarningsEnabled",
            set = "SetWarningsEnabled",
            order = 201
        },
        threshold = {
            name = "Warning threshold",
            desc = "Set overaggro warning percent threshold. Timed will display a warning when warnings are enabled and passed this amount of aggro on current target.",
            type = "range",
            min = 0.5,
            max = 1.3,
            step = 0.1,
            get = "GetWarningThreshold",
            set = "SetWarningThreshold",
            isPercent = true,
            order = 202
        },
        autodump = {
            name = "Auto dump",
            type = "toggle",
            get = "GetAutoDumpEnabled",
            set = "SetAutoDumpEnabled",
            order = 203
        },

        -- Advanced

        advanced = {
            name = "Advanced",
            type = "header",
            cmdHidden = true,
            order = 300
        },
        warning = {
            name = "WARNING! These settings are for experienced users only. Change only if you know what you are doing. Wrong values may cause Timed to completely stop working.",
            type = "description",
            cmdHidden = true,
            order = 301            
        },
        interval = {
            name = "Interval",
            desc = "Minimum time between threat queries.",
            type = "range",
            min = 3,
            max = 60,
            step = 0.1,
            get = function(info)
                return Timed.db.profile.interval
            end,
            set = "SetQueryInterval",
            order = 302
        },
        message = {
            name = "Message",
            desc = "Threat query message sent to guild channel.",
            type = "input",
            get = "GetQueryMessage",
            set = "SetQueryMessage",
            order = 303
        },
        logging = {
            name = "Enable logging",
            desc = "If enabled, Timed will store an event log, containing threat, queue and version data info.",
            type = "toggle",
            get = "IsLogging",
            set = "SetLogging",
            order = 304
        },
        verbose = {
            name = "Verbose mode",
            desc = "In verbose mode, logs are printed to default chat frame.",
            type = "toggle",
            get = "IsVerbose",
            set = "SetVerbose",
            order = 305
        },

        -- Gauges

        gauge = {
            name = "Gauge",
            desc = "Gauge management commands.",
            type = "group",
            order = 400,
            guiInline = true,
            guiHidden = true,
            args = {
                add = {
                    name = "Add",
                    desc = "Add new gauge.",
                    usage = "<unit>",
                    type = "input",
                    set = function(info, v)
                        Timed:Printf(pcall(Timed.AddGauge, Timed, v ~= "" and v or "target", v == "")
                            and "Gauge %q added successfully."
                            or "No unit selected or specified gauge already exists.", v)
                    end,
                    order = 1
                },
                delete = {
                    name = "Delete",
                    desc = "Delete specified gauge.",
                    usage = "<unit>",
                    type = "input",
                    set = function(info, v)
                        Timed:Printf(pcall(Timed.DeleteGauge, Timed, v)
                            and "Gauge %q deleted successfully."
                            or "Gauge %q does not exist.", v)
                    end,
                    order = 2
                },
                list = {
                    name = "List",
                    desc = "List all gauges.",
                    type = "execute",
                    func = "ListGauges",
                    order = 3
                }
            }
        }
    }
}

-- Slash handlers --------------------------------------------------------------

function Timed:OnSlashCmd(input)
    if not input or input:lower() == "gui" then
        self:ShowOptionsFrame()
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(Timed, "timed", "Timed", input)
    end
end

function Timed:ListGauges()
    self:Print("List of active gauges:")
    for token in pairs(Timed.gauges) do
        self:Echo("   %s", token)
    end
end

function Timed:ShowOptionsFrame()
    InterfaceOptionsFrame_OpenToFrame(self.options)
end

function Timed:Toggle(info)
    if self:IsEnabled() then
        self:Disable()
    else
        self:Enable()
    end

    info.option.name = self:IsEnabled() and "Disable" or "Enable"
end

-- Getters/Setters -------------------------------------------------------------

function Timed:SetQueryInterval(info, v) self.db.profile.interval = tonumber(v) or 10; self:Reconfigure() end

function Timed:GetQueryMessage() return self.db.profile.message end
function Timed:SetQueryMessage(info, v) self.db.profile.message = v ~= "" and v or ".debug threatlist"; self:Reconfigure() end

function Timed:GetWarningsEnabled() return self.db.profile.warnings end
function Timed:SetWarningsEnabled(info, v) self.db.profile.warnings = v; self:Reconfigure() end

function Timed:GetWarningThreshold() return self.db.profile.threshold end
function Timed:SetWarningThreshold(info, v) self.db.profile.threshold = tonumber(v) or 0.75; self:Reconfigure() end

function Timed:IsLogging() return self.db.profile.logging end
function Timed:SetLogging(info, v) self.db.profile.logging = v; self:Reconfigure() end

function Timed:IsVerbose() return self.db.profile.verbose end
function Timed:SetVerbose(info, v) self.db.profile.verbose = v; self:Reconfigure() end

function Timed:GetAutoDumpEnabled() return self.db.profile.autodump end
function Timed:SetAutoDumpEnabled(info, v) self.db.profile.autodump = v; self:Reconfigure() end