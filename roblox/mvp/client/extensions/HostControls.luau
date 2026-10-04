-- Presentation only. Every recovery is prepared and confirmed on the server.
local Module = {}
local QUESTS = { {"Q01","Bed"},{"Q02","Jasper"},{"Q03","Craft"},{"Q04","Reading"},{"Q05","Labubu wish"},{"Q06","Food"} }
function Module.Init(getContext, registry)
    local selectedQuest, expanded, dismissedToken = "Q01", "quest", nil
    local lastSession, lastResult
    local showAllAudit = false
    local function request(value)
        local context=getContext()
        if context.pending then context.toast("Wait for your last choice to finish."); return end
        value.kind="Host"
        if context.send(value) then context.refresh() end
    end
    local function isHost(context)
        return context.snapshot.host and context.snapshot.host.authorized==true and context.player:GetAttribute("BirthdayLocation")=="World"
    end
    registry.RegisterPanel("HostControls",{
        label="Host controls",title="Host controls",visible=isHost,
        render=function(container,context)
            local host=context.snapshot.host
            if not isHost(context) then context.UI.Label(container,"HostUnavailable","Host controls are available to Phuong and Andrew in the world.",16); return end
            if lastSession~=context.sessionId then lastSession=context.sessionId; dismissedToken=nil end
            local UI=context.UI
            local banner=UI.Card(container,"HostState",#host.activeOverrides>0 and "golden" or "sage"); banner.LayoutOrder=1
            UI.Label(banner,"Mode",#host.activeOverrides>0 and "HOST OVERRIDE · "..table.concat(host.activeOverrides,", ") or "Normal choices",18).LayoutOrder=1
            UI.Label(banner,"Authority",host.hint,14).LayoutOrder=2
            local petals=0; for _,done in pairs(host.petals) do if done then petals+=1 end end
            UI.Label(banner,"CurrentSharedState","Shared fund "..host.fundBalance.." · "..petals.."/6 petals",16).LayoutOrder=3
            local toggle=UI.Button(banner,"ToggleHostOverride",host.override and "End my Override" or "Enable my Override",function()
                dismissedToken=nil; request({action="SetOverride",enabled=not getContext().snapshot.host.override})
            end,host.override)
            toggle.LayoutOrder=4; UI.SetEnabled(toggle,not context.pending,host.override)
            if not host.override then
                UI.Label(container,"OverrideHelp","Enable Override to preview a recovery. Every change shows its current state and exact effect before Confirm. Either host may recover while Phuong is present.",16).LayoutOrder=2
            end
            local quote=host.confirmation
            if quote and quote.token~=dismissedToken and host.override then
                local card=UI.Card(container,"HostConfirmation","cream"); card.LayoutOrder=2
                UI.Label(card,"ConfirmTitle",quote.label.."?",18,UI.Palette.forest).LayoutOrder=1
                UI.Label(card,"Before",quote.current,15).LayoutOrder=2
                UI.Label(card,"ExactEffect",quote.effect,16).LayoutOrder=3
                UI.Label(card,"Freshness","If anything relevant changes or 30 seconds pass, review a fresh preview. Cancel leaves everything as it is.",13).LayoutOrder=4
                local confirm=UI.Button(card,"ConfirmHostRecovery",context.pending and "Saving…" or "Confirm recovery",function()
                    request({action="Confirm",token=quote.token})
                end)
                confirm.LayoutOrder=5; UI.SetEnabled(confirm,not context.pending and workspace:GetServerTimeNow()<quote.expiresAt)
                local cancel=UI.Button(card,"CancelHostRecovery","Cancel",function()
                    if getContext().pending then return end
                    dismissedToken=quote.token; request({action="Cancel",token=quote.token})
                end,true)
                cancel.LayoutOrder=6; UI.SetEnabled(cancel,not context.pending,true)
                UI.Button(card,"FreshPreview","Review current state again",function()
                    dismissedToken=quote.token; request({action="Cancel",token=quote.token})
                end,true).LayoutOrder=7
            elseif host.override then
                local function operation(parent,descriptor,order)
                    local button=UI.Button(parent,"Host"..descriptor.operation,descriptor.label,function()
                        dismissedToken=nil
                        request({action="Prepare",operation=descriptor.operation,activityId=descriptor.activityId})
                    end,true)
                    button.LayoutOrder=order; UI.SetEnabled(button,descriptor.enabled and not context.pending,true)
                    if not descriptor.enabled then UI.Label(parent,"Reason"..descriptor.operation,descriptor.reason,14).LayoutOrder=order+1 end
                end
                local quests=UI.Card(container,"HostQuestRecovery","cream"); quests.LayoutOrder=3
                UI.Button(quests,"ShowQuestRecovery",(expanded=="quest" and "▾ " or "▸ ").."Quest recovery",function() if expanded=="quest" then expanded=nil else expanded="quest" end; getContext().refresh() end,true).LayoutOrder=1
                if expanded=="quest" then
                    UI.Label(quests,"ChooseQuest","Choose one activity. Held work and completed progress are listed in the confirmation.",14).LayoutOrder=2
                    for index,entry in ipairs(QUESTS) do
                        local button=UI.Button(quests,"Choose"..entry[1],(selectedQuest==entry[1] and "✓ " or "")..entry[2]..(host.petals[entry[1]] and " · petal saved" or " · incomplete"),function() selectedQuest=entry[1]; getContext().refresh() end,selectedQuest~=entry[1])
                        button.LayoutOrder=index+20; UI.SetEnabled(button,not context.pending,selectedQuest~=entry[1])
                    end
                    UI.Label(quests,"SelectedQuest","Selected activity · "..selectedQuest,16,UI.Palette.forest).LayoutOrder=3
                    local order=4
                    for _,descriptor in ipairs(host.actions) do if descriptor.activityId==selectedQuest then operation(quests,descriptor,order); order+=2 end end
                end
                local other=UI.Card(container,"HostOtherRecovery","cream"); other.LayoutOrder=4
                UI.Button(other,"ShowOtherRecovery",(expanded=="other" and "▾ " or "▸ ").."Fund, wish, cake and return",function() if expanded=="other" then expanded=nil else expanded="other" end; getContext().refresh() end,true).LayoutOrder=1
                UI.Label(other,"TopUpBounds","Emergency fund: +20, up to 5 times this session, 30 seconds apart. Used "..host.topUpsUsed.."/5. Wish fulfillment: once, for the normally selected wish.",14).LayoutOrder=2
                if expanded=="other" then
                    local order=3
                    for _,descriptor in ipairs(host.actions) do if not descriptor.activityId then operation(other,descriptor,order); order+=2 end end
                end
            end
            local audit=UI.Card(container,"HostAudit","sage"); audit.LayoutOrder=8
            UI.Label(audit,"AuditTitle","Recent host recoveries · visible only to hosts",16).LayoutOrder=1
            if #host.audit==0 then UI.Label(audit,"NoRecovery","No recovery changes in this session.",14).LayoutOrder=2 end
            for index,entry in ipairs(host.audit) do
                if index>6 and not showAllAudit then break end
                UI.Label(audit,"HostAudit"..index,entry.actor.." · "..entry.action..(entry.activityId and " · "..entry.activityId or "").." · "..os.date("%H:%M:%S",math.floor(entry.timestamp)).."\n"..entry.prior.." → "..entry.new,13).LayoutOrder=index+1
            end
            if #host.audit>6 then UI.Button(audit,"ShowHostAudit",showAllAudit and "Show latest six" or "Show all recent audit entries",function() showAllAudit=not showAllAudit; getContext().refresh() end,true).LayoutOrder=40 end
            UI.Label(audit,"AuditLimit","The server keeps the latest 32 audit entries and at most 512 host requests this session ("..host.requestCount.." used). Close or Back leaves ordinary play available.",12).LayoutOrder=41
        end,
    })
    registry.RegisterObserver("HostControls",function(payload,context)
        if payload.kind=="PanelClosed" or payload.kind=="CharacterRemoving" or payload.kind=="LocationChanged" and not payload.inWorld then
            local quote=context.snapshot.host and context.snapshot.host.confirmation
            dismissedToken=quote and quote.token or dismissedToken
            return
        end
        if payload.hostResult then
            local result=payload.hostResult
            if payload.actionId~=lastResult then
                lastResult=payload.actionId
                context.toast(result.message,payload.ok==false)
                if result.ok and result.destination then
                    registry.Notify({kind="HostTravel",destination=result.destination},getContext())
                    context.close()
                end
            end
        end
        if context.activePanel=="HostControls" and (payload.snapshot or payload.hostResult) then getContext().refresh() end
    end)
end
return Module
