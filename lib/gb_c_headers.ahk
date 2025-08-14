; GameBoy / GameBoy Color Headers, not needed for EmuHook but used in rom autodetect example
headers := {}
; SGB
headers.sgb := {0x03: "Yes", 0x00: "No"} ; If 00 -> Normal Game Boy or GBC Only game

; MBC
headers.mbc := {0x00: "ROM ONLY",0x01: "MBC1",0x02: "MBC1+RAM",0x03: "MBC1+RAM+BATTERY",0x05: "MBC2",0x06: "MBC2+BATTERY",0x08: "ROM+RAM 9",0x09: "ROM+RAM+BATTERY 9",0x0B: "MMM01",0x0C: "MMM01+RAM",0x0D: "MMM01+RAM+BATTERY",0x0F: "MBC3+TIMER+BATTERY",0x10: "MBC3+TIMER+RAM+BATTERY 10",0x11: "MBC3",0x12: "MBC3+RAM 10",0x13: "MBC3+RAM+BATTERY 10",0x19: "MBC5",0x1A: "MBC5+RAM",0x1B: "MBC5+RAM+BATTERY",0x1C: "MBC5+RUMBLE",0x1D: "MBC5+RUMBLE+RAM",0x1E: "MBC5+RUMBLE+RAM+BATTERY",0x20: "MBC6",0x22: "MBC7+SENSOR+RUMBLE+RAM+BATTERY",0xFC: "POCKET CAMERA",0xFD: "BANDAI TAMA5",0xFE: "HuC3",0xFF: "HuC1+RAM+BATTERY"}

; ROM Size
headers.romSize := {}
headers.romSize[0x00] := "32 KiB"
headers.romSize[0x01] := "64 KiB"
headers.romSize[0x02] := "128 KiB"
headers.romSize[0x03] := "256 KiB"
headers.romSize[0x04] := "512 KiB"
headers.romSize[0x05] := "1 MiB"
headers.romSize[0x06] := "2 MiB"
headers.romSize[0x07] := "4 MiB"
headers.romSize[0x08] := "8 MiB"
headers.romSize[0x52] := "1.1 MiB"
headers.romSize[0x53] := "1.2 MiB"
headers.romSize[0x54] := "1.5 MiB"

; RAM Size
headers.ramSize := {0x00: "0",0x01: "0",0x02: "8 KiB",0x03: "32 KiB",0x04: "128 KiB",0x05: "64 KiB"}

; Destination Code
headers.destination := {0x00: "JP",0x01: "Overseas"}

; New Licensee Code
headers.newLicensee := {}
headers.newLicensee["00"] := "None"
headers.newLicensee["01"] := "Nintendo Research & Development 1"
headers.newLicensee["08"] := "Capcom"
headers.newLicensee["13"] := "EA (Electronic Arts)"
headers.newLicensee["18"] := "Hudson Soft"
headers.newLicensee["19"] := "B-AI"
headers.newLicensee["20"] := "KSS"
headers.newLicensee["22"] := "Planning Office WADA"
headers.newLicensee["24"] := "PCM Complete"
headers.newLicensee["25"] := "San-X"
headers.newLicensee["28"] := "Kemco"
headers.newLicensee["29"] := "SETA Corporation"
headers.newLicensee["30"] := "Viacom"
headers.newLicensee["31"] := "Nintendo"
headers.newLicensee["32"] := "Bandai"
headers.newLicensee["33"] := "Ocean Software/Acclaim Entertainment"
headers.newLicensee["34"] := "Konami"
headers.newLicensee["35"] := "HectorSoft"
headers.newLicensee["37"] := "Taito"
headers.newLicensee["38"] := "Hudson Soft"
headers.newLicensee["39"] := "Banpresto"
headers.newLicensee["41"] := "Ubi Soft1"
headers.newLicensee["42"] := "Atlus"
headers.newLicensee["44"] := "Malibu Interactive"
headers.newLicensee["46"] := "Angel"
headers.newLicensee["47"] := "Bullet-Proof Software2"
headers.newLicensee["49"] := "Irem"
headers.newLicensee["50"] := "Absolute"
headers.newLicensee["51"] := "Acclaim Entertainment"
headers.newLicensee["52"] := "Activision"
headers.newLicensee["53"] := "Sammy USA Corporation"
headers.newLicensee["54"] := "Konami"
headers.newLicensee["55"] := "Hi Tech Expressions"
headers.newLicensee["56"] := "LJN"
headers.newLicensee["57"] := "Matchbox"
headers.newLicensee["58"] := "Mattel"
headers.newLicensee["59"] := "Milton Bradley Company"
headers.newLicensee["60"] := "Titus Interactive"
headers.newLicensee["61"] := "Virgin Games Ltd.3"
headers.newLicensee["64"] := "Lucasfilm Games4"
headers.newLicensee["67"] := "Ocean Software"
headers.newLicensee["69"] := "EA (Electronic Arts)"
headers.newLicensee["70"] := "Infogrames5"
headers.newLicensee["71"] := "Interplay Entertainment"
headers.newLicensee["72"] := "Broderbund"
headers.newLicensee["73"] := "Sculptured Software6"
headers.newLicensee["75"] := "The Sales Curve Limited7"
headers.newLicensee["78"] := "THQ"
headers.newLicensee["79"] := "Accolade"
headers.newLicensee["80"] := "Misawa Entertainment"
headers.newLicensee["83"] := "lozc"
headers.newLicensee["86"] := "Tokuma Shoten"
headers.newLicensee["87"] := "Tsukuda Original"
headers.newLicensee["91"] := "Chunsoft Co.8"
headers.newLicensee["92"] := "Video System"
headers.newLicensee["93"] := "Ocean Software/Acclaim Entertainment"
headers.newLicensee["95"] := "Varie"
headers.newLicensee["96"] := "Yonezawa/s’pal"
headers.newLicensee["97"] := "Kaneko"
headers.newLicensee["99"] := "Pack-In-Video"
headers.newLicensee["9H"] := "Bottom Up"
headers.newLicensee["A4"] := "Konami (Yu-Gi-Oh!)"
headers.newLicensee["BL"] := "MTO"
headers.newLicensee["DK"] := "Kodansha"

; Licensee Code
headers.license := {}
headers.licensee[0x00] := "None"
headers.licensee[0x01] := "Nintendo"
headers.licensee[0x08] := "Capcom"
headers.licensee[0x09] := "HOT-B"
headers.licensee[0x0A] := "Jaleco"
headers.licensee[0x0B] := "Coconuts Japan"
headers.licensee[0x0C] := "Elite Systems"
headers.licensee[0x13] := "EA (Electronic Arts)"
headers.licensee[0x18] := "Hudson Soft"
headers.licensee[0x19] := "ITC Entertainment"
headers.licensee[0x1A] := "Yanoman"
headers.licensee[0x1D] := "Japan Clary"
headers.licensee[0x1F] := "Virgin Games Ltd.3"
headers.licensee[0x24] := "PCM Complete"
headers.licensee[0x25] := "San-X"
headers.licensee[0x28] := "Kemco"
headers.licensee[0x29] := "SETA Corporation"
headers.licensee[0x30] := "Infogrames5"
headers.licensee[0x31] := "Nintendo"
headers.licensee[0x32] := "Bandai"
headers.licensee[0x33] := "New licensee code"
headers.licensee[0x34] := "Konami"
headers.licensee[0x35] := "HectorSoft"
headers.licensee[0x38] := "Capcom"
headers.licensee[0x39] := "Banpresto"
headers.licensee[0x3C] := "Entertainment Interactive"
headers.licensee[0x3E] := "Gremlin"
headers.licensee[0x41] := "Ubi Soft1"
headers.licensee[0x42] := "Atlus"
headers.licensee[0x44] := "Malibu Interactive"
headers.licensee[0x46] := "Angel"
headers.licensee[0x47] := "Spectrum HoloByte"
headers.licensee[0x49] := "Irem"
headers.licensee[0x4A] := "Virgin Games Ltd.3"
headers.licensee[0x4D] := "Malibu Interactive"
headers.licensee[0x4F] := "U.S. Gold"
headers.licensee[0x50] := "Absolute"
headers.licensee[0x51] := "Acclaim Entertainment"
headers.licensee[0x52] := "Activision"
headers.licensee[0x53] := "Sammy USA Corporation"
headers.licensee[0x54] := "GameTek"
headers.licensee[0x55] := "Park Place13"
headers.licensee[0x56] := "LJN"
headers.licensee[0x57] := "Matchbox"
headers.licensee[0x59] := "Milton Bradley Company"
headers.licensee[0x5A] := "Mindscape"
headers.licensee[0x5B] := "Romstar"
headers.licensee[0x5C] := "Naxat Soft14"
headers.licensee[0x5D] := "Tradewest"
headers.licensee[0x60] := "Titus Interactive"
headers.licensee[0x61] := "Virgin Games Ltd.3"
headers.licensee[0x67] := "Ocean Software"
headers.licensee[0x69] := "EA (Electronic Arts)"
headers.licensee[0x6E] := "Elite Systems"
headers.licensee[0x6F] := "Electro Brain"
headers.licensee[0x70] := "Infogrames5"
headers.licensee[0x71] := "Interplay Entertainment"
headers.licensee[0x72] := "Broderbund"
headers.licensee[0x73] := "Sculptured Software6"
headers.licensee[0x75] := "The Sales Curve Limited7"
headers.licensee[0x78] := "THQ"
headers.licensee[0x79] := "Accolade15"
headers.licensee[0x7A] := "Triffix Entertainment"
headers.licensee[0x7C] := "MicroProse"
headers.licensee[0x7F] := "Kemco"
headers.licensee[0x80] := "Misawa Entertainment"
headers.licensee[0x83] := "LOZC G."
headers.licensee[0x86] := "Tokuma Shoten"
headers.licensee[0x8B] := "Bullet-Proof Software2"
headers.licensee[0x8C] := "Vic Tokai Corp.16"
headers.licensee[0x8E] := "Ape Inc.17"
headers.licensee[0x8F] := "I’Max18"
headers.licensee[0x91] := "Chunsoft Co.8"
headers.licensee[0x92] := "Video System"
headers.licensee[0x93] := "Tsubaraya Productions"
headers.licensee[0x95] := "Varie"
headers.licensee[0x96] := "Yonezawa19/S’Pal"
headers.licensee[0x97] := "Kemco"
headers.licensee[0x99] := "Arc"
headers.licensee[0x9A] := "Nihon Bussan"
headers.licensee[0x9B] := "Tecmo"
headers.licensee[0x9C] := "Imagineer"
headers.licensee[0x9D] := "Banpresto"
headers.licensee[0x9F] := "Nova"
headers.licensee[0xA1] := "Hori Electric"
headers.licensee[0xA2] := "Bandai"
headers.licensee[0xA4] := "Konami"
headers.licensee[0xA6] := "Kawada"
headers.licensee[0xA7] := "Takara"
headers.licensee[0xA9] := "Technos Japan"
headers.licensee[0xAA] := "Broderbund"
headers.licensee[0xAC] := "Toei Animation"
headers.licensee[0xAD] := "Toho"
headers.licensee[0xAF] := "Namco"
headers.licensee[0xB0] := "Acclaim Entertainment"
headers.licensee[0xB1] := "ASCII Corporation or Nexsoft"
headers.licensee[0xB2] := "Bandai"
headers.licensee[0xB4] := "Square Enix"
headers.licensee[0xB6] := "HAL Laboratory"
headers.licensee[0xB7] := "SNK"
headers.licensee[0xB9] := "Pony Canyon"
headers.licensee[0xBA] := "Culture Brain"
headers.licensee[0xBB] := "Sunsoft"
headers.licensee[0xBD] := "Sony Imagesoft"
headers.licensee[0xBF] := "Sammy Corporation"
headers.licensee[0xC0] := "Taito"
headers.licensee[0xC2] := "Kemco"
headers.licensee[0xC3] := "Square"
headers.licensee[0xC4] := "Tokuma Shoten"
headers.licensee[0xC5] := "Data East"
headers.licensee[0xC6] := "Tonkin House"
headers.licensee[0xC8] := "Koei"
headers.licensee[0xC9] := "UFL"
headers.licensee[0xCA] := "Ultra Games"
headers.licensee[0xCB] := "VAP, Inc."
headers.licensee[0xCC] := "Use Corporation"
headers.licensee[0xCD] := "Meldac"
headers.licensee[0xCE] := "Pony Canyon"
headers.licensee[0xCF] := "Angel"
headers.licensee[0xD0] := "Taito"
headers.licensee[0xD1] := "SOFEL"
headers.licensee[0xD2] := "Quest"
headers.licensee[0xD3] := "Sigma Enterprises"
headers.licensee[0xD4] := "ASK Kodansha Co."
headers.licensee[0xD6] := "Naxat Soft14"
headers.licensee[0xD7] := "Copya System"
headers.licensee[0xD9] := "Banpresto"
headers.licensee[0xDA] := "Tomy"
headers.licensee[0xDB] := "LJN"
headers.licensee[0xDD] := "Nippon Computer Systems"
headers.licensee[0xDE] := "Human Ent."
headers.licensee[0xDF] := "Altron"
headers.licensee[0xE0] := "Jaleco"
headers.licensee[0xE1] := "Towa Chiki"
headers.licensee[0xE2] := "Yutaka"
headers.licensee[0xE3] := "Varie"
headers.licensee[0xE5] := "Epoch"
headers.licensee[0xE7] := "Athena"
headers.licensee[0xE8] := "Asmik Ace Entertainment"
headers.licensee[0xE9] := "Natsume"
headers.licensee[0xEA] := "King Records"
headers.licensee[0xEB] := "Atlus"
headers.licensee[0xEC] := "Epic/Sony Records"
headers.licensee[0xEE] := "IGS"
headers.licensee[0xF0] := "A Wave"
headers.licensee[0xF3] := "Extreme Entertainment"
headers.licensee[0xFF] := "LJN"

; Version Byte
headers.version := {0x00: "JP",0x01: "US",0x02: "EU"}

/*
0x134-0x143 Title
0x13F-0x142 Manufacturer Code
0x144-0x145 New License Code
	00	None
	01	Nintendo Research & Development 1
	08	Capcom
	13	EA (Electronic Arts)
	18	Hudson Soft
	19	B-AI
	20	KSS
	22	Planning Office WADA
	24	PCM Complete
	25	San-X
	28	Kemco
	29	SETA Corporation
	30	Viacom
	31	Nintendo
	32	Bandai
	33	Ocean Software/Acclaim Entertainment
	34	Konami
	35	HectorSoft
	37	Taito
	38	Hudson Soft
	39	Banpresto
	41	Ubi Soft1
	42	Atlus
	44	Malibu Interactive
	46	Angel
	47	Bullet-Proof Software2
	49	Irem
	50	Absolute
	51	Acclaim Entertainment
	52	Activision
	53	Sammy USA Corporation
	54	Konami
	55	Hi Tech Expressions
	56	LJN
	57	Matchbox
	58	Mattel
	59	Milton Bradley Company
	60	Titus Interactive
	61	Virgin Games Ltd.3
	64	Lucasfilm Games4
	67	Ocean Software
	69	EA (Electronic Arts)
	70	Infogrames5
	71	Interplay Entertainment
	72	Broderbund
	73	Sculptured Software6
	75	The Sales Curve Limited7
	78	THQ
	79	Accolade
	80	Misawa Entertainment
	83	lozc
	86	Tokuma Shoten
	87	Tsukuda Original
	91	Chunsoft Co.8
	92	Video System
	93	Ocean Software/Acclaim Entertainment
	95	Varie
	96	Yonezawa/s’pal
	97	Kaneko
	99	Pack-In-Video
	9H	Bottom Up
	A4	Konami (Yu-Gi-Oh!)
	BL	MTO
	DK	Kodansha
0x146 SGB
	03 SGB
	00 No SGB -> Normal Game Boy or GBC Only game
0x147 MBC
	00	ROM ONLY
	01	MBC1
	02	MBC1+RAM
	03	MBC1+RAM+BATTERY
	05	MBC2
	06	MBC2+BATTERY
	08	ROM+RAM 9
	09	ROM+RAM+BATTERY 9
	0B	MMM01
	0C	MMM01+RAM
	0D	MMM01+RAM+BATTERY
	0F	MBC3+TIMER+BATTERY
	10	MBC3+TIMER+RAM+BATTERY 10
	11	MBC3
	12	MBC3+RAM 10
	13	MBC3+RAM+BATTERY 10
	19	MBC5
	1A	MBC5+RAM
	1B	MBC5+RAM+BATTERY
	1C	MBC5+RUMBLE
	1D	MBC5+RUMBLE+RAM
	1E	MBC5+RUMBLE+RAM+BATTERY
	20	MBC6
	22	MBC7+SENSOR+RUMBLE+RAM+BATTERY
	FC	POCKET CAMERA
	FD	BANDAI TAMA5
	FE	HuC3
	FF	HuC1+RAM+BATTERY
0x148 ROM Size
	inacurate data:
	Value	ROM size	Number of ROM banks
	00	32 KiB	2 (no banking)
	01	64 KiB	4
	02	128 KiB	8
	03	256 KiB	16
	04	512 KiB	32
	05	1 MiB	64
	06	2 MiB	128
	07	4 MiB	256
	08	8 MiB	512
	52	1.1 MiB	72
	53	1.2 MiB	80
	54	1.5 MiB	96
0x149 RAM Size	
	00	0	No RAM
	01	–	Unused 12
	02	8 KiB	1 bank
	03	32 KiB	4 banks of 8 KiB each
	04	128 KiB	16 banks of 8 KiB each
	05	64 KiB	8 banks of 8 KiB each
0x14A Destination Code
	00 JP
	01 Overseas
0x14B Old License Code
	00	None
	01	Nintendo
	08	Capcom
	09	HOT-B
	0A	Jaleco
	0B	Coconuts Japan
	0C	Elite Systems
	13	EA (Electronic Arts)
	18	Hudson Soft
	19	ITC Entertainment
	1A	Yanoman
	1D	Japan Clary
	1F	Virgin Games Ltd.3
	24	PCM Complete
	25	San-X
	28	Kemco
	29	SETA Corporation
	30	Infogrames5
	31	Nintendo
	32	Bandai
	33	Indicates that the New licensee code should be used instead.
	34	Konami
	35	HectorSoft
	38	Capcom
	39	Banpresto
	3C	Entertainment Interactive (stub)
	3E	Gremlin
	41	Ubi Soft1
	42	Atlus
	44	Malibu Interactive
	46	Angel
	47	Spectrum HoloByte
	49	Irem
	4A	Virgin Games Ltd.3
	4D	Malibu Interactive
	4F	U.S. Gold
	50	Absolute
	51	Acclaim Entertainment
	52	Activision
	53	Sammy USA Corporation
	54	GameTek
	55	Park Place13
	56	LJN
	57	Matchbox
	59	Milton Bradley Company
	5A	Mindscape
	5B	Romstar
	5C	Naxat Soft14
	5D	Tradewest
	60	Titus Interactive
	61	Virgin Games Ltd.3
	67	Ocean Software
	69	EA (Electronic Arts)
	6E	Elite Systems
	6F	Electro Brain
	70	Infogrames5
	71	Interplay Entertainment
	72	Broderbund
	73	Sculptured Software6
	75	The Sales Curve Limited7
	78	THQ
	79	Accolade15
	7A	Triffix Entertainment
	7C	MicroProse
	7F	Kemco
	80	Misawa Entertainment
	83	LOZC G.
	86	Tokuma Shoten
	8B	Bullet-Proof Software2
	8C	Vic Tokai Corp.16
	8E	Ape Inc.17
	8F	I’Max18
	91	Chunsoft Co.8
	92	Video System
	93	Tsubaraya Productions
	95	Varie
	96	Yonezawa19/S’Pal
	97	Kemco
	99	Arc
	9A	Nihon Bussan
	9B	Tecmo
	9C	Imagineer
	9D	Banpresto
	9F	Nova
	A1	Hori Electric
	A2	Bandai
	A4	Konami
	A6	Kawada
	A7	Takara
	A9	Technos Japan
	AA	Broderbund
	AC	Toei Animation
	AD	Toho
	AF	Namco
	B0	Acclaim Entertainment
	B1	ASCII Corporation or Nexsoft
	B2	Bandai
	B4	Square Enix
	B6	HAL Laboratory
	B7	SNK
	B9	Pony Canyon
	BA	Culture Brain
	BB	Sunsoft
	BD	Sony Imagesoft
	BF	Sammy Corporation
	C0	Taito
	C2	Kemco
	C3	Square
	C4	Tokuma Shoten
	C5	Data East
	C6	Tonkin House
	C8	Koei
	C9	UFL
	CA	Ultra Games
	CB	VAP, Inc.
	CC	Use Corporation
	CD	Meldac
	CE	Pony Canyon
	CF	Angel
	D0	Taito
	D1	SOFEL (Software Engineering Lab)
	D2	Quest
	D3	Sigma Enterprises
	D4	ASK Kodansha Co.
	D6	Naxat Soft14
	D7	Copya System
	D9	Banpresto
	DA	Tomy
	DB	LJN
	DD	Nippon Computer Systems
	DE	Human Ent.
	DF	Altron
	E0	Jaleco
	E1	Towa Chiki
	E2	Yutaka # Needs more info
	E3	Varie
	E5	Epoch
	E7	Athena
	E8	Asmik Ace Entertainment
	E9	Natsume
	EA	King Records
	EB	Atlus
	EC	Epic/Sony Records
	EE	IGS
	F0	A Wave
	F3	Extreme Entertainment
	FF	LJN
0x14C Version Byte
	US: Usually 0x01
	JP: 0x00
	EU: Often 0x02 or 0x03, depending on language support
*/