/*
Create new package

Add Execute SQL Task
- Name: Truncate battles tables
- Connection: GameOfThrones
- SQL: 
TRUNCATE TABLE dbo.battles
GO
TRUNCATE TABLE dbo.battles_attacker_won
GO
TRUNCATE TABLE dbo.battles_defender_won
GO

Add Parameter
- Name: Foldername
- Data type: String
- Value: c:\foo
- Required: True

Add variable
- Name: Filename
- Data type: String
- Scope: Package

Add Foreach Loop - Edit -> Collections
- Enumerator: Foreach File Enumerator
- Expressions: 
	- Directory: @[$Package::Foldername]
	- FileSpec: "*.txt"
- Variable Mappings:
	- Variable: User::Filename
	- Index: 0

- Add presedence constraint from truncate battles table to foreach loop

- Connection Managers
	- Add Flat File Connection
		- Filename: C:\Temp\Data\game_of_thrones_battles_298.txt
	- Right click on new connection maanger -> Properties
		- Expressions:
			- ConnectionString: @[User::Filename]

- Data Flow (inside Foreach Loop)
	- Flat File Source
	- Data Conversion
		- year to DT_I2 (two-byte signed integer)
		- battle number to DT_I1 (single-byte signed integer)
	- Derived column
		- region_trimmed -> (DT_STR, 200, 1252) TRIM([region])
	- Lookup
		- General:
			- Redirect rows to no match output
		- Connection:
			- GameOfThrones
			- dbo.regions
		- Columns:
			region_trimmed -> region
			Add fun_fact
	- Derived column
		- No match output from lookup
		- column name: fun_fact
		- expression: (DT_STR, 8000, 1252) "No fun fact :("
	- Union all
		- check fun_fact
	- Multicast
	- OLEDB Destination - from multicast
		- dbo.battles
		- year <- copy of year
		- battle_number <- copy of battle_number
		- note <- fun_fact
	- Conditional split - from multicast
		- 1: win -> [attacker_outcome] == "win"
		- default: loss
	- OLEDB Destination - from conditional split - win
		- battles_attacher_won
	- OLEDB Destination - from conditional split - loss
		- battles_defender_won
		
- Send mail task

- File system task - delete archive

- File system task - copy files from c:\temp\data to c:\temp\archive




- Execute package

- Add dataviewer and execute package again
	- Go forward
	- Explain developer debug options are great! DBA, not so much
*/