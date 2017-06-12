
# installing libraries
library (raster)
library (rgdal)
library (sp)
library (landsat)
library (caret)
library(oce)
library(tiff)
library(IM)
library(maptools)
install.packages("rasterVis")
library(rasterVis)

# set working directory
#setwd('Z:/UrbanChromatic')
setwd('H:/urbanChromatic')


#####################################################################################################
### Building Polygons from Centroids
#####################################################################################################
## original code from: http://neondataskills.org/working-with-field-data/Field-Data-Polygons-From-Centroids

# Make sure character strings don't import as factors
options(stringsAsFactors=FALSE)

# read in the point csv
#centroids <- read.csv("H:/urbanChromatic/geocodeRoundThree.csv")
centroids <- read.csv("H:/urbanChromatic/finalCities1.csv")

# set the radius for the plots
radius = 1 #radius in decimal degrees

# define the plot boundaries based upon the plot radius
# Note: This assumes that plots are oriented north and are not rotated.
# If the plots are rotated, you'd need to do aditional math to find corners
yPlus = centroids$latitude+radius
xPlus = centroids$longitude+radius
yMinus = centroids$latitude-radius
xMinus = centroids$longitude-radius

#Extract the plot ID information. NOTE: because we set
#stringsAsFactor to false above, we can import the plot 
#ID's using the code below. If we didn't do that, our ID's would 
#come in as factors by default. 
#We'd thus have to use the code ID=as.character(centroids$Plot_ID) 
ID=centroids$Plot_ID

#calculate polygon coordinates for each plot centroid. 
square=cbind(xMinus,yPlus, xPlus,yPlus, xPlus,yMinus, xMinus,yMinus,xMinus,yPlus,xMinus,yPlus)

#create spatial polygons
polys <- SpatialPolygons(mapply(function(poly, id) {
  xy <- matrix(poly, ncol=2, byrow=TRUE)
  Polygons(list(Polygon(xy)), ID=id)
}, split(square, row(square)), ID),proj4string=CRS(as.character("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")))

# Create SpatialPolygonDataFrame -- this step is required to output multiple polygons.
# combines the polygons we created and some data - just add IDs
polys.df <- SpatialPolygonsDataFrame(polys, data.frame(id=ID, row.names=ID))

#write out the data
# '.' means write it out to the current working directory
#writeOGR(polys.df, '.', 'citySquares', driver='ESRI Shapefile')
writeOGR(polys.df, '.', 'finalCities', driver='ESRI Shapefile')



#################################################################################################
### Export Shapefile to KML
#################################################################################################

# Using the OGR KML driver we can then export the data to KML. 
# dsn should equal the name of the exported file and the dataset_options 
# argument allows us to specify the labels displayed by each of the points.

#cityLocations = readOGR("H:/urbanChromatic", layer="citySquares")
cityLocations = readOGR("H:/urbanChromatic", layer="finalCities")

#writeOGR(cityLocations, dsn="citySquaresKML.kml", layer= "citySquares", driver="KML")
writeOGR(cityLocations, dsn="finalCitiesKML.kml", layer= "finalCities", driver="KML")
