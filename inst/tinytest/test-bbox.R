library(geosx)

if (requireNamespace("tinytest", quietly = TRUE)) {
  library(tinytest)
}

# geos_bbox -----------------------------------------------------------
one_poly <- geos::as_geos_geometry("POLYGON ((0 0, 0 1, 1 0, 0 0))")

expect_identical(
  geos::geos_write_wkt(geos_bbox(one_poly)),
  geos::geos_write_wkt(geos::geos_envelope(one_poly))
)
