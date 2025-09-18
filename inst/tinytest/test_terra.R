library(geos)
library(geosx)

if (requireNamespace("tinytest", quietly = TRUE)) {
  library(tinytest)
}

if (!requireNamespace("terra", quietly = TRUE)) {
  exit_file("Package terra is needed for test suite")
}

# SpatVector to geos_geometry conversion --------------------------------------
example <- system.file("extdata", "example.gpkg", package = "geosx")
polygon_v <- terra::vect(example, layer = "polygon")
polygon_geos <- as_geos_geometry(polygon_v)

expect_true(
  inherits(polygon_geos, "geos_geometry")
)
expect_identical(
  terra::crs(polygon_v),
  wk::wk_crs(polygon_geos)$wkt
)
expect_identical(
  terra::crs(polygon_v, describe = TRUE)$name,
  wk::wk_crs(polygon_geos)$input
)

# geos_geometry to SpatVector conversion --------------------------------------
polygon_geos_v <- terra::vect(polygon_geos)

expect_true(
  inherits(polygon_geos_v, "SpatVector")
)
