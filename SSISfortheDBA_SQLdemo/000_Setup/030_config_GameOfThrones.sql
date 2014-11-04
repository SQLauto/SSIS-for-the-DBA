/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Behind the scene script - not particular pretty :-)
 * Config GameOfThrones database
 * 
 * This script is free software: you can redistribute it and/or 
 * modify it under the terms of the GNU General Public License as 
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

USE master
GO

IF DB_ID('GameOfThrones') IS NULL
	CREATE DATABASE GameOfThrones
GO

USE GameOfThrones
GO


-- Structure and data from:
-- https://github.com/chrisalbon/war_of_the_five_kings_dataset

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'battles' AND SCHEMA_NAME(schema_id) = 'dbo')
	DROP TABLE dbo.battles
GO

CREATE TABLE dbo.battles (
	name VARCHAR(200) NOT NULL
	, [year] SMALLINT NOT NULL
	, battle_number TINYINT NOT NULL
	, attacker_king VARCHAR(200) NULL
	, defender_king VARCHAR(200) NULL
	, attacker_1 VARCHAR(200) NULL
	, attacker_2 VARCHAR(200) NULL
	, attacker_3 VARCHAR(200) NULL
	, attacker_4 VARCHAR(200) NULL
	, defender_1 VARCHAR(200) NULL
	, defender_2 VARCHAR(200) NULL
	, defender_3 VARCHAR(200) NULL
	, defender_4 VARCHAR(200) NULL
	, attacker_outcome VARCHAR(50) NOT NULL
	, battle_type VARCHAR(50) NULL
	, major_death BIT NOT NULL
	, major_capture BIT NOT NULL
	, attacker_size INT NULL
	, defender_size INT NULL
	, attacker_commander VARCHAR(1000) NULL
	, defender_commander VARCHAR(1000) NULL
	, summer BIT NOT NULL
	, location VARCHAR(200) NULL
	, region VARCHAR(100) NULL
	, note VARCHAR(8000) NULL
)

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'battles_attacker_won' AND SCHEMA_NAME(schema_id) = 'dbo')
	DROP TABLE dbo.battles_attacker_won
GO
CREATE TABLE dbo.battles_attacker_won (
	name VARCHAR(200) NOT NULL
	, [year] SMALLINT NOT NULL
	, battle_number TINYINT NOT NULL
	, attacker_king VARCHAR(200) NULL
)

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'battles_defender_won' AND SCHEMA_NAME(schema_id) = 'dbo')
	DROP TABLE dbo.battles_defender_won
GO
CREATE TABLE dbo.battles_defender_won (
	name VARCHAR(200) NOT NULL
	, [year] SMALLINT NOT NULL
	, battle_number TINYINT NOT NULL
	, defender_king VARCHAR(200) NULL
)



-- Regions and fun facts from:
-- http://gameofthrones.wikia.com/wiki/Category:Regions

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'regions' AND SCHEMA_NAME(schema_id) = 'dbo')
	DROP TABLE dbo.regions
GO

CREATE TABLE dbo.regions (
	region_id INT NOT NULL IDENTITY
	, region VARCHAR(100) NOT NULL
	, fun_fact VARCHAR(8000) NULL
)

INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Dorne', 'Dorne is one of the nine constituent regions of the Seven Kingdoms. It is the southernmost part of the continent of Westeros, located thousands of miles from Winterfell and the North, and has a harsh desert climate. The Dornishmen are ethnically distinct from the rest of the Seven Kingdoms, being largely descended from Rhoynar refugees who intermarried with the local population of Andals and First Men roughly a thousand years ago. As a result they have very different customs and traditions compared to the other regions of Westeros.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The North', 'The North is one of the constituent regions of the Seven Kingdoms, and was formerly a sovereign nation known as the Kingdom of the North before the Targaryen conquest. The North is ruled from the castle of Winterfell by House Bolton following the fall of House Stark during the War of the Five Kings. It is the largest of the nine major regions of the continent, almost equal in size to the other eight combined.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Beyond the Wall', 'Beyond the Wall is a generic term employed by the people of the Seven Kingdoms to refer to the large area of Westeros that lies north of the Wall. It is the only part of the continent that is not part of the realm, and thus the only place where particular attention is given to the difference between "Westeros" (the continent), and "the Seven Kingdoms" (the realm to the south of the Wall ruled by the Iron Throne).')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Vale of Arryn', 'The Vale of Arryn is one of the constituent regions of the Seven Kingdoms, and was formerly a sovereign nation known as the Kingdom of Mountain and Vale before the Targaryen Conquest. The Vale is ruled by House Arryn from the castle known as the Eyrie. Protected and surrounded by the Mountains of the Moon, the Vale is isolated from the rest of Westeros and is accessible only during warmer seasons')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Iron Islands', 'The Iron Islands form one of the nine constituent regions of Westeros. They are a group of seven small rocky islands clustered far off the western coast of the mainland of the continent, in Ironmans Bay. The Iron Islands are ruled from Pyke by House Greyjoy. They are the smallest and among the least-populous of the regions of Westeros, but the naval skills of their population are unmatched and they enjoy great mobility due to their ships. The people of the Iron Islands, the ironborn, have a unique culture centered on maritime raiding and pillaging other peoples. However, they were forced to stop these practices when they were conquered by the Targaryens, or at least, to stop raiding shipping around Westeros itself.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Riverlands', 'The Riverlands is one of the constituent regions of the Seven Kingdoms. They have been a frequent battleground in the civil wars that have afflicted the Seven Kingdoms and also in the wars that took place between the old nations of the continent before the Targaryen Conquest. During the time of the First Men, the Riverlands were an independent kingdom known as the Kingdom of the Rivers and the Hills.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Reach', 'The Reach is one of the constituent regions of the Seven Kingdoms, and was formerly a sovereign nation known as the Kingdom of the Reach before the Targaryen conquest. Geographically, it is one of the larger regions of the Seven Kingdoms. The Reach is the most fertile part of Westeros, blessed with vast, blooming fields of crops and flowers, and numerous and well-populated villages and towns; it traditionally helps supply other less fertile parts of the Seven Kingdoms (most notably Kings Landing) with grain, fruit, wine and livestock. The Reach is also the most heavily-populated part of Westeros and is one of the richest, though not as rich as the Westerlands, ruled by House Lannister. Due to this, the Tyrells can traditionally field the largest army in the Seven Kingdoms, almost as large as the armies from two of the other populous kingdoms combined. This vast supply of manpower, land, and food production gives the Reach enormous strategic value during the War of the Five Kings.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Stormlands', 'The Stormlands is one of the nine constituent regions of the Seven Kingdoms. It is located on the south east coast of the continent of Westeros, on the shores of the Narrow Sea, south of the Crownlands and north of Dorne. The Stormlands are ruled from the castle of Storms End by House Baratheon. They are so-named for the savage and frequent storms from the Narrow Sea that batter the coast. It was originally a sovereign nation known as the Storm Kingdom, until Aegon the Conqueror united Westeros under his rule.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Crownlands', 'The Crownlands is one of the nine constituent regions of the Seven Kingdoms. It was never a sovereign nation, instead being contested between the Riverlands, the Stormlands, and other regions until Aegon the Conqueror seized control of the area during his invasion and made it his primary foothold on the continent, three centuries before the death of King Robert Baratheon. It is therefore the newest of the regions in Westeros, and as a result, does not have much of a distinct "cultural identity", so much as it is shaped by its distinction as the region containing the capital city.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Westerlands', 'The Westerlands is one of the constituent regions of the Seven Kingdoms. It was formerly a sovereign realm known as the Kingdom of the Rock before the Targaryen conquest. The Westerlands are ruled from the castle of Casterly Rock by House Lannister. It is one of the smaller regions of the Seven Kingdoms, but is immensely rich in natural resources, particularly metals. Predominantly mountainous, the hills of the Westerlands are riddled with veins of gold and silver, the mining of which has made the Lannisters and their bannermen immensely rich. While the Lannister armies are not as huge as those of the Reach, they are the best-equipped in the realm, with heavily-armored soldiers and cavalry.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Gift', 'The Gift is a region to the south of the Wall under the control of the Nights Watch. It lies at the northern edge of the region known as the North. It was donated to the Nights Watch by House Stark when the order was founded thousands of years ago, in order to support the Nights Watch with food and provisions. The Gift is officially not subject to the authority of Winterfell, and is technically not part of "The North", but is a special administrative zone directly ruled by the Nights Watch. Culturally and socially, however, the lightly inhabited villages of the Gift are usually seen as just an extension of the North.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Neck', 'The Neck is a swamp and marsh-filled region of Westeros, located where the waters of the Bite, an inlet of the Shivering Sea, and Blazewater Bay, an inlet of the Sunset Sea, draw relatively close to one another, making it the narrowest part of the continent. The Neck is the southernmost part of the North, on the border with the Riverlands.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Dothraki Sea', 'The Dothraki Sea is a region on the continent of Essos, thousands of miles to the east of Westeros. It is located in the continental interior, east of the Free Cities, and is a vast landscape of steppes and plains covered in low green grass which makes it look like a sea from afar. It is named for the Dothraki people who inhabit it, horse-mounted warriors who migrate across the plains in large hordes called khalasars (each of which may contain thousands of riders) to plunder neighboring lands. Vaes Dothrak, the only city of the Dothraki and central hub of their society, lies on the northeastern edge of the Dothraki Sea.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Yi Ti', 'Yi Ti is a region located in the far east of Essos. It is located at the eastern limits of known world, beyond the Jade Sea and to the east of even Qarth. It is sometimes mentioned in the same breath as Asshai as an extremely remote part of the world from Westeros[1]. Merchant ships from Yi Ti and Asshai regularly visit Qarth to conduct trade.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Red Waste', 'The Red Waste is a desert region on the continent of Essos, located thousands of miles to the east of Westeros. It is located south of the Dothraki Sea and Lhazar, northwest of Qarth, and east of Slavers Bay. It is a harsh sandy wilderness that even the Dothraki fear to cross.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Valyrian Peninsula', 'The Valyrian Peninsula is a large, wide headland extending south from Essos into the Summer Sea, the heartland of the now extinct Valyrian Freehold and the location of its capital city, Valyria. Partially destroyed in the Doom, with many islands formed and low-lying areas flooded, becoming the Smoking Sea.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Fingers', 'The Fingers is a region on the east coast of the Vale of Arryn, located along the shores of the Narrow Sea. It consists of four long, slender peninsulas extending into the sea, divided by bays, inlets and channels. House Baelish rules over the smallest of the Fingers.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Mountains of the Moon', 'The Mountains of the Moon are a region in the Vale of Arryn. They form the western edge of the Vale, separating it from the Riverlands to the west. They are a substantial mountain range with many splinter ranges that dominate most of the territories ruled by House Arryn. The western foothills and flanks of the mountains are home to Hill tribes, warrior clans of varying size but unmitigated ferocity against the civilized inhabitants of the region.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Lhazar', 'Lhazar is a peaceful country of sheep and goat-herders, located south of Vaes Dothrak on the continent of Essos. In Essos, Slavers Bay is shielded from the Dothraki Sea by a series of coastal mountains to their northeast. As the southeastern Dothraki Sea reaches near the mountains, it gives way to the hill country of Lhazar, which is unsuitable for horse-herds but quite suitable for sheep pastures. This hill country is linked to Slaver’s Bay by the Khyzai Pass through the coastal mountains, formed by the Shahadazhan River. The upper Shahadazhan river, on the interior side of the mountains facing the Dothraki Sea, provides Lhazar with enough water to carry out basic agriculture, despite bordering the agriculturally inactive Dothraki Sea to the north and deserts of the Red Waste to the east.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Three Sisters', 'The Three Sisters are three islands located in the bay known as the Bite, south of the port city of White Harbor. They are under the authority of House Arryn of the Vale of Arryn.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Dornish Marches', 'The Dornish Marches are an area of the southwestern Stormlands bordering Dorne, the Reach, and the Sea of Dorne. They are located in the northern end of the Red Mountains which separate Dorne from the rest of the continent. As a result they have a very cold, alpine climate.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Barrowlands', 'The Barrowlands are a region in the North, located to the east of the Rills and southwest of Winterfell. The Kingsroad passes through the eastern edge of the Barrowlands. The town of Barrowton lies within the Barrowlands and is the largest settlement in the area.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Disputed Lands', 'The Disputed Lands is a war-ravaged region on the continent of Essos to the east of Westeros. It is an area that has been contested between the Free Cities of Myr and Lys for more than three centuries. Wars over the Disputed Lands frequently drag in the neighboring cities of Tyrosh and Volantis and often spill over onto the nearby Stepstone islands.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Stony Shore', 'The Stony Shore is a region in the North. It forms part of the west coast, west of the Rills and southwest of the Wolfswood and Sea Dragon Point.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Shield Islands', 'The Shield Islands are an archipelago of four islands located off the west coast of the Reach. They owe fealty to House Tyrell of Highgarden. The islands are located west of the mouth of the Mander River.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Axe', 'The Axe is a region on the continent of Essos, located to the east of Westeros. It is a large, axehead-shaped peninsular extending northwards into the Shivering Sea.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Ironman''s Bay', 'Ironmans Bay is a large area of water off the west coast of Westeros. The bay is formed by the Flint Cliffs and Cape Kraken in the north, the Cape of Eagles to the east and the north coast of the Westerlands to the south. The coastlands of the North, the Riverlands and the Westerlands all border the bay. Most famously, the bay contains the Iron Islands, and its waters are controlled by the Iron Fleet.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Sea of Myrth', 'The Sea of Myrth is a large inlet of the Narrow Sea, located in south-western Essos where it separates the Disputed Lands from the lands further north. The Free City of Myr lies on the eastern coast of the Sea of Myrth, while Tyrosh lies on an island at the mouth of the sea.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Orange Shore', 'The Orange Shore is a region of the continent of Essos. It is located to the west of Volantis, forming the south coast of the continent between the Rhoyne delta and the Disputed Lands.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Golden Fields', 'The Golden Fields is a region in western Essos. This area is located between Dagger Lake and a tributary of the Rhoyne. The Flatlands lie to the north-west and the Disputed Lands and the Free City of Myr to the south-west.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Flatlands', 'The Flatlands is a region on the continent of Essos, located to the east of Westeros beyond the Narrow Sea. The Flatlands is a fertile area of open fields and plains, located around the Free City of Pentos and responsible for feeding it. Many magisters and nobles of the cities have estates on the Flatlands.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Braavosian Coastlands', 'The Braavosian Coastlands form the north-western coast of Essos along the shores of the Narrow Sea. They run south from the Free City of Braavos towards its southern neighbor, Pentos.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Redwyne Straits', 'The Redwyne Straits separate the Arbor from the mainland of Westeros. They are controlled by House Redwyne of the Arbor and House Hightower of Oldtown, who both have ships patrolling the waters. The area overall is under the authority of House Tyrell of Highgarden.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Hills of Norvos', 'The Hills of Norvos are an extensive range of tall hills and mountains located at the north-western end of the continent of Essos. They extend from the mainland just south of Braavos along the north coast as far east as the headland known as the Axe. The extend south almost as far as Dagger Lake. The hills are named for the Free City of Norvos, which is the largest city in the area. The headwaters of most of the major tributaries of the Rhoyne form in these hills.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Ghiscari Strait', 'The Ghiscari Strait is a narrow body of water separating the islands of New Ghis from the mainland of Essos. It is located in Ghiscari territory. The strait links the Gulf of Grief with the Summer Sea.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('Dagger Lake', 'Dagger Lake is a lake in western-central Essos, formed by the confluence of the Rhoyne and the Qhoyne. It is adjacent to the Golden Fields, north of Volantis and south of Qohor and Norvos.')
INSERT INTO dbo.Regions(region, fun_fact) VALUES ('The Footprint', 'The Footprint is a heavily forested region in Essos, stretching along the coast of the Shivering Sea north of Vaes Dothrak. The island of Ibben lies off the coast of this region. This area is separated from the Dothraki sea to the south by a range of mountains.')
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'filelog' AND SCHEMA_NAME(schema_id) = 'dbo')
	DROP TABLE dbo.filelog
GO
CREATE TABLE dbo.filelog (
	[file_id] INT NOT NULL IDENTITY
	, [file_name] VARCHAR(1000) NOT NULL
	, load_date DATETIME NOT NULL
)
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SetFileLog' AND SCHEMA_NAME(schema_id) = 'dbo')
	DROP PROCEDURE dbo.SetFileLog
GO
CREATE PROCEDURE dbo.SetFileLog
	@FileName VARCHAR(1000)
AS
	INSERT INTO dbo.filelog (file_name, load_date) VALUES (@FileName, GETDATE())
GO









