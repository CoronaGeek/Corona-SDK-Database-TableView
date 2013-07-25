-- Demonstration of working with SQLite and Corona for iOS & Android devices
-- by Brian G. Burton, Ed.D.   http://www.BurtonsMediaGroup.com/blog  All Rights Reserved

--include sqlite
require("sqlite3")local widget = require("widget")local zip = {}local doneDB = false

-- Does the database exist in the documents directory (allows updating and persistance)
local path = system.pathForFile("zip.sqlite", system.DocumentsDirectory )
file = io.open( path, "r" )
   if( file == nil )then           
   	-- Doesn't Already Exist, So Copy it In From Resource Directory                          
   	pathSource     = system.pathForFile( "zip.sqlite", system.ResourceDirectory )  
   	fileSource = io.open( pathSource, "rb" ) 
   	contentsSource = fileSource:read( "*a" )                                  
		--Write Destination File in Documents Directory                                  
		pathDest = system.pathForFile( "zip.sqlite", system.DocumentsDirectory )                 
		fileDest = io.open( pathDest, "wb" )                 
		fileDest:write( contentsSource )                 
		 -- Done                      
		io.close( fileSource )        
		io.close( fileDest )         
   end   
-- One Way or Another The Database File Exists Now 

-- handle the applicationExit event to close the db
local function onSystemEvent( event )
	if( event.type == "applicationExit" and doneDB==false) then
		db:close()
	end
end

-- Open Database Connection         
db = sqlite3.open( path )-- load the data into a table array
local count =0
local sql = "SELECT * FROM zipcode Order BY state ASC LIMIT 200"
for row in db:nrows(sql) do
	count = count +1	zip[count]={}    zip[count].city = row.city    zip[count].state = row.state    zip[count].zip = row.zip
end
-- all done with database - close it.doneDB=truedb:close()-- Listen for tableView events
local function tableViewListener( event )
    local phase = event.phase
    local row = event.target

    print( event.phase )
end

-- Handle row rendering
local function onRowRender( event )
    local phase = event.phase
    local row = event.row

local rowTitle = display.newText( row, " "..zip[row.index].state .. ", "..zip[row.index].city, 0, 0, nil, 14 )
    rowTitle.x = row.x - ( row.contentWidth * 0.5 ) + ( rowTitle.contentWidth * 0.5 )
    rowTitle.y = row.contentHeight * 0.5
    rowTitle:setTextColor( 0, 0, 0 )
end

-- Handle touches on the row
local function onRowTouch( event )
    local phase = event.phase

    if "press" == phase then    native.showAlert(zip[event.target.index].state ..", "..zip[event.target.index].city, "has the zip code of "..zip[event.target.index].zip, "OKAY")
        print( event.target.index )
    end
end

-- Create a tableView
local tableView = widget.newTableView
{
    top = 100,
    width = 320, 
    height = 366,
    maskFile = "mask-320x366.png",
    listener = tableViewListener,
    onRowRender = onRowRender,
    onRowTouch = onRowTouch,
}for i = 1, 200 do
    local isCategory = false
    local rowHeight = 40
    local rowColor = 
    { 
        default = { 255, 255, 255 },
    }
    local lineColor = { 220, 220, 220 }
--[[
    -- Make some rows categories
    if i == 25 or i == 50 or i == 75 then
        isCategory = true
        rowHeight = 24
        rowColor = 
        { 
            default = { 150, 160, 180, 200 },
        }
    end
]]--
    -- Insert the row into the tableView
    tableView:insertRow
    {
        isCategory = isCategory,
        rowHeight = rowHeight,
        rowColor = rowColor,
        lineColor = lineColor,
    }
end 
-- system listener for applicationExit
Runtime:addEventListener ("system", onSystemEvent)