library(raster)
library(rgeos)
library(rasterVis)


#------------SETTINGS--------------

#Specify target ISO country code and path to downloaded shapefile

country_name <- "AUT"                             #Austria
shp          <- shapefile("srtm/tiles.shp")       #Path to SRTM Tiles (can be found in subfolder srtm)


#------------EXECUTE FROM HERE--------------

#Get country geometry first
country <- getData("GADM", 
                   country = country_name, 
                   level=0)

#Intersect country geometry with tile grid
intersects <- gIntersects(country, shp, byid=T)
tiles      <- shp[intersects[,1],]


#Download tiles
srtm_list  <- list()
for(i in 1:length(tiles)) {
  lon <- extent(tiles[i,])[1]  + (extent(tiles[i,])[2] - extent(tiles[i,])[1]) / 2
  lat <- extent(tiles[i,])[3]  + (extent(tiles[i,])[4] - extent(tiles[i,])[3]) / 2
  
  tile <- getData('SRTM', 
                  lon=lon, 
                  lat=lat)
  
  srtm_list[[i]] <- tile
}

#Mosaic
srtm_list$fun <- mean 
srtm_mosaic   <- do.call(mosaic, srtm_list)

#Crop to country borders
srtm_crop     <- mask(srtm_mosaic, country)

#Plot results
p <- levelplot(srtm_crop)
p + layer(sp.lines(country, 
                   lwd=0.8, 
                   col='darkgray'))

