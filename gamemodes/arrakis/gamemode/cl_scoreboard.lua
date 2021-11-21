if CLIENT then
    local Scoreboard_Roundness = 2
	local Scoreboard_Color = Color(35, 35, 35, 111)
	local Scoreboard_XGap = 9
	local Scoreboard_YGap = 9
	local Scoreboard_TitleToNamesGap = 2

	local Title_Height = 1
	local Title_Color = Color(255, 255, 255, 111)
	local Title_Font = "ScoreboardTitleFont"
	local Title_Text = GetHostName()
	local Title_BackgroundRoundness = 2
	local Title_BackgroundColor = Color(35, 35, 35, 56)

	local Players_Spacing = 4
	local Players_EdgeGap = 4
	local Players_BackgroundRoundness = 2
	local Players_BackgroundColor = Color(35, 35, 35, 56)

	local PlayerBar_Height = 24
	local PlayerBar_Color = Color(255, 255, 255, 255)
	local PlayerBar_Font = "Scoreboarder"
	local PlayerBar_BackgroundRoundness = 2
	local PlayerBar_BackgroundColor = Color(35, 35, 35, 56)

	local InfoBar_Height = 32
	local InfoBar_Color = Color(255, 255, 255, 255)
	local InfoBar_Font = "Scoreboarder"
	local InfoBar_BackgroundRoundness = 2
	local InfoBar_BackgroundColor = Color(35, 35, 35, 56)

	local Columns = {}
		Columns[1] = {name="Player", command=function(self, arg) return tostring(arg:Name()) end}
		Columns[2] = {name="Class", command=function(self, arg)
			return PlyGetClass(arg)
		end}
		Columns[3] = {name="KDR", command=function(self, arg) 
			return tostring(GetKDR(arg))
		end}
		Columns[4] = {name="Ping", command=function(self, arg) return tostring(arg:Ping()) end}

	surface.CreateFont("ScoreboardTitleFont",{
		font = "Orbitron",
		size = 32,
		weight = 500,
		antialias = true
	})
	surface.CreateFont("Scoreboarder",{
		font = "Orbitron",
		extended = false,
		size = 20,
		weight = 500,
		blursize = 1.05,
		scanlines = 2,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
	surface.CreateFont("ScoreboardInfoFont", {
		font		= "CloseCaption_Normal",
		size		= 28,
		weight		= 1000,
		antialias 	= true
	})

	surface.CreateFont("ScoreboardPlayersFont", {
		font		= "CloseCaption_Normal",
		size		= 18,
		weight		= 500,
		antialias 	= true
	})

	-- Thanks to slownls
	DPANELBlurMat = Material("pp/blurscreen")
	DPANELBlurMat2 = Material("pp/blurscreen")

	function TeamSort(a,b)
		return -a:Team()+5+GetKDR(a)/100 > -b:Team()+5+GetKDR(b)/100
	end

	function PanelDrawBlur(panel, amount) 
		local tx, ty = panel:LocalToScreen(0, 0) 
		local scrW, scrH = ScrW(), ScrH() 
		surface.SetDrawColor(255, 255, 255) 
		surface.SetMaterial(DPANELBlurMat) 
		for i = 1, 3 do 
			DPANELBlurMat:SetFloat("$blur", (i / 3) * (amount or 6)) 
			DPANELBlurMat:Recompute() 
			render.UpdateScreenEffectTexture() 
			surface.DrawTexturedRect(tx * -1, ty * -1, scrW, scrH) 
		end
	end

	local CreateScoreboard = function()
		Scoreboard = vgui.Create("DFrame")
		Scoreboard:SetSize(ScrW()*.65, ScrH()*.65)
		Scoreboard:SetPos((ScrW()*.1743), (ScrH()*.30)*.5)
		Scoreboard:SetTitle("")
		Scoreboard:SetDraggable(false)
		Scoreboard:ShowCloseButton(false)
		Scoreboard.Open = function(self)
			Scoreboard:SetVisible(true)
		end
		Scoreboard.Close = function(self)
			Scoreboard:SetVisible(false)
		end
		Scoreboard.Paint = function(self)
			PanelDrawBlur(self, 5)
			draw.RoundedBox(Scoreboard_Roundness, 0, 0, self:GetWide(), self:GetTall(), Scoreboard_Color)
		end
		 
		Scoreboard.TitlePanel = vgui.Create("DPanel")
		Scoreboard.TitlePanel:SetParent(Scoreboard)
		Scoreboard.TitlePanel:SetPos(Scoreboard_XGap, Scoreboard_YGap)
		surface.SetFont(Title_Font)
		local w, h = surface.GetTextSize(Title_Text)
		local Height = h+(Title_Height*2)
		Scoreboard.TitlePanel:SetSize(Scoreboard:GetWide()-(Scoreboard_XGap*2), Height)
		Scoreboard.TitlePanel.Paint = function(self)

			draw.RoundedBox(Title_BackgroundRoundness, 0, 0, self:GetWide(), self:GetTall(), Title_BackgroundColor)
			surface.SetFont(Title_Font)
			surface.SetTextColor(Title_Color.r, Title_Color.g, Title_Color.b, Title_Color.a)
			surface.SetTextPos(self:GetWide()*.5-(w*.5), self:GetTall()*.5-(h*.5))
			surface.DrawText(Title_Text)
		end

		local Column_Width = Scoreboard:GetWide()-(Scoreboard_XGap*2)
		local ColumnGap_Width = (Column_Width/#Columns)
		local ColumnGap_Half = ColumnGap_Width*.5

		Scoreboard.NamesListPanel = vgui.Create("DPanelList")
		Scoreboard.NamesListPanel.PlayerBars = {}
		Scoreboard.NamesListPanel.NextRefresh = CurTime()+3
		Scoreboard.NamesListPanel:SetParent(Scoreboard)
		Scoreboard.NamesListPanel:SetPos(Scoreboard_XGap, Scoreboard_YGap+Scoreboard.TitlePanel:GetTall()+Scoreboard_TitleToNamesGap+InfoBar_Height)
		Scoreboard.NamesListPanel:SetSize(Scoreboard:GetWide()-(Scoreboard_XGap*2), Scoreboard:GetTall()-(Scoreboard.TitlePanel:GetTall())-(Scoreboard_YGap*2)-(Scoreboard_TitleToNamesGap)-InfoBar_Height)
		Scoreboard.NamesListPanel:SetSpacing(Players_Spacing)
		Scoreboard.NamesListPanel:SetPadding(Players_EdgeGap)
		Scoreboard.NamesListPanel:EnableHorizontal(false)
		Scoreboard.NamesListPanel:EnableVerticalScrollbar(true)
		Scoreboard.NamesListPanel.Refill = function(self)

			self:Clear()

			local PlyTable = player.GetAll()

			table.sort(PlyTable, function(a, b) return TeamSort(a,b) end)
			--table.sort(PlyTable, function(a, b) return GetKDR(a) > GetKDR(b) end)

			for k, pl in pairs(PlyTable) do
				local ID = tostring(pl:SteamID())
				self.PlayerBars[ID] = vgui.Create("DPanel")
				self.PlayerBars[ID]:SetPos(0, 0)
				self.PlayerBars[ID]:SetSize(Scoreboard.NamesListPanel:GetWide()-(Players_Spacing*2), PlayerBar_Height)
				self.PlayerBars[ID].Paint = function(self)
					local PLYCOLORCONV = team.GetColor(pl:Team())
					PLYCOLORCONV.a = 55
					draw.RoundedBox(PlayerBar_BackgroundRoundness, 0, 0, self:GetWide(), self:GetTall(), PLYCOLORCONV)

					surface.SetFont(PlayerBar_Font)
					surface.SetTextColor(PlayerBar_Color.r, PlayerBar_Color.g, PlayerBar_Color.b, PlayerBar_Color.a)
					for k, v in pairs(Columns) do
						local w, h = surface.GetTextSize(v:command(pl))
						if k==1 then
							surface.SetTextPos((ColumnGap_Half*k)-(w*.5), self:GetTall()*.5-(h*.5))
						else
							surface.SetTextPos((ColumnGap_Width*(k-1))+(ColumnGap_Half)-(w*.5), self:GetTall()*.5-(h*.5))
						end
						surface.DrawText(v:command(pl))
					end
				end

				self:AddItem(self.PlayerBars[ID])
			end
		end
		Scoreboard.NamesListPanel.Think = function(self)
			if self:IsVisible() then
				if Scoreboard.NamesListPanel.NextRefresh < CurTime() then
					Scoreboard.NamesListPanel.NextRefresh = CurTime()+3
					Scoreboard.NamesListPanel:Refill()
				end
			end
		end
		Scoreboard.NamesListPanel.Paint = function(self)
			draw.RoundedBox(Players_BackgroundRoundness, 0, 0, self:GetWide(), self:GetTall(), Players_BackgroundColor)
		end

		Scoreboard.InfoBar = vgui.Create("DPanel")
		Scoreboard.InfoBar:SetParent(Scoreboard)
		Scoreboard.InfoBar:SetPos(Scoreboard_XGap, Scoreboard_YGap+Scoreboard.TitlePanel:GetTall()+Scoreboard_TitleToNamesGap)
		Scoreboard.InfoBar:SetSize(Scoreboard:GetWide()-(Scoreboard_XGap*2), InfoBar_Height)
		Scoreboard.InfoBar.Paint = function(self)
			draw.RoundedBox(InfoBar_BackgroundRoundness, 0, 0, self:GetWide(), self:GetTall(), InfoBar_BackgroundColor)
			surface.SetFont(InfoBar_Font)
			surface.SetTextColor(InfoBar_Color.r, InfoBar_Color.g, InfoBar_Color.b, InfoBar_Color.a)
			for k, v in pairs(Columns) do
				local w, h = surface.GetTextSize(v.name)
				if k==1 then
					surface.SetTextPos((ColumnGap_Half*k)-(w*.41), self:GetTall()*.5-(h*.5))
				else
					surface.SetTextPos((ColumnGap_Width*(k-0.985))+(ColumnGap_Half)-(w*.5), self:GetTall()*.5-(h*.5))
				end
				surface.DrawText(v.name)
			end
		end

		Scoreboard.NamesListPanel:Refill()
	end

	function ScoreboardOpened()
		if !ValidPanel(Scoreboard) then
			CreateScoreboard()
		end

		Scoreboard:Open()
		gui.EnableScreenClicker(true)
		return true
	end
	hook.Add("ScoreboardShow", "Open scoreboard.", ScoreboardOpened)

	function ScoreboardClosed()
		if !ValidPanel(Scoreboard) then
			CreateScoreboard()
		end

		gui.EnableScreenClicker(false)
		Scoreboard:Close()
		return true
	end
	hook.Add("ScoreboardHide", "Close scoreboard.", ScoreboardClosed)
end