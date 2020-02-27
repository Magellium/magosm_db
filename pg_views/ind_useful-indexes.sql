--------------------------------------
----------CREATION DES INDEXS---------
--------------------------------------
CREATE INDEX IF NOT EXISTS railway_index
  ON planet_osm_line
  USING btree
  (railway COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS highway_index
  ON planet_osm_line
  USING BTREE
  (route COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS tags_index
  ON planet_osm_line
  USING GIST (tags);

CREATE INDEX IF NOT EXISTS route_index
  ON planet_osm_line
  USING btree
  (route COLLATE pg_catalog."default");
  
CREATE INDEX IF NOT EXISTS amenity_point_index
  ON planet_osm_point
  USING btree
  (amenity COLLATE pg_catalog."default");
  
CREATE INDEX IF NOT EXISTS amenity_polygon_index
  ON planet_osm_point
  USING btree
  (amenity COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS shop_point_index
  ON planet_osm_point
  USING BTREE
  (shop COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS shop_poly_index
  ON planet_osm_polygon
  USING BTREE
  (shop COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS building_index
  ON planet_osm_polygon
  USING btree
  (building COLLATE pg_catalog."default");
  
CREATE INDEX IF NOT EXISTS landuse_index
  ON planet_osm_polygon
  USING btree
  (landuse COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS natural_index
  ON planet_osm_polygon
  USING btree
  ("natural" COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS wetland_index
  ON planet_osm_polygon
  USING btree
  (wetland COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS wood_index
  ON planet_osm_polygon
  USING btree
  (wood COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS boundary_index
  ON planet_osm_polygon
  USING btree
  (boundary COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS osm_id_index
  ON planet_osm_line
  USING GIST (osm_id);
